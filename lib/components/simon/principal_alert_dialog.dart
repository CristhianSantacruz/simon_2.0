import 'package:simon_final/main.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/screens/documents_user/view_docs/view_vehicle_document.dart';
import 'package:simon_final/screens/legends_uploads_information/principal_page.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';

class PrincipalAlertDialog extends StatelessWidget {
  final String? title;
  final String content;
  final IconData? iconData;
  final Color? color;
  final List<String> requirements;
  final List<String> types;

  const PrincipalAlertDialog(
      {super.key,
      this.title,
      required this.content,
      required this.iconData,
      this.color,
      required this.types,
      required this.requirements});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(DEFAULT_RADIUS)), // Bordes más redondeados
      elevation: 10, // Sombra más pronunciada
      child: Container(
        decoration: BoxDecoration(
          color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
        ),
        padding: const EdgeInsets.all(24), // Más espacio interno
        width: MediaQuery.of(context).size.width *
            0.95, // 90% del ancho de la pantalla
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación de texto
          mainAxisSize: MainAxisSize.min, // Ajustar al contenido
          children: [
            // Icono
            Icon(
              iconData ?? Icons.info_outline, // Icono por defecto
              size: 60,
              color: color ?? simon_finalPrimaryColor,
            ),
            const SizedBox(height: 7), // Espaciado

            // Título
            if (title != null)
              Text(
                title!,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8), // Espaciado

            // Contenido
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: appStore.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16), // Espaciado

            // Lista de requisitos
            Column(
              children: requirements.map((requerimient) {
                return _RowText(title: requerimient);
              }).toList(),
            ),
            const SizedBox(height: 24), // Espaciado

            // Botón
            GestureDetector(
              onTap: () {
                debugPrint("Informacion de los tipos");
                debugPrint(types.toString());
                 context.read<PageControllerProvider>().reset();

                //Provider.of<PageControllerProvider>(context,listen: false).reset();

                if (types.length == 1 && types[0] == "vehicle_documents") {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const ViewVehicleDocument()));
                  return;
                }
              

                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PrincipalUploadDocument(
                            types: types,isOne: false,))); 
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: simon_finalPrimaryColor,
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                ),
                child: const Text(
                  "Entendido, Comenzar",
                  style: TextStyle(color: Colors.white),
                ).center(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RowText extends StatelessWidget {
  final String title;

  const _RowText({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4), // Espaciado vertical
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color:Colors.green, // Color verde para el ícono de verificación
          ),
          const SizedBox(width: 8), // Espaciado
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: appStore.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
