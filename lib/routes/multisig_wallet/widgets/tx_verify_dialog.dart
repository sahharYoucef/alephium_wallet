import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/routes/transaction_details/widgets/transaction_reference.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/token_store.dart';
import 'package:alephium_wallet/storage/models/transaction_ref_store.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TransactionVerifyDialog extends StatelessWidget {
  final DecodeUnsignedTxResult transaction;
  const TransactionVerifyDialog({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${'transaction'.tr()} id",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(
                  height: 6,
                ),
                if (transaction.unsignedTx?.txId != null)
                  AddressText(
                    address: "${transaction.unsignedTx?.txId}",
                  ),
                const Divider(),
                Text(
                  "outgoingAmounts".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                TransactionReferences(
                  refs: transaction.unsignedTx?.fixedOutputs
                          ?.map((e) => TransactionRefStore(
                              hint: e.hint,
                              key: e.key,
                              address: e.address,
                              amount: e.attoAlphAmount,
                              tokens: e.tokens
                                  ?.map((e) =>
                                      TokenStore(id: e.id, amount: e.amount))
                                  .toList()))
                          .toList() ??
                      <TransactionRefStore>[],
                ),
                const Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "gasAmount".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "${transaction.unsignedTx?.gasAmount}",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "gasPrice".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      "${transaction.unsignedTx?.gasPrice}",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
