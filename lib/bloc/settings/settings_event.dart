part of 'settings_bloc.dart';

abstract class SettingsEvent {
  const SettingsEvent();
}

class ChangeAppTheme extends SettingsEvent {
  final ThemeMode themeMode;

  ChangeAppTheme(this.themeMode);
}

class LocalAuthToSend extends SettingsEvent {
  final bool value;

  LocalAuthToSend(this.value);
}
