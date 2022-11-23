import 'package:alephium_dart/alephium_dart.dart' as alephium;
import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';

mixin InputValidators {
  WalletStore get wallet;
  TransactionBloc get bloc;

  String? tokenAmountValidator(TokenStore token, value) {
    var amountNumber = double.tryParse(value!);
    if (amountNumber == null) {
      return "Please enter a valid amount!";
    }
    var balance = token.amount?.toDouble() ?? 0;
    if (amountNumber == 0) {
      return "amountIsZero".tr(args: ["0"]);
    }
    if (amountNumber > balance) {
      return "amountExceeded".tr(args: [balance.toString()]);
    }
    return null;
  }

  String? addressToValidator(value) {
    var validator = RegExp(r'^[1-9A-HJ-NP-Za-km-z]+$');
    if (!validator.hasMatch(value!)) {
      return 'invalidAddress'.tr();
    }
    return null;
  }

  String? amountValidator(value) {
    var amountNumber = double.tryParse(value!);
    var balance = wallet.addresses
            .firstWhereOrNull((element) => element == bloc.fromAddress)
            ?.balance
            ?.balance
            ?.toDouble() ??
        0;
    balance = balance / 10e17;
    if (amountNumber == null) {
      return "invalidAmount".tr();
    }
    if (balance == 0) {
      return "balanceIsZero".tr(args: [balance.toString()]);
    }
    if (amountNumber == 0) {
      return "amountIsZero".tr(args: ["0"]);
    }
    if (amountNumber > balance) {
      return "amountExceeded".tr(args: [balance.toString()]);
    }
    return null;
  }

  String? gasPriceValidator(value) {
    var amountNumber = double.tryParse(value!) ?? 0;
    if (amountNumber == 0) {
      return null;
    }
    if ((amountNumber * 10e17) < alephium.minimalGasPrice) {
      final minimalGasPrice =
          (alephium.minimalGasPrice / 10e17).toStringAsFixed(7);
      return 'gasPriceExceeded'.tr(args: [minimalGasPrice]);
    }
    return null;
  }

  String? gasAmountValidator(value) {
    var amountNumber = double.tryParse(value!) ?? 0;
    if (amountNumber == 0) {
      return null;
    }
    if (amountNumber < alephium.minimalGasAmount) {
      final minimalGasAmount = alephium.minimalGasAmount.toString();
      return 'minimalGasAmount'.tr(args: [minimalGasAmount]);
    }
    return null;
  }
}
