import 'package:alephium_wallet/routes/receive/receive_route.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';

class WalletTile extends StatelessWidget {
  final WalletStore wallet;
  const WalletTile({Key? key, required this.wallet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Theme.of(context).primaryColor,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        child: InkWell(
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 40,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            wallet.title.isEmpty
                                ? "Alephium wallet"
                                : wallet.title,
                            style: Theme.of(context).textTheme.headlineSmall),
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: "${wallet.balance}",
                              style: Theme.of(context).textTheme.headlineSmall),
                          if (wallet.balanceConverted != null &&
                              wallet.balanceConverted != "0.000") ...[
                            TextSpan(
                              text: " = ",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextSpan(
                                text: "${wallet.balanceConverted}",
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]
                        ]))
                      ],
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                OutlinedButton(
                  child: Text("Details"),
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
                    Expanded(
                        child: OutlinedButton(
                      child: Text("Send"),
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.send, arguments: {
                          "wallet": wallet,
                        });
                      },
                    )),
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                        child: OutlinedButton(
                      child: Text("Receive"),
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
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                  elevation: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: ReceivePage(
                                      wallet: wallet,
                                    ),
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
