import 'package:alephium_wallet/api/models/token_metadata.dart';

class Tokens {
  final List<TokenMetadata>? tokens;
  final int? networkId;

  Tokens({
    this.tokens,
    this.networkId,
  });

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      tokens: json['tokens'] != null
          ? (json['tokens'] as List)
              .map((i) => TokenMetadata.fromJson(i))
              .toList()
          : null,
      networkId: json['networkId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tokens': tokens?.map((e) => e.toJson()).toList(),
      'networkId': networkId,
    };
  }

  Tokens copyWith({
    List<TokenMetadata>? tokens,
    int? networkId,
  }) {
    return Tokens(
      tokens: tokens ?? this.tokens,
      networkId: networkId ?? this.networkId,
    );
  }
}
