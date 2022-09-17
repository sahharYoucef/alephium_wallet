import 'package:flutter/material.dart';

class AnimatedGradientProgressIndicator extends StatefulWidget {
  AnimatedGradientProgressIndicator({
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

  final double? size;
  final Gradient gradient;

  @override
  State<AnimatedGradientProgressIndicator> createState() =>
      _AnimatedGradientProgressIndicatorState();
}

class _AnimatedGradientProgressIndicatorState
    extends State<AnimatedGradientProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _animation;
  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
    _animation = ColorTween(
      begin: Color(0xff1902d5),
      end: Color(0xfffe594e),
    ).animate(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16,
      width: 16,
      child: CircularProgressIndicator(
        valueColor: _animation,
      ),
    );
  }
}
