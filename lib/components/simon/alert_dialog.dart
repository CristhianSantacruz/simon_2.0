import 'package:flutter/material.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final IconData? iconData;
  final Color? color;
  final bool? withRedirection;
  final String? route;
  final String? textButton;
  final void Function()? onPressedRoute;
  const CustomAlertDialog(
      {super.key, required this.title,
      required this.content,
      this.iconData,
      this.color,
      this.withRedirection,
      this.route,
      this.onPressedRoute,
      this.textButton});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(DEFAULT_RADIUS), // Bordes redondeados
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tamaño mínimo necesario
        children: [
          Container(
            width: double.infinity, // Ocupa todo el ancho
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color ?? simon_finalPrimaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DEFAULT_RADIUS),
                topRight: Radius.circular(DEFAULT_RADIUS),
              ),
            ),
            child: Stack(
              children: [
                // Ícono en la esquina superior izquierda
                if (iconData != null)
                  Positioned(
                    left: 0, // Alineado a la izquierda
                    top: 0, // Alineado arriba
                    child: Icon(
                      iconData,
                      color: Colors.white,
                    ),
                  ),
                // Título centrado
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, // Color del texto
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center, // Texto centrado
                  ),
                ),
              ],
            ),
          ),
          // Contenido del diálogo
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style:  TextStyle(
                fontSize: 16,
                color: appStore.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center, // Texto centrado
            ),
          ),
          // Botón de aceptar
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ElevatedButton(
                onPressed: onPressedRoute ?? () {
                  withRedirection == true
                      ? {
                          Navigator.of(context).pop(),
                          Navigator.of(context).pushReplacementNamed(route!)
                        }
                      : Navigator.of(context).pop(); // Cierra el diálogo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: simon_finalPrimaryColor, // Color del botón
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(8), // Bordes redondeados
                  ),
                ),
                child: Text(
                  textButton ?? "Aceptar",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
