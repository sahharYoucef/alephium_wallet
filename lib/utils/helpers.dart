import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/main.dart';
import 'package:flutter/material.dart';

export 'package:alephium_wallet/log/logger_service.dart';

extension Helper on BuildContext {
  double get width {
    return MediaQuery.of(this).size.width;
  }

  double get height {
    return MediaQuery.of(this).size.height;
  }

  showSnackBar(String content, {Level level = Level.info}) {
    scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      backgroundColor: level == Level.error ? Colors.red : Colors.blueAccent,
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
