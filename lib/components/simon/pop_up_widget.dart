import 'package:flutter/material.dart';
import 'package:simon_final/utils/images.dart';
import 'package:url_launcher/url_launcher.dart';

class PopUpAfterLogin extends StatelessWidget {
  final String photoUrl;
  final String? redirect;
  final bool? isAsset;

  const PopUpAfterLogin({Key? key, required this.photoUrl, this.isAsset , this.redirect})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(

      onTap: (){
        if(redirect != null){
          _launchURL(redirect!);
        }
      },
      child: AlertDialog(
        contentPadding: EdgeInsets.zero, // Elimina el padding por defecto
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        content: Container(
          constraints: BoxConstraints(
            maxWidth: size.width *
                0.08, // Ancho máximo para evitar crecimiento infinito
            maxHeight: size.height *
                0.30, // Altura máxima para evitar crecimiento infinito
          ),
          child: Stack(
            children: [
              // Contenido del pop-up (imagen)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: this.isAsset == false
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 250, // Establece un ancho fijo
                        height: 0.30 * size.height, // Establece una altura fija
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 300,
                            height: 300,
                            alignment: Alignment.center,
                            child: const Text(
                              "No se pudo cargar la imagen",
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      )
                    : Center(
                      child: Image.network(
                          photoUrl, // Ruta de la imagen local
                          width: 250, // Ajusta el ancho según sea necesario
                          height: size.height *
                              0.30, // Ajusta la altura según sea necesario
                          fit: BoxFit
                              .contain, // Cubre todo el espacio sin espacios vacíos
                        ),
                    ),
              ),
      
              // Botón de cierre (X) en la esquina superior derecha
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Color de fondo
                    borderRadius: BorderRadius.circular(10), // Radio de bordes
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el pop-up
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _launchURL(String url) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'No se puede abrir $url';
  }
}
