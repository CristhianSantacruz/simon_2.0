import 'package:flutter_svg/svg.dart';
import 'package:simon_final/components/simon/dropdowm_simon.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/components/text_styles.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/addres_model.dart';
import 'package:simon_final/models/cities_model.dart';
import 'package:simon_final/models/country_model.dart';
import 'package:simon_final/models/states_model.dart';
import "package:simon_final/screens/modals/address_picker.dart";
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/address_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';

class AddDirectionScreen extends StatefulWidget {
  const AddDirectionScreen({super.key});

  @override
  State<AddDirectionScreen> createState() => _AddDirectionScreenState();
}

class _AddDirectionScreenState extends State<AddDirectionScreen> {
  final TextEditingController controllerAlias = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerPostcode = TextEditingController();
  final TextEditingController controllerPhone = TextEditingController();
  final TextEditingController controllerPhoneMobile = TextEditingController();
  final TextEditingController controllerCountry = TextEditingController();
  final TextEditingController controllerState = TextEditingController();
  final TextEditingController controllerCity = TextEditingController();
  final TextEditingController controllerDistrictId = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerLastName = TextEditingController();
  final TextEditingController controllerIdentification =
      TextEditingController();

  TypeAdressModel? _selectedTypeAdress;
  final formKey = GlobalKey<FormState>();
  final _addressServices = AddressServices();
  final _countries = <CountryModel>[];
  final _states = <StateModel>[];
  final _cities = <CitieModel>[];
  int _countryId = 0;
  int _stateId = 0;
  int _cityId = 0;

  ///final _typeAdress = TypeAdressModel.ADDRESS.name;

  String _getTypeAdressText(TypeAdressModel type) {
    switch (type) {
      case TypeAdressModel.INVOICE:
        return 'Dirección para facturación';
      case TypeAdressModel.ADDRESS:
        return 'Dirección para domicilio';
      default:
        return '';
    }
  }

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    controllerName.text = user.name;
    controllerLastName.text = user.lastName ?? "";
    controllerIdentification.text = user.identification ?? "";
    controllerPhoneMobile.text = user.phone ?? "";
    super.initState();
    _fetchCountries();
    _fetchStates();
    _fetchCities();
  }

  @override
  void dispose() {
    controllerAlias.dispose();
    controllerAddress.dispose();
    controllerPostcode.dispose();
    controllerPhone.dispose();
    controllerPhoneMobile.dispose();
    controllerDistrictId.dispose();
    controllerName.dispose();
    controllerLastName.dispose();
    controllerIdentification.dispose();
    controllerCountry.dispose();
    controllerState.dispose();
    controllerCity.dispose();
    super.dispose();
  }

  Future<void> _fetchCountries() async {
    final countries = await _addressServices.getCountries();
    setState(() {
      _countries.clear();
      _countries.addAll(countries);
    });
  }

  Future<void> _fetchStates() async {
    final states = await _addressServices.getStates();
    setState(() {
      _states.clear();
      _states.addAll(states);
    });
  }

  Future<void> _fetchCities() async {
    final cities = await _addressServices.getCities();
    setState(() {
      _cities.clear();
      _cities.addAll(cities);
    });
  }

void createAddress(AddressModel address) async {
  final type = address.type;
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  try {
    // Obtener direcciones del usuario
    List<AddressModel> existingAddresses = await _addressServices.getAddressByUser(
      userProvider.user.id, 
      userProvider.currentProfile
    );

    // Verificar si ya existe una dirección de tipo ADDRESS
    bool addressExists = existingAddresses.any((addr) => addr.type == type);
    
    if (addressExists && type == "ADDRESS") {
      MessagesToast.showMessageInfo("Ya tienes una dirección de domicilio registrada");
      return; // Salir sin registrar una nueva dirección
    }

    // Si no existe, proceder a registrar
    await _addressServices.createAddress(address);
    MessagesToast.showMessageSuccess("Dirección creada");

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, Routes.directions);
    });
  } catch (e) {
    toast("Error creando dirección",
        gravity: ToastGravity.CENTER,
        bgColor: Colors.red,
        textColor: white_color);
    debugPrint("Error creando dirección: $e");
  }
}


  void _showStatePicker() {
    AddressPicker.showStatePicker(
        context: context,
        states: _states,
        countryId: _countryId,
        onStateSelected: (stateName, stateId) {
          setState(() {
            controllerState.text = stateName;
            _stateId = stateId;
          });
        },
        cities: _cities,
        onCitySelected: (cityName, cityId) {
          setState(() {
            controllerCity.text = cityName;
            _cityId = cityId;
          });
        });
  }

  void _showCityPicker() {
    AddressPicker.showCityPicker(
        context: context,
        cities: _cities,
        stateId: _stateId,
        onCitySelected: (cityName, cityId) {
          setState(() {
            controllerCity.text = cityName;
            _cityId = cityId;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: appStore.isDarkMode ? scaffoldDarkColor : Colors.white,
          elevation: 0,
          centerTitle: true,
          surfaceTintColor:
              appStore.isDarkMode ? scaffoldDarkColor : white_color,
          leading: IconButton(
            color: appStore.isDarkMode ? Colors.white : Colors.black,
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: appStore.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          title: Text('Agregar Nueva Dirección',
              style: primarytextStyle(
                weight: FontWeight.w500,
                size: 20,
                color: appStore.isDarkMode ? scaffoldLightColor : Colors.black,
              )),
          actions: [
            GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DEFAULT_RADIUS),
                      ),
                      title: const Text("Información"),
                      content: RichText(
                        text: const TextSpan(
                            text:
                                "Podras agregar una direccion de facturación  o de dirección para  domicilio.\n\nLos campos",
                            style: TextStyle(color: Colors.black),
                            children: [
                              TextSpan(
                                  text: " * ",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16)),
                              TextSpan(
                                  text: "son obligatorios",
                                  style: TextStyle(color: Colors.black)),
                            ]),
                      ),
                      actions: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: simon_finalPrimaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(DEFAULT_RADIUS)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "OK",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: Icon(
                  Icons.info,
                  size: 28,
                  color: appStore.isDarkMode ? Colors.white : Colors.black,
                )).paddingRight(16)
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                land_location_icon_svg,
                color: simon_finalPrimaryColor,
                width: 80,
                height: 80,
              ).center(),
              10.height,
              _formRegisterDirection(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AppButton(
                  width: double.infinity,
                  elevation: 2,
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      AddressModel address = AddressModel(
                        type: _selectedTypeAdress!.name,
                        alias: controllerAlias.text,
                        lastname: controllerLastName.text,
                        firstname: controllerName.text,
                        address: controllerAddress.text,
                        postcode: controllerPostcode.text,
                        phone: controllerPhone.text,
                        phoneMobile: controllerPhoneMobile.text,
                        identification: controllerIdentification.text,
                        userId: userProvider.user.id,
                        countryId: _countryId,
                        stateId: _stateId,
                        cityId: _cityId,
                        profileId: userProvider.currentProfile,
                      );
                      debugPrint("Valido para registrarse");
                      createAddress(address);
                    }
                  },
                  color: simon_finalPrimaryColor,
                  shapeBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
                  child: const Text('Agregar Direccion',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ));
  }

  Form _formRegisterDirection() {
    final FocusNode typeDirection = FocusNode();
    final FocusNode aliasFocusNode = FocusNode();
    final FocusNode addressFocusNode = FocusNode();
    final FocusNode nameFocusNode = FocusNode();
    final FocusNode lastNameFocusNode = FocusNode();
    final FocusNode identificationFocusNode = FocusNode();
    final FocusNode countryFocusNode = FocusNode();
    final FocusNode stateFocusNode = FocusNode();
    final FocusNode cityFocusNode = FocusNode();
    final FocusNode postcodeFocusNode = FocusNode();
    final FocusNode phoneFocusNode = FocusNode();
    final FocusNode phoneMobileFocusNode = FocusNode();
    return Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RithTextCampoRequired(title: "Dirección para"),
            5.height,
            CustomDropdownButtonFormField<TypeAdressModel>(
              enabled: true,
              focusNode: typeDirection,
              value: _selectedTypeAdress,
              items: TypeAdressModel.values.map((TypeAdressModel type) {
                return DropdownMenuItem<TypeAdressModel>(
                  value: type,
                  child: Text(_getTypeAdressText(type)),
                );
              }).toList(),
              onChanged: (TypeAdressModel? newValue) {
                setState(() {
                  _selectedTypeAdress = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Por favor, selecciona un tipo de dirección';
                }
                return null;
              },
              hintText: 'Selecciona un tipo de dirección',
            ),
            const RithTextCampoRequired(title: "Dirección"),
            5.height,
            TextFormFieldSimon(
              focusNode: addressFocusNode,
              suffixIcon: const Icon(Icons.location_on),
              //moreAjusted: true,
              controller: controllerAddress,
              hintText: 'Ej Avenida de la República, 1234',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_nameFocusNode);
                _showCountryPicker();
              },
            ),
            const RithTextCampoRequired(title: "País"),
            5.height,
            TextFormFieldSimon(
              onTapSimon: () {
                _showCountryPicker();
              },
              //moreAjusted: true,
              controller: controllerCountry,
              hintText: 'País',
              focusNode: countryFocusNode,
              isReadOnly: true,
              suffixIcon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.black,
              ),

              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(stateFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Estado"),
            5.height,
            TextFormFieldSimon(
              onTapSimon: () {
                if (_countryId != 0) {
                  _showStatePicker();
                }
              },
              //moreAjusted: true,
              controller: controllerState,
              isReadOnly: true,
              focusNode: stateFocusNode,
              hintText: 'Provincia',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(cityFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Ciudad"),
            5.height,
            TextFormFieldSimon(
              onTapSimon: () {
                if (_stateId != 0) {
                  _showCityPicker();
                }
              },
              // moreAjusted: true,
              controller: controllerCity,
              isReadOnly: true,
              focusNode: cityFocusNode,
              hintText: 'Ciudad',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(postcodeFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Nombre"),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerName,
              hintText: 'Ingrese su nombre',
              focusNode: nameFocusNode,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(lastNameFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Apellido"),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerLastName,
              focusNode: lastNameFocusNode,
              hintText: 'Ingrese su apellido',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(identificationFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Identificación"),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerIdentification,
              hintText: 'Ingrese su Identificación',
              textCapitalization: TextCapitalization.words,
              focusNode: identificationFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(countryFocusNode);
              },
            ),
            const RithTextCampoRequired(title: "Teléfono Móvil"),
            5.height,
            TextFormFieldSimon(
              // moreAjusted: true,
              controller: controllerPhoneMobile,
              hintText: 'Ingrese su celular',
              focusNode: phoneMobileFocusNode,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(phoneFocusNode);
              },
            ),
          ],
        ));
  }

  void _showCountryPicker() {
    AddressPicker.showCountryPicker(
      context: context,
      countries: _countries,
      onCountrySelected: (countryName, countryId) {
        setState(() {
          controllerCountry.text = countryName;
          _countryId = countryId;
        });
      },
      states: _states,
      onStateSelected: (stateName, stateId) {
        setState(() {
          controllerState.text = stateName;
          _stateId = stateId;
        });
      },
      cities: _cities,
      onCitySelected: (cityName, cityId) {
        setState(() {
          controllerCity.text = cityName;
          _cityId = cityId;
        });
      },
    );
  }
}

class RithTextCampoRequired extends StatelessWidget {
  final String title;
  const RithTextCampoRequired({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: boldTextStyle(),
          ),
          TextSpan(
            text: " ",
            style: boldTextStyle(),
          ),
          TextSpan(
            text: '*',
            style: boldTextStyle().copyWith(color: Colors.red),
          ),
        ],
      ),
    );
  }
}
