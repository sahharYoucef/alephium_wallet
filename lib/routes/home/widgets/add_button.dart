import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/contacts/widgets/add_contact_dialog.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:easy_localization/easy_localization.dart';

class FloatingAddButton extends StatelessWidget {
  final ValueNotifier<bool> isDialOpen;
  FloatingAddButton({
    required this.isDialOpen,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
        buttonSize: Size(45, 45),
        childrenButtonSize: Size(45, 50),
        heroTag: "button",
        openCloseDial: isDialOpen,
        icon: Icons.add,
        childPadding: EdgeInsets.symmetric(vertical: 2.5),
        activeIcon: Icons.close,
        overlayColor: WalletTheme.instance.background,
        backgroundColor: WalletTheme.instance.background,
        activeBackgroundColor: WalletTheme.instance.primary,
        spacing: 3,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        animationCurve: Curves.ease,
        isOpenOnStart: false,
        animationDuration: const Duration(milliseconds: 100),
        children: [
          SpeedDialChild(
            labelBackgroundColor: WalletTheme.instance.primary,
            child: const Icon(Icons.person_add),
            backgroundColor: WalletTheme.instance.primary,
            foregroundColor: WalletTheme.instance.textColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 0,
            label: 'addContact'.tr(),
            onTap: () {
              showGeneralDialog(
                barrierDismissible: true,
                barrierLabel: "AddContactDialog",
                context: context,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AddContactDialog(
                  bloc: context.read<ContactsBloc>(),
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
            child: const Icon(Icons.wallet_outlined),
            backgroundColor: WalletTheme.instance.primary,
            foregroundColor: WalletTheme.instance.textColor,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            label: "newWallet".tr(),
            onTap: () {
              Navigator.pushNamed(context, Routes.createWallet);
            },
          ),
        ]);
  }
}
