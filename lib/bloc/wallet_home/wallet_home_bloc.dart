import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/api/utils/error_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:equatable/equatable.dart';

import '../../api/utils/either.dart';
import '../../storage/models/address_store.dart';

part 'wallet_home_event.dart';
part 'wallet_home_state.dart';

class WalletHomeBloc extends Bloc<WalletHomeEvent, WalletHomeState> {
  List<WalletStore> wallets = [];
  double? price;
  final BaseApiRepository apiRepository;
  WalletHomeBloc(this.apiRepository) : super(WalletHomeInitial()) {
    on<WalletHomeEvent>((event, emit) async {
      if (event is WalletHomeLoadData) {
        emit(WalletHomeLoading());
        var currency = AppStorage.instance.currency;
        wallets = await getIt.get<BaseDBHelper>().getWallets(
              network: apiRepository.network,
            );

        emit(WalletHomeCompleted(
          wallets: List<WalletStore>.from(wallets),
          withLoadingIndicator: true,
        ));

        try {
          var _price = await apiRepository.getPrice(currency: currency);
          if (_price.hasException) {
            emit(WalletHomeError(message: _price.exception?.message));
          }
          AppStorage.instance.price = _price.data;
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
          emit(WalletHomeCompleted(
            wallets: List<WalletStore>.from(wallets),
            withLoadingIndicator: false,
          ));
        } catch (e, _) {
          emit(WalletHomeError(message: e.toString()));
        }
      } else if (event is WalletHomeRefreshData) {
        if (state is WalletHomeCompleted &&
            (state as WalletHomeCompleted).wallets.isNotEmpty) {
          var currency = AppStorage.instance.currency;
          var _price = await apiRepository.getPrice(currency: currency);
          if (_price.hasException) {
            emit(WalletHomeError(message: _price.exception?.message));
          }
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
              emit(WalletHomeError(
                message: updatedAddresses.exception?.message,
              ));
            }
            wallets = await getIt.get<BaseDBHelper>().getWallets(
                  network: apiRepository.network,
                );
            emit(WalletHomeCompleted(
              wallets: List<WalletStore>.from(wallets),
              withLoadingIndicator: false,
            ));
          } catch (e) {
            emit(WalletHomeError(message: e.toString()));
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
    ;
  }
}
