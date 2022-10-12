import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_paint.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class AlephiumIcon extends StatefulWidget {
  final bool spinning;
  AlephiumIcon({
    Key? key,
    this.spinning = false,
  }) : super(key: key);

  @override
  State<AlephiumIcon> createState() => _AlephiumIconState();
}

class _AlephiumIconState extends State<AlephiumIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    if (widget.spinning) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AlephiumIcon oldWidget) {
    if (widget.spinning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.spinning && _controller.isAnimating) {
      _controller.animateTo(_controller.upperBound);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = WalletTheme.themeMode == ThemeMode.dark;
    return AnimatedBuilder(
      builder: (context, child) {
        return SizedBox(
            height: 50,
            width: 35,
            child: CustomPaint(
                painter: AlephiumCustomPainter(
              _animation.value,
              isDarkMode ? Colors.white : Colors.black,
            )));
      },
      animation: _animation,
    );
  }
}
