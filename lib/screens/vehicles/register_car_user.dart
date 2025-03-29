import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/dropdowm_simon.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_model.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/providers/vehicles_user_provider.dart';
import 'package:simon_final/screens/dashboard/dashboard.dart';
import 'package:simon_final/screens/documents_user/new_upload_vehicle_document.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

class RegisterCarUser extends StatefulWidget {
  const RegisterCarUser({super.key});

  @override
  State<RegisterCarUser> createState() => _RegisterCarUserState();
}

class _RegisterCarUserState extends State<RegisterCarUser> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerPlateNumber = TextEditingController();
  final TextEditingController controllerYear = TextEditingController();
  final TextEditingController controllerChassisNumber = TextEditingController();
  final TextEditingController controllerEngineNumber = TextEditingController();
  final VehiclesUserServices _vehicleServices = VehiclesUserServices();
  bool _enableForms = false;
  List<VehicleModel> vehicleList = [];
  List<CarBrandModel> carBrandList = [];
  List<TypeVehicleModel> vehicleTypeList = [];
  List<ColorModel> colorList = [];

  CarBrandModel? carBrandModel;
  VehicleModel? vehicleModel;
  TypeVehicleModel? typeVehicleModel;
  ColorModel? colorModel;

  String vehicleType = 'Carro';

  @override
  void initState() {
    super.initState();
    loadInitialData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegistrationAlert(context);
    });
  }

  Future<void> loadInitialData() async {
    await Future.wait([
      loadCarBrands(),
      loadVehicleType(),
      loadColors(),
    ]);
  }

  void clearForm() {
    controllerPlateNumber.clear();
    controllerYear.clear();
    controllerChassisNumber.clear();
    controllerEngineNumber.clear();
  }

  @override
  void dispose() {
    controllerPlateNumber.dispose();
    controllerYear.dispose();
    controllerChassisNumber.dispose();
    controllerEngineNumber.dispose();
    super.dispose();
  }

  Future<void> _createVehicle(
      VehicleModelUser vehicle, int userId, int profileId) async {
    debugPrint("Datos del vehiculo creado: ${vehicle.toJson()}");
    print("Datos del vehiculo creado: ${vehicle.toJson()}");
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(
            child: LoaderAppIcon(),
          );
        },
      );

      await _vehicleServices.createVehicle(vehicle, profileId);
      if (context.mounted) Navigator.pop(context);
      MessagesToast.showMessageSuccess("Vehículo registrado");
      final provider = Provider.of<VehicleProvider>(context, listen: false);
      await provider.fetchVehicles(userId, profileId);
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UploadVehicleDocumentation(
              name: "Matricula",
              idVehicle: provider.vehicleList.last.id!,
              idDocument: 1,
            ),
          ),
        );
      }

      // Limpiar el formulario después de un breve tiempo
      Future.delayed(const Duration(milliseconds: 500), () {
        clearForm();
      });
    } catch (e) {
      if (context.mounted)
        Navigator.pop(context); // Asegurar que el diálogo se cierre
      debugPrint("Error creando vehículo: $e");
    }
  }

  Future<void> loadCarBrands() async {
    try {
      final brands = await _vehicleServices.getBrands();
      setState(() {
        carBrandList = brands;
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar las marcas");
    }
  }

  Future<void> fetchModelsByBrandId(int brandId) async {
    try {
      final models = await _vehicleServices.getModels();
      setState(() {
        vehicleList =
            models.where((model) => model.carBrandId == brandId).toList();
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar los modelos");
    }
  }

  bool _isLodingModels = false;

  Future<void> loadVehicleType() async {
    try {
      final typesModels = await _vehicleServices.getVehicleType();
      setState(() {
        vehicleTypeList = typesModels;
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar los tipos de vehiculo");
    }
  }

  Future<void> loadColors() async {
    try {
      final colors = await _vehicleServices.getColors();
      setState(() {
        colorList = colors;
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar los colores");
    }
  }

  void _showRegistrationAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          iconData: Icons.info,
          title: "!Importante!",
          onPressedRoute: () {
            Navigator.pop(context);
            _showValidationAlert(context);
          },
          content:
              "Recuerda registrar únicamente vehículos de los cuales eres propietario.",
        );
      },
    );
  }

  void _showValidationAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CustomAlertDialog(
          iconData: Icons.warning,
          title: "!Importante!",
          content:
              "Asegúrate de ingresar la matrícula en el formato correcto ABC1234 o ABC-1234 . Este dato es obligatorio, ya que nos permite identificar correctamente su vehículo y procesar solicitudes posteriores.",
        );
      },
    );
  }

  /*void _validateBrand(String value) {
    final plateRegex = RegExp(r'^[A-Z]{3}-?\d{4}$');
    if (plateRegex.hasMatch(value)) {
      setState(() {
        _enableForms = true;
      });
    }
  }*/

void _validateBrand(String value) {
  final plateRegexCar = RegExp(
      r'^[A-Z]{3}-?\d{4}$|^[A-Z]{3}\d{4}$'); // Formato carro moderno: ABC-1234 o ABC1234
  final plateRegexOldVehicle = RegExp(
      r'^[A-Z]{3}-?\d{3}$|^[A-Z]{3}\d{3}$'); // Formato vehículo antiguo: ABC-123 o ABC123
  final plateRegexMoto =
      RegExp(r'^[A-Z]{2}\d{3}[A-Z]{1}$'); // Formato moto: AA000A

  if (plateRegexCar.hasMatch(value)) {
    setState(() {
      _enableForms = true;
      vehicleType = 'Carro'; // Es carro moderno
      FocusScope.of(context).unfocus();
    });
    print('Es un carro moderno');
  } else if (plateRegexOldVehicle.hasMatch(value)) {
    setState(() {
      _enableForms = true;
      vehicleType = 'Carro'; // Es vehículo antiguo
      FocusScope.of(context).unfocus();
    });
    print('Es un vehículo antiguo');
  } else if (plateRegexMoto.hasMatch(value)) {
    setState(() {
      _enableForms = true;
      vehicleType = 'Moto'; // Es moto
      FocusScope.of(context).unfocus();
    });
    print('Es una moto');
  } else {
    setState(() {
      _enableForms = false; // Formato no reconocido
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Observer(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white),
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const DashboardScreen(initialIndex: 3)));
              },
              child: Icon(
                Icons.arrow_back_ios,
                color: appStore.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          surfaceTintColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          backgroundColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          title: Text('Registro de Vehículo',
              style: primarytextStyle(
                  color: appStore.isDarkMode ? Colors.white : Colors.black)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      vehicleType == 'Carro' ? image_auto_1 : image_moto1,
                      width: 115,
                      height: 80,
                    ),
                  ),
                  buildFormDataVehicle(
                    context: context,
                    formKey: _formKey,
                    controllerPlateNumber: controllerPlateNumber,
                    controllerYear: controllerYear,
                    controllerChassisNumber: controllerChassisNumber,
                    controllerEngineNumber: controllerEngineNumber,
                    enableForms: _enableForms,
                    onPlateChanged: _validateBrand,
                    onChangedBrand: (CarBrandModel? brand) async {
                      if (brand != null) {
                        setState(() {
                          carBrandModel = brand;
                          vehicleModel = null;
                          vehicleList = [];
                          _isLodingModels = true; // Mostrar loader
                        });

                        await fetchModelsByBrandId(brand.id).then((_) {
                          setState(() {
                            _isLodingModels = false; // Ocultar loader
                          });
                        });
                        FocusScope.of(context).unfocus();
                      }
                    },
                    onChangedModel: (VehicleModel? model) {
                      setState(() {
                        vehicleModel = model;
                      });
                      FocusScope.of(context).unfocus();
                    },
                    onChangedTypeVehicle: (TypeVehicleModel? type) {
                      setState(() {
                        typeVehicleModel = type;
                      });
                    },
                    colorModel: colorModel,
                    onChangedColor: (ColorModel? color) {
                      setState(() {
                        colorModel = color;
                      });
                    },
                    colorList: colorList,
                    carBrandModel: carBrandModel,
                    vehicleModel: vehicleModel,
                    typeVehicleModel: typeVehicleModel,
                    carBrandList: carBrandList,
                    vehicleList: vehicleList,
                    vehicleTypeList: vehicleTypeList,
                  ),
                  AppButton(
                    width: double.infinity,
                    elevation: 0,
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        VehicleModelUser vehicle = VehicleModelUser(
                          carModelId: vehicleModel!.id,
                          plateNumber: controllerPlateNumber.text,
                          carBrandId: carBrandModel!.id,
                          year: controllerYear.text,
                          carColorId: colorModel!.id,
                          chassisNumber: controllerChassisNumber.text.isNotEmpty
                              ? controllerChassisNumber.text
                              : null,
                          engineNumber: controllerEngineNumber.text.isNotEmpty
                              ? controllerEngineNumber.text
                              : null,
                          vehicleTypeId: typeVehicleModel!.id,
                          userId: userProvider.user.id,
                          ownerName: userProvider.user.name,
                        );
                        debugPrint(
                            "Datos del vehículo creado: ${vehicle.toJson()}");
                        await _createVehicle(
                          vehicle,
                          context.read<UserProvider>().user.id,
                          context.read<UserProvider>().currentProfile,
                        );
                      } else {
                        MessagesToast.showMessageError(
                            "Revisa bien los datos ingresados");
                      }
                    },
                    color: simon_finalPrimaryColor,
                    shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Registrar Vehiculo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ).paddingSymmetric(vertical: 10),
                ],
              ),
            ),

            // Loader superpuesto en el centro de la pantalla
            if (_isLodingModels)
              const Stack(
                children: [
                  Positioned.fill(
                    child: Center(
                      child: AlertDialog(
                        backgroundColor: simonGris,
                        content: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: simon_finalPrimaryColor,
                            ),
                            SizedBox(width: 10),
                            Text("Cargando modelos..."),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ModalBarrier(
                      dismissible:
                          false, // Evita que el usuario toque la pantalla
                      color: Colors
                          .transparent, // Hace que solo bloquee sin cambiar el color
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
/*
Widget buildFormDataVehicle({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController controllerPlateNumber,
  required TextEditingController controllerYear,
  required TextEditingController controllerChassisNumber,
  required TextEditingController controllerEngineNumber,
  required bool enableForms,
  required Function(String)? onPlateChanged,
  required Function(CarBrandModel?) onChangedBrand,
  required Function(VehicleModel?) onChangedModel,
  required Function(ColorModel?) onChangedColor,
  required Function(TypeVehicleModel?) onChangedTypeVehicle,
  required CarBrandModel? carBrandModel,
  required VehicleModel? vehicleModel,
  required TypeVehicleModel? typeVehicleModel,
  required ColorModel? colorModel,
  required List<CarBrandModel> carBrandList,
  required List<VehicleModel> vehicleList,
  required List<TypeVehicleModel> vehicleTypeList,
  required List<ColorModel> colorList,
  TextEditingController? controllerBrand,
  TextEditingController? controllerModel,
}) {
  final FocusNode plateNumberFocus = FocusNode();
  final FocusNode brandFocus = FocusNode();
  final FocusNode modelFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();
  final FocusNode colorFocus = FocusNode();
  final FocusNode chassisFocus = FocusNode();
  final FocusNode engineFocus = FocusNode();
  final FocusNode vehicleTypeFocus = FocusNode();

  void showLocationNumberChasis(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const CustomInfoAlert(
            imageUrl: example_matricula_2,
            withImage: true,
            title: "¿Dónde está el chasis?",
            infoMessage:
                "El número de chasis (VIN) también se encuentra en la licencia del vehículo, generalmente debajo del número de placa.");
      },
    );
  }

  return Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Placa del Vehiculo:', style: boldTextStyle()),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        TextFormFieldSimon(
          onChanged: onPlateChanged,
          // moreAjusted: true,
          controller: controllerPlateNumber,
          focusNode: plateNumberFocus,
          hintText: 'XXXXXXX',
          textCapitalization: TextCapitalization.characters,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(8),
          ],

          showInfoIcon: true,
          infoMessage:
              "Debe ingresar una matrícula válida en el formato ABC-1234 o ABC1234 para continuar.\nEste dato es obligatorio, ya que nos permite identificar correctamente su vehículo y procesar su solicitud.",
        ),
        5.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca:', style: boldTextStyle()),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        /*CustomDropdownButtonFormField<CarBrandModel>(
          enabled: enableForms,
          focusNode: brandFocus,
          value: carBrandModel,
          items: carBrandList.map((CarBrandModel brand) {
            return DropdownMenuItem<CarBrandModel>(
              value: brand,
              child: Text(brand.name), // Ajusta según tu modelo
            );
          }).toList(),
          onChanged: onChangedBrand,
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecciona una marca';
            }
            return null;
          },
          hintText: 'Selecciona una marca',
        ),*/
        Autocomplete<CarBrandModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<CarBrandModel>.empty();
            }

            final query = textEditingValue.text.toLowerCase();
            return carBrandList
                .where((brand) => brand.name.toLowerCase().contains(query))
                .take(15); // Limita resultados a 20
          },
          displayStringForOption: (CarBrandModel option) => option.name,
          onSelected: onChangedBrand,
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.name),
                        onTap: () {
                          onSelected(option);
                          FocusScope.of(context).unfocus();
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controllerBrand != null) {
              controller.text = controllerBrand.text;
            }
            return TextFormFieldSimon(
              
              enabled: enableForms,
              controller: controller,
              focusNode: focusNode,
              hintText: controllerBrand != null
                  ? "${controllerBrand!.text}"
                  : "Selecciona una marca",
              textCapitalization: TextCapitalization.characters,
              
            );
          },
        ),
        5.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modelo:', style: boldTextStyle()),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        Autocomplete<VehicleModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<VehicleModel>.empty();
            }

            final query = textEditingValue.text.toLowerCase();
            return vehicleList
                .where((model) => model.name.toLowerCase().contains(query))
                .take(15); // Limita a 20 resultados
          },
          displayStringForOption: (VehicleModel option) => option.name,
          onSelected: (VehicleModel selection) {
            onChangedModel(selection);
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                 color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.name),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            if (controllerModel != null) {
              controller.text = controllerModel.text;
            }
            return TextFormFieldSimon(
              enabled: enableForms,
              textCapitalization: TextCapitalization.characters,
              controller: controller,
              focusNode: focusNode,
              hintText: controllerModel != null
                  ? controllerModel.text
                  : "Selecciona un modelo",
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(yearFocus);
              },
            );
          },
        ),
        5.height,
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Año:', style: boldTextStyle()),
                      const Text("*",
                              style:
                                  TextStyle(fontSize: 16, color: simonNaranja))
                          .paddingSymmetric(horizontal: 2)
                    ],
                  ),
                  TextFormFieldSimon(
                    enabled: enableForms,
                    //moreAjusted: true,
                    focusNode: yearFocus,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(colorFocus);
                    },
                    controller: controllerYear,
                    hintText: 'xxxx',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El año es obligatorio';
                      }
                      final int? year = int.tryParse(value);
                      if (year == null) {
                        return 'Ingrese un año válido';
                      }

                      int currentYear = DateTime.now().year;

                      if (year < 1960 || year > (currentYear + 1)) {
                        return 'Ingrese un año válido';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ],
              ),
            ),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color:', style: boldTextStyle()),
                      const Text("*",
                              style:
                                  TextStyle(fontSize: 16, color: simonNaranja))
                          .paddingSymmetric(horizontal: 2)
                    ],
                  ),
                  CustomDropdownButtonFormField<ColorModel>(
                    enabled: enableForms,
                    focusNode: colorFocus,
                    value: colorModel,
                    items: colorList.map((ColorModel model) {
                      return DropdownMenuItem<ColorModel>(
                        value: model,
                        child: Text(model.name), // Ajusta según tu modelo
                      );
                    }).toList(),
                    onChanged: onChangedColor,
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un color';
                      }
                      return null;
                    },
                    hintText: 'Color',
                  ),
                ],
              ),
            )
          ],
        ),
        5.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de vehículo:', style: boldTextStyle()),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        CustomDropdownButtonFormField<TypeVehicleModel>(
          enabled: enableForms,
          focusNode: vehicleTypeFocus,
          value: typeVehicleModel,
          items: vehicleTypeList.map((TypeVehicleModel type) {
            return DropdownMenuItem<TypeVehicleModel>(
              value: type,
              child: Text(type.name), // Ajusta según tu modelo
            );
          }).toList(),
          onChanged: onChangedTypeVehicle,
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecciona un tipo de vehículo';
            }
            return null;
          },
          hintText: 'Selecciona un tipo de vehículo',
        ),
        Row(
          children: [
            Text('Número de chasis:', style: boldTextStyle()),
            IconButton(
                onPressed: () {
                  showLocationNumberChasis(context);
                },
                icon: const Icon(Icons.help))
          ],
        ),
        5.height,
        TextFormFieldSimon(
          showMaxLength: true,
          maxLength: 17,
          enabled: enableForms,
          inputFormatters: [
            LengthLimitingTextInputFormatter(17),
          ],
          validator: (value) {},
          //moreAjusted: true,
          focusNode: chassisFocus,
          controller: controllerChassisNumber,
          hintText: 'Número de chasis',
          textCapitalization: TextCapitalization.characters,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(engineFocus);
          },
        ),
        5.height,
      ],
    ),
  );
}*/

Widget buildFormDataVehicle({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required TextEditingController controllerPlateNumber,
  required TextEditingController controllerYear,
  required TextEditingController controllerChassisNumber,
  required TextEditingController controllerEngineNumber,
  required bool enableForms,
  required Function(String)? onPlateChanged,
  required Function(CarBrandModel?) onChangedBrand,
  required Function(VehicleModel?) onChangedModel,
  required Function(ColorModel?) onChangedColor,
  required Function(TypeVehicleModel?) onChangedTypeVehicle,
  required CarBrandModel? carBrandModel,
  required VehicleModel? vehicleModel,
  required TypeVehicleModel? typeVehicleModel,
  required ColorModel? colorModel,
  required List<CarBrandModel> carBrandList,
  required List<VehicleModel> vehicleList,
  required List<TypeVehicleModel> vehicleTypeList,
  required List<ColorModel> colorList,
  TextEditingController? controllerBrand,
  TextEditingController? controllerModel,
}) {
  final FocusNode plateNumberFocus = FocusNode();
  final FocusNode brandFocus = FocusNode();
  final FocusNode modelFocus = FocusNode();
  final FocusNode yearFocus = FocusNode();
  final FocusNode colorFocus = FocusNode();
  final FocusNode chassisFocus = FocusNode();
  final FocusNode engineFocus = FocusNode();
  final FocusNode vehicleTypeFocus = FocusNode();

  // Filtros para búsqueda
  final TextEditingController brandSearchController = TextEditingController();
  final TextEditingController modelSearchController = TextEditingController();
  List<CarBrandModel> filteredBrands = carBrandList;
  List<VehicleModel> filteredModels = vehicleList;

  void filterBrands(String query) {
    filteredBrands = carBrandList.where((brand) {
      return brand.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void filterModels(String query) {
    filteredModels = vehicleList.where((model) {
      return model.name.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  void showLocationNumberChasis(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const CustomInfoAlert(
            imageUrl: example_matricula_2,
            withImage: true,
            title: "¿Dónde está el chasis?",
            infoMessage:
                "El número de chasis (VIN) también se encuentra en la licencia del vehículo, generalmente debajo del número de placa.");
      },
    );
  }

  return Form(
    key: formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placa del Vehículo (se mantiene igual)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Placa del Vehiculo:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        TextFormFieldSimon(
          onChanged: onPlateChanged,
          controller: controllerPlateNumber,
          focusNode: plateNumberFocus,
          hintText: 'XXXXXXX',
          textCapitalization: TextCapitalization.characters,
          onFieldSubmitted: (_) {
            FocusScope.of(context).unfocus();
          },
          inputFormatters: [
            LengthLimitingTextInputFormatter(8),
          ],
          showInfoIcon: true,
          infoMessage:
              "Debe ingresar una matrícula válida en el formato ABC-1234 o ABC1234 para continuar.\nEste dato es obligatorio, ya que nos permite identificar correctamente su vehículo y procesar su solicitud.",
        ),
        5.height,

        // Marca con dropdown y búsqueda
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        AbsorbPointer(
          absorbing: !enableForms,
          child: DropdownButtonFormField2<CarBrandModel>(
            isExpanded: true,
            isDense: false,
            hint: Text(
              'Selecciona una marca',
              style: TextStyle(
                fontSize: 14,
                color:enableForms
    ? (appStore.isDarkMode ? Colors.white : Colors.black)
    : (appStore.isDarkMode ? Colors.white54 : resendColor)
              ),
            ),
            items: enableForms
                ? filteredBrands
                    .map((item) => DropdownMenuItem<CarBrandModel>(
                          value: item,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: appStore.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ))
                    .toList()
                : null,
            value: carBrandModel,
            onChanged: (value) {
              onChangedBrand(value);
              // Limpiar el modelo cuando cambia la marca
              onChangedModel(null);
              if (controllerModel != null) {
                controllerModel!.clear();
              }
              modelSearchController.clear();
              filteredModels = vehicleList;
            },
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecciona una marca';
              }
              return null;
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            iconStyleData:  IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: enableForms 
        ? (appStore.isDarkMode ? Colors.white70 : Colors.black45)
        : Colors.grey,
              ),
              iconSize: 24,
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              fillColor:
                  appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: BorderSide(
                    color: enableForms ? borderColor : resendColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: const BorderSide(color: simonNaranja, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide:
                    const BorderSide(color: simon_finalPrimaryColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide:
                    const BorderSide(color: simon_finalPrimaryColor, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: const BorderSide(color: resendColor, width: 1),
              ),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
              ),

              elevation: 4, // Sombra para mejor visibilidad
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Más espacio
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return appStore.isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[100]!; // Color al pasar el mouse
                }
                return Colors.transparent;
              }),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: brandSearchController,
              searchInnerWidgetHeight: 60,
              searchInnerWidget: Container(
                height: 60,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                decoration: BoxDecoration(
                  color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                ),
                child: TextFormField(
                  style: TextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                  textCapitalization: TextCapitalization.characters,
                  controller: brandSearchController,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 12,
                    ),
                    hintText: 'Buscar marca...',
                    hintStyle: const TextStyle(fontSize: 14),
                    fillColor: appStore.isDarkMode
                        ? scaffoldSecondaryDark
                        : Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      borderSide: BorderSide(
                        color: appStore.isDarkMode
                            ? Colors.grey[700]!
                            : borderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      borderSide: BorderSide(
                        color: appStore.isDarkMode
                            ? Colors.grey[700]!
                            : borderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      borderSide: const BorderSide(
                        color: simon_finalPrimaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    filterBrands(value);
                  },
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value!.name
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                brandSearchController.clear();
                filterBrands('');
              }
            },
          ),
        ),
        5.height,

        // Modelo con dropdown y búsqueda
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modelo:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        AbsorbPointer(
          absorbing: !enableForms,
          child: DropdownButtonFormField2<VehicleModel>(
            isExpanded: true,
            isDense: false,
            hint: Text(
              'Selecciona un modelo',
              style: TextStyle(
                fontSize: 14,
                color: enableForms
            ? (appStore.isDarkMode ? Colors.white : Colors.black)  // Texto blanco en oscuro/habilitado, negro en claro/habilitado
            : (appStore.isDarkMode ? Colors.white54 : resendColor),
              ),
            ),
            items: enableForms
                ? filteredModels
                    .map((item) => DropdownMenuItem<VehicleModel>(
                          value: item,
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: appStore.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ))
                    .toList()
                : null,
            value: vehicleModel,
            onChanged: (VehicleModel? selectedModel) {
      if (selectedModel != null) {
        onChangedModel(selectedModel);
        
        // Redirigir el foco al campo de año después de seleccionar
        FocusScope.of(context).requestFocus(yearFocus);
        
        // Opcional: Limpiar el campo de búsqueda
        modelSearchController.clear();
        filterModels('');
      }
    },
            validator: (value) {
              if (value == null) {
                return 'Por favor, selecciona un modelo';
              }
              return null;
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(right: 8),
            ),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              fillColor:
                  appStore.isDarkMode ? scaffoldSecondaryDark : Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: BorderSide(
                    color: enableForms ? borderColor : resendColor, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: const BorderSide(color: simonNaranja, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide:
                    const BorderSide(color: simon_finalPrimaryColor, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide:
                    const BorderSide(color: simon_finalPrimaryColor, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                borderSide: const BorderSide(color: resendColor, width: 1),
              ),
            ),
            iconStyleData:  IconStyleData(
              icon: Icon(
                Icons.arrow_drop_down,
                color: enableForms 
        ? (appStore.isDarkMode ? Colors.white70 : Colors.black45)
        : Colors.grey,
              ),
              iconSize: 24,
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
              ),

              elevation: 4, // Sombra para mejor visibilidad
            ),
            menuItemStyleData: MenuItemStyleData(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Más espacio
              overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return appStore.isDarkMode
                      ? Colors.grey[800]!
                      : Colors.grey[100]!; // Color al pasar el mouse
                }
                return Colors.transparent;
              }),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: modelSearchController,
              searchInnerWidgetHeight: 60,
              searchInnerWidget: Container(
                height: 60,
                padding: const EdgeInsets.only(
                  top: 8,
                  bottom: 4,
                  right: 8,
                  left: 8,
                ),
                decoration: BoxDecoration(
                  color: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                ),
                child: TextFormField(
                  controller: modelSearchController,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 12,
                      ),
                      hintText: 'Buscar modelo...',
                      hintStyle: const TextStyle(fontSize: 14),
                      fillColor: appStore.isDarkMode
                          ? scaffoldSecondaryDark
                          : Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                        borderSide: BorderSide(
                          color: appStore.isDarkMode
                              ? Colors.grey[700]!
                              : borderColor,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                        borderSide: BorderSide(
                          color: appStore.isDarkMode
                              ? Colors.grey[700]!
                              : borderColor,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                        borderSide: const BorderSide(
                          color: simon_finalPrimaryColor,
                          width: 1.5, // Borde más grueso cuando está enfocado
                        ),
                      )),
                  onChanged: (value) {
                    filterModels(value);
                  },
                ),
              ),
              searchMatchFn: (item, searchValue) {
                return item.value!.name
                    .toLowerCase()
                    .contains(searchValue.toLowerCase());
              },
            ),
            onMenuStateChange: (isOpen) {
              if (!isOpen) {
                modelSearchController.clear();
                filterModels('');
              }
            },
          ),
        ),
        5.height,

        // Resto del formulario (se mantiene igual)
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Año:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
                      const Text("*",
                              style:
                                  TextStyle(fontSize: 16, color: simonNaranja))
                          .paddingSymmetric(horizontal: 2)
                    ],
                  ),
                  TextFormFieldSimon(
                    enabled: enableForms,
                    focusNode: yearFocus,
                    onFieldSubmitted: (_) {
                      //FocusScope.of(context).requestFocus(colorFocus);
                      FocusScope.of(context).unfocus();
                    },
                    controller: controllerYear,
                    hintText: 'xxxx',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El año es obligatorio';
                      }
                      final int? year = int.tryParse(value);
                      if (year == null) {
                        return 'Ingrese un año válido';
                      }

                      int currentYear = DateTime.now().year;

                      if (year < 1960 || year > (currentYear + 1)) {
                        return 'Ingrese un año válido';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ],
              ),
            ),
            10.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
                      const Text("*",
                              style:
                                  TextStyle(fontSize: 16, color: simonNaranja))
                          .paddingSymmetric(horizontal: 2)
                    ],
                  ),
                  CustomDropdownButtonFormField<ColorModel>(
                    enabled: enableForms,
                    //focusNode: colorFocus,
                    value: colorModel,
                    items: colorList.map((ColorModel model) {
                      return DropdownMenuItem<ColorModel>(
                        value: model,
                        child: Text(model.name),
                      );
                    }).toList(),
                    onChanged: onChangedColor,
                    validator: (value) {
                      if (value == null) {
                        return 'Selecciona un color';
                      }
                      return null;
                    },
                    hintText: 'Color',
                  ),
                ],
              ),
            )
          ],
        ),
        5.height,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo de vehículo:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
            const Text("*", style: TextStyle(fontSize: 16, color: simonNaranja))
                .paddingSymmetric(horizontal: 2)
          ],
        ),
        5.height,
        CustomDropdownButtonFormField<TypeVehicleModel>(
          enabled: enableForms,
          focusNode: vehicleTypeFocus,
          value: typeVehicleModel,
          items: vehicleTypeList.map((TypeVehicleModel type) {
            return DropdownMenuItem<TypeVehicleModel>(
              value: type,
              child: Text(type.name),
            );
          }).toList(),
          onChanged: onChangedTypeVehicle,
          validator: (value) {
            if (value == null) {
              return 'Por favor, selecciona un tipo de vehículo';
            }
            return null;
          },
          hintText: 'Selecciona un tipo de vehículo',
        ),
        Row(
          children: [
            Text('Número de chasis:', style: boldTextStyle(color: appStore.isDarkMode ? scaffoldLightColor : Colors.black)),
            IconButton(
                onPressed: () {
                  showLocationNumberChasis(context);
                },
                icon: const Icon(Icons.help))
          ],
        ),
        5.height,
        TextFormFieldSimon(
          showMaxLength: true,
          maxLength: 17,
          enabled: enableForms,
          inputFormatters: [
            LengthLimitingTextInputFormatter(17),
          ],
          validator: (value) {},
          focusNode: chassisFocus,
          controller: controllerChassisNumber,
          hintText: 'Número de chasis',
          textCapitalization: TextCapitalization.characters,
          onFieldSubmitted: (_) {
            FocusScope.of(context).requestFocus(engineFocus);
          },
        ),
        5.height,
      ],
    ),
  );
}
