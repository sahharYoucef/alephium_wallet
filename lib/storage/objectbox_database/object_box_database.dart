import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:objectbox/objectbox.dart';

class ObjectBoxDbHelper extends BaseDBHelper {
  @override
  Future<void> init() async {
    // final _store = Store();
  }

  @override
  Future<void> deleteWallet(String id) {
    // TODO: implement deleteWallet
    throw UnimplementedError();
  }

  @override
  Future<List<TransactionStore>> getTransactions(String walletID) {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  Future<List<WalletStore>> getWallets() {
    // TODO: implement getWallets
    throw UnimplementedError();
  }

  @override
  Future<void> insertAddress(List<AddressStore> addresses) {
    // TODO: implement insertAddress
    throw UnimplementedError();
  }

  @override
  Future<void> insertTransactions(
      String walletId, List<TransactionStore> transactionStores) {
    // TODO: implement insertTransactions
    throw UnimplementedError();
  }

  @override
  Future<void> insertWallet(WalletStore wallet, AddressStore addressStore) {
    // TODO: implement insertWallet
    throw UnimplementedError();
  }

  @override
  Future<void> updateAddressBalance(List<AddressStore> addresses) {
    // TODO: implement updateAddressBalance
    throw UnimplementedError();
  }

  @override
  Future<void> updateWalletMainAddress(String id, String mainAddress) {
    // TODO: implement updateWalletMainAddress
    throw UnimplementedError();
  }

  @override
  Future<void> updateWalletName(String id, String title) {
    // TODO: implement updateWalletName
    throw UnimplementedError();
  }

  @override
  // TODO: implement transactions
  Map<String, List<TransactionStore>> get transactions =>
      throw UnimplementedError();
}
