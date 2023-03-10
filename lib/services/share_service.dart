import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<XFile> takeScreenShot(GlobalKey qrPreview) async {
    final boundary =
        qrPreview.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 5.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return XFile.fromData(
      byteData!.buffer.asUint8List(),
      mimeType: "png",
      name: "screenshot",
    );
  }

  Future<bool> shareImage(GlobalKey qrPreview) async {
    final file = await takeScreenShot(qrPreview);
    final result = await Share.shareXFiles([file]);
    return result.status == ShareResultStatus.success;
  }
}
