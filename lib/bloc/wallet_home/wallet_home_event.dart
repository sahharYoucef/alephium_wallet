part of 'wallet_home_bloc.dart';

abstract class WalletHomeEvent extends Equatable {
  const WalletHomeEvent();

  @override
  List<Object> get props => [];
}

class WalletHomeLoadData extends WalletHomeEvent {
  WalletHomeLoadData();
  @override
  List<Object> get props => [DateTime.now()];
}

class WalletHomeRefreshData extends WalletHomeEvent {
  WalletHomeRefreshData();
  @override
  List<Object> get props => [DateTime.now().microsecondsSinceEpoch];
}

class HomeUpdateWalletDetails extends WalletHomeEvent {
  final WalletStore walletStore;
  HomeUpdateWalletDetails(
    this.walletStore,
  );

  @override
  List<Object> get props =>
      [walletStore, DateTime.now().millisecondsSinceEpoch];
}

class WalletHomeRemoveWallet extends WalletHomeEvent {
  final String id;
  WalletHomeRemoveWallet(
    this.id,
  );

  @override
  List<Object> get props => [id];
}
