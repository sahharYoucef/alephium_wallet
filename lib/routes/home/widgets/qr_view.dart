import 'dart:convert';
import 'dart:io';

import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/address_text.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatefulWidget {
  final WalletHomeBloc? bloc;
  final bool isTransfer;
  QRScannerView({
    Key? key,
    this.bloc,
    this.isTransfer = false,
  }) : super(key: key) {
    if (isTransfer) assert(bloc != null);
  }

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isClosed = true;
  Map<String, dynamic>? transactionData;

  @override
  Widget build(BuildContext context) {
    if (!widget.isTransfer) {
      return SizedBox(
        width: context.width * .9,
        height: context.height * .6,
        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      );
    } else
      return AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: transactionData == null
            ? SizedBox(
                width: context.width * .9,
                height: context.height * .6,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              )
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: context.height * .6,
                  maxWidth: context.width * .9,
                  minWidth: context.width * .9,
                ),
                child: ListView(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  children: [
                    Text(
                      "${'sendTo'.tr()}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      "${'chooseWallet'.tr()}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Divider(),
                    Text(
                      "address".tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    AddressText(
                      address: transactionData!["address"],
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
                    if (transactionData!["amount"] != null) ...[
                      Divider(),
                      Row(
                        children: [
                          Text(
                            "amount".tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Spacer(),
                          Text(
                            "${transactionData!["amount"]}",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ],
                    Divider(),
                    ...widget.bloc!.wallets
                        .map((wallet) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                    onPressed: () {
                                      transactionData!["wallet"] = wallet;
                                      Navigator.pop<Map<String, dynamic>>(
                                          context, transactionData);
                                    },
                                    child: Row(
                                      children: [
                                        Text(wallet.title.isEmpty
                                            ? "Alephium"
                                            : wallet.title),
                                        Spacer(),
                                        Text("${wallet.balance} ℵ")
                                      ],
                                    )),
                                const SizedBox(
                                  height: 8,
                                )
                              ],
                            ))
                        .toList()
                  ],
                ),
              ),
      );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    await controller.resumeCamera();
    controller.scannedDataStream
        .distinct(((previous, next) => !isClosed))
        .listen((scanData) async {
      if (scanData.code != null) {
        try {
          isClosed = false;
          var data = <String, dynamic>{};
          var scannedData;
          try {
            scannedData = json.decode(scanData.code!);
          } catch (_) {
            scannedData = scanData.code;
          }
          if (scannedData is String) {
            data["address"] = scanData.code;
            data["Type"] = "ALEPHIUM";
          } else {
            data = scannedData;
          }
          if (data["Type"] == "ALEPHIUM") {
            transactionData = data;
            controller.stopCamera();
            if (!widget.isTransfer) {
              Navigator.pop<Map<String, dynamic>>(context, transactionData);
            } else {
              setState(() {});
            }
            return;
          }
          isClosed = true;
        } catch (e, trace) {
          var closedReason = context.showSnackBar(kErrorMessageGenericError,
              level: Level.error);
          isClosed = (await closedReason?.closed != null);
        }
      }
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
