import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class TransactionStore extends Equatable {
  // txHash TEXT PRIMARY KEY,
  // blockHash TEXT,
  // timeStamp INTEGER,
  // amount INTEGER,
  // gas TEXT,
  // status tx_status,
  // wallet_id INTEGER,
  final String address;
  final String transactionID;
  final String txHash;
  final String? blockHash;
  final int timeStamp;
  final String? transactionGas;
  final int? transactionAmount;
  final TXStatus txStatus;
  final String walletId;
  final List<TransactionRefStore> refsIn;
  final List<TransactionRefStore> refsOut;
  final Network network;

  TransactionStore({
    required this.txHash,
    required this.address,
    required this.transactionID,
    this.blockHash,
    required this.timeStamp,
    this.transactionGas,
    this.transactionAmount,
    required this.txStatus,
    required this.walletId,
    this.refsIn = const [],
    this.refsOut = const [],
    required this.network,
  });

  factory TransactionStore.fromDb(Map<String, dynamic> data) {
    final _txHash = data["txHash"] as String;
    final _address = data["tx_address"] as String;
    final _blockHash = data["blockHash"];
    final _gas = data["transactionGas"];
    final _walletId = data["wallet_id"];
    final _txStatus = status(data["status"] ?? "completed");
    final _amount = data["transactionAmount"];
    final _timeStamp = data["timeStamp"];
    final refs = (data["refs"] as List<Map<String, dynamic>>?)
        ?.map((data) => TransactionRefStore.fromDb(data))
        .toList();
    final _refsIn = refs?.where((element) => element.type == "in").toList();
    final _refsOut = refs?.where((element) => element.type == "out").toList();
    final _network = Network.network(data["network"]);
    final _transactionID = data["txID"] ?? "";
    return TransactionStore(
      transactionID: _transactionID,
      address: _address,
      txHash: _txHash,
      blockHash: _blockHash,
      transactionGas: _gas,
      walletId: _walletId,
      txStatus: _txStatus,
      transactionAmount: _amount,
      refsIn: _refsIn ?? [],
      refsOut: _refsOut ?? [],
      timeStamp: _timeStamp,
      network: _network,
    );
  }

  TransactionStore copyWith({
    String? address,
    String? txHash,
    String? blockHash,
    int? timeStamp,
    String? gas,
    int? amount,
    TXStatus? txStatus,
    String? walletId,
    List<TransactionRefStore>? refsIn,
    List<TransactionRefStore>? refsOut,
    Network? network,
    String? transactionID,
  }) {
    return TransactionStore(
      transactionID: transactionID ?? this.transactionID,
      txHash: txHash ?? this.txHash,
      address: address ?? this.address,
      timeStamp: timeStamp ?? this.timeStamp,
      txStatus: txStatus ?? this.txStatus,
      walletId: walletId ?? this.walletId,
      transactionAmount: amount ?? this.transactionAmount,
      transactionGas: gas ?? this.transactionGas,
      blockHash: blockHash ?? this.blockHash,
      refsIn: refsIn ?? this.refsIn,
      refsOut: refsOut ?? this.refsOut,
      network: network ?? this.network,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "txID": this.transactionID,
      "txHash": this.txHash,
      "blockHash": this.blockHash,
      "transactionGas": this.transactionGas,
      "wallet_id": this.walletId,
      "tx_address": this.address,
      "status": this.txStatus.title,
      "transactionAmount": this.transactionAmount,
      "id": id,
      "timeStamp": this.timeStamp,
      "network": this.network.name,
    };
  }

  static TXStatus status(String _status) => TXStatus.values.firstWhere(
        (blockchain) => blockchain.name == _status,
        orElse: () => TXStatus.completed,
      );

  String get txAmount {
    double value = 0.0;
    if (inputAddresses.contains(address)) {
      var _inAddresses =
          refsIn.where((element) => element.address == address).toList();
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _inAddresses)
        value += (BigInt.tryParse("${ref.amount}")?.toDouble() ?? 0);
      for (var ref in _outAddresses)
        value -= (BigInt.tryParse("${ref.amount}")?.toDouble() ?? 0);
      value -= feeValue;
    } else {
      var _outAddresses =
          refsOut.where((element) => element.address == address).toList();
      for (var ref in _outAddresses)
        value += (BigInt.tryParse("${ref.amount}")?.toDouble() ?? 0);
    }
    final _amount = (value / 10e17).toStringAsFixed(3);
    return "$_amount ℵ";
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

  double get feeValue {
    var gasPrice = double.tryParse("${transactionGas}");
    if (transactionAmount != null && gasPrice != null) {
      return transactionAmount! * gasPrice;
    }
    return 0;
  }

  String get fee {
    var gasPrice = double.tryParse("${transactionGas}");
    if (transactionAmount != null && gasPrice != null) {
      return (transactionAmount! * gasPrice / 10e17).toStringAsFixed(3);
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
