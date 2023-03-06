import 'dart:io';

import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/routes/contacts/contacts_page.dart';
import 'package:alephium_wallet/routes/contacts/widgets/add_contact_dialog.dart';
import 'package:alephium_wallet/routes/home/widgets/wallets_list_view.dart';
import 'package:alephium_wallet/routes/settings/settings_page.dart';
import 'package:alephium_wallet/routes/widgets/appbar_icon_button.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/home/widgets/circle_navigation_bar.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late final ValueNotifier<int> _listenable;
  var isDialOpen = ValueNotifier<bool>(false);
  @override
  void initState() {
    FlutterNativeSplash.remove();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        _listenable.value = _tabController.index;
      });
    _listenable = ValueNotifier(_tabController.index);
    _walletHomeBloc = BlocProvider.of<WalletHomeBloc>(context)
      ..add(WalletHomeLoadData());
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listenable.dispose();
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
      return false;
    }
    exit(0);
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
                      height: 70.h + context.topPadding,
                    ),
                    Expanded(
                      child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: _tabController,
                          children: [
                            RefreshIndicator(
                              backgroundColor: WalletTheme.instance.primary,
                              color: WalletTheme.instance.gradientTwo,
                              onRefresh: () async {
                                if (_walletHomeBloc.state
                                    is WalletHomeCompleted) {
                                  final state = _walletHomeBloc.state
                                      as WalletHomeCompleted;
                                  if (state.withLoadingIndicator) return;
                                }
                                if (_walletHomeBloc.state
                                    is WalletHomeLoading) {
                                  return;
                                }
                                _walletHomeBloc.add(WalletHomeRefreshData());
                              },
                              child: CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 16.h),
                                      child: Material(
                                        color: WalletTheme.instance.primary,
                                        elevation: 1,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 16.h),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: AppBarIconButton(
                                                  tooltip: "QRscanner".tr(),
                                                  label: "QRscanner".tr(),
                                                  icon: Icon(
                                                    CupertinoIcons
                                                        .qrcode_viewfinder,
                                                  ),
                                                  onPressed: () async {
                                                    var data = await showQRView(
                                                      context,
                                                      walletHomeBloc:
                                                          _walletHomeBloc,
                                                    );
                                                    if (data != null) {
                                                      Navigator.pushNamed(
                                                          context, Routes.send,
                                                          arguments: {
                                                            "wallet":
                                                                data["wallet"],
                                                            "address":
                                                                data["wallet"]
                                                                    .addresses
                                                                    .first,
                                                            "initial-data":
                                                                data,
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
                                  ),
                                  BlocBuilder<WalletHomeBloc, WalletHomeState>(
                                    bloc: _walletHomeBloc,
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
                            ),
                            ContactsPage(),
                            SettingsPage()
                          ]),
                    ),
                  ],
                )),
                WalletAppBar(
                    action: ValueListenableBuilder(
                      valueListenable: _listenable,
                      builder: (context, value, child) {
                        if (value == 1)
                          return AppBarIconButton(
                            icon: Icon(CupertinoIcons.add),
                            onPressed: () {
                              showGeneralDialog(
                                barrierDismissible: true,
                                barrierLabel: "AddContactDialog",
                                context: context,
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        AddContactDialog(
                                  bloc: context.read<ContactsBloc>(),
                                ),
                                transitionDuration:
                                    const Duration(milliseconds: 200),
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
                            },
                          );
                        else
                          return AppBarIconButton(
                            tooltip: "newWallet".tr(),
                            icon: Icon(CupertinoIcons.add),
                            onPressed: () async {
                              Navigator.pushNamed(context, Routes.createWallet);
                            },
                          );
                      },
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: BlocBuilder<WalletHomeBloc, WalletHomeState>(
                        builder: (context, state) {
                          return Row(
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
                          );
                        },
                      ),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: CircleNavigationBar(
                    tabController: _tabController,
                    navBarSelectedIconsColor: WalletTheme.instance.textColor,
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
                    ],
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
