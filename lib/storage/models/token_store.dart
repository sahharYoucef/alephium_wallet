import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:alephium_wallet/api/models/token_metadata.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';

class TokenStore extends Equatable {
  final String? id;
  final BigInt? amount;

  static List<TokenStore> getTokens(data) {
    if (data == null) return <TokenStore>[];
    var value = String.fromCharCodes(data.cast<int>());
    var decoded = jsonDecode(value.toString()) as List<dynamic>;
    var _tokens = decoded.map((ref) => TokenStore.fromDb(ref)).toList();
    return _tokens;
  }

  static Uint8List? setTokens(List<TokenStore>? data) {
    if (data == null) return null;
    final encoded = json.encode(data.map((e) => e.toDb()).toList());
    return Uint8List.fromList(encoded.codeUnits);
  }

  TokenStore({
    this.id,
    this.amount,
  });

  factory TokenStore.fromDb(Map<String, dynamic> data) {
    final _id = data["id"] as String?;
    final _amount = BigInt.tryParse(data["amount"]);
    return TokenStore(
      id: _id,
      amount: _amount,
    );
  }

  TokenStore copyWith({
    String? id,
    BigInt? amount,
    String? name,
  }) {
    return TokenStore(
      id: id ?? this.id,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "amount": this.amount?.toString(),
    };
  }

  String? get name {
    return metaData?.name;
  }

  String get label {
    return metaData?.name ?? symbol ?? "Unknown";
  }

  String? get description {
    return metaData?.description;
  }

  String? get totalSupply {
    return metaData?.totalSupply?.toString();
  }

  String? get symbol {
    return metaData?.symbol;
  }

  int get decimals {
    return metaData?.decimals ?? 1;
  }

  double get formattedAmount {
    return amount != null
        ? amount!.toDouble() / pow(10, metaData?.decimals ?? 1)
        : 0;
  }

  String? get logo {
    return metaData?.logoURI;
  }

  @override
  String toString() {
    return toDb().toString();
  }

  TokenMetadata? get metaData {
    return WalletHomeBloc.tokens
        .firstWhereOrNull((element) => element.id == id);
  }

  @override
  List<Object?> get props => [this.id];
}
