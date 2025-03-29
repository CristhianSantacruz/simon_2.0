import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simon_final/utils/colors.dart';

import '../main.dart';

const DEFAULT_RADIUS = 15.0;
final RegExp emailValidate = RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]');

InputDecoration inputDecoration(BuildContext context,
    {String? hintText,
    String? labelText,
    Widget? suffixIcon,
    Widget? prefixIcon}) {
  return InputDecoration(
    prefixIcon: prefixIcon ?? null,
    filled: true,
    fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
    border:OutlineInputBorder(borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
    labelText: labelText ?? '',
    hintStyle: TextStyle(color: appStore.isDarkMode ? Colors.white : resendColor),
    labelStyle: GoogleFonts.roboto(
        color: appStore.isDarkMode ? Colors.white :resendColor),
    suffixIcon: suffixIcon ?? null,
    hintText: hintText ?? '',
  );
}

ButtonStyle buttonStylePrimary(BuildContext context) {
  return TextButton.styleFrom(
    //textStyle: TextStyle(color: Colors.white),
    backgroundColor: simon_finalPrimaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );
}

ButtonStyle buttonStyleSeconday(BuildContext context) {
  return TextButton.styleFrom(
    textStyle: const TextStyle(color: simon_finalPrimaryColor),
    backgroundColor: appStore.isDarkMode ? Colors.white : simon_finalSecondaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );
}

ButtonStyle buttonStyleTerciary(BuildContext context) {
  return TextButton.styleFrom(
    textStyle: const TextStyle(color: simon_finalPrimaryColor),
    backgroundColor: simonNaranja,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
    ),
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );
}