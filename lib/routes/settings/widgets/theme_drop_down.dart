import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});
  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<ThemeMode>(
        menuMaxHeight: context.height / 2,
        dropdownColor: WalletTheme.instance.dropDownBackground,
        alignment: AlignmentDirectional.bottomEnd,
        elevation: 3,
        borderRadius: BorderRadius.circular(16),
        isExpanded: true,
        onChanged: (value) {
          context.read<SettingsBloc>().add(ChangeAppTheme(value!));
        },
        decoration: InputDecoration(
          label: Text(
            "theme".tr(),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        value: AppStorage.instance.themeMode,
        items: [
          ...ThemeMode.values
              .map(
                (value) => DropdownMenuItem<ThemeMode>(
                  value: value,
                  child: Text(
                    value.name.tr().toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              )
              .toList()
        ],
      ),
    );
  }
}
