import 'dart:math';

import 'package:flutter/material.dart';

//Copy this CustomPainter code to the Bottom of the File
class AlephiumCustomPainter extends CustomPainter {
  final double x;
  final Color color;
  AlephiumCustomPainter(this.x, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    Path path_1 = Path();
    path_1.moveTo(
        size.width / 2.096597 * 0.6988657, size.height / 2.099396 * 1.382401);
    path_1.cubicTo(
        size.width / 2.096597 * 0.6988657,
        size.height / 2.099396 * 1.355225,
        size.width / 2.096597 * 0.6626157,
        size.height / 2.099396 * 1.336936,
        size.width / 2.096597 * 0.6179701,
        size.height / 2.099396 * 1.341581);
    path_1.lineTo(
        size.width / 2.096597 * 0.08089552, size.height / 2.099396 * 1.397476);
    path_1.cubicTo(
        size.width / 2.096597 * 0.03625000,
        size.height / 2.099396 * 1.402123,
        0,
        size.height / 2.099396 * 1.427958,
        0,
        size.height / 2.099396 * 1.455132);
    path_1.lineTo(0, size.height / 2.099396 * 2.053932);
    path_1.cubicTo(
        0,
        size.height / 2.099396 * 2.081106,
        size.width / 2.096597 * 0.03625000,
        size.height / 2.099396 * 2.099396,
        size.width / 2.096597 * 0.08089552,
        size.height / 2.099396 * 2.094749);
    path_1.lineTo(
        size.width / 2.096597 * 0.6179701, size.height / 2.099396 * 2.038855);
    path_1.cubicTo(
        size.width / 2.096597 * 0.6626157,
        size.height / 2.099396 * 2.034209,
        size.width / 2.096597 * 0.6988657,
        size.height / 2.099396 * 2.008374,
        size.width / 2.096597 * 0.6988657,
        size.height / 2.099396 * 1.981198);
    path_1.lineTo(
        size.width / 2.096597 * 0.6988657, size.height / 2.099396 * 1.382401);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = color.withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Path path_3 = Path();
    path_3.moveTo(
        size.width / 2.096597 * 0.7863545, size.height / 2.099396 * 0.1814163);
    path_3.cubicTo(
        size.width / 2.096597 * 0.7656194,
        size.height / 2.099396 * 0.1544581,
        size.width / 2.096597 * 0.7099478,
        size.height / 2.099396 * 0.1366145,
        size.width / 2.096597 * 0.6621119,
        size.height / 2.099396 * 0.1415925);
    path_3.lineTo(
        size.width / 2.096597 * 0.08667537, size.height / 2.099396 * 0.2014802);
    path_3.cubicTo(
        size.width / 2.096597 * 0.03883582,
        size.height / 2.099396 * 0.2064581,
        size.width / 2.096597 * 0.01683582,
        size.height / 2.099396 * 0.2323855,
        size.width / 2.096597 * 0.03757090,
        size.height / 2.099396 * 0.2593436);
    path_3.lineTo(
        size.width / 2.096597 * 1.310243, size.height / 2.099396 * 1.913985);
    path_3.cubicTo(
        size.width / 2.096597 * 1.330978,
        size.height / 2.099396 * 1.940943,
        size.width / 2.096597 * 1.386649,
        size.height / 2.099396 * 1.958789,
        size.width / 2.096597 * 1.434485,
        size.height / 2.099396 * 1.953808);
    path_3.lineTo(
        size.width / 2.096597 * 2.009922, size.height / 2.099396 * 1.893923);
    path_3.cubicTo(
        size.width / 2.096597 * 2.057757,
        size.height / 2.099396 * 1.888945,
        size.width / 2.096597 * 2.079761,
        size.height / 2.099396 * 1.863015,
        size.width / 2.096597 * 2.059026,
        size.height / 2.099396 * 1.836057);
    path_3.lineTo(
        size.width / 2.096597 * 0.7863545, size.height / 2.099396 * 0.1814163);
    path_3.close();

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = color.withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);

    Path path_2 = Path();
    path_2.moveTo(
        size.width / 2.096597 * 2.096597, size.height / 2.099396 * 0.04153965);
    path_2.cubicTo(
        size.width / 2.096597 * 2.096597,
        size.height / 2.099396 * 0.01436564,
        size.width / 2.096597 * 2.060347,
        size.height / 2.099396 * -0.003925110,
        size.width / 2.096597 * 2.015698,
        size.height / 2.099396 * 0.0007202643);
    path_2.lineTo(
        size.width / 2.096597 * 1.478627, size.height / 2.099396 * 0.05661674);
    path_2.cubicTo(
        size.width / 2.096597 * 1.433978,
        size.height / 2.099396 * 0.06126211,
        size.width / 2.096597 * 1.397731,
        size.height / 2.099396 * 0.08709692,
        size.width / 2.096597 * 1.397731,
        size.height / 2.099396 * 0.1142731);
    path_2.lineTo(
        size.width / 2.096597 * 1.397731, size.height / 2.099396 * 0.7130705);
    path_2.cubicTo(
        size.width / 2.096597 * 1.397731,
        size.height / 2.099396 * 0.7402467,
        size.width / 2.096597 * 1.433978,
        size.height / 2.099396 * 0.7585352,
        size.width / 2.096597 * 1.478627,
        size.height / 2.099396 * 0.7538899);
    path_2.lineTo(
        size.width / 2.096597 * 2.015698, size.height / 2.099396 * 0.6979956);
    path_2.cubicTo(
        size.width / 2.096597 * 2.060347,
        size.height / 2.099396 * 0.6933480,
        size.width / 2.096597 * 2.096597,
        size.height / 2.099396 * 0.6675132,
        size.width / 2.096597 * 2.096597,
        size.height / 2.099396 * 0.6403392);
    path_2.lineTo(
        size.width / 2.096597 * 2.096597, size.height / 2.099396 * 0.04153965);
    path_2.close();

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    var translateX =
        (size.width - (size.width - size.width / 2.096597 * 1.397731) / 2);
    var translateY = (size.height / 2.099396 * 0.7130705 -
            size.height / 2.099396 * 0.04153965) /
        2;
    paint_2_fill.shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xfffe594e),
        Color(0xff1902d5),
      ],
    ).createShader(Rect.fromCenter(
        center: Offset(translateX, translateY), width: 10, height: 10));
    canvas.save();
    canvas.translate(translateX, translateY);
    canvas.transform(Matrix4.rotationY(2 * pi * x).storage);
    canvas.translate(-translateX, -translateY);

    canvas.drawPath(path_2, paint_2_fill);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
