import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBarIconButton extends StatelessWidget {
  final Widget icon;
  final String? tag;
  final String? tooltip;
  final void Function() onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? label;
  const AppBarIconButton({
    Key? key,
    required this.icon,
    this.label,
    this.tag,
    this.tooltip,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (label != null)
      return SizedBox(
        height: 50.h,
        child: FloatingActionButton.extended(
          tooltip: tooltip,
          heroTag: tag,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onPressed: onPressed,
          icon: icon,
          label: Text(label!),
          foregroundColor:
              foregroundColor ?? WalletTheme.instance.buttonsForeground,
          backgroundColor:
              backgroundColor ?? WalletTheme.instance.buttonsBackground,
        ),
      );
    else
      return SizedBox(
        height: 50.h,
        width: 50.h,
        child: FloatingActionButton(
          tooltip: tooltip,
          heroTag: tag,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          onPressed: onPressed,
          child: icon,
          foregroundColor:
              foregroundColor ?? WalletTheme.instance.buttonsForeground,
          backgroundColor:
              backgroundColor ?? WalletTheme.instance.buttonsBackground,
        ),
      );
  }
}
