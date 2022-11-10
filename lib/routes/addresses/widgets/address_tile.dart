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
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    IconButton(
                        onPressed: () async {
                          var data = ClipboardData(text: address.address);
                          await Clipboard.setData(data);
                          context.showSnackBar("addressCopied".tr());
                        },
                        icon: Icon(Icons.copy))
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
