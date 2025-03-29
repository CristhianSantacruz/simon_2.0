import 'package:flutter/material.dart';
import 'package:simon_final/components/simon/empty_data_message.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/vehicles/vehicle_presentation_modal.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import '../../utils/app_routes.dart';
// Importa el servicio de API

class MyVehiclesFragment extends StatefulWidget {
  const MyVehiclesFragment({super.key});

  @override
  State<MyVehiclesFragment> createState() => _MyArticlesFragmentState();
}

class _MyArticlesFragmentState extends State<MyVehiclesFragment> {
  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _fetchVehicleData(userProvider.user.id, userProvider.currentProfile);
  }

  Future<void> _fetchVehicleData(int userId, int profileId) async {
    debugPrint("ID del usuario: $userId");
    await context.read<VehicleProvider>().fetchVehicles(userId, profileId);
  }

  bool validarPlacaFormato(String placa) {
    // Expresión regular para 2 letras, 3 números y 1 letra
    final RegExp regex = RegExp(r'^[A-Z]{2}\d{3}[A-Z]$');

    return regex.hasMatch(
        placa.toUpperCase()); // Pasamos a mayúscula para asegurar el formato
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
      body: Consumer<VehicleProvider>(
        builder: (context, vehicleProvider, child) {
          if (vehicleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (vehicleProvider.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Error en la carga de vehículos"),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.createVehicle);
                    },
                    label: const Text(
                      "Registra un vehiculo ahora",
                      style: TextStyle(color: white_color),
                    ),
                    icon: const Icon(
                      Ionicons.car_outline,
                      color: white_color,
                    ),
                    style: TextButton.styleFrom(
                        backgroundColor: simon_finalPrimaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                  ),
                ],
              ),
            );
          } else if (vehicleProvider.vehicleList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  EmptyDataMessage(
                    iconData: Ionicons.car_outline,
                    title: "No se encontraron vehículos del usuario",
                    subtitle:
                        "Registra  un vehiculo ahora para poder ver los datos asociados",
                    textButton: "Registrar vehiculo",
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.createVehicle);
                    },
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: vehicleProvider.vehicleList.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicleProvider.vehicleList[index];
                      final isMoto = validarPlacaFormato(vehicle.plateNumber);
                      return Card(
                        
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                          side: const BorderSide(
                              color: simon_finalPrimaryColor, width: 1),
                          // Bordes más suaves
                        ),
                        elevation:
                            3, // Aumento de sombra para mayor profundidad
                        color: appStore.isDarkMode
                            ? scaffoldDarkColor
                            : Colors
                                .white, // Color blanco pálido para las cards
                        child: ListTile(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        VehiclePresentationModel(
                                            vehicle: vehicle)));
                            final userProvider = context.read<UserProvider>();
                            _fetchVehicleData(
                                userProvider.user.id,
                                userProvider
                                    .currentProfile); // Llama de nuevo a la función para recargar los datos
                          },
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
                          // ignore: unnecessary_null_comparison
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              isMoto ? image_moto1 : image_auto_1,
                              width: 115,
                              height: 125,
                              //color: simon_finalPrimaryColor,
                              //fit: BoxFit.cover,
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Container(
                              width: 40,
                              decoration: BoxDecoration(
                                color: simon_finalPrimaryColor, // Fondo azul
                                borderRadius: BorderRadius.circular(
                                    25), // Bordes redondeados
                              ),
                              child: Center(
                                  child: Text(
                                '${vehicle.carBrand!.name} ${vehicle.vehicleModel!.name}',
                                overflow: TextOverflow.ellipsis, // Agrega "..."
                                maxLines: 1, // Limita a una sola línea
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )).paddingSymmetric(vertical: 4, horizontal: 4),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${vehicle.plateNumber}',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: appStore.isDarkMode
                                        ? scaffoldLightColor
                                        : Colors.black87,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.color_lens,
                                      color: simonNaranja,
                                      size: 17,
                                    ),
                                    5.width,
                                    Text(
                                      '${vehicle.color!.name}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: appStore.isDarkMode
                                            ? scaffoldLightColor
                                            : resendColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: simon_finalPrimaryColor,
                                      size: 17,
                                    ),
                                    5.width,
                                    // Usamos Expanded para que el texto ocupe el espacio disponible
                                    Expanded(
                                      child: Text(
                                        overflow: TextOverflow
                                            .ellipsis, // Para cortar el texto con '...'
                                        '${vehicle.ownerName}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: appStore.isDarkMode
                                              ? scaffoldLightColor
                                              : resendColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                AppButton(
                  width: double.infinity,
                  elevation: 2,
                  onTap: () {
                    Navigator.pushNamed(context, Routes.createVehicle);
                  },
                  color: simon_finalPrimaryColor,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                      Text('Agregar vehículo',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ],
                  ),
                ).paddingBottom(16),
              ],
            ),
          );
        },
      ),
    );
  }
}
