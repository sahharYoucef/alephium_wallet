import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/home/widgets/qr_view.dart';
import 'package:alephium_wallet/routes/settings/settings_page.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/home/widgets/circle_navigation_bar.dart';
import 'package:alephium_wallet/routes/home/widgets/wallet_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final WalletHomeBloc _walletHomeBloc;
  late final TabController _tabController;
  @override
  void initState() {
    FlutterNativeSplash.remove();
    _tabController = TabController(length: 2, vsync: this);
    _walletHomeBloc = BlocProvider.of<WalletHomeBloc>(context)
      ..add(WalletHomeLoadData());
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() async {
    if (_tabController.index == 1) {
      _tabController.animateTo(0);
      return false;
    }
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      context.showSnackBar("Press back again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
                child: Column(
              children: [
                SizedBox(
                  height: 70 + context.topPadding,
                ),
                Expanded(
                  child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: [
                        BlocConsumer<WalletHomeBloc, WalletHomeState>(
                          bloc: _walletHomeBloc,
                          listener: (context, state) {
                            if (state is WalletHomeError) {
                              if (state.message != null)
                                context.showSnackBar(state.message!,
                                    level: Level.error);
                            }
                          },
                          buildWhen: (previous, current) =>
                              previous is WalletHomeCompleted &&
                              current is! WalletHomeError,
                          builder: (context, state) {
                            if (state is WalletHomeLoading) {
                              return ListView.builder(
                                padding: EdgeInsets.only(
                                  top: 16,
                                  bottom: 70,
                                ),
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return WalletTile(
                                    loading: true,
                                  );
                                },
                              );
                            } else if (state is WalletHomeCompleted) {
                              return RefreshIndicator(
                                onRefresh: () async {
                                  if (state.withLoadingIndicator) return;
                                  _walletHomeBloc.add(WalletHomeRefreshData());
                                },
                                child: ListView.builder(
                                  padding: EdgeInsets.only(
                                    top: 16,
                                    bottom: 70,
                                  ),
                                  itemCount: state.wallets.length,
                                  itemBuilder: (context, index) {
                                    return WalletTile(
                                        wallet: state.wallets[index]);
                                  },
                                ),
                              );
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                        SettingsPage()
                      ]),
                ),
              ],
            )),
            BlocBuilder<WalletHomeBloc, WalletHomeState>(
              builder: (context, state) {
                return WalletAppBar(
                  color: WalletTheme.instance.primary,
                  elevation: 1,
                  action: _walletHomeBloc.wallets.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner,
                          ),
                          onPressed: () async {
                            var data =
                                await showGeneralDialog<Map<String, dynamic>?>(
                              barrierDismissible: true,
                              barrierLabel: "receive",
                              context: context,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      Padding(
                                padding: EdgeInsets.only(
                                    top: 16,
                                    bottom: 16 + context.viewInsetsBottom,
                                    left: 16,
                                    right: 16),
                                child: Center(
                                  child: Material(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(
                                      16,
                                    ),
                                    elevation: 6,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        16,
                                      ),
                                      child: SizedBox(
                                        width: context.width * .7,
                                        height: context.height * .6,
                                        child: const QRViewExample(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              transitionBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return SlideTransition(
                                  position: animation.drive(
                                    Tween<Offset>(
                                      begin: Offset(0, 1),
                                      end: Offset.zero,
                                    ),
                                  ),
                                  child: child,
                                );
                              },
                            );

                            if (data != null) {
                              Navigator.pushNamed(context, Routes.send,
                                  arguments: {
                                    "wallet": _walletHomeBloc.wallets.first,
                                    "address": _walletHomeBloc
                                        .wallets.first.addresses.first,
                                    "initial-data": data,
                                  });
                            }
                          },
                        )
                      : null,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AlephiumIcon(
                          spinning: state is WalletHomeCompleted &&
                              state.withLoadingIndicator,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AppStorage.instance.formattedPrice ?? ''}",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              'Alephium Wallet',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  withLoadingIndicator: state is WalletHomeCompleted &&
                      state.withLoadingIndicator,
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: CircleNavigationBar(
                tabController: _tabController,
                navBarSelectedIconsColor:
                    Theme.of(context).textTheme.headlineMedium!.color!,
                navBarColor: Theme.of(context).primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, Routes.createWallet);
                },
                navbarHeight: 60,
                circleIconsColor: WalletTheme.instance.secondary,
                navBarIcons: [
                  CustomIcon(
                      icon: Icons.home,
                      onPressed: () {
                        _tabController.animateTo(0);
                      }),
                  CustomIcon(
                      icon: Icons.settings,
                      onPressed: () {
                        _tabController.animateTo(1);
                      }),
                ],
                margin: 16.0,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
