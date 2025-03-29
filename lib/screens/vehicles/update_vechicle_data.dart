import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_model.dart';
import 'package:simon_final/models/vehicle_user_model.dart';
import 'package:simon_final/providers/user_provider.dart';
import 'package:simon_final/screens/dashboard/dashboard.dart';
import 'package:simon_final/screens/vehicles/register_car_user.dart';
import 'package:simon_final/services/vehicles_user_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';


class UpdateVechicleUser extends StatefulWidget {
  final VehicleModelUser vehicle;
  const UpdateVechicleUser({super.key, required this.vehicle});

  @override
  State<UpdateVechicleUser> createState() => _UpdateVechicleUserState();
}
class _UpdateVechicleUserState extends State<UpdateVechicleUser> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controllerPlateNumber = TextEditingController();
  final TextEditingController controllerYear = TextEditingController();
  final TextEditingController controllerChassisNumber = TextEditingController();
  final TextEditingController controllerEngineNumber = TextEditingController();
  final TextEditingController controllerModel = TextEditingController();
  final TextEditingController controllerBrand = TextEditingController();

  final VehiclesUserServices _vehicleServices = VehiclesUserServices();
  bool _enableForms = true;
  List<VehicleModel> vehicleList = [];
  List<CarBrandModel> carBrandList = [];
  List<TypeVehicleModel> vehicleTypeList = [];
  List<ColorModel> colorList = [];

  CarBrandModel? carBrandModel;
  VehicleModel? vehicleModel;
  TypeVehicleModel? typeVehicleModel;
  ColorModel? colorModel;
  @override
  void initState() {
    super.initState();
    controllerPlateNumber.text = widget.vehicle.plateNumber;
    controllerYear.text = widget.vehicle.year;
    controllerChassisNumber.text = widget.vehicle.chassisNumber ?? "";
    controllerEngineNumber.text = widget.vehicle.engineNumber ?? "";
    carBrandModel = widget.vehicle.carBrand;
    controllerBrand.text = widget.vehicle.carBrand!.name;
    controllerModel.text = widget.vehicle.vehicleModel!.name!;
   // vehicleModel = widget.vehicle.vehicleModel;
    typeVehicleModel = widget.vehicle.vehicleType;
    colorModel = widget.vehicle.color;
    loadCarBrands();
    loadVehicleType();
    loadColors();
  }
  
  

  @override
  void dispose() {
    controllerPlateNumber.dispose();
    controllerYear.dispose();
    controllerChassisNumber.dispose();
    controllerEngineNumber.dispose();
    super.dispose();
  }

  void clearForm() {
    controllerPlateNumber.clear();

    controllerYear.clear();
    controllerChassisNumber.clear();
    controllerEngineNumber.clear();
  }

    bool _isLodingModels = true;
  
  Future<void> loadCarBrands() async {
    try {
      final brands = await _vehicleServices.getBrands();
      setState(() {
        carBrandList = brands;
        controllerBrand.text = carBrandList.where((element) => element.id == widget.vehicle.carBrandId).first.name;
        fetchModelsByBrandId(widget.vehicle.carBrandId);
        //debugPrint("Car brands: ${carBrandList.toString()}");
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar las marcas");
    }
  }

  Future<void> fetchModelsByBrandId(int brandId) async {
    try {
      final models = await _vehicleServices.getModels();
      setState(() {
        vehicleList = models.where((model) => model.carBrandId == brandId).toList();
        vehicleModel = models.firstWhere(
            (model) => model.id == widget.vehicle.carModelId);
        controllerModel.text = vehicleModel!.name;
      
        _isLodingModels = false;
      });
    } catch (e) {
      MessagesToast.showMessageError("Error al cargar los modelos");
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

  Future<void> _updateVehicle(VehicleModelUser vehicle,int profileId) async {
    try {
      final message = await _vehicleServices.updateVehicle(vehicle,profileId);
      MessagesToast.showMessageSuccess(message);
    } catch (e) {
      toast("Error actualizando vehiculo",bgColor: Colors.red,textColor: white_color,gravity: ToastGravity.TOP);
    }
  }void _validateBrand(String value) {
    final plateRegex = RegExp(r'^[A-Z]{3}-?\d{4}$');
    if (plateRegex.hasMatch(value)) {
      setState(() {
        _enableForms = true;
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
                color: appStore.isDarkMode ? Colors.white : Colors.black),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
            title: Text('Editar Datos del Vehículo',
                style: primarytextStyle(
                    color: appStore.isDarkMode ? Colors.white : Colors.black)),
            centerTitle: true,
          ),
          body: _isLodingModels ? const Center(child: LoaderAppIcon()) : Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                     ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        image_auto_1,
                        width: 115,
                        height: 80,
                        //color: simon_finalPrimaryColor,
                        //fit: BoxFit.cover,
                      ),
                    ),
                    buildFormDataVehicle(
                      controllerBrand: controllerBrand,
                      controllerModel: controllerModel,
                      context: context,
                      formKey: _formKey,
                      controllerPlateNumber: controllerPlateNumber,
                      controllerYear: controllerYear,
                      controllerChassisNumber: controllerChassisNumber,
                      controllerEngineNumber: controllerEngineNumber,
                      enableForms: _enableForms,
                      onPlateChanged: _validateBrand,
                      onChangedBrand: (CarBrandModel? brand) {
                        setState(() {
                          carBrandModel = brand;
                          controllerBrand.text = brand!.name;
                          this._isLodingModels = true;
                        });
                        fetchModelsByBrandId(brand!.id).then((_){
                          setState(() {
                            this._isLodingModels = false;
                          });
                        });
                      },
                      onChangedModel: (VehicleModel? model) {
                        setState(() {
                          vehicleModel = model;
                          controllerModel.text = model!.name;
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
                  ],
                ) /*FormDataVehicle(
                  formKey: _formKey,
                  controllerPlateNumber: controllerPlateNumber,
                  controllerBrand: controllerBrand,
                  controllerYear: controllerYear,
                  controllerColor: controllerColor,
                  controllerChassisNumber: controllerChassisNumber,
                  controllerEngineNumber: controllerEngineNumber,
                  controllerVehicleType: controllerVehicleType,
                  controllerModel: controllerModel,
                  enableForms: true,
                ),*/
              ),
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
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              elevation: 0,
              onTap: () async  {
                if (_formKey.currentState!.validate()==true) {

                  VehicleModelUser vehicle = VehicleModelUser(
                    id: widget.vehicle.id,
                    carModelId: vehicleModel!.id,
                    plateNumber: controllerPlateNumber.text,
                    carBrandId:carBrandModel!.id,
                    year:controllerYear.text,
                    carColorId: colorModel!.id,
                    chassisNumber: controllerChassisNumber.text,
                    engineNumber: controllerEngineNumber.text,
                    vehicleTypeId: typeVehicleModel!.id,
                    userId: userProvider.user.id,
                    ownerName: userProvider.user.name,
                  );
                  debugPrint("Datos a Actualizar del vecicle: ${vehicle.toJson()}");
                  debugPrint("ID del vehiculo: ${widget.vehicle.id}");


                 await _updateVehicle(vehicle,context.read<UserProvider>().currentProfile).then((value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardScreen(initialIndex: 3)));
                    });
                  });                 
                } else {
                   toast("Error en los datos", bgColor: Colors.red, textColor: white_color,gravity: ToastGravity.TOP);
                  return;
                }
              },
              color: simon_finalPrimaryColor,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: const Text('Actualizar Vehiculo',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ),
          ));
    });
  }
}