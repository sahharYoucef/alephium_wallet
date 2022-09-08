import 'package:alephium_dart/alephium_dart.dart' as alephium;

class BalanceDto<T> {
  int? balance;
  int? lockedBalance;
  Blockchain type;

  BalanceDto({this.balance, this.lockedBalance, required this.type});

  factory BalanceDto.fromAlephium(T model) {
    assert(model != null);
    model as alephium.Balance;
    return BalanceDto(
      type: Blockchain.Alephium,
      balance: int.tryParse('${model.balance}'),
      lockedBalance: int.tryParse('${model.lockedBalance}'),
    );
  }
}

enum Blockchain {
  Alephium("alephium");

  final String name;
  const Blockchain(this.name);
}
