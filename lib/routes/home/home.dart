import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/contacts/contacts_page.dart';
import 'package:alephium_wallet/routes/home/widgets/add_button.dart';
import 'package:alephium_wallet/routes/settings/settings_page.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
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
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
  var isDialOpen = ValueNotifier<bool>(false);
  @override
  void initState() {
    FlutterNativeSplash.remove();
    _tabController = TabController(length: 3, vsync: this);
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
    if (isDialOpen.value) {
      isDialOpen.value = false;
      return false;
    }
    if (_tabController.index != 0) {
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
      child: MultiBlocListener(
        listeners: [
          BlocListener<WalletHomeBloc, WalletHomeState>(
            bloc: _walletHomeBloc,
            listener: (context, state) {
              if (state is WalletHomeError) {
                if (state.message != null)
                  context.showSnackBar(state.message!, level: Level.error);
              }
            },
          ),
          BlocListener<ContactsBloc, ContactsState>(
            bloc: context.read<ContactsBloc>(),
            listener: (context, state) {
              if (state is ContactsErrorState) {
                context.showSnackBar(state.message, level: Level.error);
              }
            },
          )
        ],
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
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
                            BlocBuilder<WalletHomeBloc, WalletHomeState>(
                              bloc: _walletHomeBloc,
                              buildWhen: (previous, current) {
                                return current is! WalletHomeError;
                              },
                              builder: (context, state) {
                                if (state is WalletHomeLoading) {
                                  return Center(
                                    child: AlephiumIcon(
                                      spinning: true,
                                    ),
                                  );
                                } else if (state is WalletHomeCompleted) {
                                  return RefreshIndicator(
                                    backgroundColor:
                                        WalletTheme.instance.primary,
                                    color: WalletTheme.instance.gradientTwo,
                                    onRefresh: () async {
                                      if (state.withLoadingIndicator) return;
                                      _walletHomeBloc
                                          .add(WalletHomeRefreshData());
                                    },
                                    child: ListView.builder(
                                      padding: EdgeInsets.only(
                                        top: 16,
                                        bottom: 70,
                                      ),
                                      itemCount: state.wallets.length,
                                      itemBuilder: (context, index) {
                                        return Center(
                                          child: WalletTile(
                                              wallet: state.wallets[index]),
                                        );
                                      },
                                    ),
                                  );
                                } else {
                                  return SizedBox();
                                }
                              },
                            ),
                            ContactsPage(),
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
                          ? AppBarIconButton(
                              tooltip: "QRscanner".tr(),
                              icon: Icon(
                                Icons.qr_code_scanner,
                              ),
                              onPressed: () async {
                                var data = await showQRView(
                                  context,
                                  walletHomeBloc: _walletHomeBloc,
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${AppStorage.instance.formattedPrice ?? ''}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                  AutoSizeText(
                                    'alephiumWallet'.tr(),
                                    maxLines: 1,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium,
                                  ),
                                ],
                              ),
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
                    onTap: () {},
                    navbarHeight: 60,
                    circleIconsColor: WalletTheme.instance.secondary,
                    navBarIcons: [
                      IconButton(
                          tooltip: "walletHome".tr(),
                          icon: Icon(Icons.home),
                          onPressed: () {
                            _tabController.animateTo(0);
                          }),
                      IconButton(
                          tooltip: "addressesBook".tr(),
                          icon: Icon(Icons.contacts),
                          onPressed: () {
                            _tabController.animateTo(1);
                          }),
                      IconButton(
                          tooltip: "walletSetting".tr(),
                          icon: Icon(Icons.settings),
                          onPressed: () {
                            _tabController.animateTo(2);
                          }),
                      Center(
                          child: FloatingAddButton(
                        isDialOpen: isDialOpen,
                      ))
                    ],
                    margin: 16.0,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
