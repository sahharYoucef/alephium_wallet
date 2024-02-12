import 'dart:math';

import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_paint.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../utils/constants.dart';

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
    return AnimatedBuilder(
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationY(2 * pi * _animation.value),
          origin: Offset(25, 32.5),
          child: SizedBox(
              height: 65,
              width: 50,
              child: SvgPicture.asset(
                WalletIcons.alephiumIcon,
              )),
        );
      },
      animation: _animation,
    );
  }
}
