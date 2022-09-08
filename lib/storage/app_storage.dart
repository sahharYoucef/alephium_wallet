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
    return _price as double?;
  }

  String? get formattedPrice {
    if (price != null) return NumberFormat.currency(symbol: "\$").format(price);
    return null;
  }

  set price(double? value) {
    var settings = Hive.box("settings");
    settings.put("price", value);
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
}
