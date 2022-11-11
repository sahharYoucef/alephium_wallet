import 'dart:convert';
import 'dart:io';

import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerView extends StatefulWidget {
  const QRScannerView({Key? key}) : super(key: key);

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isClosed = true;

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
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
          if (scanData.code is String) {
            data["address"] = scanData.code;
            data["Type"] = "ALEPHIUM";
          } else {
            data = json.decode(scanData.code!) as Map<String, dynamic>;
          }
          if (data["Type"] == "ALEPHIUM") {
            controller.pauseCamera();
            Navigator.pop<Map<String, dynamic>>(context, data);
            return;
          }
          isClosed = true;
        } catch (e) {
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
    controller!.pauseCamera();
    controller?.dispose();
    super.dispose();
  }
}
