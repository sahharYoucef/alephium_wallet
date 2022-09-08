import 'package:alephium_wallet/main.dart';
import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:intl/intl.dart';

abstract class Format {
  static var _format = NumberFormat(
    "##0.0000",
    "en_US",
  );
  static var _currencyFormat = NumberFormat.currency(symbol: "\$");

  static String formatNumber(dynamic value) {
    if (value is String) {
      value = double.tryParse("${value}") ?? 0;
    }
    return _format.format(value);
  }

  static String? convertToCurrency(double value) {
    if (AppStorage.instance.price == null) return null;
    return _currencyFormat.format(value * AppStorage.instance.price!);
  }
}
