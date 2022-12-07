import 'package:alephium_wallet/api/utils/constants.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:bloc/bloc.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

part 'wallet_setting_event.dart';
part 'wallet_setting_state.dart';

class WalletSettingBloc extends Bloc<WalletSettingEvent, WalletSettingState> {
  final WalletStore wallet;
  final AuthenticationService authenticationService;

  WalletSettingBloc(this.wallet, this.authenticationService)
      : super(WalletSettingInitial()) {
    on<WalletSettingEvent>((event, emit) async {
      final bool canAuthenticate = await authenticationService.canAuthenticate;
      if (canAuthenticate) {
        try {
          bool didAuthenticate = true;
          String message =
              "Please authenticate to show account ${event is WalletSettingDisplayMnemonic ? 'mnemonic' : 'public key'}";
          didAuthenticate = await authenticationService.authenticate(
            message,
          );
          if (didAuthenticate) {
            if (event is WalletSettingDisplayMnemonic) {
              emit(WalletSettingDisplayDataState(
                wallet.mnemonic!,
                "Mnemonic",
                true,
              ));
            } else if (event is WalletSettingDisplayPublicKey) {
              emit(WalletSettingDisplayDataState(
                  wallet.addresses.first.publicKey!, "Public Key"));
            }
            return;
          }
          emit(WalletSettingErrorState("Authentication cancelled"));
        } catch (error) {
          emit(WalletSettingErrorState(kErrorMessageGenericError));
        }
      }
    });
  }
}
