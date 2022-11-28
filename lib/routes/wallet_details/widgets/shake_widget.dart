import 'package:flutter/material.dart';

class ShakeError extends StatefulWidget {
  const ShakeError({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.deltaX = 20,
    this.curve = Curves.bounceOut,
  }) : super(key: key);
  final Widget child;
  final Duration duration;
  final double deltaX;
  final Curve curve;

  @override
  State<ShakeError> createState() => ShakeErrorState();
}

class ShakeErrorState extends State<ShakeError>
    with SingleTickerProviderStateMixin<ShakeError> {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;

  @override
  void initState() {
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _offsetAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: widget.curve))
        .animate(_controller);
    super.initState();
  }

  void shake() async {
    _controller.reset();
    await _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// convert 0-1 to 0-1-0
  double _shake(double animation) =>
      2 * (0.5 - (0.5 - widget.curve.transform(animation)).abs());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(widget.deltaX * _shake(_offsetAnimation.value), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
