part of 'sign_tx_bloc.dart';

abstract class SignTxEvent extends Equatable {
  const SignTxEvent();

  @override
  List<Object?> get props => [];
}

class ResetSignTxEvent extends SignTxEvent {
  ResetSignTxEvent();

  @override
  List<Object?> get props => [];
}

class SignMultisigTransaction extends SignTxEvent {
  SignMultisigTransaction();

  @override
  List<Object?> get props => [];
}

class UpdateSignTxDataEvent extends SignTxEvent {
  final String? txId;
  final String? unsignedTx;
  final AddressStore? address;
  final WalletStore? walletStore;

  UpdateSignTxDataEvent({
    this.txId,
    this.unsignedTx,
    this.address,
    this.walletStore,
  });

  @override
  List<Object?> get props => [
        txId,
        unsignedTx,
        address,
        walletStore,
      ];
}

class VerifyMultisigTransaction extends SignTxEvent {
  VerifyMultisigTransaction();

  @override
  List<Object?> get props => [];
}
