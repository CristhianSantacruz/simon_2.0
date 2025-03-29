import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';

class LoaderUtils {
  static void showLoaderDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const LoaderAppIcon(); // Usa tu widget de carga personalizado
      },
    );
  }

  static void hideLoaderDialog(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
