import 'package:alephium_wallet/routes/home/widgets/token_icon.dart';
import 'package:alephium_wallet/routes/receive/receive_route.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/format.dart';
import '../../constants.dart';
import '../../send/widgets/token_details.dart';

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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        child: Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          child: Padding(
            padding: EdgeInsets.all(16.0).w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wallet.title == null
                                      ? "alephiumWallet".tr()
                                      : wallet.title!.capitalize,
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text("${wallet.balance} ℵ",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium)
                                          .obscure("ℵ"),
                                      if (wallet.balanceConverted != null &&
                                          wallet.balanceConverted !=
                                              "0.000") ...[
                                        Text(
                                          " = ",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        Expanded(
                                          child: Text(
                                                  "${wallet.balanceConverted}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium)
                                              .obscure(),
                                        ),
                                      ],
                                    ]),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
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
                      const Divider(),
                      ...wallet.tokensBalances
                          .mapIndexed((index, e) => Container(
                                padding: const EdgeInsets.only(bottom: 6),
                                width: double.maxFinite,
                                child: InkWell(
                                  onTap: () =>
                                      TokenDetails.show(context, tokenStore: e),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text("\u{2022}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text("${Format.humanReadableNumber(e.formattedAmount)}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineMedium)
                                            .obscure(),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Text(
                                            e.symbol ?? "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ).obscure(),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        TokenIcon(
                                          tokenStore: e,
                                        ),
                                      ]),
                                ),
                              ))
                          .toList()
                    ],
                  ),
                ),
                SizedBox(
                  height: 10.h,
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
                SizedBox(
                  height: 4.h,
                ),
                Row(
                  children: [
                    if (wallet.type != WalletType.readOnly) ...[
                      Expanded(
                          child: OutlinedButton.icon(
                        icon: Icon(Icons.call_made),
                        label: Text("send".tr()),
                        onPressed: () {
                          Navigator.pushNamed(context, Routes.send, arguments: {
                            "wallet": wallet,
                          });
                        },
                      )),
                      SizedBox(
                        width: 16.w,
                      ),
                    ],
                    Expanded(
                        child: OutlinedButton.icon(
                      icon: Icon(Icons.call_received),
                      label: Text("receive".tr()),
                      onPressed: () {
                        showGeneralDialog(
                          barrierDismissible: true,
                          barrierLabel: "receive",
                          context: context,
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  Padding(
                            padding: EdgeInsets.only(
                                top: 16.h,
                                bottom: 16.h + context.viewInsetsBottom,
                                left: 16.w,
                                right: 16.w),
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
                          transitionDuration: const Duration(milliseconds: 200),
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
