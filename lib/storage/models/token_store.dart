import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

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

  Map<String, dynamic> toDb() {
    return {
      "id": this.id,
      "amount": this.amount?.toString(),
    };
  }

  @override
  List<Object?> get props => [this.id];
}
