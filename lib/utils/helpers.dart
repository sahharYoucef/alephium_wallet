import 'package:alephium_wallet/bloc/wallet_home/wallet_home_bloc.dart';
import 'package:alephium_wallet/log/logger_service.dart';
import 'package:alephium_wallet/routes/contacts/widgets/choose_wallet_dialog.dart';
import 'package:alephium_wallet/routes/home/widgets/qr_view.dart';
import 'package:alephium_wallet/routes/wallet_details/widgets/shake_widget.dart';
import 'package:alephium_wallet/storage/models/wallet_store.dart';
import 'package:alephium_wallet/utils/format.dart';
import 'package:alephium_wallet/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
export 'package:alephium_wallet/log/logger_service.dart';

Future<WalletStore?> showChooseWalletDialog(
  BuildContext context, {
  String? address,
  bool showAmount = true,
  String? title,
  String? content,
}) async {
  return showGeneralDialog<WalletStore?>(
    barrierDismissible: true,
    barrierLabel: "ChooseWalletDialog",
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
            child: ChooseWalletDialog(
              address: address,
              showAmount: showAmount,
              title: title,
              content: content,
              bloc: context.read<WalletHomeBloc>(),
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

extension StringHelpers on String {
  String get capitalize {
    if (this.isEmpty) return this;
    final value = this.replaceRange(0, 1, this[0].toUpperCase());
    return value;
  }
}

extension widgetHelpers on Widget {
  Widget shake(GlobalKey<ShakeErrorState> key) {
    return ShakeError(
      child: this,
      key: key,
    );
  }
}

extension isObscure on Text {
  Widget obscure([String? currency]) {
    if (currency == null) currency = Format.symbol;
    return ValueListenableBuilder<Box<dynamic>>(
        valueListenable: Hive.box("settings").listenable(keys: ["visibility"]),
        builder: (context, value, child) {
          var isObscure = value.get("visibility", defaultValue: true) as bool;
          return Text(
            isObscure
                ? this.data!
                : '${"###"} ${currency != null ? currency : ""}',
            style: this.style,
          );
        });
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

  double get bottomPadding {
    return MediaQuery.of(this).padding.bottom;
  }

  double get topPadding {
    return MediaQuery.of(this).padding.top;
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnackBar(
      String content,
      {Level level = Level.info}) {
    ScaffoldMessenger.of(this).removeCurrentSnackBar();
    return ScaffoldMessenger.of(this).showSnackBar(SnackBar(
        margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        backgroundColor: level == Level.error
            ? WalletTheme.instance.errorColor
            : Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        content: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          if (level == Level.info)
            const Icon(
              Icons.info,
              color: Colors.white,
            )
          else if (level == Level.error)
            const Icon(
              Icons.error,
              color: Colors.white,
            ),
          if (level == Level.error || level == Level.info)
            const SizedBox(
              width: 8,
            ),
          Expanded(
            child: AutoSizeText(
              content,
              maxFontSize: 14,
              maxLines: 3,
              style: Theme.of(this)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(this).hideCurrentSnackBar();
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

// String generateAvatarImage({
//   required String name,
//   required String background,
//   required String color,
// }) {
//   // get alphanumeric initials (to avoid issues with being outside range of btoa)
//   final initials = getInitials(name: name, alphanumeric: true);

//   // generate 64x64 svg with initials in the center (horizontal and vertical) with font color and background color and font family Helvetica (plus fallbacks)
//   final svg =
//       """<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64">
//     <rect width="64" height="64" fill="${background}" />
//     <text x="50%" y="54%" dominant-baseline="middle" text-anchor="middle" font-size="28" font-family="Helvetica, Arial, sans-serif" fill="${color}">${initials}</text>
//     </svg>""";
//   return "data:image/svg+xml;base64,${svg}";
// }

// String getInitials({required String name, bool alphanumeric = false}) {
//   final regExp = RegExp(r"/[^0-9a-z ]/");
//   final filtered = alphanumeric ? name.replaceAll(regExp, "") : name;
//   final uppercase = filtered.toUpperCase();
//   final uppercaseElements = uppercase.split(" ");

//   if (uppercaseElements.length == 1) {
//     return uppercaseElements[0].substring(0, 2);
//   }
//   final initials = uppercaseElements.map((n) => n[0]).toList();
//   return [initials[0], initials[initials.length - 1]].join("");
// }

// String getColor ({required String name})  {
//   final hash = id(name).substring(-2);
//   final index = int.parse(hash, radix : 16) % argentColorsArray.length;
//   return argentColorsArray[index];
// }

// String id(String text) {
//     final data =  KeccakDigest(256).process(ascii.encode(text));
//     return utf8.decode(data);
// }

// const argentColorsArray = [
//   "02BBA8",
//   "29C5FF",
//   "0078A4",
//   "FFBF3D",
//   "FFA85C",
//   "FF875B",
//   "FF675C",
//   "FF5C72",
// ]

