part of 'wallet_setting_bloc.dart';

abstract class WalletSettingState extends Equatable {
  const WalletSettingState();

  @override
  List<Object> get props => [];
}

class WalletSettingInitial extends WalletSettingState {}

class WalletSettingDisplayDataState extends WalletSettingState {
  final String title;
  final String data;

  WalletSettingDisplayDataState(this.data, this.title);

  @override
  List<Object> get props => [data, title, DateTime.now()];
}

class WalletSettingErrorState extends WalletSettingState {
  final String message;

  WalletSettingErrorState(this.message);

  @override
  List<Object> get props => [message, DateTime.now()];
}
