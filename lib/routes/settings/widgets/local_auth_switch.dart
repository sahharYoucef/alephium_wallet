import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
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
          bloc: BlocProvider.of<SettingsBloc>(context),
          buildWhen: (previous, current) => current is LocalAuthToSendState,
          builder: (context, state) {
            return Switch(
                value: AppStorage.instance.localAuth,
                onChanged: (value) {
                  BlocProvider.of<SettingsBloc>(context)
                      .add(LocalAuthToSend(!AppStorage.instance.localAuth));
                });
          },
        )
      ],
    );
  }
}
