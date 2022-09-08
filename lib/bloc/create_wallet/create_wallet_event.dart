part of 'create_wallet_bloc.dart';

abstract class CreateWalletEvent extends Equatable {
  const CreateWalletEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalletGenerateMnemonic extends CreateWalletEvent {
  final String passphrase;

  CreateWalletGenerateMnemonic({
    required this.passphrase,
  });

  @override
  List<Object?> get props => [passphrase];
}

class SaveWalletToDatabase extends CreateWalletEvent {
  final WalletStore wallet;
  SaveWalletToDatabase({
    required this.wallet,
  });

  @override
  List<Object?> get props => [wallet.mnemonic, wallet.addresses];
}

class CreateWalletRestore extends CreateWalletEvent {
  final String mnemonic;
  CreateWalletRestore({
    required this.mnemonic,
  });

  @override
  List<Object?> get props => [
        mnemonic,
        DateTime.now(),
      ];
}
