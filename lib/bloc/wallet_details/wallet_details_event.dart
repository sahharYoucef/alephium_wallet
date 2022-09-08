part of 'wallet_details_bloc.dart';

abstract class WalletDetailsEvent extends Equatable {
  const WalletDetailsEvent();

  @override
  List<Object> get props => [];
}

class WalletDetailsLoadData extends WalletDetailsEvent {
  WalletDetailsLoadData();
  @override
  List<Object> get props => [DateTime.now()];
}

class AddPendingTxs extends WalletDetailsEvent {
  final List<TransactionStore> transactions;

  AddPendingTxs(this.transactions);

  @override
  List<Object> get props => [transactions];
}

class WalletDetailsRefreshData extends WalletDetailsEvent {
  WalletDetailsRefreshData();

  @override
  List<Object> get props => [DateTime.now()];
}

class GenerateNewAddress extends WalletDetailsEvent {
  final bool isMain;
  final String? title;
  final String? color;
  final int group;
  GenerateNewAddress(
      {required this.isMain, this.title, this.color, required this.group});

  @override
  List<Object> get props => [DateTime.now()];
}

class GenerateOneAddressPerGroup extends WalletDetailsEvent {
  final String? title;
  final String? color;
  GenerateOneAddressPerGroup({
    this.title,
    this.color,
  });

  @override
  List<Object> get props => [DateTime.now()];
}

class UpdateWalletName extends WalletDetailsEvent {
  final String name;

  UpdateWalletName(this.name);

  @override
  List<Object> get props => [name];
}
