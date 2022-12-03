import 'dart:convert';
import 'dart:typed_data';

import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

enum WalletType { multisig, normal, readOnly }

@immutable
class WalletStore extends Equatable {
  final String id;
  final String? title;
  final String? passphrase;
  final String? mnemonic;
  final List<String>? signatures;
  final String? seed;
  final int? mRequired;
  late final List<AddressStore> _addresses;
  final String mainAddress;
  final WalletType type;

  WalletStore({
    required this.id,
    this.title,
    this.passphrase,
    this.mnemonic,
    this.seed,
    this.mRequired,
    this.signatures,
    required this.mainAddress,
    List<AddressStore> addresses = const [],
    this.type = WalletType.normal,
  }) {
    _addresses = addresses;
  }

  factory WalletStore.multisig({
    required String address,
    String? title,
    required int mrequired,
    required List<String> signatures,
  }) {
    final String id = Uuid().v1();
    return WalletStore(
      title: title,
      mainAddress: address,
      id: id,
      type: WalletType.multisig,
      mRequired: mrequired,
      signatures: signatures,
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

  factory WalletStore.redOnly({
    required String address,
    required String publicKey,
    String? title,
  }) {
    final String id = Uuid().v1();
    return WalletStore(
      title: title,
      mainAddress: address,
      id: id,
      type: WalletType.readOnly,
      addresses: [
        AddressStore(
          index: 0,
          group: 1,
          walletId: id,
          address: address,
          publicKey: publicKey,
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
    final _mnemonic = data["mnemonic"] as String?;
    final _seed = data["seed"] as String?;
    final _mrequired = data["required"] as int?;
    final _mainAddress = data["mainAddress"] as String;
    final _type = WalletType.values.firstWhereOrNull(
          (element) => element.name == data["type"] as String?,
        ) ??
        WalletType.normal;
    final List<AddressStore> _addresses =
        (data["addresses"] as List<Map<String, dynamic>>)
            .map((value) => AddressStore.fromDb(value))
            .toList();
    final _signatures = _getSignatures(data["signatures"]);
    return WalletStore(
      id: _id,
      title: _title.isEmpty ? "Alephium" : _title,
      passphrase: _passphrase,
      mnemonic: _mnemonic,
      mainAddress: _mainAddress,
      seed: _seed,
      addresses: _addresses,
      type: _type,
      signatures: _signatures,
      mRequired: _mrequired,
    );
  }

  WalletStore copyWith({
    String? title,
    String? mainAddress,
    List<AddressStore>? addresses,
    Network? network,
  }) {
    return WalletStore(
      id: this.id,
      title: title ?? this.title,
      passphrase: this.passphrase,
      mnemonic: this.mnemonic,
      seed: this.seed,
      mainAddress: mainAddress ?? this.mainAddress,
      addresses: addresses ?? this._addresses,
      type: this.type,
      mRequired: this.mRequired,
      signatures: this.signatures,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "title": this.title,
      "passphrase": this.passphrase,
      "mnemonic": this.mnemonic,
      "seed": this.seed,
      "mainAddress": this.mainAddress,
      "type": this.type.name,
      "signatures": _setSignatures(signatures),
      "required": this.mRequired,
    };
  }

  static List<String>? _getSignatures(data) {
    if (data == null) return null;
    var value = String.fromCharCodes(data.cast<int>());
    var decoded = jsonDecode(value.toString()) as List;
    return decoded.cast<String>();
  }

  Uint8List? _setSignatures(List<String>? data) {
    if (data == null) return null;
    final encoded = json.encode(data);
    return Uint8List.fromList(encoded.codeUnits);
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

  List<TokenStore> get tokensBalances {
    List<TokenStore> tokens = [];
    for (var address in _addresses) {
      {
        if (address.balance?.tokens != null)
          for (var token in address.balance!.tokens!) {
            if (!tokens.contains(token)) {
              tokens.add(token);
            } else {
              late BigInt amount;
              amount =
                  tokens.firstWhere((element) => element == token).amount ??
                      BigInt.zero;
              amount += token.amount ?? BigInt.zero;
              final index = tokens.indexWhere((element) => element == token);
              tokens[index] = TokenStore(id: token.id, amount: amount);
            }
          }
      }
    }
    return tokens;
  }

  String get balance {
    var value = 0.0;
    for (var address in _addresses) {
      double? addressBalance;
      addressBalance = address.balance?.balance?.toDouble();
      value += addressBalance ?? 0;
    }
    return Format.formatNumber(value / 10e17);
  }

  String get lockedBalance {
    var value = 0.0;
    for (var address in _addresses) {
      double? addressBalance;
      addressBalance = address.balance?.lockedBalance?.toDouble();
      value += addressBalance ?? 0;
    }
    return Format.formatNumber(value / 10e17);
  }

  String? get balanceConverted {
    var value = double.parse(balance);
    return Format.convertToCurrency(value);
  }

  String? get lockedBalanceConverted {
    var value = double.parse(lockedBalance);
    return Format.convertToCurrency(value);
  }

  @override
  String toString() {
    return this.toDb().toString();
  }

  @override
  List<Object?> get props => [id];
}
