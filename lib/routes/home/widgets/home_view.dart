import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/home/widgets/wallets_list_view.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeView extends StatelessWidget {
  final WalletHomeBloc bloc;
  const HomeView({Key? key, required this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: WalletTheme.instance.primary,
      color: WalletTheme.instance.gradientTwo,
      onRefresh: () async {
        if (bloc.state is WalletHomeCompleted) {
          final state = bloc.state as WalletHomeCompleted;
          if (state.withLoadingIndicator) return;
        }
        if (bloc.state is WalletHomeLoading) {
          return;
        }
        bloc.add(WalletHomeRefreshData());
      },
      child: CustomScrollView(
        slivers: [
          BlocBuilder<SettingsBloc, SettingsState>(
            buildWhen: (previous, current) {
              return current is SwitchAdvancedModeState;
            },
            builder: (context, state) {
              if (!AppStorage.instance.advanced)
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 16.h),
                  ),
                );
              return SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Material(
                    color: WalletTheme.instance.primary,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 16.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: AppBarIconButton(
                              tooltip: "QRscanner".tr(),
                              label: "QRscanner".tr(),
                              icon: Icon(
                                CupertinoIcons.qrcode_viewfinder,
                              ),
                              onPressed: () async {
                                var data = await showQRView(
                                  context,
                                  walletHomeBloc: bloc,
                                );
                                if (data != null) {
                                  Navigator.pushNamed(context, Routes.send,
                                      arguments: {
                                        "wallet": data["wallet"],
                                        "address":
                                            data["wallet"].addresses.first,
                                        "initial-data": data,
                                      });
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: 8.w,
                          ),
                          Expanded(
                            child: AppBarIconButton(
                              tooltip: "signer".tr(),
                              label: "signer".tr(),
                              icon: Icon(
                                CupertinoIcons.signature,
                              ),
                              onPressed: () async {
                                Navigator.pushNamed(
                                  context,
                                  Routes.signMultisigTx,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          BlocBuilder<WalletHomeBloc, WalletHomeState>(
            bloc: bloc,
            buildWhen: (previous, current) {
              return current is! WalletHomeError;
            },
            builder: (context, state) {
              if (state is WalletHomeLoading) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: AlephiumIcon(
                      spinning: true,
                    ),
                  ),
                );
              } else if (state is WalletHomeCompleted) {
                return WalletListView(
                  wallets: state.wallets,
                );
              } else {
                return SliverToBoxAdapter();
              }
            },
          ),
        ],
      ),
    );
  }
}
