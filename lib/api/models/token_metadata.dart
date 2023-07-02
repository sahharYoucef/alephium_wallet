import 'package:equatable/equatable.dart';

class TokenMetadata extends Equatable {
  final String? id;
  final String? name;
  final String? symbol;
  final int? decimals;
  final String? logoURI;
  final String? description;
  final BigInt? totalSupply;

  TokenMetadata({
    this.id,
    this.name,
    this.symbol,
    this.decimals,
    this.logoURI,
    this.description,
    this.totalSupply,
  });

  @override
  List<Object?> get props => [
        id,
      ];

  factory TokenMetadata.fromJson(Map<String, dynamic> json) {
    return TokenMetadata(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      decimals: json['decimals'],
      logoURI: json['logoURI'],
      description: json['description'],
      totalSupply: json['totalSupply'] != null
          ? BigInt.tryParse(
              json['totalSupply'],
            )
          : null,
    );
  }

  factory TokenMetadata.fromDB(Map<String, dynamic> json) {
    return TokenMetadata(
      id: json['tokenId'],
      name: json['name'],
      symbol: json['symbol'],
      decimals: int.tryParse("${json['decimals']}"),
      logoURI: json['logoURI'],
      description: json['description'],
      totalSupply: json['totalSupply'] != null
          ? BigInt.tryParse(
              json['totalSupply'],
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'decimals': decimals,
      'logoURI': logoURI,
      'description': description,
      'totalSupply': totalSupply?.toString(),
    };
  }

  Map<String, dynamic> toDB() {
    return {
      'tokenId': id,
      'name': name,
      'symbol': symbol,
      'decimals': decimals?.toString(),
      'logoURI': logoURI,
      'description': description,
      'totalSupply': totalSupply?.toString(),
      'type': "token",
    };
  }

  TokenMetadata copyWith({
    String? id,
    String? name,
    String? symbol,
    int? decimals,
    String? logoURI,
    String? description,
    BigInt? totalSupply,
  }) {
    return TokenMetadata(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      logoURI: logoURI ?? this.logoURI,
      description: description ?? this.description,
      totalSupply: totalSupply ?? this.totalSupply,
    );
  }
}
