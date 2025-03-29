import 'package:simon_final/components/simon/custom_alert_dialog_with_actions.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/comment_model.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/screens/settings_screen/personal_info.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/profiles_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/messages_toast.dart';

class MyProfiles extends StatefulWidget {
  const MyProfiles({super.key});

  @override
  State<MyProfiles> createState() => _MyProfilesState();
}

class _MyProfilesState extends State<MyProfiles> {
  final _profileServices = ProfilesServices();
  late Future<List<ProfileModel>> _futureProfiles;
  @override
  void initState() {
    super.initState();
    _futureProfiles = fetchDataProfiles();
  }

  Future<List<ProfileModel>> fetchDataProfiles() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final profiles = await _profileServices.getProfiles(userProvider.user.id);
    return profiles;
  }

  void deleteProfile(int profileId) async {
  //  final userProvider = Provider.of<UserProvider>(context, listen: false);
   // final vehicleProvier = Provider.of<VehicleProvider>(context, listen: false);
   // final documentGeneratedProvider =Provider.of<DocumentsGenerateProvider>(context, listen: false);
    try {
      await _profileServices.deleteProfile(profileId);
      List<ProfileModel> updatedProfiles = await fetchDataProfiles();
     // ProfileModel? profilePrincipal = updatedProfiles.firstWhere((element) => element.profileModelDefault == 1);
     // userProvider.setProfile(profilePrincipal.id);
     //  vehicleProvier.resetAndFetchVehicles(userProvider.user.id, userProvider.currentProfile);
     //  documentGeneratedProvider.getDocumentGenerates(userProvider.user.id, userProvider.currentProfile);

      setState(() {
        _futureProfiles = Future.value(updatedProfiles);
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al eliminar el perfil");
    }
  }

  void showAlerPerfil(BuildContext context, void Function()? onAccept) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return CustomAlertDialogWithActions(
          title: "Informacion",
          content:
              "Recuerda que una vez eliminado el perfil no hay manera de recuperar los datos.",
          contentQuestion: " ¿Deseas eliminar ahora?",
          onAccept: onAccept,
          onCancel: () {
            Navigator.pop(context);
            print("No presionado");
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          surfaceTintColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          iconTheme: IconThemeData(
              color:
                  appStore.isDarkMode ? scaffoldLightColor : scaffoldDarkColor),
          backgroundColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          title: Text('Perfiles',
              style: primarytextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black)),
          centerTitle: true,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios))),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<ProfileModel>>(
              future: fetchDataProfiles(), // Obtener los perfiles
              builder: (context, snapshot) {
                // Manejo del estado del FutureBuilder
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator()); // Mostrar cargando
                } else if (snapshot.hasError) {
                  return const Center(
                      child: const Text(
                          "Ocurrio un error al traer los perfiles")); // Manejo de errores
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                          'No se encontraron perfiles.')); // Si no hay perfiles
                } else {
                  // Mostrar perfiles si están disponibles
                  final profiles = snapshot.data!;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: profiles.length,
                    itemBuilder: (context, index) {
                      return _CardProfile(
                        onPressedDeleted: () {
                          showAlerPerfil(context, () {
                            Navigator.pop(context);
                            deleteProfile(profiles[index].id);
                          });
                        },
                        profileModel: profiles[index], // Pasar el perfil actual
                      );
                    },
                  );
                }
              },
            ),
          ],
        ).paddingAll(16),
      ),
      bottomNavigationBar: AppButton(
        width: double.infinity,
        elevation: 2,
        shapeBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
        color: simon_finalPrimaryColor,
        textColor: Colors.white,
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewRegisterScreen(isCreateProfile: true),
            ),
          );
          if (result == true) {
            setState(() {});
          }
        },
        child: const Text(
          "Crear Perfil",
          style: TextStyle(color: Colors.white),
        ),
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}

class _CardProfile extends StatelessWidget {
  final ProfileModel profileModel;
  final void Function()? onPressedDeleted;
  const _CardProfile({
    super.key,
    required this.profileModel,
    required this.onPressedDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    final vehicleProvier = Provider.of<VehicleProvider>(context, listen: false);
    final documentGeneratedProvider =
        Provider.of<DocumentsGenerateProvider>(context, listen: false);
    final isPrincipal = profileModel.profileModelDefault == 1;
    final currentProfile =
        Provider.of<UserProvider>(context, listen: false).currentProfile;
    return Card(
      color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
            color: simon_finalPrimaryColor, width: isPrincipal ? 3 : 1),
        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
      ),
      elevation: isPrincipal ? 6 : 2,
      child: Column(
        children: [
          // parte principal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // CircleAvatar a la izquierda
              CircleAvatar(
                radius: 22,
                backgroundColor: simon_finalPrimaryColor, // Ajusta el tamaño si es necesario
                child: Icon(
                    isPrincipal
                        ? Icons.star_border_outlined
                        : Icons.person_outline,
                    color: Colors.white,
                    size: 30), // Color de fondo
              ),

              // Información de perfil (nombre y identificación) en el centro
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 10), // Agrega espacio entre el avatar y los textos
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${profileModel.name} ${profileModel.lastName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: appStore.isDarkMode
                              ? scaffoldLightColor
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${profileModel.identification}",
                        style: TextStyle(
                          color: appStore.isDarkMode
                              ? scaffoldLightColor
                              : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Botones de acción a la derecha
              Row(
                children: [

                isPrincipal == false ?  IconButton(
                    onPressed: () {
                      PersonalInfo(
                        profileId: profileModel.id,
                      ).launch(context);
                    },
                    icon: const Icon(Icons.edit, color: simonVerde),
                  ) : const SizedBox.shrink(),
                  isPrincipal == true  
                      ? const SizedBox.shrink()
                      :  profileModel.id != userProvider.currentProfile ?  IconButton(
                          onPressed: onPressedDeleted ?? () {},
                          icon: const Icon(Icons.delete, color: simonNaranja),
                        ) : const SizedBox.shrink()
                ],
              ),
            ],
          ),
          profileModel.profileModelDefault == 1
              ? Container(
                  // width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: simon_finalSecondaryColor,
                    borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                  ),
                  child: Text(
                    "Perfil principal",
                    style: primarytextStyle(
                        weight: FontWeight.w700,
                        size: 13,
                        color: simon_finalPrimaryColor),
                  ).center(),
                ).paddingSymmetric(vertical: 3)
              : const SizedBox.shrink(),

          // datos del perfil

          _RowDataInfo(
              title: "Tipo de identificación:",
              data: profileModel.typeIdentification),
          _RowDataInfo(title: "Email:", data: profileModel.email),
          _RowDataInfo(title: "Telefono:", data: profileModel.phone),

          userProvider.currentProfile != profileModel.id
              ? AppButton(
                  width: double.infinity,
                  elevation: 2,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                  color: simonGris,
                  onTap: () async {
                    userProvider.setProfileData(profileModel.id, profileModel);
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
                    await Future.delayed(const Duration(seconds: 2));
                    vehicleProvier.resetAndFetchVehicles(
                        userProvider.user.id, profileModel.id);
                    documentGeneratedProvider.getDocumentGenerates(
                        userProvider.user.id, userProvider.currentProfile);
                    Navigator.pop(context);
                    Navigator.pushNamed(context, Routes.dashboard);
                  },
                  child: const Text(
                    "Seleccionar Perfil",
                    style: TextStyle(color: simon_finalPrimaryColor),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: simon_finalPrimaryColor,
                    borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Text(
                    "Perfil Actual",
                    style: primaryTextStyle(color: Colors.white, size: 16),
                  ),
                ),

          // boton de seleccionar perfil
        ],
      ).paddingAll(16),
    );
  }
}

class _RowDataInfo extends StatelessWidget {
  final String title;
  final String data;
  const _RowDataInfo({
    super.key,
    required this.title,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${title}",
          style: const TextStyle(color: resendColor),
        ),
        Text(
          "${data}",
          style: TextStyle(
              color: appStore.isDarkMode ? scaffoldLightColor : Colors.black),
        ),
      ],
    ).paddingSymmetric(vertical: 3);
  }
}
