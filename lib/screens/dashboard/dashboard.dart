import 'package:animate_do/animate_do.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simon_final/components/simon/pop_up_widget.dart';
import 'package:simon_final/firebase_and_notifications.dart';
import 'package:simon_final/models/pop_up_model.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/template_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/device_token.dart';
import 'package:simon_final/services/profiles_services.dart';
import 'package:simon_final/services/template_services.dart';
import 'package:ionicons/ionicons.dart';
import 'package:simon_final/screens/dashboard/settings_screen.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/images.dart';

import '../../components/text_styles.dart';
import '../../main.dart';
import '../fragments/home_fragment.dart';
import '../fragments/my_vehicles_fragment.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  const DashboardScreen({super.key, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentPageIndex = 0;
  final TemplateServices _templateServices = TemplateServices();
  List<TemplateModel> templates = [];
  final _profileServices = ProfilesServices();
  //UserModel? _user;
  final _deviceTokenService = DeviceTokenService();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final popUp = ModalRoute.of(context)!.settings.arguments as PopUpModel?;

      if (popUp != null && popUp.photoUrl.isNotEmpty) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PopUpAfterLogin(
                photoUrl: popUp.photoUrl,
                redirect: popUp.redirect,
              );
            },
          );
        });
      }
    });
    currentPageIndex = this.widget.initialIndex;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    //fetchVehicles(userProvider.user.id,userProvider.currentProfile);
    _loadTemplates();
    registerTokenAfterLogin(userProvider.user.id);
    Provider.of<DocumentsGenerateProvider>(
      context,
      listen: false,
    ).getDocumentGenerates(userProvider.user.id, userProvider.currentProfile);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchVehicles(int userId, int profileId) async {
    final vehicleProvider = Provider.of<VehicleProvider>(
      context,
      listen: false,
    );
    await vehicleProvider.fetchVehicles(userId, profileId);
  }

  void registerTokenAfterLogin(int userId) async {
    try {
      String deviceToken = await FirebaseAndNotifications.getDeviceToken();
      await _deviceTokenService.registerDeviceToken(userId, deviceToken);
    } catch (e) {
      debugPrint("Error al registrar el token: $e");
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

  Future<void> _loadTemplates() async {
    try {
      List<TemplateModel> fetchedTemplates =
          await _templateServices.getTemplates();
      setState(() {
        templates = fetchedTemplates;
      });
    } catch (e) {
      debugPrint("Error al cargar las plantillas: $e");
    }
  }

  List<String> title = [
    'Simón',
    'Mis impugnaciones',
    'Impugnar',
    'Mis vehículos',
    'Mi Perfil',
  ];

  Future<List<ProfileModel>> fetchDataProfiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profiles = await _profileServices.getProfiles(userProvider.user.id);
    return profiles;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const HomeFragment(),
      const DocsDocumentGeneratedFragment(),
      TemplateFragment(templates: this.templates),
      const MyVehiclesFragment(),
      const SettingsScreen(),
    ];
    return Observer(
      builder: (context) {
        return Scaffold(
          backgroundColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          appBar: AppBar(
            surfaceTintColor:
                appStore.isDarkMode ? scaffoldDarkColor : white_color,
            backgroundColor:
                appStore.isDarkMode ? scaffoldDarkColor : white_color,
            elevation: currentPageIndex == 0 ? 4 : 0,
            centerTitle: currentPageIndex == 0 ? false : true,
            title:
                currentPageIndex == 0
                    ? Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        onTap: () {
                          _showModelBottomProfile(context);
                        },
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FutureBuilder<ProfileModel>(
                            future:
                                fetchDataProfile(), // Asegúrate de tener acceso a `profileId` aquí
                            builder: (context, snapshot) {
                              // Estados de carga/error
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator(color: simon_finalPrimaryColor,);
                              } else if (snapshot.hasError) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          simonNaranja, // Color de error
                                      child: Icon(
                                        Icons.error, // Ícono de error
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Error al cargar los datos', // Mensaje amigable
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  appStore.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Inténtalo nuevamente más tarde.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else if (!snapshot.hasData) {
                                return const Text(
                                  "No se encontró el perfil",
                                ); // Si no hay datos
                              }

                              // Datos del perfil (con valores por defecto)
                              final profile = snapshot.data!;
                              final name = profile.name ?? "Sin nombre";
                              final lastName =
                                  profile.lastName ?? "No disponible";
                              final identification =
                                  profile.identification ?? "No disponible";

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundColor: simon_finalPrimaryColor,
                                    child: ColorFiltered(
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                      child: Image.asset(icon_login),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ), // Reemplaza `5.width` si no usas extensions
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$name $lastName',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                appStore.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          identification,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    )
                    : Text(
                      title[currentPageIndex],
                      style: primarytextStyle(
                        weight: FontWeight.w500,
                        size: 20,
                        color:
                            appStore.isDarkMode
                                ? scaffoldLightColor
                                : scaffoldDarkColor,
                      ),
                    ),
            leading:
                currentPageIndex == 0
                    ? null
                    : Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            currentPageIndex = 0;
                          });
                          log(screens[currentPageIndex]);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color:
                              appStore.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
            automaticallyImplyLeading: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    SvgPicture.asset(
                      notification_icon,
                      // ignore: deprecated_member_use
                      color:
                          appStore.isDarkMode
                              ? scaffoldLightColor
                              : simon_finalPrimaryColor,
                      width: 25,
                      height: 25,
                    ),
                    Positioned(
                      right: 4,
                      top: -9,
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child: Center(
                          child: const Text(
                            "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ).paddingAll(4),
                        ),
                      ),
                    ),
                  ],
                ).onTap(() {
                  Navigator.pushNamed(context, Routes.notifications);
                }),
              ),

              /*SvgPicture.asset(
                  NavBarImage.user_address,
                  color: simon_finalPrimaryColor,
                  width: 30,
                ).paddingSymmetric(horizontal: 10).onTap((){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => DirectionsUser()));
                }),*/
              /*Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Ionicons.location_outline, color: simon_finalPrimaryColor, size: 30).onTap((){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => DirectionsUser()));
                  }),
                ),*/
            ],
          ),
          body: screens[currentPageIndex],
          bottomNavigationBar: Container(
            // height: 70,
            child: BottomNavigationBar(
              backgroundColor:
                  appStore.isDarkMode
                      ? scaffoldDarkColor
                      : simon_finalSecondaryColor,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              currentIndex: currentPageIndex,
              onTap: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
                log(screens[currentPageIndex]);
              },
              unselectedItemColor:
                  appStore.isDarkMode
                      ? simon_finalSecondaryColor
                      : scaffoldDarkColor,
              selectedItemColor: simon_finalPrimaryColor,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              iconSize: 22,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(NavBarImage.home_icon_svg, width: 35),
                  activeIcon: const ActiveIconContainer(
                    imagePath: NavBarImage.home_icon_svg,
                  ),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    NavBarImage.folder_icon_svg,
                    /* color: appStore.isDarkMode
                      ? scaffoldLightColor
                      : scaffoldDarkColor,*/
                    width: 35,
                  ),
                  activeIcon: const ActiveIconContainer(
                    imagePath: NavBarImage.folder_icon_svg,
                  ),
                  label: 'Mis Impugnaciones',
                ),
                BottomNavigationBarItem(
                  icon: Container(), // Espacio vacío en el medio
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    NavBarImage.car_icon_svg,
                    /* color: appStore.isDarkMode
                      ? scaffoldLightColor
                      : scaffoldDarkColor,*/
                    width: 35,
                  ),
                  activeIcon: const ActiveIconContainer(
                    imagePath: NavBarImage.car_icon_svg,
                  ),
                  label: 'Mis vehículos',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    NavBarImage.user_icom_svg,
                    // color: simon_finalPrimaryColor,
                    /* color: appStore.isDarkMode
                      ? scaffoldLightColor
                      : scaffoldDarkColor,*/
                    width: 35,
                  ),
                  activeIcon: const ActiveIconContainer(
                    imagePath: NavBarImage.user_icom_svg,
                  ),
                  label: 'Perfil',
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 10), // Ajusta la posición
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.3), // Color azul con opacidad
              ),
              padding: const EdgeInsets.all(
                4,
              ), // Espaciado entre el círculo y el FAB
              child: FloatingActionButton(
                shape: const StadiumBorder(),
                backgroundColor: simon_finalPrimaryColor,
                foregroundColor: Colors.white,
                onPressed: () {
                  setState(() {
                    currentPageIndex = 2;
                  });
                },
                child: const Icon(Ionicons.document),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> _showModelBottomProfile(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vehicleProvier = Provider.of<VehicleProvider>(context, listen: false);
    final documentGeneratedProvider = Provider.of<DocumentsGenerateProvider>(
      context,
      listen: false,
    );
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      builder: (BuildContext context) {
        return FutureBuilder<List<ProfileModel>>(
          future: _profileServices.getProfiles(
            Provider.of<UserProvider>(context, listen: false).user.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text("Ocurrio un error al intentar cargar los perfiles"),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay perfiles disponibles"));
            } else {
              final profiles = snapshot.data!;
              return Column(
                children: [
                  Text(
                    "Selecciona tu perfil",
                    style: TextStyle(
                      fontSize: 20,
                      color:
                          appStore.isDarkMode
                              ? scaffoldLightColor
                              : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ).center().paddingSymmetric(vertical: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        profiles.sort((a, b) {
                          if (a.profileModelDefault == 1) return -1;
                          if (b.profileModelDefault == 1) return 1;
                          if (a.id ==
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).currentProfile)
                            return -1;
                          if (b.id ==
                              Provider.of<UserProvider>(
                                context,
                                listen: false,
                              ).currentProfile)
                            return 1;
                          return 0;
                        });
                        final profile = profiles[index];
                        final currentProfile =
                            profile.id ==
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).currentProfile;
                        final isPrincipal = profile.profileModelDefault == 1;
                        return Card(
                          color:
                              currentProfile
                                  ? simon_finalPrimaryColor
                                  : Colors.white,
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: simon_finalPrimaryColor,
                              width: 1,
                            ), // Borde azul
                          ),
                          elevation: 3,
                          child: ListTile(
                            onTap: () async {
                              // Ejecutar el cambio de perfil
                              userProvider.setProfileData(profile.id, profile);
                              showDialog(
                                context: context,
                                barrierDismissible:
                                    false, // Evita que se cierre tocando fuera del diálogo
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    backgroundColor: Colors.white,
                                    content: Row(
                                      children: [
                                        CircularProgressIndicator(
                                          color: simon_finalPrimaryColor,
                                        ),
                                        SizedBox(width: 10),
                                        Text("Cargando perfil..."),
                                      ],
                                    ),
                                  );
                                },
                              );

                              // Retrasar un poco antes de realizar las siguientes acciones
                              await Future.delayed(const Duration(seconds: 2));

                              // Realizar las demás acciones
                              vehicleProvier.resetAndFetchVehicles(
                                userProvider.user.id,
                                profile.id,
                              );
                              documentGeneratedProvider.getDocumentGenerates(
                                userProvider.user.id,
                                userProvider.currentProfile,
                              );
                              Navigator.pop(context);
                              Navigator.pushNamed(context, Routes.dashboard);
                            },
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  currentProfile
                                      ? Colors.white
                                      : simon_finalPrimaryColor,
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  currentProfile
                                      ? simon_finalPrimaryColor
                                      : Colors.white,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(icon_login),
                              ),
                            ),
                            title: Text(
                              profile.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    currentProfile
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              "${profile.identification} ${isPrincipal ? "- Principal" : ""}",
                              style: TextStyle(
                                color:
                                    currentProfile
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            trailing:
                                currentProfile
                                    ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flash(
                                          infinite: true,
                                          child: const Icon(
                                            Icons.circle,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                        const Text(
                                          "Actual",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    )
                                    : const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}

class ActiveIconContainer extends StatelessWidget {
  final String imagePath;

  const ActiveIconContainer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: simon_finalPrimaryColor, // Fondo blanco cuando está activo
        borderRadius: BorderRadius.circular(20), // Hacer el contorno redondeado
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 2,
      ), // Ajusta el espacio dentro del círculo
      child: SvgPicture.asset(
        imagePath,
        color: Colors.white, // Icono blanco cuando está activo
        width: 30,
      ),
    );
  }
}
