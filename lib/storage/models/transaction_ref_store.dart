import 'package:alephium_wallet/storage/models/token_store.dart';
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
  final BigInt? amount;
  final String? hash;
  final String? type;
  final int? hint;
  final String? key;
  final int? lockTime;
  final String? spent;
  final String? message;
  final List<TokenStore>? tokens;

  TransactionRefStore({
    this.hint,
    this.key,
    this.lockTime,
    this.spent,
    this.message,
    this.address,
    this.unlockScript,
    this.amount,
    this.hash,
    this.type,
    this.tokens,
  });

  String get txAmount {
    double value = amount?.toDouble() ?? 0;
    var _amount = (value / 10e17).toStringAsFixed(3);
    return "$_amount ℵ";
  }

  factory TransactionRefStore.fromDb(Map<String, dynamic> data) {
    final _address = data["address"] as String;
    final _unlockScript = data["unlockScript"];
    final _amount = BigInt.tryParse(data["amount"] ?? "0");
    final _hash = data["hash"];
    final _type = data["type"];
    final _spent = data["spent"];
    final _lockTime = data["lockTime"];
    final _hint = data["hint"];
    final _message = data["message"];
    final _key = data["key"];
    final _tokens = TokenStore.getTokens(data["tokens"]);
    return TransactionRefStore(
      address: _address,
      unlockScript: _unlockScript,
      amount: _amount,
      hash: _hash,
      spent: _spent,
      type: _type,
      key: _key,
      message: _message,
      hint: _hint,
      lockTime: _lockTime,
      tokens: _tokens,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "address": this.address,
      "unlockScript": this.unlockScript,
      "amount": this.amount?.toString(),
      "hash": this.hash,
      "type": this.type,
      "hint": this.hint,
      "message": this.message,
      "lockTime": this.lockTime,
      "spent": this.spent,
      "key": this.key,
      "tokens": TokenStore.setTokens(tokens),
    };
  }

  @override
  String toString() {
    return toDb().toString();
  }
}
