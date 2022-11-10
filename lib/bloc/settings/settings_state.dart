part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsError extends SettingsState {
  final String error;

  SettingsError(this.error);

  @override
  List<Object> get props => [error];
}

class AppThemeState extends SettingsState {
  final ThemeMode themeMode;

  AppThemeState(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class LocalAuthToSendState extends SettingsState {
  final bool value;

  LocalAuthToSendState(this.value);

  @override
  List<Object> get props => [value];
}
