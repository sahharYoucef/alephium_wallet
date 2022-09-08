import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/widgets/advanced_option_dialog.dart';
import 'package:alephium_wallet/routes/addresses/widgets/generate_address_dialog.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        openCloseDial: isDialOpen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        animatedIcon: AnimatedIcons.menu_close,
        // dialRoot: (ctx, open, toggleChildren) {
        //   return FloatingActionButton(
        //     child: AnimatedIcon(icon: AnimatedIcons.close_menu,),
        //     onPressed: toggleChildren,
        //     shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0)),
        //   );
        // },
        elevation: 0,
        animationCurve: Curves.ease,
        isOpenOnStart: false,
        animationDuration: const Duration(milliseconds: 100),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.generating_tokens),
            backgroundColor: Color(0xff797979),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            label: 'Generate address',
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return GenerateWalletDialog(
                      type: GenerationType.single,
                      bloc: bloc,
                    );
                  });
            },
            onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.keyboard_option_key),
            backgroundColor: Color(0xff797979),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            label: 'Advanced options',
            onTap: () {
              showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (_) => AdvancedOptionsDialog(
                        bloc: bloc,
                      ));
            },
            onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
        ]);
  }
}
