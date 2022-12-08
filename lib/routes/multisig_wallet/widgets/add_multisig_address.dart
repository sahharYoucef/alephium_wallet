import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/utils/gradient_input_border.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddMultisigAddressDialog extends StatelessWidget {
  const AddMultisigAddressDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      minimum:
          EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
      child: Container(
        padding:
            EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
        decoration: BoxDecoration(
            color: WalletTheme.instance.background,
            borderRadius: BorderRadius.circular(
              16,
            )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "addPublicKey".tr(),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(
              height: 6,
            ),
            Divider(),
            const SizedBox(
              height: 6,
            ),
            Text(
              "addPublicKeyDescription".tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(
              height: 12,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: Material(
                    color: WalletTheme.instance.primary,
                    shape: GradientOutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            WalletTheme.instance.gradientOne,
                            WalletTheme.instance.gradientTwo,
                          ],
                        )),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        var text = await Clipboard.getData("text/plain");
                        Navigator.pop(context, text?.text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Spacer(),
                            Icon(Icons.paste),
                            const Spacer(),
                            Text(
                              "clipboardIconMsg".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14.sp),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Material(
                    color: WalletTheme.instance.primary,
                    shape: GradientOutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            WalletTheme.instance.gradientOne,
                            WalletTheme.instance.gradientTwo,
                          ],
                        )),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        var data = await showQRView(
                          context,
                          isTransfer: false,
                        );
                        String? address;
                        if (data?["address"] != null &&
                            data!["address"] is String &&
                            data["address"].trim().isNotEmpty) {
                          address = data["address"];
                        }
                        Navigator.pop<String>(context, address);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Icon(Icons.qr_code_scanner),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "QrIconMsg".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14.sp),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Material(
                    color: context.read<WalletHomeBloc>().wallets.length == 0
                        ? Theme.of(context).disabledColor
                        : WalletTheme.instance.primary,
                    shape: GradientOutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            WalletTheme.instance.gradientOne,
                            WalletTheme.instance.gradientTwo,
                          ],
                        )),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: context.read<WalletHomeBloc>().wallets.length == 0
                          ? null
                          : () async {
                              final wallet = await showChooseWalletDialog(
                                context,
                                title: "alephiumWallet".tr(),
                                content: "selectKeyDialogMessage".tr(),
                              );
                              if (wallet == null) {
                                return;
                              }
                              final address = await Navigator.pushNamed<String>(
                                  context, Routes.addresses,
                                  arguments: {"wallet": wallet});
                              Navigator.pop<String>(context, address);
                            },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Icon(Icons.check_box_outline_blank_sharp),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "selectKeyIconMsg".tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(fontSize: 14.sp),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
