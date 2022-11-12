part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionLoading extends TransactionState {}

class TransactionStatusState extends TransactionState {
  final TransactionBuildDto? transaction;
  final bool isFinished;
  final String? amount;
  final List<String> toAddresses;
  final String? fromAddress;

  const TransactionStatusState({
    this.fromAddress,
    this.transaction,
    this.isFinished = false,
    this.amount,
    required this.toAddresses,
  });

  @override
  List<Object?> get props => [
        fromAddress,
        transaction?.txId,
        transaction?.unsignedTx,
        isFinished,
        toAddresses,
        amount,
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

class TransactionError extends TransactionState {
  final String message;
  const TransactionError({required this.message});
  @override
  List<Object?> get props => [message];
}
