import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';

abstract class BaseDBHelper {
  Map<String, Map<String, List<TransactionStore>>> get transactions;

  @mustCallSuper
  BaseDBHelper() {
    init();
  }

  Future<void> init();

  Future<List<ContactStore>> getContacts();

  Future<void> insertContact(ContactStore contactStore);

  Future<void> deleteContact(String id);

  Future<void> insertWallet(WalletStore wallet, AddressStore addressStore);

  Future<List<WalletStore>> getWallets({required Network network});

  Future<void> updateWalletName(String id, String title);

  Future<void> updateWalletMainAddress(String id, String mainAddress);

  Future<void> deleteWallet(String id);

  Future<void> insertAddress(List<AddressStore> addresses);

  Future<void> updateAddressBalance(List<AddressStore> addresses);

  Future<void> insertTransactions(
    String walletId,
    List<TransactionStore> transactionStores,
  );

  Future<List<TransactionStore>> getTransactions(
      String walletID, Network network);
}
