import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/dialog_with_image.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/dashboard/dashboard.dart';
import 'package:simon_final/screens/documents_user/new_upload_vehicle_document.dart';
import 'package:simon_final/screens/vehicles/update_vechicle_data.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class VehiclePresentationModel extends StatefulWidget {
  final VehicleModelUser vehicle;
  const VehiclePresentationModel({super.key, required this.vehicle});

  @override
  State<VehiclePresentationModel> createState() =>
      _VehiclePresentationModelState();
}

class _VehiclePresentationModelState extends State<VehiclePresentationModel> {
  List<VehicleDocumentTypeModel> documentsByCar = [];
  final _vehicleService = VehiclesUserServices();
  bool vehicleContaisAllDocuments = true;

  @override
  void initState() {
    super.initState();
    vehicleContainerDocument(widget.vehicle.id!, widget.vehicle.userId);
    debugPrint("Init State del Presentation Model");
    debugPrint(" Cantidad de documentos: ${documentsByCar.length}");
    debugPrint("Estado del Presentation Model: ${vehicleContaisAllDocuments}");
  }

  void vehicleContainerDocument(int vehicleId, int userId) async {
    final currentProfile =
        Provider.of<UserProvider>(context, listen: false).currentProfile;
    List<VehicleDocumentTypeModel> documents = await _vehicleService
        .getVehicleDocumentTypes(vehicleId, userId, currentProfile);
    setState(() {
      documentsByCar = documents;
      vehicleContaisAllDocuments =
          documents.every((element) => element.vehicleDocument != null);
    });
  }

  void _deleteDocument(int documentId) async {
    try {
      await _vehicleService.deleteDocumentUpload(documentId).then((_) {
        MessagesToast.showMessageSuccess("Documento eliminado");
      });
    } catch (e) {
      MessagesToast.showMessageError(
          "Ocurrio un fallo al eliminar el documento");
    }
  }

  void _showDocumentOptions(
      BuildContext context, VehicleDocumentTypeModel vehicleDocument) {
    showDialog(
        context: context,
        builder: (context) => DocumentWithPreviewOptionsDialog(
            onPressedDeleted: () {
              _deleteDocument(vehicleDocument.vehicleDocument!.id);
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          VehiclePresentationModel(vehicle: widget.vehicle)));
              setState(() {});
            },
            documentId: vehicleDocument.vehicleDocument!.id,
            mimeType: vehicleDocument.vehicleDocument!.mimeType,
            title: vehicleDocument.name,
            secondDocumentUrl: vehicleDocument.vehicleDocument!.originalUrl2,
            imageUrl: vehicleDocument.vehicleDocument!.originalUrl,
            documentUrl: vehicleDocument.vehicleDocument!.originalUrl));
  }

  @override
  Widget build(BuildContext context) {
    // final _vehicleService = VehiclesUserServices();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
        title: Text(
          'Detalles de mi vehiculo',
          style: TextStyle(
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Stack(
                  //mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          widget.vehicle.plateNumber.length < 7
                              ? image_moto1
                              : image_auto_1,
                          width: 115,
                          height: 110,
                          //color: simon_finalPrimaryColor,
                          //fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: simonVerde,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              // border: Border.all(color: borderColor, width: 2),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  UpdateVechicleUser(vehicle: widget.vehicle)
                                      .launch(context);
                                },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: Colors.black,
                                )),
                          ),
                          10.height,
                          Container(
                            decoration: const BoxDecoration(
                              color: simonNaranja,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                              // border: Border.all(color: borderColor, width: 2),
                            ),
                            child: IconButton(
                                onPressed: () {
                                  _showDialogDelete(context);
                                },
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ).paddingLeft(8),
                    )
                  ],
                ),
              ),
              Text("${widget.vehicle.carBrand!.name}-${widget.vehicle.vehicleModel!.name}",
                      style: TextStyle(
                          color: appStore.isDarkMode
                              ? scaffoldLightColor
                              : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))
                  .paddingBottom(5),
              Text(
                "${widget.vehicle.year}",
                style: primaryTextStyle(
                    color: appStore.isDarkMode ? Colors.white70 : resendColor),
              ),
              Text(
                "Placa: ${widget.vehicle.plateNumber}",
                style: primaryTextStyle(
                    weight: FontWeight.w800,
                    color: appStore.isDarkMode
                        ? scaffoldLightColor
                        : Colors.black),
              ),
              VehicleAttributeCard(
                  attribute: "Color", value: widget.vehicle.color!.name),
              VehicleAttributeCard(
                  attribute: "Tipo de vehiculo",
                  value: widget.vehicle.vehicleType!.name),
              VehicleAttributeCard(
                  attribute: "Dueño", value: widget.vehicle.ownerName),
              widget.vehicle.chassisNumber != null
                  ? VehicleAttributeCard(
                      attribute: "Chasis", value: widget.vehicle.chassisNumber!)
                  : const SizedBox(),
              widget.vehicle.engineNumber != null
                  ? VehicleAttributeCard(
                      attribute: "Engine", value: widget.vehicle.engineNumber!)
                  : const SizedBox(),
              20.height,
              FutureBuilder(
                future: Future.delayed(const Duration(milliseconds: 800)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: simon_finalPrimaryColor,
                    );
                  } else {
                    return this.vehicleContaisAllDocuments
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Documentos Cargado",
                                        style: TextStyle(
                                            color: simon_finalPrimaryColor,
                                            fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Ionicons.checkmark_circle,
                                      color: Colors.green,
                                      size: 25,
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: FilledButton(
                                  style: buttonStylePrimary(context),
                                  onPressed: () {
                                    _showDocumentOptions(
                                        context, documentsByCar.first);
                                  },
                                  child: Text(
                                    "Ver documento",
                                    style: primaryTextStyle(
                                        color: Colors.white, size: 13),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 10)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              3.height,
                              AppButton(
                                width: double.infinity,
                                elevation: 2,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UploadVehicleDocumentation(
                                                name: "Matricula",
                                                idDocument: 1,
                                                idVehicle: widget.vehicle.id!,
                                                onlyMatricula: true,
                                              )));
                                },
                                color: simonNaranja,
                                shapeBorder: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(DEFAULT_RADIUS)),
                                child: const Text('Subir documentos',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                              ),
                            ],
                          );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showDialogDelete(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return showDialog(
      context: context, // Necesitas el contexto para mostrar el diálogo
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: "Confimar Eliminacion",
          content: "¿Estás seguro de que deseas eliminar este vehículo?",
          withRedirection: true,
          onPressedRoute: () {
            Provider.of<VehicleProvider>(context, listen: false)
                .deleteVehicleById(widget.vehicle.id!, context,
                    userProvider.user.id, userProvider.currentProfile);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen(initialIndex: 3)));

            print("Vehículo eliminado");
          },
        );
      },
    );
  }
}

class VehicleAttributeCard extends StatelessWidget {
  final String attribute;
  final String value;

  const VehicleAttributeCard({
    Key? key,
    required this.attribute,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      //margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        color: simon_finalSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${attribute}:",
                style: const TextStyle(
                  color: simon_finalPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              4.height,
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
