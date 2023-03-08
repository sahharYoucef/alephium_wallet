part of 'settings_bloc.dart';

abstract class SettingsState {
  const SettingsState();
}

class SettingsError extends SettingsState {
  final String error;

  SettingsError(this.error);
}

class AppThemeState extends SettingsState {
  final ThemeMode themeMode;

  AppThemeState(this.themeMode);
}

class LocalAuthToSendState extends SettingsState {
  final bool value;

  LocalAuthToSendState(this.value);
}

class SwitchAdvancedModeState extends SettingsState {
  final bool value;

  SwitchAdvancedModeState(this.value);
}
