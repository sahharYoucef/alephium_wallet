import 'package:alephium_wallet/routes/addresses/widgets/address_qr_view.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/gradient_icon.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/utils/gradient_input_border.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        address.title?.capitalize ?? "",
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
                    if (address.group != null)
                      Text(
                        "${'group'.tr()} : ${address.group.toString()}",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                  ],
                ),
                const Divider(),
                if (address.balance != null)
                  Row(children: [
                    Text("${'balance'.tr()} : ",
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text("${address.formattedBalance} ℵ",
                            style: Theme.of(context).textTheme.headlineSmall)
                        .obscure("ℵ"),
                    if (address.balanceConverted != null &&
                        address.balance?.balance != "0.0000") ...[
                      Text(" = ",
                          style: Theme.of(context).textTheme.bodyMedium),
                      Text("${address.balanceConverted}  ",
                              style: Theme.of(context).textTheme.bodyMedium)
                          .obscure(),
                    ]
                  ]),
                Row(
                  children: [
                    Expanded(
                      child: AddressText(
                        address: address.address,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                        tooltip: "copy".tr(),
                        onPressed: () async {
                          showModalBottomSheet(
                            isDismissible: true,
                            context: context,
                            backgroundColor: Colors.transparent,
                            builder: (
                              context,
                            ) =>
                                SafeArea(
                              bottom: true,
                              minimum: EdgeInsets.only(
                                  left: 16.w,
                                  right: 16.w,
                                  top: 16.h,
                                  bottom: 16.h),
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
