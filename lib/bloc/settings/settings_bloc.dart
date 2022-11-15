import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AuthenticationService authenticationService;
  SettingsBloc(this.authenticationService)
      : super(AppThemeState(AppStorage.instance.themeMode)) {
    on<SettingsEvent>((event, emit) async {
      if (event is ChangeAppTheme) {
        AppStorage.instance.themeMode = event.themeMode;
        emit(AppThemeState(event.themeMode));
      } else if (event is LocalAuthToSend) {
        try {
          final bool canAuthenticate =
              await authenticationService.canAuthenticate;
          if (!event.value) {
            AppStorage.instance.localAuth = event.value;
          } else if (canAuthenticate) {
            final didAuthenticate = await authenticationService.authenticate(
              "activateLocalAuthentication".tr(),
            );
            if (didAuthenticate)
              AppStorage.instance.localAuth = event.value;
            else
              emit(SettingsError(kErrorMessageGenericError));
          }
          emit(LocalAuthToSendState(AppStorage.instance.localAuth));
        } catch (e) {
          emit(SettingsError(kErrorMessageGenericError));
        }
      }
    });
  }
}
