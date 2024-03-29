import 'package:alephium_wallet/storage/app_storage.dart';
import 'package:intl/intl.dart';

abstract class Format {
  static var _format = NumberFormat(
    "##0.0##",
    "en_US",
  );

  static String humanReadableNumber(dynamic value) {
    if (value is BigInt) {
      value = value.toDouble();
    }
    if (value is String) {
      value = double.tryParse("${value}") ?? 0;
    }
    if ((value as double) == value.roundToDouble()) {
      return NumberFormat.compactCurrency(decimalDigits: 0, symbol: "")
          .format(value);
    }
    final numOfDecimals = value.toString().split(".").last.length;
    return NumberFormat.decimalPatternDigits(
            decimalDigits: numOfDecimals.clamp(0, 4))
        .format(value);
  }

  static String formatNumber(dynamic value) {
    if (value is String) {
      value = double.tryParse("${value}") ?? 0;
    }
    return _format.format(value);
  }

  static String formatCurrency(double value) {
    final symbol =
        getCurrencySymbol(AppStorage.instance.currency.toUpperCase());
    var decimalDigits = value >= 1.0 ? 2 : 3;
    var _currencyFormat =
        NumberFormat.currency(symbol: "$symbol ", decimalDigits: decimalDigits);
    final formattedValue = _currencyFormat.format(value);
    return formattedValue;
  }

  static String get symbol {
    return getCurrencySymbol(AppStorage.instance.currency.toUpperCase());
  }

  static String? convertToCurrency(double value) {
    if (AppStorage.instance.price == null) return null;
    final symbol =
        getCurrencySymbol(AppStorage.instance.currency.toUpperCase());
    var _currencyFormat = NumberFormat.currency(
      symbol: symbol,
    );
    return _currencyFormat.format(value * AppStorage.instance.price!);
  }

  static String getCurrencySymbol(String value) {
    return NumberFormat.simpleCurrency(name: value).currencySymbol;
  }
}
