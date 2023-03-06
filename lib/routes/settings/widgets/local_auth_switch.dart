import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalAuthSwitch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "authToSend".tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Spacer(),
        BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is SettingsError) {
              context.showSnackBar(state.error, level: Level.error);
            }
          },
          bloc: context.read<SettingsBloc>(),
          buildWhen: (previous, current) => current is LocalAuthToSendState,
          builder: (context, state) {
            return Switch(
                activeColor: WalletTheme.instance.buttonsBackground,
                inactiveTrackColor: WalletTheme.instance.textColor,
                activeTrackColor: WalletTheme.instance.textColor,
                inactiveThumbColor:
                    WalletTheme.instance.disabledButtonsBackground,
                value: AppStorage.instance.localAuth,
                onChanged: (value) {
                  context
                      .read<SettingsBloc>()
                      .add(LocalAuthToSend(!AppStorage.instance.localAuth));
                });
          },
        )
      ],
    );
  }
}
