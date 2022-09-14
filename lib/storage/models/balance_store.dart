import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/utils/helpers.dart';

class BalanceStore {
  final double balance;
  final double balanceHint;
  final double lockedBalance;
  final String address;
  final Network network;

  BalanceStore({
    required this.balance,
    required this.balanceHint,
    required this.lockedBalance,
    required this.address,
    required this.network,
  });

  factory BalanceStore.fromDb(Map<String, dynamic> data) {
    final _address = data["address_id"] as String;
    final _balance = data["address_balance"];
    final _balanceHint = data["balance_hint"];
    final _lockedBalance = data["balance_locked"];
    final _network = Network.network(data["network"]);
    return BalanceStore(
      address: _address,
      balanceHint: _balanceHint,
      balance: _balance,
      lockedBalance: _lockedBalance,
      network: _network,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      "balance_id": "${network.name}${address}",
      "address_id": address,
      "address_balance": balance,
      "balance_hint": balanceHint,
      "balance_locked": lockedBalance,
      "network": network.name,
    };
  }
}
