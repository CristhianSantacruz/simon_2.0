import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import 'colors.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(simon_finalPrimaryColor),
      primaryColor: simon_finalPrimaryColor,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: simon_finalPrimaryColor,
        outlineVariant: borderColor,
      ),
      fontFamily: GoogleFonts.roboto().fontFamily,
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
      iconTheme: IconThemeData(color: textPrimaryColorGlobal),
      textTheme: GoogleFonts.robotoTextTheme(),
      unselectedWidgetColor: Colors.black,
      dividerColor: borderColor,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: Colors.white,
      ),
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
      ),
      dialogTheme: DialogTheme(shape: dialogShape()),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(simon_finalPrimaryColor),
      primaryColor: simon_finalPrimaryColor,
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      scaffoldBackgroundColor: scaffoldDarkColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: simon_finalPrimaryColor,
        outlineVariant: borderColor,
        onSurface: textPrimaryColorGlobal,
      ),
      fontFamily: GoogleFonts.roboto().fontFamily,
      bottomNavigationBarTheme:
          BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
      iconTheme: IconThemeData(color: Colors.white),
      textTheme: GoogleFonts.robotoTextTheme(),
      unselectedWidgetColor: Colors.white60,
      useMaterial3: true,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
        ),
        backgroundColor: scaffoldDarkColor,
      ),
      
      dividerColor: dividerDarkColor,
      cardColor: cardDarkColor,
      dialogTheme: DialogTheme(shape: dialogShape()),
    );
  }
}
