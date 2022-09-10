import 'package:alephium_dart/alephium_dart.dart';
import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/bloc/create_wallet/create_wallet_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_details/wallet_details_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/alephium/alephium_wallet_service.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/routes/addresses/addresses_route.dart';
import 'package:alephium_wallet/routes/constants.dart';
import 'package:alephium_wallet/routes/restore_wallet/restore_wallet.dart';
import 'package:alephium_wallet/routes/send/consolidate_utxos.dart';
import 'package:alephium_wallet/routes/send/send_transaction.dart';
import 'package:alephium_wallet/routes/wallet_details/wallet_details.dart';
import 'package:alephium_wallet/routes/home/home.dart';
import 'package:alephium_wallet/routes/wallet_settings/wallet_settings_route.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/sqflite_database/sqflite_database.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'routes/new_wallet/new_wallet_route.dart';
import 'routes/mnemonic_verify/mnemonic_verify_page.dart';
import 'routes/wallet_mnemonic_page.dart';

const double elevation = 0;

final getIt = GetIt.instance;
GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    LoggerService.instance.log(
        "onTransition (${transition.currentState == transition.nextState}) : ${transition.currentState} => ${transition.nextState}");

    super.onTransition(bloc, transition);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    LoggerService.instance.log("$bloc => $event");
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    LoggerService.instance.log("${change.currentState} => ${change.nextState}");
    super.onChange(bloc, change);
  }
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  getIt.registerLazySingleton<BaseWalletService>(() => AlephiumWalletService());
  getIt.registerLazySingleton<BaseApiRepository>(
      () => AlephiumApiRepository(Network.testnet));
  getIt.registerSingleton<BaseDBHelper>(SQLiteDBHelper());
  await AppStorage.instance.initHive();
  Bloc.observer = AppBlocObserver();
  final box = await Hive.openBox("settings");
  var firstRun = box.get("firstRun");
  if (firstRun == null) {
    box.put("firstRun", true);
    firstRun = true;
  }
  runApp(MyApp(
    firstRun: firstRun,
  ));
}

class MyApp extends StatelessWidget {
  final bool firstRun;
  const MyApp({Key? key, this.firstRun = true})
      : super(
          key: key,
        );

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WalletHomeBloc>(
          create: (context) => WalletHomeBloc(
            getIt.get<BaseApiRepository>(),
          ),
          lazy: true,
        ),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(
          primaryColor: Color(0xffEDEDED),
          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
          backgroundColor: Colors.white,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: StadiumBorder(),
              side: BorderSide(
                width: 2,
                color: Theme.of(context).primaryColor,
              ),
              primary: Colors.white,
              shadowColor: Colors.black26,
              elevation: 5,
              backgroundColor: Color(0xff797979),
              minimumSize: Size.fromHeight(50),
              textStyle: GoogleFonts.cairo(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 0,
            backgroundColor: Color(0xff797979),
          ),
          textTheme: TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 1.2,
              height: 1.3,
              textBaseline: TextBaseline.alphabetic,
              color: Colors.black,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 1.1,
            ),
            bodySmall: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            bodyMedium: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.3,
            ),
            bodyLarge: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              height: 1.3,
            ),
          ),
        ),
        darkTheme: ThemeData(
          primaryColor: Color(0xff242424),
          cardColor: Color(0xff121211),
          scaffoldBackgroundColor: Color(0xff121211),
          fontFamily: GoogleFonts.roboto().fontFamily,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: StadiumBorder(),
              side: BorderSide(
                width: 2,
                color: Color(0xffEDEDED),
              ),
              primary: Colors.white,
              shadowColor: Colors.black26,
              elevation: 5,
              backgroundColor: Color(0xff242424),
              minimumSize: Size.fromHeight(50),
              textStyle: GoogleFonts.cairo(
                textStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            elevation: 2,
            backgroundColor: Color(0xff242424),
          ),
          textTheme: TextTheme(
            headlineMedium: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: 1.2,
              height: 1.3,
              textBaseline: TextBaseline.alphabetic,
              color: Colors.white,
            ),
            headlineSmall: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 1.1,
              color: Colors.white,
            ),
            bodySmall: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.white,
            ),
            bodyMedium: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              height: 1.3,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
              height: 1.3,
              color: Colors.white,
            ),
          ),
        ),
        themeMode: themeMode,
        debugShowCheckedModeBanner: false,
        initialRoute: firstRun ? Routes.createWallet : Routes.home,
        onGenerateRoute: (settings) {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark
              .copyWith(statusBarColor: Colors.transparent));
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
          }

          return null;
        },
      ),
    );
  }
}
