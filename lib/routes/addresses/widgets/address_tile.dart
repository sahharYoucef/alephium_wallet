import 'package:alephium_wallet/routes/addresses/widgets/address_qr_view.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/gradient_input_border.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddressTile extends StatelessWidget {
  final AddressStore address;
  final bool isMain;
  final void Function() onTap;
  const AddressTile(
      {Key? key,
      required this.address,
      required this.isMain,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        elevation: 0,
        color: Theme.of(context).primaryColor,
        shape: GradientOutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(width: 3),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                WalletTheme.instance.gradientOne,
                WalletTheme.instance.gradientTwo,
              ],
            )),
        child: InkWell(
          customBorder:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GradientIcon(icon: isMain ? Icons.star : Icons.circle),
                    Expanded(
                      child: Text(
                        address.title ?? "",
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${'index'.tr()} : ${address.index}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${'group'.tr()} : ${address.group.toString()}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Divider(),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "${'balance'.tr()} : ",
                      style: Theme.of(context).textTheme.headlineSmall),
                  TextSpan(
                      text: "${address.formattedBalance} ℵ",
                      style: Theme.of(context).textTheme.headlineSmall),
                  if (address.balanceConverted != null &&
                      address.balance?.balance != "0.0000") ...[
                    TextSpan(
                        text: " = ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextSpan(
                        text: "${address.balanceConverted}  ",
                        style: Theme.of(context).textTheme.bodyMedium),
                  ]
                ])),
                Row(
                  children: [
                    Expanded(
                      child: AddressText(
                        address: address.address,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                              foreground: Paint()
                                ..shader = LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    WalletTheme.instance.gradientOne,
                                    WalletTheme.instance.gradientTwo,
                                  ],
                                ).createShader(
                                    Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                        tooltip: "copy".tr(),
                        onPressed: () async {
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
                                    child: AddressQRDialog(
                                      addressStore: address,
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
                        icon: GradientIcon(
                          icon: Icons.qr_code,
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
