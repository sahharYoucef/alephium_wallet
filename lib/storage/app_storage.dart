import 'package:alephium_wallet/api/utils/network.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class AppStorage {
  AppStorage._();
  static final AppStorage _instance = AppStorage._();
  static AppStorage get instance => _instance;

  Future<void> initHive() async {
    final dir = await getApplicationSupportDirectory();
    Hive.init(dir.path);
  }

  Map<String, dynamic>? get customNetwork {
    var settings = Hive.box("settings");
    var _customNetwork = settings.get("networkSetting");
    if (_customNetwork == null) return null;
    return Map<String, String?>.from(_customNetwork);
  }

  set customNetwork(Map<String, dynamic>? network) {
    var settings = Hive.box("settings");
    settings.put("networkSetting", network);
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

  String get language {
    var settings = Hive.box("settings");
    var _language = settings.get("language");
    if (_language == null) {
      language = _language = "en";
    }
    return _language;
  }

  set language(String? value) {
    var settings = Hive.box("settings");
    settings.put("language", value);
  }

  bool get visibility {
    var settings = Hive.box("settings");
    var _visibility = settings.get("visibility");
    if (_visibility == null) {
      visibility = _visibility = true;
    }
    return _visibility;
  }

  set visibility(bool? value) {
    var settings = Hive.box("settings");
    settings.put("visibility", value);
  }

  bool get advanced {
    var settings = Hive.box("settings");
    var _advanced = settings.get("advanced");
    if (_advanced == null) {
      advanced = _advanced = false;
    }
    return _advanced;
  }

  set advanced(bool? value) {
    var settings = Hive.box("settings");
    settings.put("advanced", value);
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

  NetworkType get network {
    var settings = Hive.box("settings");
    var _network = settings.get("network") as String?;
    if (_network == null) {
      network = NetworkType.mainnet;
      _network = network.name;
    }
    return NetworkType.network(_network);
  }

  set network(NetworkType value) {
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

  bool get localAuth {
    var settings = Hive.box("settings");
    var _localAuth = settings.get("localAuth") as bool?;
    if (_localAuth == null) {
      localAuth = false;
      _localAuth = localAuth;
    }
    return _localAuth;
  }

  set localAuth(bool value) {
    var settings = Hive.box("settings");
    settings.put("localAuth", value);
  }
}
