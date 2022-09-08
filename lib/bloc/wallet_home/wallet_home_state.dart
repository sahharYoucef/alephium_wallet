part of 'wallet_home_bloc.dart';

abstract class WalletHomeState {
  const WalletHomeState();
}

class WalletHomeInitial extends WalletHomeState {}

class WalletHomeCompleted extends WalletHomeState {
  final List<WalletStore> wallets;
  final bool withLoadingIndicator;
  WalletHomeCompleted({
    required this.wallets,
    this.withLoadingIndicator = false,
  });
}

class WalletHomeLoading extends WalletHomeState {
  WalletHomeLoading();
}

class WalletHomeError extends WalletHomeState {
  final String? message;
  WalletHomeError({this.message});
}
