import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage _instance = AppStorage._();
  static AppStorage get instance => _instance;

  Future<void> initHive() async {
    final dir = await getApplicationSupportDirectory();
    Hive.init(dir.path);
  }

  String get currency {
    var settings = Hive.box("settings");
    var _currency = settings.get("currency");
    if (_currency == null) {
      _currency = currency = "usd";
    }
    return _currency as String;
  }

  set currency(String value) {
    var settings = Hive.box("settings");
    settings.put("currency", value);
  }

  double? get price {
    var settings = Hive.box("settings");
    var _price = settings.get("price");
    return _price?[currency] as double?;
  }

  String? get formattedPrice {
    if (price != null) return Format.formatCurrency(price!);
    return null;
  }

  set price(double? value) {
    var settings = Hive.box("settings");
    settings.put("price", {currency: value});
  }

  bool get firstRun {
    var settings = Hive.box("settings");
    var _firstRun = settings.get("firstRun");
    if (_firstRun == null) {
      firstRun = _firstRun = true;
    }
    return _firstRun;
  }

  set firstRun(bool? value) {
    var settings = Hive.box("settings");
    settings.put("firstRun", value);
  }

  Network get network {
    var settings = Hive.box("settings");
    var _network = settings.get("network") as String?;
    if (_network == null) {
      network = Network.testnet;
      _network = network.name;
    }
    return Network.network(_network);
  }

  set network(Network value) {
    var settings = Hive.box("settings");
    settings.put("network", value.name);
  }

  ThemeMode get themeMode {
    var settings = Hive.box("settings");
    var _themeMode = settings.get("themeMode") as String?;
    if (_themeMode == null) {
      themeMode = ThemeMode.light;
      _themeMode = themeMode.name;
    }
    return ThemeMode.values.firstWhere((element) => element.name == _themeMode);
  }

  set themeMode(ThemeMode value) {
    var settings = Hive.box("settings");
    settings.put("themeMode", value.name);
  }
}
