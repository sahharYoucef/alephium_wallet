import 'dart:async';

import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/api/utils/either.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

part 'wallet_details_event.dart';
part 'wallet_details_state.dart';

class WalletDetailsBloc extends Bloc<WalletDetailsEvent, WalletDetailsState> {
  final BaseApiRepository apiRepository;
  final BaseWalletService walletService;
  final WalletHomeBloc walletHomeBloc;
  late final NetworkType network;
  late final String id;
  WalletStore wallet;

  Timer? periodic;

  List<TransactionStore> _transactions = <TransactionStore>[];
  WalletDetailsBloc({
    required this.apiRepository,
    required this.walletService,
    required this.wallet,
    required this.walletHomeBloc,
  })  : network = apiRepository.network,
        id = wallet.id,
        super(WalletDetailsInitial()) {
    on<WalletDetailsEvent>((event, emit) async {
      if (event is WalletDetailsLoadData) {
        emit(WalletDetailsLoading());
        _transactions = await _getSortedTransactions;
        emit(WalletDetailsCompleted(
          transactions: List.from(_transactions),
          withLoadingIndicator: true,
          wallet: wallet,
        ));
        try {
          var updateTransactions = await _updateTransactions;

          if (updateTransactions.data!.isNotEmpty) {
            _transactions.removeWhere(
                (element) => updateTransactions.data!.contains(element));
            _transactions.addAll(updateTransactions.data!);
            _transactions.sort(((a, b) {
              return -a.timeStamp.compareTo(b.timeStamp);
            }));
            getIt.get<BaseDBHelper>().txCaches[network]?[id] =
                List.from(_transactions);
            getIt
                .get<BaseDBHelper>()
                .insertTransactions(id, updateTransactions.data!);
          }
          if (updateTransactions.hasException) {
            emit(WalletDetailsError(
              message: updateTransactions.exception?.message,
            ));
          }
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
          ));
        } catch (e, trace) {
          emit(WalletDetailsError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is WalletDetailsRefreshData) {
        emit(WalletDetailsCompleted(
          transactions: List.from(_transactions),
          wallet: wallet,
          withLoadingIndicator: true,
        ));
        try {
          var updateTransactions = await _updateTransactions;

          if (updateTransactions.data!.isEmpty &&
              (periodic?.isActive ?? false)) {
            if (updateTransactions.hasException) {
              emit(WalletDetailsError(
                message: updateTransactions.exception?.message,
              ));
            }
            return;
          }

          var updatedAddresses = await _updateAddresses;
          if (updatedAddresses.data!.isNotEmpty) {
            getIt.get<BaseDBHelper>().updateAddressBalance(
                  updatedAddresses.data!,
                );
            wallet = wallet.copyWith(addresses: updatedAddresses.data!);
            walletHomeBloc.add(HomeUpdateWalletDetails(wallet));
          }
          if (updateTransactions.data!.isNotEmpty) {
            _transactions.removeWhere(
                (element) => updateTransactions.data!.contains(element));
            _transactions.addAll(updateTransactions.data!);
            _transactions.sort(((a, b) {
              return -a.timeStamp.compareTo(b.timeStamp);
            }));
            getIt.get<BaseDBHelper>().txCaches[network]?[id] =
                _transactions.toList();
          }
          if (updateTransactions.hasException ||
              updatedAddresses.hasException) {
            emit(WalletDetailsError(
              message: updatedAddresses.exception?.message,
            ));
          }
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
            withLoadingIndicator: false,
          ));
          await getIt
              .get<BaseDBHelper>()
              .insertTransactions(id, updateTransactions.data!);
        } catch (e, trace) {
          emit(WalletDetailsError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is AddPendingTxs) {
        try {
          _transactions = await _getSortedTransactions;
          getIt.get<BaseDBHelper>().txCaches[network]?[id] = _transactions;
          periodic = Timer.periodic(Duration(seconds: 10), (value) {
            var tx = _transactions.firstWhereOrNull(
                (element) => element.status == TXStatus.pending);
            if (tx == null) {
              periodic?.cancel();
              return;
            }
            if (!this.isClosed) add(WalletDetailsRefreshData());
          });
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            withLoadingIndicator: true,
            wallet: wallet,
          ));
          add(UpdateWalletBalance());
        } catch (e, trace) {
          emit(WalletDetailsError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is UpdateWalletBalance) {
        try {
          var updatedAddresses = await _updateAddresses;
          if (updatedAddresses.data!.isNotEmpty) {
            getIt.get<BaseDBHelper>().updateAddressBalance(
                  updatedAddresses.data!,
                );
            wallet = wallet.copyWith(addresses: updatedAddresses.data);
            walletHomeBloc.add(HomeUpdateWalletDetails(wallet));
          }
          if (updatedAddresses.hasException) {
            emit(WalletDetailsError(
              message: updatedAddresses.exception?.message,
            ));
          }
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
            withLoadingIndicator: false,
          ));
        } catch (e, trace) {
          emit(WalletDetailsError(
            message: ApiError(exception: e, trace: trace).message,
          ));
        }
      } else if (event is GenerateNewAddress) {
        var indexes = wallet.addresses.map((e) => e.index).toList();
        var newAddress = walletService.deriveNewAddress(
          walletId: id,
          seed: wallet.seed!,
          skipAddressIndexes: indexes,
          forGroup: event.group,
          title: event.title,
        );
        wallet.addresses.add(newAddress);
        if (event.isMain) {
          wallet = wallet.copyWith(mainAddress: newAddress.address);
          getIt
              .get<BaseDBHelper>()
              .updateWalletMainAddress(id, wallet.mainAddress);
        }
        emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
            withLoadingIndicator: true));
        await getIt.get<BaseDBHelper>().insertAddress([newAddress]);
        add(WalletDetailsRefreshData());
      } else if (event is GenerateOneAddressPerGroup) {
        var newAddresses = walletService.generateOneAddressPerGroup(
          wallet: wallet,
          title: event.title,
          color: event.color,
        );
        wallet.addresses.addAll(newAddresses);
        emit(WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
            withLoadingIndicator: true));
        await getIt.get<BaseDBHelper>().insertAddress(newAddresses);
        add(WalletDetailsRefreshData());
      } else if (event is UpdateWalletName) {
        wallet = wallet.copyWith(title: event.name);
        await getIt.get<BaseDBHelper>().updateWalletName(id, event.name);
        emit(
          WalletDetailsCompleted(
            transactions: List.from(_transactions),
            wallet: wallet,
          ),
        );
        walletHomeBloc.add(HomeUpdateWalletDetails(wallet));
      }
    });
  }

  Future<List<TransactionStore>> get _getSortedTransactions async {
    _transactions = getIt.get<BaseDBHelper>().txCaches[network]?[id] ??
        await getIt.get<BaseDBHelper>().getTransactions(id, network);
    _transactions.sort(((a, b) {
      return -a.timeStamp.compareTo(b.timeStamp);
    }));
    return _transactions.toSet().toList();
  }

  Future<Either<List<TransactionStore>>> get _updateTransactions async {
    var addresses = <AddressStore>[];
    bool withException = false;
    for (var address in wallet.addresses) addresses.add(address);
    List<Either<List<TransactionStore>>> data = [];
    var chunks = <List<AddressStore>>[];
    int chunkSize = 15;
    for (var i = 0; i < addresses.length; i += chunkSize) {
      chunks.add(
        addresses.sublist(
          i,
          i + chunkSize > addresses.length ? addresses.length : i + chunkSize,
        ),
      );
    }
    for (var element in chunks) {
      var subData = await Future.wait<Either<List<TransactionStore>>>(
        element.map((e) => apiRepository.getAddressTransactions(
            address: e.address,
            walletId: e.walletId) as Future<Either<List<TransactionStore>>>),
      );
      data.addAll(subData);
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
    var updateTransactions = <TransactionStore>[];
    for (var value in data) {
      if (value.hasData && value.data != null) {
        for (var tx in value.data!) {
          var a = _transactions.firstWhereOrNull((element) {
            return element == tx;
          });
          if (a == null || a.status == TXStatus.pending)
            updateTransactions.add(tx);
        }
      } else if (value.hasException) {
        withException = true;
      }
    }
    return Either(
      data: updateTransactions,
      error: withException
          ? ApiError(exception: Exception(kErrorMessageGenericError))
          : null,
    );
  }

  Future<Either<List<AddressStore>>> get _updateAddresses async {
    var addresses = <AddressStore>[];
    bool withException = false;
    for (var address in wallet.addresses) addresses.add(address);
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
}
