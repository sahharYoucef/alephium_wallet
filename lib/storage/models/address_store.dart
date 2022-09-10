import 'dart:convert';

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
  final double? addressBalance;
  final double? balanceHint;
  final String publicKey;
  final String privateKey;
  final double? balanceLocked;
  final int index;
  final int group;
  final String? warning;
  final String walletId;
  final String? color;
  final String? title;

  AddressStore({
    required this.address,
    required this.publicKey,
    required this.privateKey,
    this.addressBalance,
    this.balanceHint,
    this.balanceLocked,
    required this.index,
    required this.group,
    this.warning,
    this.color,
    this.title,
    required this.walletId,
  });

  String get formattedBalance {
    if (addressBalance == null) return "";
    return (addressBalance! / 10e17).toStringAsPrecision(3);
  }

  factory AddressStore.fromDb(Map<String, dynamic> data) {
    final _address = data["address"] as String;
    final _balance = data["address_balance"] as double?;
    final _balanceHint = data["balance_hint"] as double?;
    final _balanceLocked = data["balance_locked"] as double?;
    final _index = data["address_index"] as int;
    final _warning = data["warning"] as String?;
    final _walletId = data["wallet_id"] as String;
    final _publicKey = data["publicKey"] as String;
    final _privateKey = data["privateKey"] as String;
    final _group = data["group_index"] as int? ?? 0;
    final _title = data["address_title"] as String?;
    final _color = data["address_color"] as String?;
    return AddressStore(
      address: _address,
      index: _index,
      group: _group,
      walletId: _walletId,
      privateKey: _privateKey,
      publicKey: _publicKey,
      addressBalance: _balance,
      balanceHint: _balanceHint,
      balanceLocked: _balanceLocked,
      warning: _warning,
      color: _color,
      title: _title,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "address": this.address,
      "address_balance": this.addressBalance,
      "address_color": this.color,
      "address_title": this.title,
      "balance_hint": this.balanceHint,
      "balance_locked": this.balanceLocked,
      "address_index": this.index,
      "group_index": this.group,
      "wallet_id": this.walletId,
      "warning": this.warning,
      "privateKey": this.privateKey,
      "publicKey": this.publicKey,
    };
  }

  String get balance {
    var value = 0.0;
    value += addressBalance ?? 0;
    return Format.formatNumber(value / 10e17);
  }

  String? get balanceConverted {
    var value = double.tryParse(balance);
    if (value == null) return null;
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
