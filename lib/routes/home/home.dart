import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/home/widgets/circle_navigation_bar.dart';
import 'package:alephium_wallet/routes/home/widgets/wallet_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';
import '../new_wallet/new_wallet_route.dart';

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
    _tabController = TabController(length: 2, vsync: this);
    _walletHomeBloc = BlocProvider.of<WalletHomeBloc>(context)
      ..add(WalletHomeLoadData());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: Stack(
        children: [
          Positioned.fill(
              child: Column(
            children: [
              BlocBuilder<WalletHomeBloc, WalletHomeState>(
                builder: (context, state) {
                  return WalletAppBar(
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
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(
                                'Alephium Wallet',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
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
                        builder: (context, state) {
                          if (state is WalletHomeLoading) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is WalletHomeCompleted) {
                            return Column(
                              children: [
                                Expanded(
                                  child: RefreshIndicator(
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
                                        return WalletTile(
                                            wallet: state.wallets[index]);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return SizedBox();
                          }
                        },
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).padding.top + 70,
                          )
                        ],
                      )
                    ]),
              ),
            ],
          )),
          Align(
            alignment: Alignment.bottomCenter,
            child: CircleNavigationBar(
              navBarColor: WalletTheme.lightPrimaryColor,
              onTap: () {
                Navigator.pushNamed(context, Routes.createWallet);
              },
              navbarHeight: 60,
              circleIconsColor: Color(0xff797979),
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
    );
  }
}
