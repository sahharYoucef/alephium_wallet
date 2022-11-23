import 'package:alephium_wallet/utils/gradient_input_border.dart';
import 'package:alephium_wallet/utils/gradient_stadium_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletTheme {
  late final Color textColor;
  late final Color primary;
  late final Color secondary;
  late final Color black;
  late final Color background;
  late final Color gradientOne;
  late final Color gradientTwo;
  final fontFamily = GoogleFonts.montserrat().fontFamily;

  static ThemeMode themeMode = ThemeMode.dark;

  WalletTheme() {
    if (themeMode == ThemeMode.system) {
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      if (isDarkMode)
        themeMode = ThemeMode.dark;
      else
        themeMode = ThemeMode.light;
    }
    if (themeMode == ThemeMode.dark) {
      textColor = Color.fromARGB(255, 225, 225, 225);
      primary = Color.fromARGB(255, 0, 0, 0);
      secondary = Color.fromARGB(255, 32, 32, 32);
      black = Color(0xff040404);
      background = Color(0xff171717);
      gradientOne = Color(0xff1902d5);
      gradientTwo = Color(0xfffe594e);
    } else if (themeMode == ThemeMode.light) {
      textColor = Color(0xff000000);
      primary = Color(0xffffffff);
      secondary = Color.fromARGB(255, 238, 238, 238);
      black = Color(0xff040404);
      background = Color(0xffe8dbeb);
      gradientOne = Color(0xfffe594e);
      gradientTwo = Color(0xff1902d5);
    }
  }

  ThemeData get themeData {
    return ThemeData(
      primaryColor: primary,
      fontFamily: fontFamily,
      backgroundColor: background,
      scaffoldBackgroundColor: background,
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: GradientStadiumBorder(),
          side: BorderSide(
            width: 2,
            color: primary,
          ),
          elevation: 5,
          foregroundColor: textColor,
          disabledForegroundColor: textColor.withOpacity(.2),
          backgroundColor: secondary,
          minimumSize: Size.fromHeight(50),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: secondary,
        thickness: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: secondary,
        foregroundColor: textColor,
        extendedTextStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: fontFamily,
          fontSize: 16,
          height: 1.3,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textColor.withOpacity(.6),
          height: 1.3,
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textColor.withOpacity(.6),
          height: 1.3,
        ),
        filled: true,
        fillColor: secondary,
        enabledBorder: GradientOutlineInputBorder(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xff1902d5),
              Color(0xfffe594e),
            ],
          ),
          borderSide: BorderSide(
            width: 2,
            color: primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: gradientTwo,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        border: GradientOutlineInputBorder(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xff1902d5),
              Color(0xfffe594e),
            ],
          ),
          borderSide: BorderSide(
            width: 2,
            color: primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 20,
          letterSpacing: 1.2,
          height: 1.3,
          textBaseline: TextBaseline.alphabetic,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
          letterSpacing: 1.1,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: textColor,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          height: 1.3,
          color: textColor,
        ),
      ),
      iconTheme: IconThemeData(color: textColor, opacity: .8),
    );
  }

  static late WalletTheme instance;
}
