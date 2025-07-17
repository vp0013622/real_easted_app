import 'package:flutter/material.dart';
import 'package:inhabit_realties/constants/contants.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme{
  static TextTheme lightTextTheme = TextTheme(
    // Headlines
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.lightDarkText),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.lightDarkText),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.lightDarkText),

    // Titles
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.lightDarkText),
    titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.lightDarkText),
    titleSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.lightDarkText),

    // Body
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.lightDarkText),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.lightDarkText),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.lightDarkText),

    // Labels
    labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightDarkText),
    labelMedium: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.lightDarkText),
    labelSmall: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.lightDarkText),    
  );


  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.darkWhiteText),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkWhiteText),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.darkWhiteText),

    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.darkWhiteText),
    titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkWhiteText),
    titleSmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.darkWhiteText),

    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.darkWhiteText),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.darkWhiteText),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.darkWhiteText),

    labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkWhiteText),
    labelMedium: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.darkWhiteText),
    labelSmall: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w500, color: AppColors.darkWhiteText),
  );

  // #region -------------- light disply ----------------
  //primary text theme
  static TextTheme textLightThemePrimary = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightPrimary), // primary large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightPrimary),  // primary medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightPrimary), // primary small
  );

  //success text theme
  static TextTheme textLightThemeSuccess = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightSuccess), // success large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightSuccess),  // success medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightSuccess), // success small
  );

  //danger text theme
  static TextTheme textLightThemeDanger = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightDanger), // danger large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightDanger),  // danger medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightDanger), // danger small
  );

  //warning text theme
  static TextTheme textLightThemeWarning = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightWarning), // warning large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightWarning),  // warning medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightWarning), // warning small
  );
  //#endregion

  // #region -------------- dark disply ----------------
   //primary text theme
  static TextTheme textDarkThemePrimary = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkPrimary), // primary large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkPrimary),  // primary medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkPrimary), // primary small
  );

  //success text theme
  static TextTheme textDarktThemeSuccess = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkSuccess), // success large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkSuccess),  // success medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkSuccess), // success small
  );

  //danger text theme
  static TextTheme textDarkThemeDanger = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkDanger), // danger large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkDanger),  // danger medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkDanger), // danger small
  );

  //warning text theme
  static TextTheme textDarkThemeWarning = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkWarning), // warning large
    displayMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkWarning),  // warning medium
    displaySmall: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkWarning), // warning small
  );
  //#endregion

  static ThemeData lightTheme(){
    return ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        cardColor: AppColors.lightCardBackground,
        primaryColor: AppColors.lightPrimary,
        textTheme: lightTextTheme,
        appBarTheme: AppBarTheme(
          color: AppColors.lightBackground,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: lightTextTheme.titleLarge!.copyWith(
            color: AppColors.darkCardBackground
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:  AppColors.brandTurnary,
            foregroundColor: AppColors.darkWhiteText,
            textStyle: lightTextTheme.bodyLarge,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                  ),
          )
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppColors.lightPrimary),
            textStyle: WidgetStateProperty.all(lightTextTheme.bodyMedium),
          ),
        )
      );
  }
  static ThemeData darkTheme(){
    return ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        cardColor: AppColors.darkCardBackground,
        primaryColor: AppColors.darkPrimary,
        textTheme: darkTextTheme,
        appBarTheme: AppBarTheme(
          color: AppColors.darkBackground,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: lightTextTheme.titleLarge!.copyWith(
            color: AppColors.darkWhiteText
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandTurnary,
            foregroundColor: AppColors.darkWhiteText,
            textStyle: lightTextTheme.bodyLarge,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                  ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(AppColors.darkPrimary),
            textStyle: WidgetStateProperty.all(darkTextTheme.bodyMedium),
          ),
        )
      );
  }
}