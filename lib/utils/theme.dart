import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WalletTheme {
  late final Color textColor;
  late final Color primary;
  late final Color secondary;
  late final Color black;
  late final Color background;
  late final Color gradientOne;
  late final Color gradientTwo;
  late final Color buttonsBackground;
  late final Color disabledButtonsBackground;
  late final Color buttonsForeground;
  late final Color errorColor;
  late final Color dropDownBackground;

  final fontFamily = GoogleFonts.montserrat().fontFamily;
  final double maxWidth = 450;

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
      buttonsBackground = Colors.grey[900]!;
      dropDownBackground = Colors.grey[900]!;
      disabledButtonsBackground = Colors.grey[700]!;
      buttonsForeground = Color(0xffffffff);
      errorColor = Color(0xffFF284F);
    } else if (themeMode == ThemeMode.light) {
      textColor = Color(0xff000000);
      primary = Color(0xffffffff);
      secondary = Color.fromARGB(255, 238, 238, 238);
      black = Color(0xff040404);
      background = Color(0xffB7B7B7);
      gradientOne = Color(0xfffe594e);
      gradientTwo = Color(0xff1902d5);
      dropDownBackground = Color(0xffffffff);
      buttonsBackground = Color(0xff1B1B1B);
      disabledButtonsBackground = Colors.grey[700]!;
      buttonsForeground = Color(0xffffffff);
      errorColor = Color(0xffFF284F);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.w),
            side: BorderSide(
              width: 2,
              color: primary,
            ),
          ),
          elevation: 1,
          maximumSize: Size.fromWidth(
            450,
          ),
          foregroundColor: buttonsForeground,
          disabledBackgroundColor: disabledButtonsBackground,
          disabledForegroundColor: buttonsForeground,
          backgroundColor: buttonsBackground,
          minimumSize: Size(450, 50.h),
          textStyle: TextStyle(
            fontFamily: fontFamily,
            color: textColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: secondary,
        thickness: 2,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        backgroundColor: buttonsBackground,
        foregroundColor: buttonsForeground,
        extendedTextStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: textColor,
          fontFamily: fontFamily,
          fontSize: 16.sp,
          height: 1.3.h,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        errorStyle: TextStyle(fontSize: 0, height: 0.01),
        errorMaxLines: 1,
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: textColor.withOpacity(.6),
          height: 1.3.h,
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: textColor.withOpacity(.6),
          height: 1.3.h,
        ),
        filled: true,
        fillColor: secondary,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: WalletTheme.instance.errorColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: WalletTheme.instance.errorColor,
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
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: primary,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
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
          fontSize: 20.sp,
          letterSpacing: 1.2,
          height: 1.3,
          textBaseline: TextBaseline.alphabetic,
          color: textColor,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
          letterSpacing: 1.1,
          color: textColor,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
          color: textColor,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16.sp,
          color: textColor,
          height: 1.3,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18.sp,
          height: 1.3,
          color: textColor,
        ),
      ),
      iconTheme: IconThemeData(color: textColor, opacity: .8),
    );
  }

  static late WalletTheme instance;
}
