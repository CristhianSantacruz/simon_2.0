import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentWithPreviewOptionsDialog extends StatelessWidget {
  final int documentId;
  final String title;
  final String mimeType;
  final String imageUrl;
  final String documentUrl;
  final String? secondDocumentUrl;
  final IconData? iconData;
  final  void Function()? onPressedDeleted;
  const DocumentWithPreviewOptionsDialog({
    required this.title,
    required this.imageUrl,
    required this.documentUrl,
    this.secondDocumentUrl,
    required this.mimeType,
    required this.documentId,
    required this.onPressedDeleted,
    this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final docName =  documentUrl.split('/').last;
   
    return AlertDialog(

      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(DEFAULT_RADIUS), // Bordes redondeados
      ),
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        width: double.infinity, // Ocupa todo el ancho
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: simon_finalPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(DEFAULT_RADIUS),
            topRight: Radius.circular(DEFAULT_RADIUS),
          ),
        ),
        child: Stack(
          children: [
           
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
      content: mimeType == "image"
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Parte Frontal"),
                Image.network(
                  imageUrl,
                  width: 300,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        color: Colors.red); // Manejo de errores
                  },
                ),
                if (secondDocumentUrl != null && secondDocumentUrl!.isNotEmpty)
                  const Text("Parte Trasera").paddingTop(15),
                if (secondDocumentUrl != null && secondDocumentUrl!.isNotEmpty)
                 Image.network(
                  secondDocumentUrl!,
                  width: 300,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error,
                        color: Colors.red); // Manejo de errores
                  },
                ),
              ],
            )
          : Column(
            mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Archivo subido correctamente"),
                const SizedBox(height: 10),
                Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              color: simonNaranja, size: 40),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "${docName}",
                              style: const TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new,
                                color: simon_finalPrimaryColor),
                            onPressed: () {
                              _launchURL(documentUrl);
                            },
                          ),
                        ],
                      ),
                    )),
              ],
            ),
      actions: [
        
       AppButton(
        width: double.infinity,
         shapeBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
        ),
          color: simonNaranja,
          onTap: (){
            showCustomAlertImpugnar(context, onPressedDeleted);
          },
          child: const Text(
            "Eliminar",
            style: TextStyle(color: Colors.white),
          ),
        ).expand(),
        // Botón "Ver documento"
        
      ],
    );
  }

  // Función para abrir una URL
  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir $url';
    }
  }
  void showCustomAlertImpugnar(BuildContext context, void Function()? onAccept) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CustomAlertDialogWithActions(
        title: "Informacion",
        content:"Recuerda que estos documentos son necesario para un proceso de impugnación.",
        contentQuestion: " ¿Deseas eliminar ahora?",
        onAccept: onAccept,
        onCancel: () {
          Navigator.pop(context);
          print("No presionado");
        },
      );
    },
  );
}

}
