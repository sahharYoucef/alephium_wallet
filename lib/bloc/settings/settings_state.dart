part of 'settings_bloc.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class AppThemeState extends SettingsState {
  final ThemeMode themeMode;

  AppThemeState(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}
