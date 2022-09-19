import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  ThemeMode _themeMode = AppStorage.instance.themeMode;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Theme",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Spacer(),
        Switch(
            value: _themeMode == ThemeMode.light,
            onChanged: (value) {
              setState(() {
                if (_themeMode == ThemeMode.light)
                  _themeMode = ThemeMode.dark;
                else
                  _themeMode = ThemeMode.light;
              });
              BlocProvider.of<SettingsBloc>(context)
                  .add(ChangeAppTheme(_themeMode));
            })
      ],
    );
  }
}
