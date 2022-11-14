import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TransactionSuccessDialog extends StatelessWidget {
  final TransactionStore transaction;
  const TransactionSuccessDialog({Key? key, required this.transaction})
      : super(key: key);

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
                AddressText(
                  address: "${transaction.transactionID}",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              WalletTheme.instance.gradientOne,
                              WalletTheme.instance.gradientTwo,
                            ],
                          ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                      ),
                ),
                const Divider(),
                Row(
                  children: [
                    Text(
                      "amount".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Spacer(),
                    Text(
                      "${transaction.txAmount}",
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
                      "timestamp".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      DateTime.fromMillisecondsSinceEpoch(transaction.timeStamp)
                          .toIso8601String(),
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  "outgoingAmounts".tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ...transaction.refsOut.map(
                  (ref) => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "\u2022  ",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AddressText(
                              address: "${ref.address}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.w600,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        begin: Alignment.topRight,
                                        end: Alignment.bottomLeft,
                                        colors: [
                                          WalletTheme.instance.gradientOne,
                                          WalletTheme.instance.gradientTwo,
                                        ],
                                      ).createShader(
                                          Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  ),
                            ),
                            Text(
                              "${ref.txAmount}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                      transaction.fee,
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
                      "${transaction.transactionGas}",
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
