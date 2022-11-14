import 'dart:async';

import 'package:alephium_wallet/api/repositories/alephium/alephium_api_repository.dart';
import 'package:alephium_wallet/api/repositories/base_api_repository.dart';
import 'package:alephium_wallet/api/utils/either.dart';
import 'package:alephium_wallet/app.dart';
import 'package:alephium_wallet/bloc/settings/settings_bloc.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/encryption/alephium/alephium_wallet_service.dart';
import 'package:alephium_wallet/encryption/base_wallet_service.dart';
import 'package:alephium_wallet/services/authentication_service.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:alephium_wallet/storage/base_db_helper.dart';
import 'package:alephium_wallet/storage/models/address_store.dart';
import 'package:alephium_wallet/storage/sqflite_database/sqflite_database.dart';
import 'package:alephium_wallet/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const double elevation = 0;
int id = 0;

final getIt = GetIt.instance;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

final List<DarwinNotificationCategory> darwinNotificationCategories =
    <DarwinNotificationCategory>[
  DarwinNotificationCategory(
    darwinNotificationCategoryText,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.text(
        'text_1',
        'Action 1',
        buttonTitle: 'Send',
        placeholder: 'Placeholder',
      ),
    ],
  ),
  DarwinNotificationCategory(
    darwinNotificationCategoryPlain,
    actions: <DarwinNotificationAction>[
      DarwinNotificationAction.plain('id_1', 'Action 1'),
      DarwinNotificationAction.plain(
        'id_2',
        'Action 2 (destructive)',
        options: <DarwinNotificationActionOption>{
          DarwinNotificationActionOption.destructive,
        },
      ),
      DarwinNotificationAction.plain(
        navigationActionId,
        'Action 3 (foreground)',
        options: <DarwinNotificationActionOption>{
          DarwinNotificationActionOption.foreground,
        },
      ),
      DarwinNotificationAction.plain(
        'id_4',
        'Action 4 (auth required)',
        options: <DarwinNotificationActionOption>{
          DarwinNotificationActionOption.authenticationRequired,
        },
      ),
    ],
    options: <DarwinNotificationCategoryOption>{
      DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
    },
  )
];

/// Note: permissions aren't requested here just to demonstrate that can be
/// done later
final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  requestAlertPermission: false,
  requestBadgePermission: false,
  requestSoundPermission: false,
  onDidReceiveLocalNotification:
      (int id, String? title, String? body, String? payload) async {
    didReceiveLocalNotificationStream.add(
      ReceivedNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      ),
    );
  },
  notificationCategories: darwinNotificationCategories,
);
final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
  iOS: initializationSettingsDarwin,
  macOS: initializationSettingsDarwin,
);

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

final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

/// A notification action which triggers a url launch event
const String urlLaunchActionId = 'id_1';

/// A notification action which triggers a App navigation event
const String navigationActionId = 'id_3';

/// Defines a iOS/MacOS notification category for text input actions.
const String darwinNotificationCategoryText = 'textCategory';

/// Defines a iOS/MacOS notification category for plain actions.
const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final db = SQLiteDBHelper();
    await Hive.openBox("settings");
    var network = AppStorage.instance.network;
    final repo = AlephiumApiRepository(network);
    if (flutterLocalNotificationsPlugin == null) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      flutterLocalNotificationsPlugin!.initialize(initializationSettings);
    }
    if (task == "check-for-transactions") {
      final wallets = await db.getWallets(network: network);
      var addresses = <AddressStore>[];
      for (var wallet in wallets) {
        for (var address in wallet.addresses) addresses.add(address);
      }
      List<Either<AddressStore>> data = [];
      var chunks = <List<AddressStore>>[];
      int chunkSize = 15;
      for (var i = 0; i < addresses.length; i += chunkSize) {
        chunks.add(addresses.sublist(
            i,
            i + chunkSize > addresses.length
                ? addresses.length
                : i + chunkSize));
      }
      for (var element in chunks) {
        var subData = await Future.wait<Either<AddressStore>>(
          element.map((e) => repo.getAddressBalance(address: e)),
        );
        data.addAll(subData);
        await Future.delayed(
          const Duration(seconds: 2),
        );
      }
      var updatedAddresses = <AddressStore>[];
      for (var address in data) {
        if (address.hasData && address.getData != null) {
          updatedAddresses.add(address.getData!);
        }
      }
      _showNotification();
      flutterLocalNotificationsPlugin!.show(
          1, "test", updatedAddresses.first.address, NotificationDetails());
    }
    return Future.value(true);
  });
}

Future<void> _showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails('your channel id', 'your channel name',
          channelDescription: 'your channel description',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker');
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin!.show(
      id++, 'plain title', 'plain body', notificationDetails,
      payload: 'item x');
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
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  Workmanager().initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode:
          true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
  Workmanager().registerPeriodicTask("task-identifier", "simpleTask",
      frequency: Duration(
        minutes: 15,
      ));

  flutterLocalNotificationsPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestPermission();
  flutterLocalNotificationsPlugin!.initialize(initializationSettings);
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
