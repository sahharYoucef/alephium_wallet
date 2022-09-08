import 'dart:async';

import 'package:collection/collection.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:sqflite/sqflite.dart';

import '../models/address_store.dart';
import '../models/wallet_store.dart';

final String _walletTable = "wallets";
final String _transactionTable = "transactions";
final String _transactionRefsTable = "transaction_refs";
final String _addressesTable = "addresses";

class SQLiteDBHelper extends BaseDBHelper {
  @override
  Map<String, List<TransactionStore>> transactions = {};

  SQLiteDBHelper() : super();

  late Completer<Database> db;

  dropTables(Database _db) async {
    // await _db.execute('DROP TABLE IF EXISTS $_addressesTable');
    // await _db.execute('DROP TABLE IF EXISTS $_transactionRefsTable');
    // await _db.execute('DROP TABLE IF EXISTS $_transactionTable');
    // await _db.execute('DROP TABLE IF EXISTS $_walletTable');
  }

  _onConfigure(Database _db) async {
    await dropTables(_db);
    await _db.execute('PRAGMA foreign_keys = ON');
    await _db.execute("""
      CREATE TABLE IF NOT EXISTS $_walletTable (
          id TEXT PRIMARY KEY NOT NULL,
          title TEXT,
          passphrase TEXT,
          blockchain TEXT NOT NULL,
          mnemonic TEXT NOT NULL,
          seed TEXT NOT NULL,
          mainAddress TEXT NOT NULL
      )""");
    await _db.execute("""
      CREATE TABLE IF NOT EXISTS $_transactionTable (
          id TEXT PRIMARY KEY NOT NULL,
          txHash TEXT NOT NULL,
          address TEXT NOT NULL,
          wallet_id TEXT NOT NULL,
          blockHash TEXT,
          timeStamp INTEGER,
          transactionAmount INTEGER,
          transactionGas TEXT,
          status TEXT,
          FOREIGN KEY(wallet_id) REFERENCES $_walletTable(id) ON DELETE CASCADE
      )""");
    await _db.execute("""
      CREATE TABLE IF NOT EXISTS $_transactionRefsTable (
          address TEXT NOT NULL,
          unlockScript TEXT,
          amount INTEGER,
          txHashRef TEXT,
          status TEXT,
          type TEXT,
          transaction_id TEXT NOT NULL,
          FOREIGN KEY(transaction_id) REFERENCES $_transactionTable(id) ON DELETE CASCADE
      )""");
    await _db.execute("""
      CREATE TABLE IF NOT EXISTS $_addressesTable (
          address TEXT PRIMARY KEY NOT NULL,
          address_title TEXT,
          address_color TEXT,
          publicKey TEXT NOT NULL,
          privateKey TEXT NOT NULL,
          address_balance REAL,
          address_index INTEGER,
          group_index INTEGER,
          balance_hint REAL,
          balance_locked REAL,
          warning TEXT,
          wallet_id TEXT NOT NULL,
          FOREIGN KEY(wallet_id) REFERENCES $_walletTable(id)  ON DELETE CASCADE
      )
      """);
  }

  @override
  init() async {
    db = Completer<Database>();
    var _db = await openDatabase(
      "db.db",
      onConfigure: _onConfigure,
      version: 1,
    );
    db.complete(_db);
  }

  @override
  insertWallet(WalletStore wallet, AddressStore addressStore) async {
    var _db = await db.future;
    var batch = _db.batch();
    batch.insert(_walletTable, wallet.toDb());
    batch.insert(_addressesTable, addressStore.toDb());
    await batch.commit();
  }

  @override
  Future<List<WalletStore>> getWallets() async {
    var _db = await db.future;
    var data = await _db.rawQuery("""
        SELECT * FROM ${_walletTable} wallets
        LEFT JOIN ${_addressesTable} addresses
        ON wallets.id = addresses.wallet_id;
      """);
    return List<Map<String, dynamic>>.from(data)
        .combine()
        .map((e) => WalletStore.fromDb(e))
        .toList();
  }

  @override
  updateWalletName(String id, String title) async {
    var _db = await db.future;
    await _db.update(
      _walletTable,
      {"title": title},
      where: "id = ?",
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  updateWalletMainAddress(String id, String mainAddress) async {
    var _db = await db.future;
    await _db.update(
      _walletTable,
      {"mainAddress": mainAddress},
      where: "id = ?",
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  @override
  deleteWallet(String id) async {
    var _db = await db.future;
    var batch = _db.batch();
    batch.delete(
      _walletTable,
      where: "id = ?",
      whereArgs: [id],
    );
    await batch.commit();
  }

  @override
  insertAddress(List<AddressStore> addresses) async {
    var _db = await db.future;
    var batch = _db.batch();
    for (var address in addresses)
      batch.insert(_addressesTable, address.toDb());
    await batch.commit();
  }

  @override
  updateAddressBalance(List<AddressStore> addresses) async {
    var _db = await db.future;
    var batch = await _db.batch();
    for (var address in addresses)
      batch.update(
          _addressesTable,
          {
            "address_balance": address.addressBalance,
            "balance_locked": address.balanceLocked,
            "balance_hint": address.balanceHint,
          },
          where: "address = ?",
          whereArgs: [address.address]);
    batch.commit();
  }

  @override
  Future<void> insertTransactions(
    String walletId,
    List<TransactionStore> transactionStores,
  ) async {
    if (transactionStores.isEmpty) return;
    var _db = await db.future;
    var batch = _db.batch();
    transactionStores.forEach((element) {
      batch.insert(_transactionTable, element.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (var ref in element.refsIn) {
        batch.insert(
          _transactionRefsTable,
          ref.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      for (var ref in element.refsOut) {
        batch.insert(
          _transactionRefsTable,
          ref.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    await batch.commit();
  }

  @override
  Future<List<TransactionStore>> getTransactions(String walletID) async {
    var _db = await db.future;
    var data = await _db.rawQuery(
      '''SELECT * FROM $_transactionTable t 
           LEFT JOIN $_transactionRefsTable r 
           ON t.id = r.transaction_id WHERE t.wallet_id = "${walletID}"
           ORDER BY timeStamp ASC
        ''',
    );
    var transactions = data
        .combine("id", "refs")
        .map((e) => TransactionStore.fromDb(e))
        .toList();
    return transactions;
  }
}

extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inPlace = true]) {
    final ids = Set();
    var list = inPlace ? this : List<E>.from(this);
    list.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));
    return list;
  }
}

extension Combine on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> combine(
      [String compare = 'id', String whereReturns = 'addresses']) {
    List<Map<String, dynamic>> updated = [];
    for (var element in this) {
      if (updated.isEmpty || element[compare] != updated.last[compare]) {
        updated.add({...element});
        updated.last[whereReturns] = <Map<String, dynamic>>[];
      }
      updated.last[whereReturns].add(element);
    }
    return updated;
  }
}
