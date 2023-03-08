import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdvancedSwitch extends StatefulWidget {
  @override
  State<AdvancedSwitch> createState() => _AdvancedSwitchState();
}

class _AdvancedSwitchState extends State<AdvancedSwitch> {
  late bool isAdvanced;
  @override
  void initState() {
    isAdvanced = AppStorage.instance.advanced;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "advancedMode".tr(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Spacer(),
        Switch(
            activeColor: WalletTheme.instance.buttonsBackground,
            inactiveTrackColor: WalletTheme.instance.textColor,
            activeTrackColor: WalletTheme.instance.textColor,
            inactiveThumbColor: WalletTheme.instance.disabledButtonsBackground,
            value: isAdvanced,
            onChanged: (value) {
              isAdvanced = !isAdvanced;
              AppStorage.instance.advanced = isAdvanced;
              setState(() {});
              context.read<SettingsBloc>().add(SwitchAdvancedMode(isAdvanced));
            }),
      ],
    );
  }
}
