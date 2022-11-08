import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BalanceTile extends StatelessWidget {
  final WalletStore wallet;
  const BalanceTile({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(16.0),
      color: Colors.white,
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${'balance'.tr()} :",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            Align(
              alignment: Alignment.center,
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(
                  text: "${wallet.balance}",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (wallet.balanceConverted != null &&
                    wallet.balanceConverted != "0.000") ...[
                  TextSpan(
                    text: " = ",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: "${wallet.balanceConverted}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ]
              ])),
            ),
            if (wallet.lockedBalance != 0.00) ...[
              SizedBox(
                height: 20,
              ),
              Text(
                '${'lockedBalance'.tr()} :',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(),
              Align(
                alignment: Alignment.center,
                child: RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: "${wallet.lockedBalanceConverted}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: " = ",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  TextSpan(
                    text: "${wallet.lockedBalanceConverted}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ])),
              )
            ]
          ],
        ),
      ),
    );
  }
}
