part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class ChangeAppTheme extends SettingsEvent {
  final ThemeMode themeMode;

  ChangeAppTheme(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class LocalAuthToSend extends SettingsEvent {
  final bool value;

  LocalAuthToSend(this.value);

  @override
  List<Object> get props => [value];
}
