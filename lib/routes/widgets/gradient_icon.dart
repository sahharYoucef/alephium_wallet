import 'package:flutter/material.dart';

class GradientIcon extends StatelessWidget {
  GradientIcon({
    required this.icon,
    this.size = 24,
    this.gradient = const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xff1902d5),
        Color(0xfffe594e),
      ],
    ),
  });

  final IconData icon;
  final double? size;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
      shaderCallback: (Rect bounds) {
        return gradient.createShader(bounds);
      },
    );
  }
}
