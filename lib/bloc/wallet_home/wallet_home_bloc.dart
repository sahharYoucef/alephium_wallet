import 'dart:async';
import 'dart:convert';

import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/models/nft_metadata.dart';
import 'package:alephium_wallet/api/models/token_metadata.dart';
import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;

import '../../api/models/tokens.dart';
import '../../api/utils/either.dart';
import '../../storage/models/address_store.dart';

part 'wallet_home_event.dart';
part 'wallet_home_state.dart';

class WalletHomeBloc extends Bloc<WalletHomeEvent, WalletHomeState> {
  List<WalletStore> wallets = [];
  static List<TokenMetadata> tokens = [];
  static List<NftMetadata> nfts = [];

  late Either<Tokens> tokensData;

  late final Timer timer;

  _refreshData() {
    this.add(WalletHomeRefreshData(withError: false));
  }

  double? price;
  final BaseApiRepository apiRepository;
  WalletHomeBloc(this.apiRepository) : super(WalletHomeInitial()) {
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        _refreshData();
      },
    );
    on<WalletHomeEvent>((event, emit) async {
      if (event is WalletHomeLoadData) {
        emit(WalletHomeLoading());
        var currency = AppStorage.instance.currency;
        wallets = await getIt.get<BaseDBHelper>().getWallets(
              network: apiRepository.network,
            );
        final (_nfts, _tokens) =
            await getIt.get<BaseDBHelper>().getNftAndTokensMetaData();

        nfts = _nfts;
        tokens = _tokens;

        emit(WalletHomeCompleted(
          wallets: List<WalletStore>.from(wallets),
          withLoadingIndicator: true,
        ));
        try {
          tokensData = await apiRepository.getTokensMetadata();
          if (tokensData.hasData) {
            final tokensToUpdate = tokensData.data!.tokens!
                .where((element) => !tokens.contains(element));
            if (tokensToUpdate.isNotEmpty) {
              await getIt
                  .get<BaseDBHelper>()
                  .insertTokensMetaData(tokensToUpdate.toList());
              final (_nfts, _tokens) =
                  await getIt.get<BaseDBHelper>().getNftAndTokensMetaData();

              nfts = _nfts;
              tokens = _tokens;
            }
          }
          var _price = await apiRepository.getPrice(currency: currency);
          if (_price.hasException) {
            emit(WalletHomeError(message: _price.exception?.message));
          } else if (_price.hasData) {
            AppStorage.instance.price = _price.data;
          }
          final updatedAddresses = await _updateAddresses();
          if (updatedAddresses.data!.isNotEmpty) {
            await getIt
                .get<BaseDBHelper>()
                .updateAddressBalance(updatedAddresses.data!);
          }
          if (updatedAddresses.hasException) {
            emit(WalletHomeError(
              message: updatedAddresses.exception?.message,
            ));
          }
          wallets = await getIt.get<BaseDBHelper>().getWallets(
                network: apiRepository.network,
              );
          List<String> tokensIds = [];
          List<String> nftIds = [];
          List<String> others = [];
          for (var wallet in wallets) {
            for (var token in wallet.tokensBalances) {
              if (!tokensIds.contains(token.id)) {
                tokensIds.add(token.id!);
              }
            }
            for (var nft in wallet.nftTokensBalances) {
              if (!nftIds.contains(nft.id)) {
                nftIds.add(nft.id!);
              }
            }
            for (var other in wallet.otherTokens) {
              if (!others.contains(other.id)) {
                others.add(other.id!);
              }
            }
          }
          for (final item in others) {
            final call = fetchStdTokenMetaDate(item);
            final data = await apiRepository.getContractsAddressState(
                address: call.first['address']!, group: call.first['group']);
            final tokenType = guessStdTokenType(
                tokenId: item, immFields: data.data!.immFields);
            if (tokenType == TokenType.nonFungible) {
              nftIds.add(item);
            } else if (tokenType == TokenType.fungible) {
              tokensIds.add(item);
            }
          }

          final List<TokenMetadata> tokensToAdd =
              await getTokenMetadata(tokensIds);
          final List<NftMetadata> nftsToAdd = await getNftMetadata(nftIds);

          if (tokensToAdd.isNotEmpty) {
            await getIt
                .get<BaseDBHelper>()
                .insertTokensMetaData(tokensToAdd.toList());
          }
          if (nftsToAdd.isNotEmpty) {
            await getIt
                .get<BaseDBHelper>()
                .insertNftMetaData(nftsToAdd.toList());
          }
          final (_nfts, _tokens) =
              await getIt.get<BaseDBHelper>().getNftAndTokensMetaData();

          nfts = _nfts;
          tokens = _tokens;
          emit(WalletHomeCompleted(
            wallets: List<WalletStore>.from(wallets),
            withLoadingIndicator: false,
          ));
        } catch (e, trace) {
          emit(WalletHomeError(
              message:
                  ApiError(exception: Exception(e.toString()), trace: trace)
                      .message));
          rethrow;
        }
      } else if (event is WalletHomeRefreshData) {
        if (state is WalletHomeCompleted &&
            (state as WalletHomeCompleted).wallets.isNotEmpty) {
          var currency = AppStorage.instance.currency;
          var _price = await apiRepository.getPrice(currency: currency);
          if (_price.hasException) {
            if (event.withError)
              emit(WalletHomeError(message: _price.exception?.message));
          }

          AppStorage.instance.price = _price.data;

          wallets = (state as WalletHomeCompleted).wallets;
          emit(WalletHomeCompleted(
            wallets: List<WalletStore>.from(wallets),
            withLoadingIndicator: true,
          ));
          try {
            final updatedAddresses = await _updateAddresses();
            if (updatedAddresses.data!.isNotEmpty) {
              await getIt
                  .get<BaseDBHelper>()
                  .updateAddressBalance(updatedAddresses.data!);
            }
            if (updatedAddresses.hasException) {
              if (event.withError)
                emit(WalletHomeError(
                  message: updatedAddresses.exception?.message,
                ));
            }
            List<String> others = [];

            for (var wallet in wallets) {
              for (var other in wallet.otherTokens) {
                if (!others.contains(other.id)) {
                  others.add(other.id!);
                }
              }
            }
            List<String> tokensIds = [];
            List<String> nftIds = [];
            for (final item in others) {
              final call = fetchStdTokenMetaDate(item);
              final data = await apiRepository.getContractsAddressState(
                  address: call.first['address']!, group: call.first['group']);
              final tokenType = guessStdTokenType(
                  tokenId: item, immFields: data.data!.immFields);
              if (tokenType == TokenType.nonFungible) {
                nftIds.add(item);
              } else if (tokenType == TokenType.fungible) {
                tokensIds.add(item);
              }
            }
            final List<TokenMetadata> tokensToAdd =
                await getTokenMetadata(tokensIds);
            final List<NftMetadata> nftsToAdd = await getNftMetadata(nftIds);
            if (tokensToAdd.isNotEmpty) {
              await getIt
                  .get<BaseDBHelper>()
                  .insertTokensMetaData(tokensToAdd.toList());
            }
            if (nftsToAdd.isNotEmpty) {
              await getIt
                  .get<BaseDBHelper>()
                  .insertNftMetaData(nftsToAdd.toList());
            }
            final (_nfts, _tokens) =
                await getIt.get<BaseDBHelper>().getNftAndTokensMetaData();

            nfts = _nfts;
            tokens = _tokens;
            wallets = await getIt.get<BaseDBHelper>().getWallets(
                  network: apiRepository.network,
                );
            emit(WalletHomeCompleted(
              wallets: List<WalletStore>.from(wallets),
              withLoadingIndicator: false,
            ));
          } catch (e, trace) {
            if (event.withError)
              emit(WalletHomeError(
                  message: ApiError(exception: e, trace: trace).message));
            rethrow;
          }
        } else {
          add(WalletHomeLoadData());
        }
      } else if (event is WalletHomeRemoveWallet) {
        wallets.removeWhere((element) => element.id == event.id);
        getIt.get<BaseDBHelper>().deleteWallet(event.id);
        emit(WalletHomeCompleted(
          wallets: List<WalletStore>.from(wallets),
          withLoadingIndicator: false,
        ));
      } else if (event is HomeUpdateWalletDetails) {
        var index =
            wallets.indexWhere((element) => element.id == event.walletStore.id);
        wallets[index] = event.walletStore;
        emit(WalletHomeCompleted(
          wallets: List<WalletStore>.from(wallets),
          withLoadingIndicator: false,
        ));
      }
    });
  }

  Future<Either<List<AddressStore>>> _updateAddresses() async {
    var addresses = <AddressStore>[];
    bool withException = false;
    for (var wallet in wallets) {
      for (var address in wallet.addresses) addresses.add(address);
    }
    List<Either<AddressStore>> data = [];
    var chunks = <List<AddressStore>>[];
    int chunkSize = 15;
    for (var i = 0; i < addresses.length; i += chunkSize) {
      chunks.add(addresses.sublist(i,
          i + chunkSize > addresses.length ? addresses.length : i + chunkSize));
    }
    for (var element in chunks) {
      var subData = await Future.wait<Either<AddressStore>>(
        element.map((e) => apiRepository.getAddressBalance(address: e)),
      );
      data.addAll(subData);
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
    var updatedAddresses = <AddressStore>[];
    for (var address in data) {
      if (address.hasData && address.data != null) {
        updatedAddresses.add(address.data!);
      } else if (address.hasException) {
        withException = true;
      }
    }
    return Either(
      data: updatedAddresses,
      error: withException
          ? ApiError(exception: Exception(kErrorMessageGenericError))
          : null,
    );
  }

  Future<List<NftMetadata>> getNftMetadata(List<String> nftIds) async {
    final List<NftMetadata> nftsToAdd = [];
    for (var id in nftIds) {
      final call = fetchStdTokenMetaDate(id);
      final data = await apiRepository.getContractsAddressState(
          address: call.first['address']!, group: call.first['group']);
      if (data.hasData) {
        final metadataUri =
            utf8.decode(hex.decode((data.data!.immFields![1].value as String)));
        final response = await http.get(Uri.parse(metadataUri));
        final metadata = json.decode(response.body);
        final nft = NftMetadata(
            name: metadata["name"],
            description: metadata["description"],
            image: metadata["image"],
            totalSupply: 1,
            id: id,
            owner: data.data!.immFields![2].value!);

        nftsToAdd.add(nft);
      }
    }
    return nftsToAdd;
  }

  Future<List<TokenMetadata>> getTokenMetadata(List<String> tokensIds) async {
    final List<TokenMetadata> tokensToAdd = [];
    for (var token in tokensIds) {
      final isExist = tokens.firstWhereOrNull((element) => element.id == token);
      final calls = fetchStdTokenMetaDate(token);
      final data = await apiRepository.postContractsMultiCallContract(
          calls: MultipleCallContract(
              calls: calls
                  .map((e) => CallContract(
                        group: e['group'],
                        address: e['address'],
                        methodIndex: e['methodIndex'],
                      ))
                  .toList()));
      if (data.hasData) {
        late TokenMetadata tokenMetadata;
        if (isExist == null) {
          tokenMetadata = TokenMetadata(
              id: token,
              symbol: utf8
                  .decode(hex.decode(data.data!.results[0].returns![0].value!)),
              name: utf8
                  .decode(hex.decode(data.data!.results[1].returns![0].value!)),
              decimals:
                  int.tryParse("${data.data?.results[2].returns?[0].value}"),
              totalSupply: BigInt.tryParse(
                  "${data.data?.results[3].returns?[0].value}"));
        } else {
          tokenMetadata = isExist.copyWith(
            name: isExist.name == null
                ? utf8.decode(
                    hex.decode(data.data!.results[1].returns![0].value!))
                : null,
            totalSupply: isExist.totalSupply == null
                ? BigInt.tryParse("${data.data?.results[3].returns?[0].value}")
                : null,
            decimals: isExist.decimals == null
                ? int.tryParse("${data.data?.results[2].returns?[0].value}")
                : null,
            symbol: isExist.symbol == null
                ? utf8.decode(
                    hex.decode(data.data!.results[0].returns![0].value!))
                : null,
          );
        }
        tokensToAdd.add(tokenMetadata);
      }
    }
    return tokensToAdd;
  }

  @override
  Future<void> close() {
    timer.cancel();
    return super.close();
  }
}
