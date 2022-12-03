import 'dart:convert';

import 'package:alephium_wallet/storage/models/balance_store.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class AddressStore extends Equatable {
  // address TEXT PRIMARY KEY,
  // balance REAL,
  // index INTEGER,
  // balance_hint REAL,
  // balance_locked REAL,
  // warning TEXT,
  // wallet_id INTEGER,

  final String address;
  final String? publicKey;
  final String? privateKey;
  final int index;
  final int? group;
  final String? warning;
  final String walletId;
  final String? color;
  final String? title;
  final BalanceStore? balance;

  AddressStore({
    required this.address,
    this.publicKey,
    this.privateKey,
    required this.index,
    this.group,
    required this.walletId,
    this.balance,
    this.warning,
    this.color,
    this.title,
  });

  factory AddressStore.fromDb(Map<String, dynamic> data) {
    final _walletId = data["walletId"] as String;
    final _address = data["address"] as String;
    final _index = data["addressIndex"] as int;
    final _group = data["addressGroup"] as int?;
    final _title = data["addressTitle"] as String?;
    final _color = data["addressColor"] as String?;
    final _warning = data["warning"] as String?;
    final _publicKey = data["publicKey"] as String?;
    final _privateKey = data["privateKey"] as String?;
    return AddressStore(
      balance:
          data["balanceAddress"] != null ? BalanceStore.fromDb(data) : null,
      address: _address,
      index: _index,
      group: _group,
      walletId: _walletId,
      privateKey: _privateKey,
      publicKey: _publicKey,
      warning: _warning,
      color: _color,
      title: _title,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "address": this.address,
      "walletId": this.walletId,
      "addressColor": this.color,
      "addressTitle": this.title,
      "addressIndex": this.index,
      "addressGroup": this.group,
      "warning": this.warning,
      "privateKey": this.privateKey,
      "publicKey": this.publicKey,
    };
  }

  String get formattedBalance {
    return Format.formatNumber(addressBalance);
  }

  double get addressBalance {
    double? addressBalance = balance?.balance?.toDouble();
    return (addressBalance ?? 0) / 10e17;
  }

  String? get balanceConverted {
    var value = addressBalance;
    return Format.convertToCurrency(value);
  }

  @override
  List<Object?> get props => [address];

  @override
  String toString() {
    return this.toDb().toString();
  }

  String receiveAmount(double? value) {
    final Map<String, dynamic> data = {
      "Type": "ALEPHIUM",
      "address": this.address,
    };
    if (value != null) data["amount"] = value;
    return json.encode(data);
  }
}
