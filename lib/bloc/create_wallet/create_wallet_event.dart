part of 'create_wallet_bloc.dart';

abstract class CreateWalletEvent extends Equatable {
  const CreateWalletEvent();

  @override
  List<Object?> get props => [];
}

class CreateWalletMultisigWallet extends CreateWalletEvent {
  final List<String> signatures;
  final int mrequired;
  final String? title;

  CreateWalletMultisigWallet({
    required this.signatures,
    required this.mrequired,
    required this.title,
  });

  @override
  List<Object?> get props => [
        signatures,
        mrequired,
        title,
      ];
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

class AddReadOnlyWallet extends CreateWalletEvent {
  final String value;
  final String? title;
  AddReadOnlyWallet({
    required this.value,
    this.title,
  });

  @override
  List<Object?> get props => [
        value,
        title,
        DateTime.now(),
      ];
}
