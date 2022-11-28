import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CheckTransactionResult extends StatelessWidget {
  final TransactionBloc bloc;
  const CheckTransactionResult({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: WalletTheme.instance.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "${'toAddress'.tr().capitalize} : ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "${bloc.toAddress}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ])),
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "${'expectedFees'.tr()} : ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "${bloc.expectedFees}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ])),
                const SizedBox(
                  height: 4,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "${'amountToSend'.tr()} : ",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: "${bloc.formattedAmount}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ])),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
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
