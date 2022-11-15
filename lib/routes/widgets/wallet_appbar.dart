import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletAppBar extends StatefulWidget {
  final AppBarIconButton? action;
  final Text? label;
  final bool withLoadingIndicator;
  final ScrollController? controller;
  final Widget? leading;
  late final Color color;
  final double elevation;
  WalletAppBar({
    Key? key,
    this.action,
    this.controller,
    this.label,
    this.withLoadingIndicator = false,
    this.leading,
    this.elevation = 0,
    Color? color,
  }) : super(key: key) {
    this.color = color ?? WalletTheme.instance.background;
  }

  @override
  State<WalletAppBar> createState() => _WalletAppBarState();
}

class _WalletAppBarState extends State<WalletAppBar> {
  late Color appBarColor;
  late double elevation;

  @override
  void initState() {
    appBarColor = widget.color;
    elevation = widget.elevation;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WalletAppBar oldWidget) {
    if (widget.controller != null) {
      appBarColor = Color.lerp(widget.color, WalletTheme.instance.primary,
          (widget.controller!.offset / 50).clamp(0, 1))!;
    } else {
      appBarColor = widget.color;
    }
    setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var safeArea = SafeArea(
      bottom: false,
      child: Container(
        width: double.infinity,
        height: 70,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (widget.leading != null)
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: context.width - 80,
                        ),
                        child: widget.leading!)
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
                        : const SizedBox(
                            height: 50,
                            width: 50,
                          ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: widget.label != null
                            ? AutoSizeText(
                                widget.label!.data!,
                                style: widget.label!.style,
                                maxLines: 1,
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: widget.action == null
                        ? const SizedBox(
                            height: 50,
                            width: 50,
                          )
                        : widget.action,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    late final Widget child;
    if (widget.controller != null) {
      child = AnimatedBuilder(
        animation: widget.controller!,
        builder: (context, child) {
          try {
            appBarColor = Color.lerp(widget.color, WalletTheme.instance.primary,
                (widget.controller!.offset / 50).clamp(0, 1))!;
            elevation = (widget.controller!.offset / 50 * 2).clamp(0, 2);
          } catch (_) {
            appBarColor = widget.color;
            elevation = widget.elevation;
          }
          return Material(
            elevation: elevation,
            color: appBarColor,
            shadowColor: WalletTheme.instance.gradientOne,
            child: child,
          );
        },
        child: safeArea,
      );
    } else {
      child = Material(
        elevation: elevation,
        color: appBarColor,
        shadowColor: WalletTheme.instance.gradientOne,
        child: safeArea,
      );
    }
    return Align(
      alignment: Alignment.topCenter,
      child: Hero(
        tag: "app-bar",
        child: child,
      ),
    );
  }
}
