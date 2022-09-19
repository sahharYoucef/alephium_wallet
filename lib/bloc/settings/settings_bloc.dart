import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(AppThemeState(AppStorage.instance.themeMode)) {
    on<SettingsEvent>((event, emit) {
      if (event is ChangeAppTheme) {
        AppStorage.instance.themeMode = event.themeMode;
        emit(AppThemeState(event.themeMode));
      }
    });
  }
}
