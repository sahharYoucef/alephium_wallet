part of 'wallet_details_bloc.dart';

abstract class WalletDetailsState {
  const WalletDetailsState();
}

class WalletDetailsInitial extends WalletDetailsState {}

class WalletDetailsLoading extends WalletDetailsState {}

class WalletDetailsCompleted extends WalletDetailsState {
  final List<TransactionStore>? transactions;
  final bool withLoadingIndicator;
  final WalletStore? wallet;
  WalletDetailsCompleted({
    this.transactions = const [],
    this.withLoadingIndicator = false,
    this.wallet,
  });
}

class WalletDetailsError extends WalletDetailsState {
  final String? message;
  WalletDetailsError({this.message = "Something went wrong!"});
}
