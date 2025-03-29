import 'package:flutter/material.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class CustomAlertDialogWithActions extends StatelessWidget {
  final String title;
  final String content;
  final String? contentQuestion;
  final String acceptText;
  final String cancelText;
  final VoidCallback? onAccept;
  final VoidCallback? onCancel;

  const CustomAlertDialogWithActions({
    required this.title,
    required this.content,
    this.acceptText = "Aceptar",
    this.cancelText = "No",
    this.onAccept,
    this.onCancel,
    this.contentQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS), // Bordes redondeados
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Tamaño mínimo necesario
        children: [
          Container(
            width: double.infinity, // Ocupa todo el ancho
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: simon_finalPrimaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(DEFAULT_RADIUS),
                topRight: Radius.circular(DEFAULT_RADIUS),
              ),
            ),
            child: Center(
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
          ),
          // Contenido del diálogo
          contentQuestion != null ? Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: primarytextStyle(size: 15,color: Colors.black87),
              textAlign: TextAlign.center, // Texto centrado
            ),
          ) : const SizedBox.shrink(),
          Text("${contentQuestion}",style: primaryTextStyle(size: 16,color: Colors.black,weight: FontWeight.bold),).center().paddingBottom(16),
          
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, // Espacio entre botones
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel ?? () {
                      Navigator.of(context).pop(); // Cierra el diálogo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: simonNaranja,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(  DEFAULT_RADIUS), // Bordes redondeados
                      ),
                    ),
                    child: Text(
                      cancelText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                20.width,
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept ?? () {
                      Navigator.of(context).pop(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: simon_finalPrimaryColor, 
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS), // Bordes redondeados
                      ),
                    ),
                    child: FittedBox(
                      child: Text(
                        acceptText,
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
          ),
        ],
      ),
    );
  }
}