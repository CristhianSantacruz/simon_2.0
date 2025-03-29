import 'package:flutter/cupertino.dart';
import 'package:simon_final/components/simon/drow_component_register.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/models/comment_model.dart';
import 'package:simon_final/models/profession_model.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/profile_model_register.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/models/user_model_register.dart';
import 'package:simon_final/screens/auth/change_password.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/services/professions_services.dart';
import 'package:simon_final/services/profiles_services.dart';
import 'package:simon_final/services/register_service.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:intl/intl.dart';
import 'package:ionicons/ionicons.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
class PersonalInfo extends StatefulWidget {
  final int? profileId;
  final int? userId;
  const PersonalInfo({super.key, this.profileId, this.userId});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController typeIdentificationController =
      TextEditingController();
  final TextEditingController maritalStatusController = TextEditingController();
  final TextEditingController identificationController =
      TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController nombramientoController = TextEditingController();
  final TextEditingController verificationTokenController =
      TextEditingController();
  final TextEditingController sexoController = TextEditingController();

  bool _editFiels = false;

  final userServices = RegisterService();

  final profileServices = ProfilesServices();

  late ProfileModel profileModelData;

  late int
      currentProfessionId; // Cambiado de currentProfession a currentProfessionId
  String currentProfessionName = ""; // Nuevo campo para el nombre

  bool _isLoading = true;

  List<ProfessionModel> _professions = [];
  final _professionServices = ProfessionServices();
  @override
  void initState() {
    super.initState();
    if (widget.profileId != null) {
      fetchProfileData();
    } else {
      fetchPersonalData();
    }

    // es por es un usuario y se usa el otro metodo
    // _loadProfessions();
  }

  void _loadProfessions() async {
    try {
      final professions = await _professionServices.getProfessions();
      setState(() {
        _professions = professions;
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar profesiones");
    }
  }

  void fetchPersonalData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final professions = await _professionServices.getProfessions();
    setState(() {
      nameController.text = userProvider.userPrincipalData.name;
      lastNameController.text =
          userProvider.userPrincipalData.lastName ?? "Sin apellido";
      emailController.text = userProvider.userPrincipalData.email;
      identificationController.text =
          userProvider.userPrincipalData.identification ?? "Sin identificación";
      maritalStatusController.text =
          userProvider.userPrincipalData.maritalStatus ?? "Sin estado civil";
      typeIdentificationController.text =
          userProvider.userPrincipalData.typeIdentification ?? "Sin tipo";
      phoneController.text =
          userProvider.userPrincipalData.phone ?? "Sin teléfono";
      birthDateController.text =
          userProvider.userPrincipalData.birthDate ?? "Sin Fecha";
      if (userProvider.userPrincipalData.nombramiento != null && userProvider.userPrincipalData.nombramiento!.isNotEmpty && userProvider.userPrincipalData.nombramiento != "Sin nombramiento") {
        nombramientoController.text =
            userProvider.userPrincipalData.nombramiento!;
      }
      sexoController.text = userProvider.userPrincipalData.sexo ?? "Sin sexo";
      _professions = professions;
      currentProfessionId = userProvider.userPrincipalData.professionId!;
      final profession = professions.firstWhere(
        (p) => p.id == userProvider.userPrincipalData.professionId,
      );

      currentProfessionName = profession.name;
      professionController.text =
          currentProfessionId.toString(); // Guardamos el ID
      _isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime maxDate = DateTime(now.year - 18, now.month, now.day);

    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          // Para centrarlo en la pantalla
          child: Material(
            // Para manejar bordes y sombras
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.9, // 90% del ancho de la pantalla
                height: 300,
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra superior con título y botón de cerrar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: const BoxDecoration(
                        color: simon_finalPrimaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Seleccionar Fecha",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    // Picker de fecha
                    Expanded(
                      child: CupertinoDatePicker(
                        backgroundColor: Colors.white,
                        initialDateTime: maxDate,
                        minimumDate: DateTime(1900),
                        maximumDate: maxDate,
                        mode: CupertinoDatePickerMode.date,
                        dateOrder: DatePickerDateOrder.ymd,
                        use24hFormat: true,
                        onDateTimeChanged: (DateTime dateTime) {
                          setState(() {
                            //_selectedDate = dateTime;
                            birthDateController.text =
                                DateFormat('yyyy-MM-dd').format(dateTime);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> fetchProfileData() async {
    try {
      ProfileModel profile =
          await profileServices.getProfile(widget.profileId!);
      final professions = await _professionServices.getProfessions();

      setState(() {
        profileModelData = profile;
        nameController.text = profile.name;
        professionController.text = profile.professionId.toString();
        emailController.text = profile.email;
        sexoController.text = profile.sexo ?? "SIN SEXO";
        lastNameController.text = profile.lastName;
        typeIdentificationController.text = profile.typeIdentification;
        maritalStatusController.text =
            profile.maritalStatus ?? "SIN ESTADO CIVIL";
        identificationController.text = profile.identification;
        phoneController.text = profile.phone;
        birthDateController.text =
            DateFormat('yyyy-MM-dd').format(profile.birthDate);
        if (profile.nombramiento != null) {
          nombramientoController.text = profile.nombramiento!;
        }
        _professions = professions;
        currentProfessionId = profile.professionId;
        // Busca la profesión correspondiente al ID
        final profession = professions.firstWhere(
          (p) => p.id == profile.professionId,
        );

        currentProfessionName = profession.name;
        professionController.text =
            currentProfessionId.toString(); // Guardamos el ID
        _isLoading = false;
      });
      debugPrint("Datos de perfil cargados ${profile.toJson()}");
    } catch (e) {
      print('Error al cargar el perfil: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    lastNameController.dispose();
    typeIdentificationController.dispose();
    maritalStatusController.dispose();
    identificationController.dispose();
    professionController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    verificationTokenController.dispose();
    super.dispose();
  }

  void updateDataProfile(
      ProfileModelRegister profileModelUpdate, int profileId) {
    profileServices.updateProfile(profileModelUpdate, profileId).then((value) {
      mostrarMensajeExito();
    }).catchError((error) {
      mostrarMensajeError(error);
    });
  }

  void updateDataUserPrincipal(UserModelRegiser userRegister, int userId) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userServices.updateUser(userRegister, userId).then((value) {
      mostrarMensajeExito();
      userProvider.updateUserPrincipal(userRegister);
    }).catchError((error) {
      mostrarMensajeError(error);
    });
  }

  void mostrarMensajeExito() {
    MessagesToast.showMessageSuccess("Datos actualizados");
    Navigator.pushReplacementNamed(context, Routes.dashboard);
    setState(() {
      _editFiels = false;
    });
  }

  void mostrarMensajeError(error) {
    print("Ocurrió un error: $error");
    MessagesToast.showMessageError("Error al actualizar los datos");
  }

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context, listen: false);
    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios)),
          surfaceTintColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          iconTheme: IconThemeData(
              color: appStore.isDarkMode ? Colors.white : Colors.black),
          title: Text(
            'Información Personal',
            style: primarytextStyle(
                color: appStore.isDarkMode ? Colors.white : Colors.black),
          ),
          backgroundColor: appStore.isDarkMode
              ? scaffoldDarkColor
              : context.scaffoldBackgroundColor,
          centerTitle: true,
        ),
        body: _isLoading
            ? const LoaderAppIcon()
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: 0, left: 16, right: 16, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Image.asset(legal_2_png,
                                  width: 150,
                                  height: 90), // Ícono en lugar de imagen
                              Text(
                                nameController.text,
                                style: primarytextStyle(
                                    color: appStore.isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                    size: 17),
                              ).center(),
                              Text(
                                emailController.text,
                                style: primarytextStyle(
                                    color: resendColor, size: 16),
                              ).center(),
                            ],
                          ).center(),
                          const SizedBox(height: 20),
                          Text('Nombre', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Ionicons.people,
                            controller: nameController,
                            enabled: this._editFiels,
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El nombre no puede estar vacío';
                              }
                              return null; // Si todo está bien
                            },
                          ),
                          Text('Apellido', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Icons.family_restroom_outlined,
                            textCapitalization: TextCapitalization.characters,
                            controller: lastNameController,
                            enabled: this._editFiels,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El apellido no puede estar vacío';
                              }
                              return null;
                            },
                          ),
                          Text('Email', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Icons.email,
                            controller: emailController,
                            enabled: this._editFiels,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El correo electrónico no puede estar vacío';
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                                  .hasMatch(value)) {
                                return 'Por favor ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          5.height,
                          Text('Fecha de nacimiento', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Icons.calendar_today,
                            onTapSimon: () {
                              _pickDate();
                            },
                            controller: birthDateController,
                            enabled: this._editFiels,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La fecha de nacimiento no puede estar vacío';
                              }
                              return null;
                            },
                          ),
                          Text('Estado civil', style: boldTextStyle()),
                          5.height,
                          DropdownTextFieldRegister(
                            enabledDropdown: _editFiels,
                            onChangedDropdown: (value) {
                              setState(() {
                                maritalStatusController.text = value!;
                              });
                            },
                            value: maritalStatusController.text,
                            hintText: "Estado Civil",
                            controller: maritalStatusController,
                            //icon: Icon(Icons.arrow_drop_down_outlined),
                            items: [
                              DropdownMenuItem(
                                enabled: _editFiels,
                                value: "SOLTERO",
                                child: const Text('SOLTERO/A'),
                              ),
                              DropdownMenuItem(
                                enabled: _editFiels,
                                value: 'CASADO',
                                child: const Text('CASADO/A'),
                              ),
                              DropdownMenuItem(
                                enabled: _editFiels,
                                value: 'UNIONLIBRE',
                                child: const Text('UNIÓN LIBRE'),
                              ),
                              DropdownMenuItem(
                                enabled: _editFiels,
                                value: 'VIUDO',
                                child: const Text('VIUDO/A'),
                              ),
                              DropdownMenuItem(
                                enabled: _editFiels,
                                value: 'DIVORCIADO',
                                child: const Text('DIVORCIADO/A'),
                              ),
                            ],
                          ),
                          5.height,
                          Text('Profesión', style: boldTextStyle()),
                          5.height,
                          DropdownButtonFormField<int>(
                            // Cambiado a int
                            style: TextStyle(
                              color:  appStore.isDarkMode ? Colors.white: Colors.black,
                            ),
                            value: _editFiels ? currentProfessionId : null,
                             dropdownColor: appStore.isDarkMode ?scaffoldSecondaryDark : Colors.white, 
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.work_outlined,
                                color: simon_finalPrimaryColor,
                              ),
                              filled: true,
          fillColor: appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
                              hintText: currentProfessionName,
                              hintStyle: TextStyle(color: appStore.isDarkMode ? Colors.white :scaffoldSecondaryDark ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            items:
                                _professions.map((ProfessionModel profession) {
                              return DropdownMenuItem<int>(
                                value: profession.id,
                                child: Text(profession.name,style: TextStyle(color:  appStore.isDarkMode ? Colors.white : scaffoldSecondaryDark ,)),
                              );
                            }).toList(),
                            onChanged: _editFiels
                                ? (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        currentProfessionId = newValue;
                                        currentProfessionName = _professions
                                            .firstWhere((p) => p.id == newValue)
                                            .name;
                                        professionController.text =
                                            newValue.toString();
                                      });
                                    }
                                  }
                                : null,
                            validator: (value) {
                              if (value == null) {
                                return 'Por favor selecciona una profesión';
                              }
                              return null;
                            },
                            isExpanded: true,
                          ),
                          Text('Identificación', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Icons.fingerprint_outlined,
                            controller: identificationController,
                            enabled: this._editFiels,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'La identificación no puede estar vacía';
                              }
                              return null;
                            },
                          ),
                          nombramientoController.text.isNotEmpty
                              ? Text('Nombramiento', style: boldTextStyle())
                              : const SizedBox.shrink(),
                          nombramientoController.text.isNotEmpty
                              ? TextFormFieldSimon(
                                  controller: nombramientoController,
                                  enabled: this._editFiels,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'El nombramiento no puede estar vacío';
                                    }
                                    return null;
                                  },
                                )
                              : const SizedBox.shrink(),
                          Text('Teléfono', style: boldTextStyle()),
                          5.height,
                          TextFormFieldSimon(
                            icon: Icons.phone,
                            controller: phoneController,
                            enabled: this._editFiels,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'El teléfono no puede estar vacío';
                              } else if (!RegExp(r"^\+?\d{10,15}$")
                                  .hasMatch(value)) {
                                return 'Por favor ingresa un número de teléfono válido';
                              }
                              return null;
                            },
                          ),
                          5.height,

                          /*  TextFormFieldSimon(
                      controller: birthDateController,
                      enabled: this._editFiels,
                    ),
                    5.height, */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: _editFiels == false
            ? widget.profileId == null
                ? Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:  widget.profileId == null ? const EdgeInsets.only(left: 16, right: 16) : const EdgeInsets.all(0),
                          child: AppButton(
                            elevation: 2,
                            onTap: () {
                              if(widget.profileId == null){
                                showDialog(context: context, builder: (BuildContext context) {
                                  return  CustomAlertDialog(
                                    title: "!Importante!",
                                    content: "Recuerda que esta informacion es muy importante para el flujo de actividades dentro de Simón",
                                    iconData: Icons.info,
                                    onPressedRoute: (){
                                      Navigator.pop(context);
                                        setState(() {
                                _editFiels = true;
                              });
                                    },
                                  );
                                });
                                return;
                              }
                              setState(() {
                                _editFiels = true;
                              });
                              
                            },
                            color: !_editFiels
                                ? simonNaranja
                                : simon_finalPrimaryColor,
                            shapeBorder: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(DEFAULT_RADIUS)),
                            child: FittedBox(
                              fit : BoxFit.scaleDown,
                              child: Text(
                                widget.profileId != null
                                    ? 'Editar Perfil'
                                    : 'Editar Usuario',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 20), // Espaciado entre los botones
                      Expanded(
                        child: AppButton(
                          elevation: 2,
                          onTap: () {
                            final userRegister = UserModelRegiser(
                              name: nameController.text,
                              lastName: lastNameController.text,
                              typeIdentification:
                                  typeIdentificationController.text,
                              maritalStatus: maritalStatusController.text,
                              identification:
                                  identificationController.text,
                              profession_id: currentProfessionId,
                              email: emailController.text,
                              sexo: sexoController.text == "SIN SEXO"
                                  ? 'HOMBRE'
                                  : sexoController.text,
                              phone: phoneController.text,
                              birthDate: DateTime.parse(
                                  birthDateController.text),
                              nombramiento: nombramientoController.text,
                            );
                           //  ChangePasswordScreen(userModelRegiser: userRegister).launch(context);
                            showDialog(context: context, builder: (BuildContext context) {
                              return  CustomAlertDialog(
                                title: "!Importante!",
                                content: "Recuerda que esta informacion es muy importante para el ingreso posterior a la app",
                                iconData: Icons.info,
                                onPressedRoute: (){
                                  Navigator.pop(context);
                                  ChangePasswordScreen(userModelRegiser: userRegister).launch(context);
                                },
                              );
                            });
        
                          },
                          color: simon_finalPrimaryColor,
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(DEFAULT_RADIUS)),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Cambiar Contraseña',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AppButton(
                        elevation: 2,
                        onTap: () {
                          setState(() {
                            _editFiels = true;
                          });
                        },
                        color: !_editFiels
                            ? simonNaranja
                            : simon_finalPrimaryColor,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(DEFAULT_RADIUS)),
                        child: Text(
                            widget.profileId != null
                                ? 'Editar Perfil'
                                : 'Editar datos personales',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                      ),
                  ),
                )
            : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onTap: () {
                        setState(() {
                          _editFiels = false;
                        });
                      },
                      color: simon_finalSecondaryColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DEFAULT_RADIUS)),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: simon_finalPrimaryColor),
                      ),
                    ),
                  ),
                  20.width,
                  Expanded(
                    child: AppButton(
                      onTap: () {
                        if (_editFiels == true) {
                          if (_formKey.currentState!.validate()) {
                            if (widget.profileId != null) {
                              final profileModel = ProfileModelRegister(
                                sexo: sexoController.text == "SIN SEXO"
                                    ? 'HOMBRE'
                                    : sexoController.text,
                                name: nameController.text,
                                lastName: lastNameController.text,
                                typeIdentification:
                                    typeIdentificationController.text,
                                maritalStatus: maritalStatusController.text,
                                identification:
                                    identificationController.text,
                                professionId: currentProfessionId,
                                email: emailController.text,
                                phone: phoneController.text,
                                birthDate: DateTime.parse(
                                    birthDateController.text),
                                nombramiento: nombramientoController.text,
                                userId: userProvider.user.id,
                              );
        
                              debugPrint(
                                  "Datos finales del usuario a editar ${profileModel.toJson()}");
                              updateDataProfile(
                                  profileModel, widget.profileId!);
                            } else {
                              final userRegister = UserModelRegiser(
                                name: nameController.text,
                                lastName: lastNameController.text,
                                typeIdentification:
                                    typeIdentificationController.text,
                                maritalStatus: maritalStatusController.text,
                                identification:
                                    identificationController.text,
                                profession_id: currentProfessionId,
                                email: emailController.text,
                                sexo: sexoController.text == "SIN SEXO"
                                    ? 'HOMBRE'
                                    : sexoController.text,
                                phone: phoneController.text,
                                birthDate: DateTime.parse(
                                    birthDateController.text),
                                nombramiento: nombramientoController.text,
                              );
                              debugPrint(
                                  "Datos finales del usuario a editar ${userRegister.toJson()}");
                              updateDataUserPrincipal(
                                  userRegister, userProvider.user.id);
                            }
                          }
                        }
                      },
                      color: simon_finalPrimaryColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DEFAULT_RADIUS)),
                      child: const Text(
                        "Guardar",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
      );
    });
  }
}
