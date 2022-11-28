import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BalanceTile extends StatelessWidget {
  final WalletStore wallet;
  const BalanceTile({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PhysicalModel(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        elevation: 1,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: WalletTheme.instance.maxWidth,
          ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${wallet.balance} ℵ",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ).obscure("ℵ"),
                    if (wallet.balanceConverted != null &&
                        wallet.balanceConverted != "0.000") ...[
                      Text(
                        " = ",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        "${wallet.balanceConverted}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ).obscure(),
                    ]
                  ],
                ),
              ),
              if (wallet.lockedBalance != "0.0") ...[
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
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${wallet.lockedBalance} ℵ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ).obscure("ℵ"),
                        Text(
                          " = ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "${wallet.lockedBalanceConverted}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ).obscure("ℵ"),
                      ]),
                )
              ],
              if (wallet.tokensBalances.isNotEmpty) ...[
                SizedBox(
                  height: 20,
                ),
                Text(
                  '${'tokensBalances'.tr()} :',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Divider(),
                ...wallet.tokensBalances.map((token) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddressText(
                            address: "${token.id}",
                          ),
                          Text(
                            "${token.amount}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ))
              ],
            ],
          ),
        ),
      ),
    );
  }
}
