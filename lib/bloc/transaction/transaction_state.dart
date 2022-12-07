part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {}

class TransactionStatusState extends TransactionState {
  final BuildTransactionResult? transaction;
  final bool isFinished;
  final double? amount;
  final String? toAddress;
  final String? fromAddress;
  final List<TokenStore>? tokens;

  const TransactionStatusState({
    this.fromAddress,
    this.transaction,
    this.isFinished = false,
    this.amount,
    this.toAddress,
    this.tokens,
  });

  @override
  List<Object?> get props => [
        fromAddress,
        transaction?.txId,
        transaction?.unsignedTx,
        isFinished,
        toAddress,
        amount,
        tokens,
        if (tokens != null) ...tokens!.map((e) => e.amount),
      ];
}

class TransactionSendingCompleted extends TransactionState {
  final List<TransactionStore> transactions;

  const TransactionSendingCompleted({required this.transactions});

  @override
  List<Object?> get props => [
        this.transactions,
      ];
}

class WaitForOtherSignatureState extends TransactionState {
  final String txId;
  final List<String> addresses;

  const WaitForOtherSignatureState({
    required this.addresses,
    required this.txId,
  });

  @override
  List<Object?> get props => [
        this.addresses,
        this.txId,
      ];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError({required this.message});
  @override
  List<Object?> get props => [message];
}

class TransactionSingingCompleted extends TransactionState {
  final String signature;
  const TransactionSingingCompleted({required this.signature});
  @override
  List<Object?> get props => [signature];
}
