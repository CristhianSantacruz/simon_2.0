import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/services/profiles_services.dart';
//import 'package:simon_final/services/preferences_user.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:simon_final/components/settings_component.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  UserModel? _user;
  int profileIdPrincipal =
      0; // Usar un tipo nullable para evitar errores de acceso tardío
  final _profileServices = ProfilesServices();

  @override
  void initState() {
    super.initState();
    _user = Provider.of<UserProvider>(context, listen: false).user;
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final profiles = await _profileServices.getProfiles(userProvider.user.id);
      setState(() {
        profileIdPrincipal =
            profiles
                .where((element) => element.profileModelDefault == 1)
                .first
                .id;
      });
    } catch (e) {
      print('Error al cargar el perfil: $e');
    }
  }

  Future<ProfileModel> fetchDataProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profiles = await _profileServices.getProfiles(userProvider.user.id);
    final profile = profiles.firstWhere(
      (p) => p.id == userProvider.currentProfile,
    );
    return profile;
  }

  // Aquí puedes usar el nombre completo del usuario
  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final size = MediaQuery.of(context).size;
    List<String> nameParts = userProvider.user.name.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      if (initials.length <= 1) {
        initials = nameParts[0][0] + nameParts[0][1]; // si solo tiene un nombre
      } else {
        initials =
            nameParts[0][0] +
            nameParts[1][0]; // Primera letra del nombre y apellido
      }
    }

    return Observer(
      builder: (context) {
        final currentProfile =
            Provider.of<UserProvider>(context, listen: false).currentProfile;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        return Scaffold(
          backgroundColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila con la imagen del perfil y el nombre al lado
                FutureBuilder<ProfileModel>(
                  future:
                      fetchDataProfile(), // Asegúrate de pasar el profileId correctamente
                  builder: (context, snapshot) {
                    // Estados de carga/error
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: simon_finalPrimaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            color: simonNaranja, // Color de error
                            borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Icon(
                                  Icons.error,
                                  color: Colors.white,
                                  size: 40,
                                ), // Ícono de error
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Error al cargar perfil",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "No pudimos obtener los datos.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Text("No se encontró el perfil"),
                      );
                    }

                    final profile = snapshot.data!;
                    final name = profile.name ?? "Sin nombre";
                    final identification =
                        profile.identification ?? "Sin identificación";

                    return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      decoration: BoxDecoration(
                        color: simon_finalPrimaryColor,
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ClipOval(
                            child: Icon(
                              Ionicons.people_circle,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    overflow: TextOverflow.clip,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        appStore.isDarkMode
                                            ? scaffoldLightColor
                                            : scaffoldLightColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      FontAwesomeIcons.idCard,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      identification,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color:
                                            appStore.isDarkMode
                                                ? scaffoldLightColor
                                                : scaffoldLightColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).center();
                  },
                ),
                const SizedBox(height: 32),

                // Opciones de configuración
                Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color:
                        appStore.isDarkMode
                            ? scaffoldLightColor
                            : scaffoldDarkColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Lista de componentes de configuración
                Column(
                  children: settingComponent(
                    context,
                    userProvider.currentProfile,
                    userProvider.user.phone!,
                    userProvider.user.id,
                  ), // Componentes personalizados de configuración
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
