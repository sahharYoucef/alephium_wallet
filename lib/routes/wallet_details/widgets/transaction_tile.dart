import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/utils/helpers.dart';

import '../../../utils/format.dart';
import '../../send/widgets/token_details.dart';
import 'address_text.dart';

class TransactionTile extends StatelessWidget {
  final TransactionStore transaction;
  const TransactionTile({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = transaction.type;
    final date = DateTime.fromMillisecondsSinceEpoch(transaction.timeStamp);
    final status = transaction.status == TXStatus.completed;
    final languageCode = EasyLocalization.of(context)?.locale.languageCode;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: WalletTheme.instance.maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Material(
            color: Theme.of(context).primaryColor,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.transactionDetails,
                  arguments: {
                    "transaction": transaction,
                  },
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Row(
                            children: [
                              !status
                                  ? SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: AlephiumIcon(
                                        spinning: true,
                                      ),
                                    )
                                  : GradientIcon(
                                      size: 16, icon: Icons.check_circle),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                status ? "confirmed".tr() : "pending".tr(),
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
                        Spacer(),
                        Text(
                          timeAgo.format(
                            date,
                            locale: languageCode,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (transaction.amount != "0.000 ℵ") ...[
                                    Text('amount'.tr(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: WalletTheme
                                                  .instance.textColor
                                                  .withOpacity(.6),
                                            )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: WalletTheme.instance.background,
                                      ),
                                      child: Text(
                                        '${transaction.amount}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w600),
                                      ).obscure("ℵ"),
                                    ),
                                    Spacer(),
                                  ],
                                  if (type == TransactionType.withdraw) ...[
                                    Text('fee'.tr(),
                                        maxLines: 1,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                              color: WalletTheme
                                                  .instance.textColor
                                                  .withOpacity(.6),
                                              overflow: TextOverflow.ellipsis,
                                            )),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: WalletTheme.instance.background,
                                      ),
                                      child: Text(
                                        '${transaction.fee}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w600),
                                      ).obscure("ℵ"),
                                    ),
                                  ]
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (transaction.tokens.isNotEmpty) ...[
                                for (final token in transaction.tokens) ...[
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          TokenDetails.show(context,
                                              tokenStore: token);
                                        },
                                        child: Text(
                                            "${token.name ?? token.symbol ?? 'Unknown Token'.tr()}"
                                                .tr(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  color: WalletTheme
                                                      .instance.textColor
                                                      .withOpacity(.6),
                                                )),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color:
                                              WalletTheme.instance.background,
                                        ),
                                        child: Text(
                                          '${Format.humanReadableNumber(token.formattedAmount)}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(
                                                  fontWeight: FontWeight.w600),
                                        ).obscure(),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ]
                              ],
                              if (transaction.tokens.isEmpty)
                                const SizedBox(
                                  height: 10,
                                ),
                              AddressText(
                                address: '${transaction.address}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GradientIcon(
                            icon: type == TransactionType.withdraw
                                ? Icons.arrow_upward
                                : Icons.arrow_downward),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
