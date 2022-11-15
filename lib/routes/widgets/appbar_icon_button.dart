import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  final Widget icon;
  final String? tag;
  final String? tooltip;
  final void Function() onPressed;
  const AppBarIconButton({
    Key? key,
    required this.icon,
    this.tag,
    this.tooltip,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: tooltip,
      heroTag: tag,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onPressed,
      child: icon,
    );
  }
}
