part of 'wallet_setting_bloc.dart';

abstract class WalletSettingEvent extends Equatable {
  const WalletSettingEvent();

  @override
  List<Object> get props => [];
}

class WalletSettingDisplayMnemonic extends WalletSettingEvent {
  @override
  List<Object> get props => [DateTime.now()];
}

class WalletSettingDisplayPublicKey extends WalletSettingEvent {
  @override
  List<Object> get props => [DateTime.now()];
}
