import 'dart:convert';

import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TransactionStore extends Equatable {
  final String address;
  final String? transactionID;
  final String txHash;
  final String? blockHash;
  final int timeStamp;
  final int? gasAmount;
  final BigInt? gasPrice;
  final TXStatus status;
  final String walletId;
  final List<TransactionRefStore> refsIn;
  final List<TransactionRefStore> refsOut;
  final NetworkType network;

  TransactionStore({
    required this.txHash,
    required this.address,
    required this.transactionID,
    this.blockHash,
    required this.timeStamp,
    this.gasAmount,
    this.gasPrice,
    required this.status,
    required this.walletId,
    this.refsIn = const [],
    this.refsOut = const [],
    required this.network,
  });

  static List<TransactionRefStore> _getRefs(Uint8List? data) {
    if (data == null) return <TransactionRefStore>[];
    var value = String.fromCharCodes(data);
    var decoded = jsonDecode(value.toString()) as List<dynamic>;
    var _refs = decoded.map((ref) => TransactionRefStore.fromDb(ref)).toList();
    return _refs;
  }

  Uint8List _setRefs(List<TransactionRefStore> data) {
    final encoded = json.encode(data.map((e) => e.toDb()).toList());
    return Uint8List.fromList(encoded.codeUnits);
  }

  factory TransactionStore.fromDb(Map<String, dynamic> data) {
    final _txHash = data["hash"] as String;
    final _address = data["txAddress"] as String;
    final _blockHash = data["blockHash"];
    final _gasAmount = data["gasAmount"];
    final _walletId = data["walletId"];
    final _txStatus = _getStatus(data["status"] ?? "completed");
    final _timeStamp = data["timeStamp"];
    final _network = NetworkType.network(data["network"]);
    final _transactionID = data["txID"];
    final _gasPrice = BigInt.tryParse(data["gasPrice"]);
    final _refsIn = _getRefs(data["refsIn"] as Uint8List?);
    final _refsOut = _getRefs(data["refsOut"] as Uint8List?);
    return TransactionStore(
      transactionID: _transactionID,
      address: _address,
      txHash: _txHash,
      blockHash: _blockHash,
      gasAmount: _gasAmount,
      walletId: _walletId,
      status: _txStatus,
      refsIn: _refsIn,
      refsOut: _refsOut,
      timeStamp: _timeStamp,
      network: _network,
      gasPrice: _gasPrice,
    );
  }

  TransactionStore copyWith({
    String? address,
    String? txHash,
    String? blockHash,
    int? timeStamp,
    int? gasAmount,
    BigInt? gasPrice,
    int? txAmount,
    TXStatus? txStatus,
    String? walletId,
    List<TransactionRefStore>? refsIn,
    List<TransactionRefStore>? refsOut,
    NetworkType? network,
    String? transactionID,
  }) {
    return TransactionStore(
      transactionID: transactionID ?? this.transactionID,
      txHash: txHash ?? this.txHash,
      address: address ?? this.address,
      timeStamp: timeStamp ?? this.timeStamp,
      status: txStatus ?? this.status,
      walletId: walletId ?? this.walletId,
      gasAmount: gasAmount ?? this.gasAmount,
      gasPrice: gasPrice ?? this.gasPrice,
      blockHash: blockHash ?? this.blockHash,
      refsIn: refsIn ?? this.refsIn,
      refsOut: refsOut ?? this.refsOut,
      network: network ?? this.network,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "txId": this.transactionID,
      "hash": this.txHash,
      "blockHash": this.blockHash,
      "gasAmount": this.gasAmount,
      "gasPrice": this.gasPrice?.toString(),
      "walletId": this.walletId,
      "txAddress": this.address,
      "status": this.status.title,
      "id": id,
      "timeStamp": this.timeStamp,
      "network": this.network.name,
      "refsIn": _setRefs(this.refsIn),
      "refsOut": _setRefs(this.refsOut),
    };
  }

  static TXStatus _getStatus(String _status) => TXStatus.values.firstWhere(
        (blockchain) => blockchain.name == _status,
        orElse: () => TXStatus.completed,
      );

  String get amount {
    double value = 0.0;
    if (inputAddresses.contains(address)) {
      var _inAddresses =
          refsIn.where((element) => element.address == address).toList();
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _inAddresses) value += ref.amount?.toDouble() ?? 0;
      for (var ref in _outAddresses) value -= ref.amount?.toDouble() ?? 0;
      value -= feeValue.toDouble();
    } else {
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _outAddresses) value += ref.amount?.toDouble() ?? 0;
    }
    final _amount = (value / 10e17).toStringAsFixed(3);
    return "$_amount ℵ";
  }

  List<TokenStore> get tokens {
    List<TokenStore> tokens = [];
    if (inputAddresses.contains(address)) {
      var _inAddresses =
          refsIn.where((element) => element.address == address).toList();
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _inAddresses) {
        if (ref.tokens != null) {
          for (final token in ref.tokens!) {
            if (tokens.contains(token)) {
              final index = tokens.indexWhere((element) => element == token);
              tokens[index] = tokens[index]
                  .copyWith(balance: tokens[index].balance! + token.balance!);
            } else {
              tokens.add(token);
            }
          }
        }
      }
      for (var ref in _outAddresses) {
        if (ref.tokens != null) {
          for (final token in ref.tokens!) {
            if (tokens.contains(token)) {
              final index = tokens.indexWhere((element) => element == token);
              tokens[index] = tokens[index]
                  .copyWith(balance: tokens[index].balance! - token.balance!);
            } else {
              tokens.add(token);
            }
          }
        }
      }
    } else {
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _outAddresses) {
        if (ref.tokens != null) {
          for (final token in ref.tokens!) {
            if (tokens.contains(token)) {
              var index = tokens.indexWhere((element) => element == token);
              tokens[index] = tokens[index]
                  .copyWith(balance: tokens[index].balance! + token.balance!);
            } else {
              tokens.add(token);
            }
          }
        }
      }
    }
    return tokens;
  }

  List<String> get inputAddresses {
    List<String> addresses = [];
    for (var v in refsIn) {
      if (v.address != null) addresses.add(v.address!);
    }
    return addresses;
  }

  List<String> get outputAddresses {
    List<String> addresses = [];
    for (var v in refsIn) {
      if (v.address != null) addresses.add(v.address!);
    }
    return addresses;
  }

  BigInt get feeValue {
    var _gasAmount = gasAmount;
    if (gasPrice != null && _gasAmount != null) {
      return gasPrice! * BigInt.from(_gasAmount);
    }
    return BigInt.zero;
  }

  String get fee {
    var _gasAmount = gasAmount;
    if (gasPrice != null && _gasAmount != null) {
      return (gasPrice!.toDouble() * _gasAmount / 10e17).toStringAsFixed(4);
    }
    return "???";
  }

  String get id {
    return "${this.address}${this.txHash}";
  }

  TransactionType get type {
    if (inputAddresses.contains(address)) return TransactionType.withdraw;
    return TransactionType.deposit;
  }

  @override
  List<Object?> get props => [id];
  @override
  String toString() {
    return this.toDb().toString();
  }
}

enum TransactionType {
  deposit("received"),
  withdraw("sent");

  final String type;
  const TransactionType(this.type);
}

enum TXStatus {
  pending("pending"),
  completed("completed");

  final String title;
  const TXStatus(this.title);
}
