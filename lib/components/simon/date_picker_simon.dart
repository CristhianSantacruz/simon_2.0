import 'package:flutter/material.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

Future<DateTime?> selectDate({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String helpText = "Selecciona una fecha",
  String cancelText = "Cancelar",
  String confirmText = "Aceptar",
  Color headerBackgroundColor = simon_finalPrimaryColor
}) async {
  final DateTime now = DateTime.now();
  final DateTime maxDate = lastDate ?? DateTime(now.year - 18, now.month, now.day);
  
  // Llamamos al showDatePicker
  final DateTime? picked = await showDatePicker(
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: ThemeData(
          datePickerTheme: DatePickerThemeData(
            headerBackgroundColor: headerBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            headerForegroundColor: Colors.white,
            headerHelpStyle: const TextStyle(fontSize: 16),
          ),
          primarySwatch: Colors.grey,
          splashColor: Colors.white,
          textTheme: const TextTheme(
            headlineLarge: TextStyle(color: Colors.black),
          ),
          colorScheme: ColorScheme.light(
            primary: headerBackgroundColor,
            onSecondary: Colors.black,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
          dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
        ),
        child: child ?? const Text(""),
      );
    },
    locale: const Locale('es'),
    context: context,
    initialDate: initialDate ?? maxDate,
    firstDate: firstDate ?? DateTime(1940),
    lastDate: maxDate,
    helpText: helpText,
    cancelText: cancelText,
    confirmText: confirmText,
  );

  return picked;
}
