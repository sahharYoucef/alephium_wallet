import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/format.dart';

class TransactionSuccessDialog extends StatelessWidget {
  final TransactionStore transaction;
  final String? amount;
  const TransactionSuccessDialog(
      {Key? key, required this.transaction, this.amount})
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
                ),
                if (amount != null) ...[
                  const Divider(),
                  Row(
                    children: [
                      Text(
                        "amount".tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Spacer(),
                      Text(
                        "${amount}",
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ],
                  ),
                ],
                if (transaction.tokens.isNotEmpty) ...[
                  const Divider(),
                  for (final token in transaction.tokens)
                    Row(
                      children: [
                        Text(
                          "${token.name ?? 'Unknown Token'.tr()}".tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Spacer(),
                        Text(
                          "${Format.humanReadableNumber(token.formattedAmount)}",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                ],
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
                            fontSize: 20.sp, fontWeight: FontWeight.w900),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AddressText(
                              address: "${ref.address}",
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
                            if (ref.tokens != null)
                              ...ref.tokens!.map(
                                (token) => Text(
                                  "${Format.humanReadableNumber(token.formattedAmount)} ${token.symbol ?? 'Unknown Token'.tr()}"
                                      .tr(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
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
                      transaction.gasAmount.toString(),
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
                      "${transaction.gasPrice}",
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
