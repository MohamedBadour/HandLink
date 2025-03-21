import 'package:flutter/material.dart';

class ThemeConfig {
  static const Color mainColor = Color(0xFF0A7075);
  static const Color lightColor = Color(0xFFF0F3F2);
  static const Color darkColor = Color(0xFF121212);
  static const Color darkHover = Color(0xFF3A3A3A);

  static const BoxShadow mainShadow = BoxShadow(
    color: Color.fromRGBO(145, 158, 171, 0.2),
    blurRadius: 10,
    spreadRadius: 1,
    offset: Offset(0, 2),
  );

  static const TextStyle mainTextStyle = TextStyle(
    fontFamily: 'Encode Sans Expanded',
    color: mainColor,
  );

  static const TextStyle lightTextStyle = TextStyle(
    fontFamily: 'Encode Sans Expanded',
    color: lightColor,
  );

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      primaryColor: mainColor,
      colorScheme: const ColorScheme.light(
        primary: mainColor,
        secondary: lightColor,
      ),
      scaffoldBackgroundColor: lightColor,
      textTheme: const TextTheme(
        bodyLarge: mainTextStyle,
        bodyMedium: lightTextStyle,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: mainColor,
        disabledColor: mainColor.withOpacity(0.6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: mainColor,
        iconTheme: IconThemeData(color: lightColor),
        titleTextStyle: TextStyle(color: lightColor, fontSize: 20),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      primaryColor: mainColor,
      colorScheme: const ColorScheme.dark(
        primary: mainColor,
        secondary: darkColor,
      ),
      scaffoldBackgroundColor: darkColor,
      textTheme: TextTheme(
        bodyLarge: mainTextStyle.copyWith(color: darkHover),
        bodyMedium: lightTextStyle,
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: darkHover,
        disabledColor: darkHover.withOpacity(0.6),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkColor,
        iconTheme: IconThemeData(color: lightColor),
        titleTextStyle: TextStyle(color: lightColor, fontSize: 20),
      ),
    );
  }
}
