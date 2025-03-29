import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/screens/legends_uploads_information/principal_upload_user_documentation.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_documents_types.services.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
class UploadVehicleDocumentation extends StatefulWidget {
  final String name;
  final int idDocument;
  final int idVehicle;
  final bool? onlyMatricula;  

  const UploadVehicleDocumentation(
      {super.key,
      //this.withDateExpiration = false,
      required this.name,
      required this.idVehicle,
      this.onlyMatricula = false,
      required this.idDocument});

  @override
  State<UploadVehicleDocumentation> createState() =>
      _UploadUserDocumentationState();
}

class _UploadUserDocumentationState extends State<UploadVehicleDocumentation> {
  final TextEditingController documentController = TextEditingController();
  String? documentFilePath;
  String? secondDocumentFilePath;
  final userDocuments = UserDocumentsTypesServices();
  bool withDateExpiration = false;

  @override
  void initState() {
    super.initState();
    withDateExpiration = widget.name == ("Cedula") ||
        widget.name == ("Matricula"); //|| widget.name == ("Matricula");
  }

  final vehicleServices = VehiclesUserServices();



  void showCustomAlertImpugnar(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomAlertDialogWithActions(
        title: "!Perfecto!",
        content: "Tu vehiculo esta listo.",
        contentQuestion: "¿Deseas impugnar ahora?",
        onAccept: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, Routes.impugnaMultas);
          print("Aceptar presionado");
        },
        onCancel: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, Routes.dashboard);
          print("No presionado");
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    //final providerDocuments = Provider.of<DocumentUserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new,
                color: appStore.isDarkMode ? Colors.white : Colors.black)),
        surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
        iconTheme: IconThemeData(
            color: appStore.isDarkMode ? Colors.white : Colors.black),
        title: Text(
          textAlign: TextAlign.center,
          'Subir Documento',
          style: primarytextStyle(
            color: appStore.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16), // Padding responsivo
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sube tu ${widget.name} sin problemas para realizar tus tramites en todo momento",
                style: const TextStyle(fontSize: 16, color: resendColor),
                textAlign: TextAlign.center,
              ).center(),

             UploadUserDocumentation(name: "Matricula", idDocument: 1,onlyMatricula: widget.onlyMatricula,idVehicle: widget.idVehicle,)
            ],
          ),
        ),
      ),
    );
  }
}
