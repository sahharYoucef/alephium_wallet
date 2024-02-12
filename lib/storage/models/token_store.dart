import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/models/nft_metadata.dart';
import 'package:alephium_wallet/api/models/token_metadata.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

class TokenStore extends Equatable {
  final String? id;
  final BigInt? balance;
  final BigInt? lockedBalance;

  static List<TokenStore> getTokens(data) {
    if (data == null) return <TokenStore>[];
    var value = String.fromCharCodes(data.cast<int>());
    var decoded = jsonDecode(value.toString()) as List<dynamic>;
    final contracts = decoded.map((ref) => TokenStore.fromDb(ref)).toList();
    return contracts.toList();
  }

  static Uint8List? setTokens(List<TokenStore>? data) {
    if (data == null) return null;
    final encoded = json.encode(data.map((e) => e.toDb()).toList());
    return Uint8List.fromList(encoded.codeUnits);
  }

  TokenStore({
    this.id,
    this.balance,
    this.lockedBalance,
  });

  factory TokenStore.fromDb(Map<String, dynamic> data) {
    final _id = data["id"] as String?;
    final _balance = BigInt.tryParse(data["amount"]);
    final _lockedBalance = BigInt.tryParse("${data["lockedBalance"]}");

    return TokenStore(
        id: _id, balance: _balance, lockedBalance: _lockedBalance);
  }

  TokenStore copyWith({
    String? id,
    BigInt? balance,
    BigInt? lockedBalance,
    String? name,
    TokenType? type,
  }) {
    return TokenStore(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      lockedBalance: lockedBalance ?? this.lockedBalance,
    );
  }

  TokenType get type {
    if (nftMetaData != null) return TokenType.nonFungible;
    if (metaData != null) return TokenType.fungible;
    return TokenType.none;
  }

  bool get isNft {
    return type == TokenType.nonFungible;
  }

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "amount": this.balance?.toString(),
      "lockedBalance": this.lockedBalance?.toString(),
    };
  }

  String? get name {
    return isNft ? nftMetaData?.name : metaData?.name;
  }

  String get label {
    return isNft
        ? nftMetaData?.name ?? ""
        : (metaData?.name ?? symbol ?? "token".tr());
  }

  String? get description {
    return isNft ? nftMetaData?.description : metaData?.description;
  }

  String? get totalSupply {
    return metaData?.totalSupply?.toString();
  }

  String? get symbol {
    return metaData?.symbol;
  }

  int get decimals {
    return metaData?.decimals ?? 0;
  }

  double get formattedBalance {
    return balance != null
        ? balance!.toDouble() / pow(10, metaData?.decimals ?? 0)
        : 0;
  }

  double get formattedLockedBalance {
    return lockedBalance != null
        ? lockedBalance!.toDouble() / pow(10, metaData?.decimals ?? 0)
        : 0;
  }

  BigInt get availableBalance {
    return (balance ?? BigInt.zero) - (lockedBalance ?? BigInt.zero);
  }

  double get formattedAvailableBalance {
    return availableBalance.toDouble() / pow(10, metaData?.decimals ?? 0);
  }

  String? get logo {
    return isNft ? nftMetaData?.image : metaData?.logoURI;
  }

  @override
  String toString() {
    return toDb().toString();
  }

  TokenMetadata? get metaData {
    return WalletHomeBloc.tokens
        .firstWhereOrNull((element) => element.id == id);
  }

  NftMetadata? get nftMetaData {
    return WalletHomeBloc.nfts.firstWhereOrNull((element) => element.id == id);
  }

  @override
  List<Object?> get props => [this.id];
}
