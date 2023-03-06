import 'dart:math';

import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bloc/settings/settings_bloc.dart';

class WalletAppBar extends StatelessWidget {
  final Widget? action;
  final Text? label;
  final bool withLoadingIndicator;
  final ScrollController? controller;
  final Widget? leading;
  final double elevation;
  WalletAppBar({
    Key? key,
    this.action,
    this.controller,
    this.label,
    this.withLoadingIndicator = false,
    this.leading,
    this.elevation = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsBloc>();
    var safeArea = SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: 70.h.clamp(0, 70),
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (leading != null)
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.width - 80,
                        ),
                        child: leading!)
                  else
                    ModalRoute.of(context)!.canPop
                        ? AppBarIconButton(
                            tooltip: "back".tr(),
                            icon: Icon(
                              CupertinoIcons.back,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                        : SizedBox(
                            height: 50.h,
                            width: 50.h,
                          ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                      child: Align(
                        alignment: Alignment.center,
                        child: label != null
                            ? AutoSizeText(
                                label!.data!,
                                style: label!.style,
                                maxLines: 1,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0.h),
                    child: action == null
                        ? SizedBox(
                            height: 50.h,
                            width: 50.h,
                          )
                        : action,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return Align(
      alignment: Alignment.topCenter,
      child: Hero(
        tag: "app-bar",
        child: Material(
          shape: const AppBarShape(),
          elevation: elevation,
          color: WalletTheme.instance.primary,
          shadowColor: WalletTheme.instance.gradientOne,
          child: safeArea,
        ),
      ),
    );
  }
}

class AppBarShape extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    Path path = _getPath(rect.size);
    return path;
  }

  const AppBarShape({double radius = 16}) : arcHeight = radius * 2;

  final arcHeight;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = _getPath(rect.size);
    return path;
  }

  Path _getPath(Size size) {
    final path = Path();
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height + arcHeight);
    path.arcTo(
        Rect.fromLTWH(
            size.width - arcHeight, size.height, arcHeight, arcHeight),
        0,
        -pi / 2,
        false);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, size.height);
    path.arcTo(
      Rect.fromLTWH(0, size.height, arcHeight, arcHeight),
      -pi / 2,
      -pi / 2,
      false,
    );

    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    Path path = _getPath(rect.size);
    Paint hexagonPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.transparent;

    canvas..drawPath(path, hexagonPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return this;
  }
}
