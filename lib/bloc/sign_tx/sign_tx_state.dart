part of 'sign_tx_bloc.dart';

abstract class SignTxState extends Equatable {
  const SignTxState();

  @override
  List<Object?> get props => [];
}

class SignTxUpdateStatus extends SignTxState {
  final String? txId;
  final String? unsignedTx;
  final AddressStore? address;
  final WalletStore? walletStore;
  final bool reset;

  SignTxUpdateStatus({
    this.txId,
    this.unsignedTx,
    this.address,
    this.walletStore,
    this.reset = false,
  });
  @override
  List<Object?> get props => [
        txId,
        unsignedTx,
        address,
        reset,
        walletStore,
      ];
}

class SignTxLoading extends SignTxState {}

class SignTxError extends SignTxState {
  final String message;
  const SignTxError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SignTxCompleted extends SignTxState {
  final String signature;
  const SignTxCompleted({required this.signature});
  @override
  List<Object?> get props => [signature];
}

class TxIdVerifyCompleted extends SignTxState {
  final String unsignedTx;
  final DecodeUnsignedTxResult tx;
  const TxIdVerifyCompleted({
    required this.unsignedTx,
    required this.tx,
  });
  @override
  List<Object?> get props => [unsignedTx];
}
