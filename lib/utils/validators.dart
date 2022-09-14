import 'package:alephium_dart/alephium_dart.dart' as alephium;
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:collection/collection.dart';

mixin InputValidators {
  WalletStore get wallet;
  TransactionBloc get bloc;
  String? addressToValidator(value) {
    var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
    if (!validator.hasMatch(value!)) {
      return 'Invalid Address';
    }
    return null;
  }

  String? amountValidator(value) {
    var amountNumber = double.tryParse(value!);
    var balance = wallet.addresses
            .firstWhereOrNull((element) => element == bloc.fromAddress)
            ?.balance
            ?.balance ??
        0;
    if (amountNumber == null) {
      return null;
    }
    if (amountNumber == 0) {
      return "Amount must be greater than 0";
    }
    if (amountNumber > balance) {
      return 'Amount must be less than ${balance}';
    }
    return null;
  }

  String? gasPriceValidator(value) {
    var amountNumber = double.tryParse(value!) ?? 0;
    if (amountNumber == 0) {
      return null;
    }
    if ((amountNumber * 10e17) < alephium.MINIMAL_GAS_PRICE) {
      return 'Gas price must be greater than ${(alephium.MINIMAL_GAS_PRICE / 10e17).toStringAsFixed(7)}';
    }
    return null;
  }

  String? gasAmountValidator(value) {
    var amountNumber = double.tryParse(value!) ?? 0;
    if (amountNumber == 0) {
      return null;
    }
    if (amountNumber < alephium.MINIMAL_GAS_AMOUNT) {
      return 'Amount must be greater than ${alephium.MINIMAL_GAS_AMOUNT}';
    }
    return null;
  }
}
