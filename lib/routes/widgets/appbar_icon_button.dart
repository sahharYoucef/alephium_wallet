import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';

class AppBarIconButton extends StatelessWidget {
  final Widget icon;
  final String? tag;
  final void Function() onPressed;
  const AppBarIconButton({
    Key? key,
    required this.icon,
    this.tag,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: tag,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onPressed: onPressed,
      child: icon,
    );
  }
}
