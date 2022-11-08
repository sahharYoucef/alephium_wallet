import 'package:alephium_wallet/app.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

export 'package:alephium_wallet/log/logger_service.dart';

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var f = 1 - percent / 100;
  return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
      (c.blue * f).round());
}

Color lighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  var p = percent / 100;
  return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round());
}

class AmountFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var isValid =
        double.tryParse(newValue.text) != null || newValue.text.isEmpty;
    if (isValid) {
      return newValue;
    }
    return oldValue;
  }
}

extension Helper on BuildContext {
  double get width {
    return MediaQuery.of(this).size.width;
  }

  double get height {
    return MediaQuery.of(this).size.height;
  }

  double get viewInsetsBottom {
    return MediaQuery.of(this).viewInsets.bottom;
  }

  double get topPadding {
    return MediaQuery.of(this).padding.top;
  }

  showSnackBar(String content, {Level level = Level.info}) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      backgroundColor: level == Level.error
          ? Colors.red.withOpacity(.5)
          : Colors.blueAccent.withOpacity(.5),
      behavior: SnackBarBehavior.floating,
      content: Row(
        children: [
          if (level == Level.info)
            Icon(
              Icons.info,
              color: Colors.white,
            )
          else if (level == Level.error)
            Icon(
              Icons.error,
              color: Colors.white,
            ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              content,
              style: Theme.of(this)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    ));
  }
}
