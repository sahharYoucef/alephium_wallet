import 'package:alephium_wallet/api/dto_models/balance_dto.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

@immutable
class WalletStore extends Equatable {
  // id INTEGER PRIMARY KEY,
  // title TEXT,
  // publicKey TEXT,
  // privateKey TEXT,
  // passphrase TEXT,
  // blockchain TEXT,
  // mnemonic TEXT,
  // seed TEXT,

  final String id;
  final String title;
  final String? passphrase;
  final Blockchain blockchain;
  final String? mnemonic;
  final String? seed;
  late final List<AddressStore> _addresses;
  final String mainAddress;

  WalletStore({
    required this.id,
    this.title = "",
    this.passphrase,
    required this.blockchain,
    this.mnemonic,
    this.seed,
    required this.mainAddress,
    List<AddressStore> addresses = const [],
  }) {
    _addresses = addresses;
  }

  factory WalletStore.redOnly(String address) {
    final String id = Uuid().v1();
    return WalletStore(
      mainAddress: address,
      id: id,
      blockchain: Blockchain.Alephium,
      addresses: [
        AddressStore(
          index: 0,
          group: 1,
          walletId: id,
          address: address,
        ),
      ],
    );
  }

  factory WalletStore.fromDb(
    Map<String, dynamic> data,
  ) {
    final _id = data["id"] as String;
    final _title = (data["title"] as String?) ?? "Alephium";
    final _passphrase = data["passphrase"] as String?;
    final _blockchain = _getBlockchain(data["blockchain"]);
    final _mnemonic = data["mnemonic"] as String?;
    final _seed = data["seed"] as String?;
    final _mainAddress = data["mainAddress"] as String;
    final List<AddressStore> _addresses =
        (data["addresses"] as List<Map<String, dynamic>>)
            .map((value) => AddressStore.fromDb(value))
            .toList();
    return WalletStore(
      id: _id,
      title: _title,
      passphrase: _passphrase,
      blockchain: _blockchain,
      mnemonic: _mnemonic,
      mainAddress: _mainAddress,
      seed: _seed,
      addresses: _addresses,
    );
  }

  WalletStore copyWith({
    String? id,
    String? title,
    String? passphrase,
    Blockchain? blockchain,
    String? mnemonic,
    String? seed,
    String? mainAddress,
    List<AddressStore>? addresses,
    Network? network,
  }) {
    return WalletStore(
      id: id ?? this.id,
      title: title ?? this.title,
      passphrase: passphrase ?? this.passphrase,
      blockchain: blockchain ?? this.blockchain,
      mnemonic: mnemonic ?? this.mnemonic,
      seed: seed ?? this.seed,
      mainAddress: mainAddress ?? this.mainAddress,
      addresses: addresses ?? this._addresses,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "title": this.title,
      "passphrase": this.passphrase,
      "blockchain": this.blockchain.name,
      "mnemonic": this.mnemonic,
      "seed": this.seed,
      "mainAddress": this.mainAddress,
    };
  }

  List<AddressStore> get addresses {
    var values = _addresses;
    values.sort((a, b) {
      if (a.address == mainAddress) {
        return -1;
      } else if (b.address == mainAddress) {
        return 1;
      }
      return a.index.compareTo(b.index);
    });
    return values;
  }

  String get balance {
    var value = 0.0;
    for (var address in _addresses) {
      double? addressBalance;
      addressBalance = address.balance?.balance;
      value += addressBalance ?? 0;
    }
    return Format.formatNumber(value / 10e17);
  }

  String? get balanceConverted {
    var value = double.parse(balance);
    return Format.convertToCurrency(value);
  }

  static Blockchain _getBlockchain(String value) =>
      Blockchain.values.firstWhere(
        (blockchain) => blockchain.name == value,
        orElse: () => Blockchain.Alephium,
      );

  @override
  String toString() {
    return this.toDb().toString();
  }

  @override
  List<Object?> get props => [id];
}
