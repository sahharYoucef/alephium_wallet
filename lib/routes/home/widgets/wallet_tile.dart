import 'package:alephium_wallet/routes/receive/receive_route.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants.dart';

class WalletTile extends StatelessWidget {
  final WalletStore wallet;
  WalletTile({
    Key? key,
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: WalletTheme.instance.maxWidth,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wallet.title == null
                                ? "alephiumWallet".tr()
                                : wallet.title!,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text("${wallet.balance} ℵ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium)
                                    .obscure("ℵ"),
                                if (wallet.balanceConverted != null &&
                                    wallet.balanceConverted != "0.000") ...[
                                  Text(
                                    " = ",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text("${wallet.balanceConverted}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium)
                                      .obscure(),
                                ]
                              ])
                        ],
                      ),
                    ),
                    const Spacer(),
                    GradientIcon(
                      icon: wallet.type == WalletType.normal
                          ? Icons.account_balance_wallet_outlined
                          : wallet.type == WalletType.multisig
                              ? Icons.multiple_stop_outlined
                              : Icons.lock,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                  child: Text("details".tr()),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      Routes.wallet,
                      arguments: {"wallet": wallet},
                    );
                  },
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    if (wallet.type != WalletType.readOnly) ...[
                      Expanded(
                          child: OutlinedButton(
                        child: Text("send".tr()),
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.send, arguments: {
                            "wallet": wallet,
                          });
                        },
                      )),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                    Expanded(
                        child: OutlinedButton(
                      child: Text("receive".tr()),
                      onPressed: () {
                        showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: "receive",
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Padding(
                            padding: EdgeInsets.only(
                                top: 16,
                                bottom: 16 + context.viewInsetsBottom,
                                left: 16,
                                right: 16),
                            child: Center(
                              child: Material(
                                  color: WalletTheme.instance.background,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                  elevation: 6,
                                  child: ReceivePage(
                                    wallet: wallet,
                                  )),
                            ),
                          ),
                          transitionDuration: const Duration(milliseconds: 300),
                          transitionBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween<Offset>(
                                  begin: Offset(0, 1),
                                  end: Offset.zero,
                                ),
                              ),
                              child: child,
                            );
                          },
                        );
                      },
                    ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
