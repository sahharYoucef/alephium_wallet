import 'package:alephium_wallet/api/utils/network.dart';
import 'package:flutter/foundation.dart';

@immutable
class TransactionRefStore {
  // address TEXT PRIMARY KEY,
  // unlockScript TEXT,
  // amount INTEGER,
  // txHashRef TEXT,
  // status TEXT,
  // transaction_id TEXT,

  final String? address;
  final String? unlockScript;
  final String? amount;
  final String? txHashRef;
  final String? transactionId;
  final String? type;

  TransactionRefStore({
    this.address,
    this.unlockScript,
    this.amount,
    this.txHashRef,
    this.transactionId,
    this.type,
  });

  factory TransactionRefStore.fromDb(Map<String, dynamic> data) {
    final _address = data["ref_address"] as String;
    final _unlockScript = data["unlockScript"];
    final _amount = data["amount"] as String?;
    final _txHashRef = data["txHashRef"];
    final _transactionId = data["transaction_id"];
    final _type = data["type"];
    return TransactionRefStore(
      address: _address,
      unlockScript: _unlockScript,
      amount: _amount,
      txHashRef: _txHashRef,
      transactionId: _transactionId,
      type: _type,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "ref_address": this.address,
      "unlockScript": this.unlockScript,
      "amount": this.amount,
      "txHashRef": this.txHashRef,
      "transaction_id": this.transactionId,
      "type": this.type,
    };
  }

  @override
  String toString() {
    return toDb().toString();
  }
}
