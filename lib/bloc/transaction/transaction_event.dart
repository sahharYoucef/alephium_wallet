part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionValuesChangedEvent extends TransactionEvent {
  final String? toAddress;
  final AddressStore? fromAddress;
  final String? amount;
  final String? gas;
  final String? gasPrice;

  TransactionValuesChangedEvent({
    this.toAddress,
    this.fromAddress,
    this.amount,
    this.gas,
    this.gasPrice,
  });

  @override
  List<Object?> get props => [
        toAddress,
        amount,
        fromAddress,
        gas,
        gasPrice,
      ];
}

class AddTokenTransactionEvent extends TransactionEvent {
  final String id;
  final String amount;
  final int decimals;
  const AddTokenTransactionEvent(
    this.id,
    this.amount,
    this.decimals,
  );

  @override
  List<Object?> get props => [this.id, this.amount];
}

class DeleteTokenTransactionEvent extends TransactionEvent {
  final String id;
  const DeleteTokenTransactionEvent(
    this.id,
  );

  @override
  List<Object?> get props => [this.id];
}

class CheckTransactionEvent extends TransactionEvent {
  final AddressStore? fromAddress;
  const CheckTransactionEvent(this.fromAddress);

  @override
  List<Object?> get props => [
        this.fromAddress,
      ];
}

class CheckSignMultisigTransaction extends TransactionEvent {
  final AddressStore? fromAddress;
  const CheckSignMultisigTransaction(this.fromAddress);

  @override
  List<Object?> get props => [
        this.fromAddress,
      ];
}

class SendMultisigTransaction extends TransactionEvent {
  final List<String> signatures;
  final String unsignedTx;

  SendMultisigTransaction({
    required this.signatures,
    required this.unsignedTx,
  });

  @override
  List<Object?> get props => [
        signatures,
        unsignedTx,
      ];
}

class SignAndSendTransaction extends TransactionEvent {
  final String privateKey;
  final String transactionID;
  final String unsignedTx;

  SignAndSendTransaction({
    required this.privateKey,
    required this.transactionID,
    required this.unsignedTx,
  });

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
