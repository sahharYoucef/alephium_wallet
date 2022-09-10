import 'dart:math';

import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';

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
      _controller.reset();
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
    bool isDarkMode = themeMode == ThemeMode.dark;
    return RotationTransition(
      turns: _animation,
      child: SvgPicture.asset(
        isDarkMode
            ? WalletIcons.lightAlephiumIcon
            : WalletIcons.darkAlephiumIcon,
        height: 40,
        width: 40,
      ),
    );
  }
}
