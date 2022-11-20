import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/widgets/advanced_option_dialog.dart';
import 'package:alephium_wallet/routes/addresses/widgets/generate_address_dialog.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:easy_localization/easy_localization.dart';

class FloatingOptionsButton extends StatelessWidget {
  final ValueNotifier<bool> isDialOpen;
  final WalletDetailsBloc bloc;

  FloatingOptionsButton({
    Key? key,
    required this.isDialOpen,
    required this.bloc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
        tooltip: "advancedOptions".tr(),
        heroTag: "button",
        icon: Icons.add,
        activeIcon: Icons.close,
        overlayColor: WalletTheme.instance.background,
        spacing: 3,
        openCloseDial: isDialOpen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        animatedIcon: AnimatedIcons.menu_close,
        animationCurve: Curves.ease,
        isOpenOnStart: false,
        animationDuration: const Duration(milliseconds: 100),
        children: [
          SpeedDialChild(
            labelBackgroundColor: WalletTheme.instance.primary,
            child: const Icon(Icons.generating_tokens),
            backgroundColor: WalletTheme.instance.secondary,
            foregroundColor: WalletTheme.instance.textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            label: 'generateAddress'.tr(),
            onTap: () {
              showGeneralDialog(
                barrierDismissible: true,
                barrierLabel: "receive",
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    GenerateWalletDialog(
                  type: GenerationType.single,
                  bloc: bloc,
                ),
                transitionDuration: const Duration(milliseconds: 300),
                transitionBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: animation.drive(
                      Tween<Offset>(
                        begin: Offset(0, 1),
                        end: Offset.zero,
                      ),
                    ),
                    child: child,
                  );
                },
              );
            },
          ),
          SpeedDialChild(
            labelBackgroundColor: WalletTheme.instance.primary,
            child: const Icon(Icons.engineering_outlined),
            backgroundColor: WalletTheme.instance.secondary,
            foregroundColor: WalletTheme.instance.textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            label: "advancedOptions".tr(),
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (_) => AdvancedOptionsDialog(
                        bloc: bloc,
                      ));
            },
          ),
        ]);
  }
}
