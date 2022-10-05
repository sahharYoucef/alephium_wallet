import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class AnimatedGradientProgressIndicator extends StatefulWidget {
  AnimatedGradientProgressIndicator({
    this.size = 24,
  });

  final double? size;

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
      begin: WalletTheme.instance.gradientOne,
      end: WalletTheme.instance.gradientTwo,
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
