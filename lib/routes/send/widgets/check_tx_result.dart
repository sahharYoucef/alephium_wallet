import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/format.dart';

class CheckTransactionResult extends StatelessWidget {
  final TransactionBloc bloc;
  const CheckTransactionResult({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: WalletTheme.instance.secondary,
        border: Border.all(
          color: WalletTheme.instance.primary,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  "${'toAddress'.tr().capitalize} : ",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "${bloc.toAddress}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
              SizedBox(
                height: 2,
              ),
              Row(children: [
                Text(
                  "${'expectedFees'.tr()}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Text(
                  "${bloc.expectedFees}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ]),
              SizedBox(
                height: 2,
              ),
              if (bloc.amount != null)
                Row(children: [
                  Text(
                    "${'amountToSend'.tr()}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  Text(
                    "${bloc.formattedAmount}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ]),
              SizedBox(
                height: 2,
              ),
              if (bloc.tokens.isNotEmpty)
                ...bloc.tokens
                    .map((e) => [
                          Row(children: [
                            Text(
                              "${e.name ?? 'token'.tr()}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "${Format.humanReadableNumber(e.formattedBalance)}",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ]),
                          const SizedBox(
                            height: 2,
                          ),
                        ])
                    .reduce((value, element) => value..addAll(element)),
            ],
          ),
          Positioned(
              top: -16.h,
              right: -16.w,
              child: IconButton(
                iconSize: 20,
                icon: GradientIcon(
                  icon: Icons.close,
                  size: 20,
                ),
                onPressed: () {
                  bloc.add(TransactionValuesChangedEvent(
                      fromAddress: bloc.fromAddress));
                },
              )),
        ],
      ),
    );
  }
}
