import 'package:alephium_wallet/app.dart';
import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/routes/home/widgets/qr_view.dart';
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

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
      String content,
      {Level level = Level.info}) {
    return scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        backgroundColor: level == Level.error ? Colors.red : Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        content: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
          SizedBox(
            width: 10,
          ),
          Text(
            content,
            style: Theme.of(this)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white),
          ),
          SizedBox(
            width: 10,
          ),
          Spacer(),
          InkWell(
            onTap: () {
              scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
            },
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
          )
        ])));
  }
}

Future<Map<String, dynamic>?> showQRView(
  BuildContext context, {
  WalletHomeBloc? walletHomeBloc,
  bool isTransfer = true,
}) async {
  return showGeneralDialog<Map<String, dynamic>?>(
    barrierDismissible: true,
    barrierLabel: "receive",
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) => Padding(
      padding: EdgeInsets.only(
          top: 16, bottom: 16 + context.viewInsetsBottom, left: 16, right: 16),
      child: Center(
        child: Material(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(
            16,
          ),
          elevation: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              16,
            ),
            child: QRScannerView(
              bloc: walletHomeBloc,
              isTransfer: isTransfer,
            ),
          ),
        ),
      ),
    ),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: Offset(0, 1),
            end: Offset.zero,
          ),
        ),
        child: child,
      );
    },
  );
}
