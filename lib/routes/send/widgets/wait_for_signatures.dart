import 'dart:convert';

import 'package:alephium_wallet/bloc/transaction/transaction_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:collection/collection.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';

class WaitForOtherSignatures extends StatefulWidget {
  final String txId;
  final List<String> addresses;
  final WalletStore wallet;
  final TransactionBloc bloc;
  const WaitForOtherSignatures({
    super.key,
    required this.txId,
    required this.addresses,
    required this.wallet,
    required this.bloc,
  });

  @override
  State<WaitForOtherSignatures> createState() => _WaitForOtherSignaturesState();
}

class _WaitForOtherSignaturesState extends State<WaitForOtherSignatures> {
  late final List<String?> signatures;
  String? signature;
  late final String qrData;

  @override
  void initState() {
    qrData = json.encode({
      "txId": widget.bloc.transaction?.txId,
      "unsignedTx": widget.bloc.transaction?.unsignedTx,
    });
    signatures =
        List.generate(widget.wallet.signatures!.length, (index) => null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final confirmedSignatures =
        signatures.where((element) => element != null).toList().cast<String>();
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        bottom: true,
        minimum:
            EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
        child: Material(
          color: WalletTheme.instance.background,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                left: 16.w, right: 16.w, top: 16.h, bottom: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 6,
                ),
                SizedBox(
                  height: 180,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBarIconButton(
                        tooltip: "QRscanner".tr(),
                        icon: Icon(
                          CupertinoIcons.qrcode_viewfinder,
                        ),
                        onPressed: () async {
                          var data = await showQRView(
                            context,
                            isTransfer: false,
                          );
                          if (data?["address"] != null &&
                              data!["address"] is String &&
                              data["address"].trim().isNotEmpty) {
                            setState(() {
                              final index = signatures
                                  .indexWhere((element) => element == null);
                              if (index == -1)
                                signatures[index] = data["address"];
                              else
                                signatures.last = data["address"];
                            });
                          }
                        },
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: WalletTheme.instance.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: QrImage(
                              data: qrData,
                              backgroundColor: Colors.transparent,
                              foregroundColor: WalletTheme.instance.textColor,
                              version: QrVersions.auto,
                              size: 180.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AppBarIconButton(
                            tooltip: "copy".tr(),
                            icon: Icon(
                              Icons.copy,
                            ),
                            onPressed: () async {
                              var data = ClipboardData(text: qrData);
                              await Clipboard.setData(data);
                              context.showSnackBar(
                                "addressCopied".tr(),
                              );
                            },
                          ),
                          Spacer(),
                          AppBarIconButton(
                            tooltip: "copy".tr(),
                            icon: Icon(
                              CupertinoIcons.signature,
                            ),
                            onPressed: () async {
                              Navigator.pushNamed(
                                context,
                                Routes.signMultisigTx,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...signatures.mapIndexed(
                      (index, e) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 4),
                        child: Material(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "#${index} - ",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Expanded(
                                  child: AddressText(
                                    address: "${widget.addresses[index]}",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: InkWell(
                                      onTap: () async {
                                        if (signatures[index] == null) {
                                          var text = await Clipboard.getData(
                                              "text/plain");
                                          signatures[index] = text?.text;
                                        } else {
                                          signatures[index] = null;
                                        }
                                        setState(() {});
                                      },
                                      child: Icon(
                                        e == null ? Icons.paste : Icons.close,
                                        size: 24,
                                      )),
                                )
                              ],
                            ),
                          ),
                          elevation: 0,
                          shape: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                width: 2.5,
                                color: e == null
                                    ? WalletTheme.instance.errorColor
                                    : Colors.green,
                              )),
                          color: WalletTheme.instance.secondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      "waitRequiredSignature".tr(args: [
                        "${confirmedSignatures.length}",
                        "${widget.wallet.mRequired}"
                      ]),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        child: Text(
                          'cancel'.tr(),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    Expanded(
                      child: OutlinedButton(
                        child: Text(
                          'confirm'.tr(),
                        ),
                        onPressed: confirmedSignatures.length >=
                                widget.wallet.mRequired!
                            ? () {
                                widget.bloc.add(
                                  SendMultisigTransaction(
                                    signatures: confirmedSignatures,
                                    unsignedTx: widget.txId,
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
