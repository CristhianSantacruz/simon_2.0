import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simon_final/components/simon/loader_app_icon.dart';
import 'package:simon_final/components/simon/text_form_field_simon.dart';
import 'package:simon_final/models/addres_model.dart';
import 'package:simon_final/models/cities_model.dart';
import 'package:simon_final/models/country_model.dart';
import 'package:simon_final/models/states_model.dart';
import 'package:simon_final/providers/page_controller_provider.dart';
import 'package:simon_final/screens/directions/add_direction_screen.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/address_services.dart';
import 'package:simon_final/utils/colors.dart';
import 'package:simon_final/utils/common.dart';
import 'package:simon_final/utils/images.dart';
import 'package:simon_final/utils/messages_toast.dart';
import "package:simon_final/screens/modals/address_picker.dart";
class ResidencyRegistration extends StatefulWidget {
  final bool? isOne;
  const ResidencyRegistration({super.key, this.isOne = false});

  @override
  State<ResidencyRegistration> createState() => _ResidencyRegistrationState();
}

class _ResidencyRegistrationState extends State<ResidencyRegistration> {
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
  final FocusNode _aliasFocusNode = FocusNode();
  final FocusNode _addressFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _identificationFocusNode = FocusNode();
  final FocusNode _countryFocusNode = FocusNode();
  final FocusNode _stateFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _postcodeFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _phoneMobileFocusNode = FocusNode();
  final formKey = GlobalKey<FormState>();
  final _addressServices = AddressServices();
  final _countries = <CountryModel>[];
  final _states = <StateModel>[];
  final _cities = <CitieModel>[];
  int _countryId = 0;
  int _stateId = 0;
  int _cityId = 0;
  bool _isCreating = false;

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
    controllerCountry.dispose();
    controllerState.dispose();
    controllerCity.dispose();
    controllerIdentification.dispose();
    controllerName.dispose();
    _aliasFocusNode.dispose();
    _addressFocusNode.dispose();
    _nameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _identificationFocusNode.dispose();
    _countryFocusNode.dispose();
    _stateFocusNode.dispose();
    _cityFocusNode.dispose();
    _postcodeFocusNode.dispose();
    _phoneFocusNode.dispose();
    _phoneMobileFocusNode.dispose();
    //controllerTypeAdress.dispose();
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

  void _showStatePicker(){
    AddressPicker.showStatePicker(context: context, states: _states, countryId: _countryId, onStateSelected: (stateName,stateId){
      setState(() {
        controllerState.text = stateName;
        _stateId = stateId;
      });
    }, cities: _cities, onCitySelected: (cityName, cityId) {
      setState(() {
        controllerCity.text = cityName;
        _cityId = cityId;
      });
    });
  }

  void _showCityPicker(){
    AddressPicker.showCityPicker(context: context, cities: _cities,  stateId: _stateId, onCitySelected: (cityName, cityId) {
      setState(() {
        controllerCity.text = cityName;
        _cityId = cityId;
      });
    });
  }
  void createAddress(AddressModel address) async {
    final pageControllerProvider = Provider.of<PageControllerProvider>(context, listen: false);
    setState(() {
      _isCreating = true;
    });
    try {
      await _addressServices.createAddress(address).then((_) {
        MessagesToast.showMessageSuccess("Dirección creada");
        if (widget.isOne == true) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else if (pageControllerProvider.isLastPage()) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
        } else {
          Provider.of<PageControllerProvider>(context, listen: false)
              .nextPage();
        }
      });
    } catch (e) {
      
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final pageController =
        Provider.of<PageControllerProvider>(context, listen: false);
    return !_isCreating
        ? SingleChildScrollView(
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
                Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        const RithTextCampoRequired(title: "Dirección"),
                        5.height,
                        TextFormFieldSimon(
                          focusNode: _addressFocusNode,
                          suffixIcon: const Icon(Icons.location_on),
                          //moreAjusted: true,
                          controller: controllerAddress,
                          hintText: 'Ej Avenida de la República, 1234',
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            _showCountryPicker();
                          },
                        ),
                        const RithTextCampoRequired(title: "País"),
                        5.height,
                        TextFormFieldSimon(
                          onTapSimon: (){
                            _showCountryPicker();
                          },
                          //moreAjusted: true,
                          controller: controllerCountry,
                          hintText: 'País',
                          focusNode: _countryFocusNode,
                          isReadOnly: true,
                          suffixIcon:  const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                            ),
                          
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_stateFocusNode);
                          },
                        ),
                        const RithTextCampoRequired(title: "Estado"),
                        5.height,
                        TextFormFieldSimon(
                          //moreAjusted: true,
                          controller: controllerState,
                          onTapSimon: (){
                            if(_countryId != 0){
                               _showStatePicker();
                            }
                          },
                          isReadOnly: true,
                          focusNode: _stateFocusNode,
                          hintText: 'Provincia',
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_cityFocusNode);
                          },
                        ),
                        const RithTextCampoRequired(title: "Ciudad"),
                        5.height,
                        TextFormFieldSimon(
                          // moreAjusted: true,
                          controller: controllerCity,
                          onTapSimon: (){
                            if(_stateId != 0){
                              _showCityPicker();
                            }
                          },
                          isReadOnly: true,
                          focusNode: _cityFocusNode,
                          hintText: 'Ciudad',
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_postcodeFocusNode);
                          },
                        ),
                        const RithTextCampoRequired(title: "Nombre"),
                        5.height,
                        TextFormFieldSimon(
                          //moreAjusted: true,
                          controller: controllerName,
                          hintText: 'Ingrese su nombre',
                          focusNode: _nameFocusNode,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_lastNameFocusNode);
                          },
                        ),
                        const RithTextCampoRequired(title: "Apellido"),
                        5.height,
                        TextFormFieldSimon(
                          //moreAjusted: true,
                          controller: controllerLastName,
                          focusNode: _lastNameFocusNode,
                          hintText: 'Ingrese su apellido',
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_identificationFocusNode);
                          },
                        ),
                        const RithTextCampoRequired(title: "Identificación"),
                        5.height,
                        TextFormFieldSimon(
                          //moreAjusted: true,
                          controller: controllerIdentification,
                          hintText: 'Ingrese su Identificación',
                          textCapitalization: TextCapitalization.words,
                          focusNode: _identificationFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_countryFocusNode);
                          },
                        ),
                        
                        const RithTextCampoRequired(title: "Teléfono Móvil"),
                        5.height,
                        TextFormFieldSimon(
                          // moreAjusted: true,
                          controller: controllerPhoneMobile,
                          hintText: 'Ingrese su celular Ej 04 xxxxxxx',
                          focusNode: _phoneMobileFocusNode,
                          textCapitalization: TextCapitalization.words,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_phoneFocusNode);
                          },
                        ),
                        
                      ],
                    )),
                AppButton(
                  width: double.infinity,
                  elevation: 2,
                  onTap: () async {
                    // falta validar
                    if (formKey.currentState!.validate()) {
                      AddressModel address = AddressModel(
                        type: TypeAdressModel.ADDRESS.name,
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
                ).paddingSymmetric(vertical: 4),
              ],
            ),
          ).paddingSymmetric(horizontal: 16, vertical: 2)
        : const LoaderAppIcon();
  }
}
