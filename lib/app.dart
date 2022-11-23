import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/routes/addresses/addresses_route.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/read_only_wallet.dart/read_only_wallet_page.dart';
import 'package:alephium_wallet/routes/restore_wallet/restore_wallet.dart';
import 'package:alephium_wallet/routes/send/consolidate_utxos.dart';
import 'package:alephium_wallet/routes/send/send_transaction.dart';
import 'package:alephium_wallet/routes/transaction_details/transaction_details.dart';
import 'package:alephium_wallet/routes/wallet_details/wallet_details.dart';
import 'package:alephium_wallet/routes/home/home.dart';
import 'package:alephium_wallet/routes/wallet_settings/wallet_settings_route.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/transaction_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'routes/new_wallet/new_wallet_route.dart';
import 'routes/mnemonic_verify/mnemonic_verify_page.dart';
import 'routes/wallet_mnemonic_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  final bool firstRun;
  App({Key? key, this.firstRun = true})
      : super(
          key: key,
        );

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    var window = WidgetsBinding.instance.window;
    window.onPlatformBrightnessChanged = () {
      WidgetsBinding.instance.handlePlatformBrightnessChanged();
      if (AppStorage.instance.themeMode == ThemeMode.system) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          BlocProvider.of<SettingsBloc>(context)
              .add(ChangeAppTheme(ThemeMode.system));
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
        bloc: BlocProvider.of<SettingsBloc>(context),
        buildWhen: (previous, current) => current is AppThemeState,
        builder: (context, state) {
          if (state is AppThemeState) {
            WalletTheme.themeMode = AppStorage.instance.themeMode;
            WalletTheme.instance = WalletTheme();
            SystemChrome.setSystemUIOverlayStyle(
                WalletTheme.themeMode == ThemeMode.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark.copyWith(
                        statusBarColor: Colors.transparent,
                      ));
          }
          return MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              EasyLocalization.of(context)!.delegate,
            ],
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            scaffoldMessengerKey: scaffoldMessengerKey,
            theme: WalletTheme.instance.themeData,
            darkTheme: WalletTheme.instance.themeData,
            themeMode: WalletTheme.themeMode,
            debugShowCheckedModeBanner: false,
            initialRoute: widget.firstRun ? Routes.createWallet : Routes.home,
            onGenerateRoute: (settings) {
              if (settings.name == Routes.walletMnemonic) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final wallet = arguments["wallet"] as WalletStore;
                final bloc = arguments["bloc"] as CreateWalletBloc;
                return MaterialPageRoute(
                  builder: (context) => WalletMnemonicPage(
                    wallet: wallet,
                    bloc: bloc,
                  ),
                );
              } else if (settings.name == Routes.walletVerifyMnemonic) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final wallet = arguments["wallet"] as WalletStore;
                final bloc = arguments["bloc"] as CreateWalletBloc;
                return MaterialPageRoute(
                  builder: (context) => WalletMnemonicVerifyPage(
                    wallet: wallet,
                    bloc: bloc,
                  ),
                );
              } else if (settings.name == Routes.createWallet) {
                return MaterialPageRoute(
                  builder: (context) => NewWalletPage(),
                );
              } else if (settings.name == Routes.home) {
                return MaterialPageRoute(
                  builder: (context) => HomePage(),
                );
              } else if (settings.name == Routes.readOnlyWallet) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final bloc = arguments["bloc"] as CreateWalletBloc;
                return MaterialPageRoute(
                  builder: (context) => ReadOnlyWalletPage(
                    bloc: bloc,
                  ),
                );
              } else if (settings.name == Routes.restoreWallet) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final bloc = arguments["bloc"] as CreateWalletBloc;
                return MaterialPageRoute(
                  builder: (context) => RestoreWallet(
                    bloc: bloc,
                  ),
                );
              } else if (settings.name == Routes.wallet) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final wallet = arguments["wallet"] as WalletStore;
                return MaterialPageRoute(
                  builder: (context) => WalletDetails(
                    wallet: wallet,
                  ),
                );
              } else if (settings.name == Routes.send) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final wallet = arguments["wallet"] as WalletStore;
                final detailsBloc =
                    arguments["wallet-details"] as WalletDetailsBloc?;
                final address = arguments["address"] as AddressStore?;
                final initialData =
                    arguments["initial-data"] as Map<String, dynamic>?;
                return MaterialPageRoute(
                  builder: (context) => SendTransactionPage(
                    wallet: wallet,
                    detailsBloc: detailsBloc,
                    addressStore: address,
                    initialData: initialData,
                  ),
                );
              } else if (settings.name == Routes.addresses) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final detailsBloc =
                    arguments["wallet-details"] as WalletDetailsBloc;
                return MaterialPageRoute(
                  builder: (context) => AddressesPage(
                    bloc: detailsBloc,
                  ),
                );
              } else if (settings.name == Routes.walletSettings) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final detailsBloc =
                    arguments["wallet-details"] as WalletDetailsBloc;
                return MaterialPageRoute(
                  builder: (context) => WalletSetting(
                    detailsBloc: detailsBloc,
                  ),
                );
              } else if (settings.name == Routes.walletUtxo) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final wallet = arguments["wallet"] as WalletStore;
                final detailsBloc =
                    arguments["wallet-details"] as WalletDetailsBloc;
                return MaterialPageRoute(
                  builder: (context) => ConsolidateUtxosRoute(
                    detailsBloc: detailsBloc,
                    wallet: wallet,
                  ),
                );
              } else if (settings.name == Routes.transactionDetails) {
                Map<String, dynamic> arguments =
                    settings.arguments as Map<String, dynamic>;
                final transaction =
                    arguments["transaction"] as TransactionStore;
                return MaterialPageRoute(
                  builder: (context) => TransactionDetails(
                    transaction: transaction,
                  ),
                );
              }

              return null;
            },
          );
        });
  }
}
