import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/contact_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';

abstract class BaseDBHelper {
  Map<NetworkType, Map<String, List<TransactionStore>>> get txCaches;

  @mustCallSuper
  BaseDBHelper() {
    init();
  }

  Future<void> init();

  Future<List<ContactStore>> getContacts();

  Future<void> insertContact(ContactStore contactStore);

  Future<void> updateContact(int id, ContactStore contactStore);

  Future<void> deleteContact(int id);

  Future<void> insertWallet(
      WalletStore wallet, List<AddressStore> addressStore);

  Future<List<WalletStore>> getWallets({required NetworkType network});

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
      String walletID, NetworkType network);
}
