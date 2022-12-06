import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';

class BalanceStore {
  final BigInt? balance;
  final String? balanceHint;
  final BigInt? lockedBalance;
  final String? lockedBalanceHint;
  final String address;
  final NetworkType network;
  final List<TokenStore>? tokens;

  BalanceStore({
    required this.balance,
    required this.balanceHint,
    required this.lockedBalance,
    required this.lockedBalanceHint,
    required this.address,
    required this.network,
    this.tokens,
  });

  factory BalanceStore.fromDb(Map<String, dynamic> data) {
    final _address = data["balanceAddress"] as String;
    final _balance = BigInt.tryParse("${data["balance"]}");
    final _balanceHint = data["balanceHint"];
    final _lockedBalance = BigInt.tryParse("${data["balanceLocked"]}");
    final _lockedBalanceHint = data["balanceLockedHint"];
    final _network = NetworkType.network(data["network"]);
    final _tokens = TokenStore.getTokens(data["tokens"]);
    return BalanceStore(
      address: _address,
      balanceHint: _balanceHint,
      balance: _balance,
      lockedBalance: _lockedBalance,
      lockedBalanceHint: _lockedBalanceHint,
      network: _network,
      tokens: _tokens,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "balanceId": "${network.name}${address}",
      "balanceAddress": address,
      "balance": balance?.toString(),
      "balanceHint": balanceHint,
      "balanceLocked": lockedBalance?.toString(),
      "balanceLockedHint": lockedBalanceHint,
      "tokens": TokenStore.setTokens(tokens),
      "network": network.name,
    };
  }
}
