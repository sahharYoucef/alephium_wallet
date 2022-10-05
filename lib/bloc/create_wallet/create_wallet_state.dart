part of 'create_wallet_bloc.dart';

abstract class CreateWalletState extends Equatable {
  const CreateWalletState();

  @override
  List<Object?> get props => [];
}

class CreateWalletInitial extends CreateWalletState {}

class CreateWalletGenerateMnemonicSuccess extends CreateWalletState {
  final WalletStore wallet;

  CreateWalletGenerateMnemonicSuccess({
    required this.wallet,
  });

  @override
  List<Object?> get props => [wallet.mnemonic];
}

class CreateWalletFailure extends CreateWalletState {
  final String error;
  CreateWalletFailure({
    required this.error,
  });
  @override
  List<Object> get props => [error, DateTime.now()];
}

class SaveWalletToDatabaseSuccess extends CreateWalletState {
  final WalletStore wallet;
  SaveWalletToDatabaseSuccess({
    required this.wallet,
  });
  @override
  List<Object?> get props => [wallet.mnemonic];
}
