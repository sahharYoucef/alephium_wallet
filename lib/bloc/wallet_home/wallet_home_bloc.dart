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
        wallets = await getIt.get<BaseDBHelper>().getWallets();
        emit(WalletHomeCompleted(
          wallets: List<WalletStore>.from(wallets),
          withLoadingIndicator: true,
        ));

        try {
          var _price = await apiRepository.getPrice(currency: currency);
          if (_price.hasException) {
            emit(WalletHomeError(message: _price.getException?.message));
          }
          AppStorage.instance.price = _price.getData;
          var data = await Future.wait<Either<AddressStore>>([
            for (var wallet in wallets)
              for (var address in wallet.addresses)
                apiRepository.getAddressBalance(
                  address: address,
                )
          ]);
          var updatedAddresses = <AddressStore>[];
          for (var address in data) {
            if (address.hasData && address.getData != null) {
              updatedAddresses.add(address.getData!);
            }
          }
          await getIt
              .get<BaseDBHelper>()
              .updateAddressBalance(updatedAddresses);
          wallets = await getIt.get<BaseDBHelper>().getWallets();
          emit(WalletHomeCompleted(
            wallets: List<WalletStore>.from(wallets),
            withLoadingIndicator: false,
          ));
        } catch (e, trace) {
          print(trace);
          emit(WalletHomeError(message: e.toString()));
        }
      } else if (event is WalletHomeRefreshData) {
        if (state is WalletHomeCompleted &&
            (state as WalletHomeCompleted).wallets.isNotEmpty) {
          wallets = (state as WalletHomeCompleted).wallets;
          emit(WalletHomeCompleted(
            wallets: List<WalletStore>.from(wallets),
            withLoadingIndicator: true,
          ));
          try {
            var data = await Future.wait<Either<AddressStore>>([
              for (var wallet in wallets)
                for (var address in wallet.addresses)
                  apiRepository.getAddressBalance(
                    address: address,
                  )
            ]);
            var updatedAddresses = <AddressStore>[];
            for (var address in data) {
              if (address.hasData && address.getData != null) {
                updatedAddresses.add(address.getData!);
              }
            }
            await getIt
                .get<BaseDBHelper>()
                .updateAddressBalance(updatedAddresses);
            wallets = await getIt.get<BaseDBHelper>().getWallets();
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
}
