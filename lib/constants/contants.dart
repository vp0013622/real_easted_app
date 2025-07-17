import 'package:flutter/material.dart';

class AppConstants {
  //static const String baseUrl = 'http://localhost:3000/api';
  static const String baseUrl = 'https://insightwaveit-backend-p0cl.onrender.com/api'; 
}

class AppColors {
  //#region light theme
  static const lightBackground = Color(0xFFF9FAFB);
  static const lightCardBackground = Color(0xFFFFFFFF);
  static const lightDarkText = Color(0xFF464646);
  static const lightSuccess = Color(0xFF8AC640);
  static const lightDanger = Color(0xFFEB5463);
  static const lightWarning = Color(0xFFFFCE55);
  static const lightPrimary = Color(0xFF5E9BEB);
  static const lightSecondary = Color(0xFF00726D);
  static const lightShadowColor = Color.fromRGBO(0, 0, 0, 0.1);
  //#endregion

  //#region dark theme
  static const darkBackground = Color(0xFF0B0B0B);
  static const darkCardBackground = Color(0xFF2D2D2D);
  static const darkWhiteText = Color(0xFFF9FAFB);
  static const darkSuccess = Color(0xFF8AC640);
  static const darkDanger = Color(0xFFD94553);
  static const darkWarning = Color(0xFFF6BB41);
  static const darkPrimary = Color(0xFF925FF0);
  static const darkSecondary = Color(0xFF00726D);
  static const darkShadowColor = Color.fromRGBO(255, 255, 255, 0.05);
  //#endregion

  //brand
  static const brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color.fromRGBO(163, 0, 163, 1), // #A300A3
      Color.fromRGBO(217, 2, 219, 1), // #D902DB
      Color.fromRGBO(108, 2, 107, 1), // #6C026B
    ],
  );

  static const brandSecondary = Color.fromRGBO(163, 0, 163, 1);
  static const brandPrimary = Color.fromRGBO(217, 2, 219, 1);
  static const brandTurnary = Color.fromRGBO(108, 2, 107, 1);

  //gry color:
  static const greyColor = Colors.grey;
  static Color greyColor2 = Colors.grey[600]!;

  //#region default sizings
  static const defaultPadding = 20.0;
  //#endregion

  // Get success color based on theme
  static Color successColor(bool isDark) => isDark ? darkSuccess : lightSuccess;

  // Get warning color based on theme
  static Color warningColor(bool isDark) => isDark ? darkWarning : lightWarning;
}
