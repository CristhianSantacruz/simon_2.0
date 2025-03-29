import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/empty_data_message.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/vehicle_document_user.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/screens/documents_user/new_upload_vehicle_document.dart';
import 'package:simon_final/screens/documents_user/view_docs/docs_vehicle_Associated_screen.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:ionicons/ionicons.dart';

class VehicleWithPendingDocuments {
  final VehicleModelUser vehicle;
  final List<VehicleDocumentTypeModel> pendingDocuments;
  VehicleWithPendingDocuments(
      {required this.vehicle, required this.pendingDocuments});
}

class ViewVehicleDocument extends StatefulWidget {
  const ViewVehicleDocument({super.key});

  @override
  State<ViewVehicleDocument> createState() => _ViewVehicleDocumentState();
}

class _ViewVehicleDocumentState extends State<ViewVehicleDocument> {
  final vehicleServices = VehiclesUserServices();
  List<VehicleWithPendingDocuments> vehiclesWithDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final userId = context.read<UserProvider>();
    Provider.of<VehicleProvider>(context, listen: false)
        .fetchVehicles(userId.user.id, userId.currentProfile);
    _fetchVehicleData(userId.user.id, userId.currentProfile);
  }

  Future<void> _fetchVehicleData(int userId, int profileId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<VehicleProvider>().fetchVehicles(userId, profileId);
      List<VehicleModelUser> vehicles =
          Provider.of<VehicleProvider>(context, listen: false).vehicleList;
      List<VehicleWithPendingDocuments> tempList = [];
      for (var vehicle in vehicles) {
        List<VehicleDocumentTypeModel> pendingDocs =
            await _fetchPendingDocuments(vehicle.id!, userId, profileId);
        tempList.add(VehicleWithPendingDocuments(
            vehicle: vehicle, pendingDocuments: pendingDocs));
      }
      setState(() {
        vehiclesWithDocuments = tempList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error al cargar vehículos: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<VehicleDocumentTypeModel>> _fetchPendingDocuments(
      int vehicleId, int userId, int profileId) async {
    try {
      List<VehicleDocumentTypeModel> allDocuments = await vehicleServices
          .getVehicleDocumentTypes(vehicleId, userId, profileId);

      return allDocuments;
    } catch (e) {
      debugPrint("Error al cargar documentos: $e");
      return [];
    }
  }

  bool _vehicleHasPendingDocuments(List<VehicleDocumentTypeModel> vehicleData) {
    for (var document in vehicleData) {
      if (document.vehicleDocument == null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
      body: _isLoading
          ? const LoaderAppIcon()
          : Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                          style: primarytextStyle(
                              color: appStore.isDarkMode
                                  ? scaffoldLightColor
                                  : Colors.black,
                              size: 14),
                          textAlign: TextAlign.center,
                          vehiclesWithDocuments.isEmpty
                              ? ""
                              : "Selecciona un vehiculo registrado para subir los documento pertinente")),
                  20.height,
                  vehiclesWithDocuments.isEmpty
                      ? EmptyDataMessage(
                          title: "Registra un auto",
                          iconData: Ionicons.car_outline,
                          textButton: "Registrar un auto",
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.registerCar);
                          },
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: vehiclesWithDocuments.length,
                            itemBuilder: (context, index) {
                              final vehicleData = vehiclesWithDocuments.reversed
                                  .toList()[index];
                              final pending = _vehicleHasPendingDocuments(
                                  vehicleData.pendingDocuments);
                              return Card(
                                color: pending
                                    ? simon_finalSecondaryColor
                                    : appStore.isDarkMode
                                        ? scaffoldDarkColor
                                        : Colors.white,
                                elevation: pending ? 2 : 0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(DEFAULT_RADIUS),
                                  side: BorderSide(
                                      color: pending
                                          ? Colors.transparent
                                          : simon_finalPrimaryColor,
                                      width: 2),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.asset(
                                          image_auto_1,
                                          width: 110,
                                          height: 60,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              "${vehicleData.vehicle.carBrand!.name} - ${vehicleData.vehicle.plateNumber}",
                                              style: primarytextStyle(
                                                  size: 16,
                                                  color: pending
                                                      ? Colors.black
                                                      : appStore.isDarkMode
                                                          ? scaffoldLightColor
                                                          : Colors.black),
                                            ).center(),
                                            Text(
                                              "Modelo: ${vehicleData.vehicle.vehicleModel!.name}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: resendColor,
                                              ),
                                            ),
                                            Text(
                                              "Color: ${vehicleData.vehicle.color!.name}",
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: resendColor,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  if (pending)
                                                    FittedBox(
                                                      child: FilledButton.icon(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  UploadVehicleDocumentation(
                                                                name:
                                                                    "Matricula",
                                                                idVehicle: vehicleData
                                                                        .vehicle
                                                                        .id ??
                                                                    0,
                                                                idDocument: 1,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style:
                                                            buttonStyleTerciary(
                                                                context),
                                                        icon: const Icon(
                                                          Ionicons
                                                              .cloud_upload_outline,
                                                          color: Colors.white,
                                                        ),
                                                        label: Text(
                                                          "Documentos pendientes",
                                                          style:
                                                              primaryTextStyle(
                                                            color: Colors.white,
                                                            size: 12,
                                                            weight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  if (!pending)
                                                    FilledButton.icon(
                                                      icon: const Icon(
                                                          Ionicons.document),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                DocsVehicleAssociatedScreen(
                                                              idSelectedVehicle:
                                                                  vehicleData
                                                                          .vehicle
                                                                          .id ??
                                                                      0,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      style: buttonStylePrimary(
                                                          context),
                                                      label: Text(
                                                        "Ver Documentos",
                                                        style: primaryTextStyle(
                                                          color: Colors.white,
                                                          size: 12,
                                                          weight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                ],
              ),
            ),
    );
  }
}
