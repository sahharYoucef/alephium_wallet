import 'dart:async';

import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/alephium_icon.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/balance_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/main_address_tile.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/transaction_tile.dart';
import 'package:alephium_wallet/routes/widgets/wallet_appbar.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/constants.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

class WalletDetails extends StatefulWidget {
  final WalletStore wallet;
  WalletDetails({Key? key, required this.wallet}) : super(key: key);

  @override
  State<WalletDetails> createState() => _WalletDetailsState();
}

class _WalletDetailsState extends State<WalletDetails> {
  late WalletDetailsBloc _walletDetailsBloc;
  Completer<void>? _refresh;
  @override
  void initState() {
    _walletDetailsBloc = WalletDetailsBloc(
        apiRepository: getIt.get<BaseApiRepository>(),
        walletService: getIt.get<BaseWalletService>(),
        wallet: widget.wallet,
        walletHomeBloc: BlocProvider.of<WalletHomeBloc>(context))
      ..add(WalletDetailsLoadData());
    super.initState();
  }

  @override
  void dispose() {
    _walletDetailsBloc.close();
    _refresh = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: Color(0xff797979),
        color: Colors.white,
        onRefresh: () async {
          if (_refresh != null) return;
          _refresh = Completer();
          _walletDetailsBloc.add(WalletDetailsRefreshData());
          await _refresh?.future;
          _refresh = null;
        },
        child: Column(
          children: [
            WalletAppBar(
                label: Text(
                  '${widget.wallet.title} Wallet',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                action: IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.walletSettings,
                        arguments: {
                          "wallet-details": _walletDetailsBloc,
                        });
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                )),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverStickyHeader(
                    header: PhysicalModel(
                      color: Colors.white,
                      shadowColor: Colors.black54,
                      elevation: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          // border: Border.symmetric(
                          //     horizontal: BorderSide(
                          //   color: Theme.of(context).primaryColor,
                          //   width: 3,
                          // )),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Wallet Details',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Spacer(),
                            AlephiumIcon(
                              spinning: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    sliver: SliverToBoxAdapter(
                      child:
                          BlocConsumer<WalletDetailsBloc, WalletDetailsState>(
                        bloc: _walletDetailsBloc,
                        listener: (context, state) {
                          if (state is WalletDetailsCompleted) {
                            if (!state.withLoadingIndicator) {
                              _refresh?.complete();
                            }
                          } else if (state is WalletDetailsError) {
                            if (state is WalletDetailsCompleted) {
                              _refresh?.complete();
                              if (state.message != null)
                                context.showSnackBar(state.message!,
                                    level: Level.info);
                            }
                          }
                        },
                        builder: (context, state) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                BalanceTile(
                                  wallet: _walletDetailsBloc.wallet,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                MainAddressTile(
                                  wallet: _walletDetailsBloc.wallet,
                                  walletDetailsBloc: _walletDetailsBloc,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  BlocBuilder<WalletDetailsBloc, WalletDetailsState>(
                      bloc: _walletDetailsBloc,
                      buildWhen: (previous, current) {
                        if (previous is WalletDetailsCompleted &&
                            current is WalletDetailsCompleted) {
                          return previous.transactions != current.transactions;
                        }
                        return true;
                      },
                      // box-shadow: rgba(100, 100, 111, 0.2) 0px 7px 29px 0px;
                      builder: (context, state) {
                        return SliverStickyHeader(
                            header: PhysicalModel(
                              color: Colors.white,
                              shadowColor: Colors.black54,
                              elevation: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  // border: Border.symmetric(
                                  //     horizontal: BorderSide(
                                  //   color: Theme.of(context).primaryColor,
                                  //   width: 3,
                                  // )),
                                  color: Theme.of(context).primaryColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      'Transactions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium,
                                    ),
                                    Spacer(),
                                    AlephiumIcon(
                                      spinning:
                                          state is WalletDetailsCompleted &&
                                              state.withLoadingIndicator,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            sliver: state is WalletDetailsCompleted
                                ? SliverPadding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    sliver: SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                      final transaction =
                                          state.transactions?[index];
                                      if (transaction == null)
                                        return const SizedBox();
                                      return TransactionTile(
                                        _walletDetailsBloc,
                                        transaction: transaction,
                                      );
                                    },
                                            childCount:
                                                state.transactions?.length ??
                                                    0)),
                                  )
                                : SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ));
                      })
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: "button",
        label: Text(
          'Send',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: Icon(Icons.send_outlined),
        onPressed: () {
          Navigator.pushNamed(context, Routes.send, arguments: {
            "wallet": widget.wallet,
            "wallet-details": _walletDetailsBloc
          });
        },
      ),
    );
  }
}
