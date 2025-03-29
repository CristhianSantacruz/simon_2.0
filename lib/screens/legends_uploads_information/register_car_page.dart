import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:simon_final/components/simon/alert_dialog.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_model.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';

class RegisterCardUploadPage extends StatefulWidget {
  const RegisterCardUploadPage({super.key});

  @override
  State<RegisterCardUploadPage> createState() => _RegisterCardUploadPageState();
}

class _RegisterCardUploadPageState extends State<RegisterCardUploadPage> {
  bool _enableForms = false;
  bool _isRegistering = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerPlateNumber = TextEditingController();
  final TextEditingController controllerYear = TextEditingController();
  final TextEditingController controllerChassisNumber = TextEditingController();
  final TextEditingController controllerEngineNumber = TextEditingController();
  final VehiclesUserServices _vehicleServices = VehiclesUserServices();
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
    _loadInitialData();
    _showRegistrationAlert(context);
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      loadCarBrands(),
      loadVehicleType(),
      loadColors(),
    ]);
  }

  @override
  void dispose() {
    controllerPlateNumber.dispose();
    controllerYear.dispose();
    controllerChassisNumber.dispose();
    controllerEngineNumber.dispose();
    super.dispose();
  }



  void _showRegistrationAlert(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            onPressedRoute: (){
              Navigator.pop(context);
              _showValidationAlert(context);
            },
            iconData: Icons.info,
            title: "!Importante!",
            content:
                "Recuerda registrar únicamente vehículos de los cuales eres propietario.",
          );
        },
      );
    });
  }

    void _showValidationAlert(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const CustomAlertDialog(
        iconData: Icons.warning,
        title: "!Importante!",
        content: "Asegúrate de ingresar la matrícula en el formato correcto ABC1234 o ABC-1234. Este dato es obligatorio, ya que nos permite identificar correctamente su vehículo y procesar solicitudes posteriores.",
      );
    },
  );
}


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

  


  Future<void> _createVehicle(VehicleModelUser vehicle,int profileId) async {
  try {
    await _vehicleServices.createVehicle(vehicle,profileId);
    MessagesToast.showMessageSuccess("Vehículo creado correctamente");
  } catch (e) {
   // MessagesToast.showMessageError("Error creando vehículo");
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
  
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final PageControllerProvider pageControllerProvider =
        Provider.of<PageControllerProvider>(context);
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return !_isRegistering
        ? Stack(
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
                            vehicleModel =null; 
                            vehicleList =[]; 
                            isLoading = true; 
                          });
            
                          await fetchModelsByBrandId(brand.id).then((_){
                            setState(() {
                              isLoading = false; 
                            });
                          });
                        }
                        ;
                      },
                      onChangedModel: (VehicleModel? model) {
                        setState(() {
                          vehicleModel = model;
                        });
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
                        if (_formKey.currentState!.validate() == true) {
                          setState(() {
                            _isRegistering = true;
                          });
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
                         
                            
                          await _createVehicle(vehicle,userProvider.currentProfile).then((value) {
                            Future.delayed(const Duration(milliseconds: 500), () {
                              // clearForm();
                              pageControllerProvider.nextPage();
                            });
                          });
                        } else {
                          toast("Error en los datos",
                              bgColor: Colors.red,
                              textColor: white_color,
                              gravity: ToastGravity.TOP);
                          return;
                        }
                      },
                      color: simon_finalPrimaryColor,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text('Registrar Vehiculo',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white)),
                    ).paddingSymmetric(vertical: 10)
                  ],
                ),
              ),
               if (isLoading)
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
        )
        : const LoaderAppIcon();
  }
}
