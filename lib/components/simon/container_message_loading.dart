import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';

class ContainerMessageLoading extends StatelessWidget {
  final String? textTitle;
  final String? textSubtitle;
  const ContainerMessageLoading({super.key, this.textSubtitle, this.textTitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width *
            0.7, // 80% del ancho de la pantalla
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: // ignore: deprecated_member_use
                  Colors.black.withOpacity(0.2), // Sombra con opacidad
              blurRadius: 4,
              offset: const Offset(0, 2), // Desplazamiento de la sombra
            ),
          ],
        ),
        padding: const EdgeInsets.all(20), // Padding interno
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ajustar el tamaño de la columna al contenido
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textTitle != null
                ? Text(
                    textTitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Color del texto
                    ),
                    textAlign: TextAlign.center, // Centrar el texto
                  )
                : const SizedBox(),
            const SizedBox(height: 10), // Espacio entre los textos
            Text(
              textSubtitle ?? "Cargando...",
              style: const TextStyle(
                fontSize: 14,
                color: simon_finalPrimaryColor, // Color del texto con opacidad
              ),
            ),
            const SizedBox(height: 20), // Espacio antes del CircularProgressIndicator
            const LoaderAppIcon()
          ],
        ),
      ),
    );
  }
}
