import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletAppBar extends StatefulWidget {
  final IconButton? action;
  final Widget? label;
  final bool withLoadingIndicator;
  final ScrollController? controller;
  final Widget? leading;
  const WalletAppBar({
    Key? key,
    this.action,
    this.controller,
    this.label,
    this.withLoadingIndicator = false,
    this.leading,
  }) : super(key: key);

  @override
  State<WalletAppBar> createState() => _WalletAppBarState();
}

class _WalletAppBarState extends State<WalletAppBar> {
  late Color appBarColor;
  late double elevation;

  @override
  void initState() {
    appBarColor = WalletTheme.instance.background;
    elevation = 0;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WalletAppBar oldWidget) {
    if (widget.controller != null) {
      appBarColor = Color.lerp(
          WalletTheme.instance.background,
          WalletTheme.instance.primary,
          (widget.controller!.offset / 50).clamp(0, 1))!;
    } else {
      appBarColor = WalletTheme.instance.background;
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (widget.leading != null)
                    widget.leading!
                  else
                    ModalRoute.of(context)!.canPop
                        ? AppBarIconButton(
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
                      child: Align(
                    alignment: Alignment.center,
                    child: widget.label ?? const SizedBox(),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: widget.action == null
                        ? const SizedBox(
                            height: 50,
                            width: 50,
                          )
                        : AppBarIconButton(
                            icon: widget.action!.icon,
                            onPressed: widget.action!.onPressed!),
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
            appBarColor = Color.lerp(
                WalletTheme.instance.background,
                WalletTheme.instance.primary,
                (widget.controller!.offset / 50).clamp(0, 1))!;
            elevation = (widget.controller!.offset / 50 * 2).clamp(0, 2);
          } catch (_) {
            appBarColor = WalletTheme.instance.background;
            elevation = 0;
          }
          return Material(
            elevation: elevation,
            color: appBarColor,
            shadowColor: Colors.black,
            child: child,
          );
        },
        child: safeArea,
      );
    } else {
      child = Material(
        elevation: elevation,
        color: appBarColor,
        shadowColor: Colors.black,
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
