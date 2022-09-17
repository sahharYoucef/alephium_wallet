import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

part 'wallet_setting_event.dart';
part 'wallet_setting_state.dart';

class WalletSettingBloc extends Bloc<WalletSettingEvent, WalletSettingState> {
  final WalletStore wallet;
  final LocalAuthentication auth = LocalAuthentication();

  WalletSettingBloc(this.wallet) : super(WalletSettingInitial()) {
    on<WalletSettingEvent>((event, emit) async {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (canAuthenticate) {
        try {
          final isDeviceSupported = await auth.isDeviceSupported();
          bool didAuthenticate = true;
          String message =
              "Please authenticate to show account ${event is WalletSettingDisplayMnemonic ? 'mnemonic' : 'public key'}";
          if (isDeviceSupported) {
            didAuthenticate = await auth.authenticate(
              localizedReason: message,
            );
          }
          if (didAuthenticate) {
            if (event is WalletSettingDisplayMnemonic) {
              emit(WalletSettingDisplayDataState(wallet.mnemonic, "Mnemonic"));
            } else if (event is WalletSettingDisplayPublicKey) {
              emit(WalletSettingDisplayDataState(
                  wallet.addresses.first.publicKey, "Public Key"));
            }
            return;
          }
          emit(WalletSettingErrorState("Authentication cancelled"));
        } on PlatformException catch (error) {
          emit(WalletSettingErrorState("${error.message}"));
        }
      }
    });
  }
}
