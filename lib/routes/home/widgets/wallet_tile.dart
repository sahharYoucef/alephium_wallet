import 'package:alephium_wallet/routes/receive/receive_route.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/gradient_stadium_border.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants.dart';

class WalletTile extends StatelessWidget {
  final WalletStore? wallet;
  final bool loading;
  WalletTile({Key? key, this.wallet, this.loading = false}) : super(key: key) {
    if (!loading) assert(this.wallet != null, "wallet must not be null");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Theme.of(context).primaryColor,
        elevation: 1,
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
                    GradientIcon(
                      icon: Icons.account_balance_wallet_outlined,
                      size: 40,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (loading)
                          Shimmer.fromColors(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white,
                            child: Text(
                              "Alephium wallet",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          )
                        else
                          Text(
                            wallet!.title.isEmpty
                                ? "Alephium wallet"
                                : wallet!.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        if (loading)
                          Shimmer.fromColors(
                            baseColor: Colors.grey,
                            highlightColor: Colors.white,
                            child: SizedBox(
                              width: 100,
                              height: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.fontSize,
                            ),
                          )
                        else
                          RichText(
                              text: TextSpan(children: [
                            TextSpan(
                                text: "${wallet!.balance}",
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            if (wallet!.balanceConverted != null &&
                                wallet!.balanceConverted != "0.000") ...[
                              TextSpan(
                                text: " = ",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              TextSpan(
                                  text: "${wallet!.balanceConverted}",
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
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
                  onPressed: loading
                      ? null
                      : () {
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
                      onPressed: loading
                          ? null
                          : () {
                              Navigator.pushNamed(context, Routes.send,
                                  arguments: {
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
                      onPressed: loading
                          ? null
                          : () {
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
                                        color: WalletTheme.instance.secondary,
                                        borderRadius: BorderRadius.circular(
                                          16,
                                        ),
                                        elevation: 6,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: ReceivePage(
                                            wallet: wallet!,
                                          ),
                                        )),
                                  ),
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                                transitionBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
