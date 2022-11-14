import 'dart:async';

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

import '../../api/utils/either.dart';
import '../../storage/models/address_store.dart';
import '../../storage/models/wallet_store.dart';

part 'wallet_details_event.dart';
part 'wallet_details_state.dart';

class WalletDetailsBloc extends Bloc<WalletDetailsEvent, WalletDetailsState> {
  final BaseApiRepository apiRepository;
  final BaseWalletService walletService;
  final WalletHomeBloc walletHomeBloc;
  WalletStore wallet;

  Timer? periodic;

  List<TransactionStore> _transactions = <TransactionStore>[];
  WalletDetailsBloc({
    required this.apiRepository,
    required this.walletService,
    required this.wallet,
    required this.walletHomeBloc,
  }) : super(WalletDetailsInitial()) {
    on<WalletDetailsEvent>((event, emit) async {
      if (event is WalletDetailsLoadData) {
        emit(WalletDetailsLoading());
        _transactions = getIt
                .get<BaseDBHelper>()
                .transactions[apiRepository.network.name]?[wallet.id] ??
            await getIt
                .get<BaseDBHelper>()
                .getTransactions(wallet.id, apiRepository.network);
        emit(WalletDetailsCompleted(
          transactions: List.from(_transactions),
          withLoadingIndicator: true,
          wallet: wallet,
        ));
        try {
          var updateTransactions = await _updateTransactions();
          _transactions
              .removeWhere((element) => updateTransactions.contains(element));
          _transactions.addAll(updateTransactions);
          _transactions.sort(((a, b) => a.timeStamp.compareTo(b.timeStamp)));
          getIt.get<BaseDBHelper>().transactions[apiRepository.network.name]
              ?[wallet.id] = List.from(_transactions.reversed);
          await Future.delayed(Duration(seconds: 2));
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions.reversed),
            wallet: wallet,
          ));
          await getIt
              .get<BaseDBHelper>()
              .insertTransactions(wallet.id, updateTransactions);
        } on Exception catch (e) {
          emit(WalletDetailsError(
            message: ApiError(exception: e).message,
          ));
        }
      } else if (event is WalletDetailsRefreshData) {
        emit(WalletDetailsCompleted(
          transactions: List.from(_transactions.reversed),
          wallet: wallet,
          withLoadingIndicator: true,
        ));
        try {
          var updateTransactions = await _updateTransactions();
          if (updateTransactions.isEmpty && (periodic?.isActive ?? false))
            return;

          var updatedAddresses = await _updateAddresses();
          getIt.get<BaseDBHelper>().updateAddressBalance(
                updatedAddresses,
              );
          wallet = wallet.copyWith(addresses: updatedAddresses);
          walletHomeBloc.add(HomeUpdateWalletDetails(wallet));

          _transactions
              .removeWhere((element) => updateTransactions.contains(element));
          _transactions.addAll(updateTransactions);
          _transactions.sort(((a, b) => a.timeStamp.compareTo(b.timeStamp)));
          getIt.get<BaseDBHelper>().transactions[apiRepository.network.name]
              ?[wallet.id] = _transactions.reversed.toList();
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions.reversed),
            wallet: wallet,
            withLoadingIndicator: false,
          ));
          await getIt
              .get<BaseDBHelper>()
              .insertTransactions(wallet.id, updateTransactions);
        } on Exception catch (e) {
          emit(WalletDetailsError(
            message: ApiError(exception: e).message,
          ));
        }
      } else if (event is AddPendingTxs) {
        try {
          _transactions = getIt
                  .get<BaseDBHelper>()
                  .transactions[apiRepository.network.name]?[wallet.id] ??
              await getIt
                  .get<BaseDBHelper>()
                  .getTransactions(wallet.id, apiRepository.network);
          _transactions.sort(((a, b) => a.timeStamp.compareTo(b.timeStamp)));
          getIt.get<BaseDBHelper>().transactions[apiRepository.network.name]
              ?[wallet.id] = _transactions;
          periodic = Timer.periodic(Duration(seconds: 10), (value) {
            var tx = _transactions.firstWhereOrNull(
                (element) => element.txStatus == TXStatus.pending);
            if (tx == null) {
              periodic?.cancel();
              return;
            }
            if (!this.isClosed) add(WalletDetailsRefreshData());
          });
          emit(WalletDetailsCompleted(
            transactions: List.from(_transactions.reversed),
            withLoadingIndicator: true,
            wallet: wallet,
          ));
          add(UpdateWalletBalance());
          getIt
              .get<BaseDBHelper>()
              .insertTransactions(wallet.id, event.transactions);
        } catch (e) {
          emit(WalletDetailsError(
            message: ApiError(exception: e).message,
          ));
        }
      } else if (event is UpdateWalletBalance) {
        var updatedAddresses = await _updateAddresses();
        getIt.get<BaseDBHelper>().updateAddressBalance(
              updatedAddresses,
            );
        wallet = wallet.copyWith(addresses: updatedAddresses);
        walletHomeBloc.add(HomeUpdateWalletDetails(wallet));
        emit(WalletDetailsCompleted(
          transactions: List.from(_transactions.reversed),
          wallet: wallet,
          withLoadingIndicator: false,
        ));
      } else if (event is GenerateNewAddress) {
        var indexes = wallet.addresses.map((e) => e.index).toList();
        var newAddress = walletService.deriveNewAddress(
          walletId: wallet.id,
          seed: wallet.seed!,
          skipAddressIndexes: indexes,
          forGroup: event.group,
        );
        wallet.addresses.add(newAddress);
        if (event.isMain) {
          wallet = wallet.copyWith(mainAddress: newAddress.address);
          getIt
              .get<BaseDBHelper>()
              .updateWalletMainAddress(wallet.id, wallet.mainAddress);
        }
        emit(WalletDetailsCompleted(
            transactions: List.from(_transactions.reversed),
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
            transactions: List.from(_transactions.reversed),
            wallet: wallet,
            withLoadingIndicator: true));
        await getIt.get<BaseDBHelper>().insertAddress(newAddresses);
        add(WalletDetailsRefreshData());
      } else if (event is UpdateWalletName) {
        wallet = wallet.copyWith(title: event.name);
        await getIt.get<BaseDBHelper>().updateWalletName(wallet.id, event.name);
        emit(
          WalletDetailsCompleted(
            transactions: List.from(_transactions.reversed),
            wallet: wallet,
          ),
        );
        walletHomeBloc.add(HomeUpdateWalletDetails(wallet));
      }
    });
  }

  Future<List<TransactionStore>> _updateTransactions() async {
    var addresses = <AddressStore>[];
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
      if (value.hasException) print(value.exception?.message);
      if (value.hasData && value.data != null) {
        for (var tx in value.data!) {
          var a = _transactions.firstWhereOrNull((element) {
            return element == tx;
          });
          if (a == null || a.txStatus == TXStatus.pending)
            updateTransactions.add(tx);
        }
      }
    }
    return updateTransactions;
  }

  Future<List<AddressStore>> _updateAddresses() async {
    var addresses = <AddressStore>[];
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
      }
    }
    return updatedAddresses;
  }
}
