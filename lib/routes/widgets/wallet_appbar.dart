import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WalletAppBar extends StatelessWidget {
  final IconButton? action;
  final Widget? label;
  final bool withLoadingIndicator;
  final Widget? leading;
  const WalletAppBar({
    Key? key,
    this.action,
    this.label,
    this.withLoadingIndicator = false,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: PhysicalModel(
        elevation: 0,
        color: Theme.of(context).primaryColor,
        shadowColor: Colors.black,
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            height: 70,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (leading != null)
                      leading!
                    else
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ModalRoute.of(context)!.canPop
                            ? AppBarIconButton(
                                icon: Icon(
                                  CupertinoIcons.back,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                })
                            : const SizedBox(
                                height: 50,
                                width: 50,
                              ),
                      ),
                    Expanded(
                        child: Align(
                      alignment: Alignment.center,
                      child: label ?? const SizedBox(),
                    )),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: action == null
                          ? const SizedBox(
                              height: 50,
                              width: 50,
                            )
                          : AppBarIconButton(
                              icon: action!.icon,
                              onPressed: action!.onPressed!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
