part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionValuesChangedEvent extends TransactionEvent {
  final List<String>? toAddresses;
  final AddressStore? fromAddress;
  final String? amount;
  final String? gas;
  final String? gasPrice;

  TransactionValuesChangedEvent({
    this.toAddresses,
    this.fromAddress,
    this.amount,
    this.gas,
    this.gasPrice,
  });

  @override
  List<Object?> get props => [
        toAddresses,
        amount,
        fromAddress,
        gas,
        gasPrice,
      ];
}

class CheckTransactionEvent extends TransactionEvent {
  final AddressStore? fromAddress;
  const CheckTransactionEvent(this.fromAddress);

  @override
  List<Object?> get props => [
        this.fromAddress,
      ];
}

class SignAndSendTransaction extends TransactionEvent {
  final String privateKey;
  final String transactionID;
  final String unsignedTx;

  SignAndSendTransaction(
      {required this.privateKey,
      required this.transactionID,
      required this.unsignedTx});

  @override
  List<Object?> get props => [
        privateKey,
        transactionID,
        unsignedTx,
      ];
}

class SweepTransaction extends TransactionEvent {
  final AddressStore fromAddress;
  final AddressStore toAddress;

  SweepTransaction(this.fromAddress, this.toAddress);

  @override
  List<Object?> get props => [
        fromAddress,
        toAddress,
      ];
}
