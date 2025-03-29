import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/components/simon/dialog_with_image.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/documents_user/new_upload_vehicle_document.dart';
import 'package:simon_final/screens/documents_user/view_docs/view_vehicle_document.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../main.dart';
import '../../../../models/article_model.dart';
import 'package:animate_do/animate_do.dart';

class DocsVehicleAssociatedScreen extends StatefulWidget {
  final int idSelectedVehicle;
  const DocsVehicleAssociatedScreen({super.key, this.idSelectedVehicle = 0});

  @override
  State<DocsVehicleAssociatedScreen> createState() =>
      _DocsVehicleAssociatedScreenState();
}

class _DocsVehicleAssociatedScreenState
    extends State<DocsVehicleAssociatedScreen> {
  List<ArticleModel> vehicleList = [];
  VehicleModelUser? selectedVehicle;
  int idSelectedVehicle = 0;
  int idSelectedDocument = 0;
  List<VehicleDocumentTypeModel> documents = [];
  bool isLoadingDocuments = false;
  bool errorLoadingDocuments = false;

  String? vehicleDocumentFilePath;
  bool documentLoading = false;

  final vehicleServices = VehiclesUserServices();

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _fetchVehicleData(userProvider.user.id, userProvider.currentProfile);
    idSelectedVehicle = widget.idSelectedVehicle;
    List<VehicleModelUser> vehicleList =
        context.read<VehicleProvider>().vehicleList;
    if (this.idSelectedVehicle != 0) {
      this.selectedVehicle =
          vehicleList.firstWhere((element) => element.id == idSelectedVehicle);
      _fetchVehicleDocuments(
          idSelectedVehicle, userProvider.user.id, userProvider.currentProfile);
    }
  }

  Future<void> _fetchVehicleData(int userId, int profileId) async {
    await context.read<VehicleProvider>().fetchVehicles(userId, profileId);
  }

  Future<void> _fetchVehicleDocuments(
      int vehicleId, int userId, int profileId) async {
    setState(() {
      isLoadingDocuments = true;
      errorLoadingDocuments = false;
    });
    try {
      documents = await vehicleServices.getVehicleDocumentTypes(
          vehicleId, userId, profileId);
    } catch (e) {
      setState(() {
        errorLoadingDocuments = true;
      });
    }

    setState(() {
      isLoadingDocuments = false;
    });
  }

  final _vehicleService = VehiclesUserServices();
  Future<void> _deleteDocument(int documentId) async {
    try {
      await _vehicleService.deleteDocumentUpload(documentId).then((_) {
        MessagesToast.showMessageSuccess("Documento eliminado");
      });
    } catch (e) {
      MessagesToast.showMessageError(
          "Ocurrio un fallo al eliminar el documento");
    }
  }

  void fecthVehicleData(int userId, int profileId) async {
    await context.read<VehicleProvider>().fetchVehicles(userId, profileId);
  }

  void _showDocumentOptions(
      BuildContext context, VehicleDocumentTypeModel documentVehicle) {
    debugPrint("Datos que envie");
    debugPrint("Type ${documentVehicle.vehicleDocument?.mimeType}");
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) => DocumentWithPreviewOptionsDialog(
              iconData: Icons.badge,
              documentId: documentVehicle.vehicleDocument!.id,
              mimeType: documentVehicle.vehicleDocument!.mimeType,
              secondDocumentUrl: documentVehicle.vehicleDocument!.originalUrl2,
              title: documentVehicle.name,
              imageUrl: documentVehicle.vehicleDocument!.originalUrl,
              documentUrl: documentVehicle.vehicleDocument!.originalUrl,
              onPressedDeleted: () async {
                await _deleteDocument(documentVehicle.vehicleDocument!.id);
                await _fetchVehicleData(
                    userProvider.user.id, userProvider.currentProfile);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ViewVehicleDocument()));

              },
            ));

 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios_new,
                color: appStore.isDarkMode ? Colors.white : Colors.black)),
        centerTitle: true,
        surfaceTintColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
        iconTheme: IconThemeData(
            color: appStore.isDarkMode ? Colors.white : Colors.black),
        title: Text('Documentos del vehículo',
            style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black,
                size: 16)),
        backgroundColor: appStore.isDarkMode
            ? scaffoldDarkColor
            : context.scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (idSelectedVehicle != 0)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          'Documentos asociados a ${selectedVehicle!.plateNumber}',
                          style: boldTextStyle(size: 13,color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (isLoadingDocuments)
                        const Center(child: CircularProgressIndicator())
                      else if (errorLoadingDocuments)
                        const Center(
                            child: Text('Error al cargar los documentos'))
                      else if (documents.isEmpty)
                        const Center(
                            child: Text(
                                'No hay documentos asociados a este vehículo.'))
                      else
                        Expanded(
                          child: ListView(
                            children: documents.map((doc) {
                              final documentExits = doc.vehicleDocument != null;
                              return FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: documentExits ? 2 : 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            DEFAULT_RADIUS),
                                        side: BorderSide(
                                            color: documentExits
                                                ? simon_finalPrimaryColor
                                                : Colors.transparent,
                                            width: 1),
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: doc.vehicleDocument != null
                                              ? appStore.isDarkMode ? scaffoldDarkColor : Colors.white
                                              : simon_finalSecondaryColor,
                                          borderRadius: BorderRadius.circular(
                                              DEFAULT_RADIUS),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Título con icono
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    doc.name,
                                                    style: primaryTextStyle(
                                                      size: 18,
                                                      weight: FontWeight.bold,
                                                      color:
                                                          doc.vehicleDocument !=
                                                                  null
                                                              ? appStore.isDarkMode ? scaffoldLightColor : Colors.black
                                                              : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                doc.vehicleDocument != null
                                                    ? const Icon(Ionicons.car,
                                                        color:
                                                            simon_finalPrimaryColor,
                                                        size: 28)
                                                    : Flash(
                                                        duration:
                                                            const Duration(
                                                                seconds: 3),
                                                        infinite: true,
                                                        child: const Icon(
                                                            Ionicons
                                                                .cloud_upload_outline,
                                                            color: simonNaranja,
                                                            size: 28),
                                                      ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),

                                            // Mensaje de documento
                                            doc.vehicleDocument != null
                                                ? Text(
                                                    "Archivo subido correctamente",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: appStore.isDarkMode ? Colors.white54 : Colors.black54),
                                                  )
                                                : Text(
                                                    "Archivo no subido",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: appStore.isDarkMode ? Colors.white54 : Colors.black54),
                                                  ),

                                            const SizedBox(height: 12),

                                            // Botón de acción
                                            GestureDetector(
                                              onTap: () {
                                                if (doc.vehicleDocument ==
                                                    null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UploadVehicleDocumentation(
                                                        name: doc.name,
                                                        idVehicle:
                                                            selectedVehicle!
                                                                    .id ??
                                                                0,
                                                        idDocument: doc.id,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  _showDocumentOptions(
                                                      context, doc);
                                                }
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: doc.vehicleDocument !=
                                                          null
                                                      ? simon_finalPrimaryColor
                                                      : Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          DEFAULT_RADIUS),
                                                  border: doc.vehicleDocument !=
                                                          null
                                                      ? Border.all(
                                                          color:
                                                              simon_finalPrimaryColor,
                                                          width: 2)
                                                      : null,
                                                ),
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      doc.vehicleDocument !=
                                                              null
                                                          ? Ionicons.eye_outline
                                                          : Icons
                                                              .file_upload_outlined,
                                                      size: 26,
                                                      color: doc.vehicleDocument !=
                                                              null
                                                          ? Colors.white
                                                          : simon_finalPrimaryColor,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      doc.vehicleDocument !=
                                                              null
                                                          ? " Ver Documento"
                                                          : "Subir Documento",
                                                      style: primaryTextStyle(
                                                        size: 14,
                                                        weight: FontWeight.w700,
                                                        color: doc.vehicleDocument !=
                                                                null
                                                            ? Colors.white
                                                            : simon_finalPrimaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

void showCustomAlertImpugnar(BuildContext context, void Function()? onAccept) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return CustomAlertDialogWithActions(
        title: "Informacion",
        content:
            "Recuerda que estos documentos son necesario para un proceso de impugnación.",
        contentQuestion: "¿Deseas eliminar ahora?",
        onAccept: onAccept,
        onCancel: () {
          Navigator.pop(context);
          print("No presionado");
        },
      );
    },
  );
}
