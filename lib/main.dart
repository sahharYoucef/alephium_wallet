import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/app.dart';
import 'package:alephium_wallet/bloc/contacts/contacts_bloc.dart';
import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/alephium/alephium_wallet_service.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/sqflite_database/sqflite_database.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

const double elevation = 0;

final getIt = GetIt.instance;
final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

class AppBlocObserver extends BlocObserver {
  @override
  void onTransition(Bloc bloc, Transition transition) {
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
  final _firstRun = await _initApp();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<WalletHomeBloc>(
        create: (context) => WalletHomeBloc(
          getIt.get<BaseApiRepository>(),
        ),
        lazy: true,
      ),
      BlocProvider<SettingsBloc>(
        create: (context) => SettingsBloc(
          getIt.get<AuthenticationService>(),
        ),
      ),
      BlocProvider<ContactsBloc>(
        create: (context) => ContactsBloc(
          dbHelper: getIt.get<BaseDBHelper>(),
        )..add(LoadAllContactsEvent()),
      ),
    ],
    child: EasyLocalization(
        supportedLocales: [
          Locale('en'),
          Locale('fr'),
          Locale('it'),
          Locale('es'),
        ],
        useOnlyLangCode: true,
        fallbackLocale: Locale('en'),
        path:
            'assets/translations', // <-- change the path of the translation files
        child: App(
          firstRun: _firstRun,
        )),
  ));
}

Future<bool> _initApp() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    statusBarColor: Colors.transparent,
  ));
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await EasyLocalization.ensureInitialized();
  getIt.registerLazySingleton<BaseWalletService>(() => AlephiumWalletService());
  getIt.registerLazySingleton<AuthenticationService>(
      () => AuthenticationService());
  getIt.registerSingleton<BaseDBHelper>(SQLiteDBHelper());
  await AppStorage.instance.initHive();
  Bloc.observer = AppBlocObserver();
  await Hive.openBox("settings");
  var firstRun = AppStorage.instance.firstRun;
  var network = AppStorage.instance.network;
  getIt.registerLazySingleton<BaseApiRepository>(
      () => AlephiumApiRepository(network));
  return firstRun;
}
