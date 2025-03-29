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
import 'package:ionicons/ionicons.dart';

class UpdateDirectionScreen extends StatefulWidget {
  final AddressModel addressModel;
  const UpdateDirectionScreen({super.key, required this.addressModel});

  @override
  State<UpdateDirectionScreen> createState() => _UpdateDirectionScreenState();
}

class _UpdateDirectionScreenState extends State<UpdateDirectionScreen> {
  final TextEditingController controllerAlias = TextEditingController();
  final TextEditingController controllerAddress = TextEditingController();
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerLastName = TextEditingController();
  final TextEditingController controllerIdentification =
      TextEditingController();
  final TextEditingController controllerPostcode = TextEditingController();
  final TextEditingController controllerPhone = TextEditingController();
  final TextEditingController controllerPhoneMobile = TextEditingController();
  final TextEditingController controllerCountry = TextEditingController();
  final TextEditingController controllerState = TextEditingController();
  final TextEditingController controllerCity = TextEditingController();
  final TextEditingController controllerDistrictId = TextEditingController();
  TypeAdressModel? _selectedTypeAdress;
  final _formKey = GlobalKey<FormState>();
  final _addressServices = AddressServices();
  final _countries = <CountryModel>[];
  final _states = <StateModel>[];
  final _cities = <CitieModel>[];
  int _countryId = 0;
  int _stateId = 0;
  int _cityId = 0;
  

  String _getTypeAdressText(TypeAdressModel type) {
    switch (type) {
      case TypeAdressModel.INVOICE:
        return 'Dirección para facturación';
      case TypeAdressModel.ADDRESS:
        return 'Dirección para domicilio';
    }
  }

  @override
  void initState() {
    // final user = Provider.of<UserProvider>(context, listen: false).user;
    controllerName.text = widget.addressModel.firstname;
    controllerLastName.text = widget.addressModel.lastname;
    controllerIdentification.text = widget.addressModel.identification;
    controllerPhoneMobile.text = widget.addressModel.phoneMobile ?? "";
    controllerPhone.text = widget.addressModel.phone ?? "";
    controllerPostcode.text = widget.addressModel.postcode ?? "";
    controllerCountry.text = widget.addressModel.countryId.toString();
    controllerState.text = widget.addressModel.stateId.toString();
    controllerCity.text = widget.addressModel.cityId.toString();
    controllerAlias.text = widget.addressModel.alias ?? "";
    controllerDistrictId.text = widget.addressModel.districtId.toString();
    _countryId = widget.addressModel.countryId;
    _stateId = widget.addressModel.stateId;
    _cityId = widget.addressModel.cityId;
    controllerAddress.text = widget.addressModel.address;
    super.initState();
    _fetchCountries();
    _fetchStates();
    _fetchCities();
    _getTypeAdressText(TypeAdressModel.values.firstWhere((element) => element.name == widget.addressModel.type));
    _selectedTypeAdress = TypeAdressModel.values.firstWhere((element) => element.name == widget.addressModel.type);
  }

  Future<void> _fetchCountries() async {
    final countries = await _addressServices.getCountries();
    setState(() {
      _countries.clear();
      _countries.addAll(countries);

      final country =
          _countries.firstWhere((element) => element.id == _countryId);
      controllerCountry.text = country.name;
    });
  }

  Future<void> _fetchStates() async {
    final states = await _addressServices.getStates();
    setState(() {
      _states.clear();
      _states.addAll(states);
      final state = _states.firstWhere((element) => element.id == _stateId);
      controllerState.text = state.name;
    });
  }

  Future<void> _fetchCities() async {
    final cities = await _addressServices.getCities();
    setState(() {
      _cities.clear();
      _cities.addAll(cities);
      final city = _cities.firstWhere((element) => element.id == _cityId);
      controllerCity.text = city.name;
    });
  }

  void _updateAddress(AddressModel addressModel) async {
   
    try {
      await _addressServices.updateAddress(addressModel);
      toast("Dirección actualizada",bgColor: simon_finalPrimaryColor,textColor: Colors.white,gravity: ToastGravity.CENTER);
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, Routes.directions);
    } catch (e) {
      toast("Error al actualizar dirección");
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
        surfaceTintColor: appStore.isDarkMode ? scaffoldDarkColor : white_color,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: appStore.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Editar Dirección',
          style: primarytextStyle(
              weight: FontWeight.w500,
              size: 20,
              color: appStore.isDarkMode
                  ? scaffoldLightColor
                  : Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
        child: Column(
          children: [
            Icon(
              Ionicons.location,
              color: simon_finalPrimaryColor,
              size: 60,
              shadows: [
                Shadow(
                  color: Colors.blue[300]!, // Color de la sombra
                  offset: const Offset(0, 3), // Sombra solo hacia abajo (eje Y)
                  blurRadius: 3, // Difuminado de la sombra
                ),
              ],
            ).center(),
            _formUpdateDirection(),
            AppButton(
              width: double.infinity,
              elevation: 2,
              onTap: () async {
                if(_formKey.currentState!.validate()){
                  AddressModel address = AddressModel(
                    id: widget.addressModel.id,
                    type: _selectedTypeAdress!.name,
                    alias: controllerAlias.text,
                    lastname: controllerLastName.text,
                    firstname: controllerName.text,
                    address: controllerAddress.text,
                    postcode: controllerPostcode.text,
                    phone: controllerPhone.text,
                    phoneMobile: controllerPhoneMobile.text,
                    identification: controllerIdentification.text,
                    userId:userProvider.user.id,
                    countryId: _countryId,
                    stateId: _stateId,
                    cityId: _cityId,
                    profileId: userProvider.currentProfile,
                    districtId: widget.addressModel.districtId,

                  );
                  
                  _updateAddress(address);  
                
              }},
              color: simon_finalPrimaryColor,
              shapeBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DEFAULT_RADIUS)),
              child: const Text('Actualizar Dirección',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ).paddingSymmetric(vertical: 16),
          ],
        ),
      ),
    );
  }

  Form _formUpdateDirection() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dirección para:', style: boldTextStyle()),
            5.height,
            DropdownButtonFormField<TypeAdressModel>(
              value: _selectedTypeAdress,
              decoration: InputDecoration(
                hintText: widget.addressModel.type == TypeAdressModel.ADDRESS ? 'Dirección para domicilio' : 'Dirección para facturación',
                // contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: simon_finalSecondaryColor,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: borderColor, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.red[300]!, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(color: simon_finalPrimaryColor, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide:
                      const BorderSide(color: simon_finalPrimaryColor, width: 2),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                ),
              ),
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
            ),
            
            Text('Dirección', style: boldTextStyle()),
            5.height,
            TextFormFieldSimon(
              suffixIcon: const Icon(Icons.location_on),
              //moreAjusted: true,
              controller: controllerAddress,
              hintText: 'Ej Avenida de la República, 1234',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text(
              'Nombre',
              style: boldTextStyle(),
            ),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerName,
              hintText: 'Ingrese su nombre',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text('Apellido',style: boldTextStyle(),),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerLastName,
              hintText: 'Ingrese su apellido',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text('Identificación',style: boldTextStyle(),),
            5.height,
            TextFormFieldSimon(
              //moreAjusted: true,
              controller: controllerIdentification,
              hintText: 'Ingrese su Identificación',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text('País', style: boldTextStyle()),
            5.height,
            TextFormFieldSimon(
              onTapSimon: (){
                _showCountryPicker();
              },
              //moreAjusted: true,
              controller: controllerCountry,
              hintText: 'País',
              isReadOnly: true,
              suffixIcon: 
                 const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black,
              
              ),
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text('Estado', style: boldTextStyle()),
            5.height,
            TextFormFieldSimon(
              onTapSimon: (){
                _showStatePicker();
              },
              //moreAjusted: true,
              isReadOnly: true,
              controller: controllerState,
              hintText: 'Provincia',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            Text('Ciudad', style: boldTextStyle()),
            5.height,
            TextFormFieldSimon(
               onTapSimon: (){
                _showCityPicker();
              },
              // moreAjusted: true,
              controller: controllerCity,
              isReadOnly: true,
              hintText: 'Ciudad',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
              },
            ),
            
            Text('Teléfono Móvil', style: boldTextStyle()),
            5.height,
            TextFormFieldSimon(
              // moreAjusted: true,
              controller: controllerPhoneMobile,
              hintText: 'Ingrese su celular',
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) {
                //FocusScope.of(context).requestFocus(_addressFocus);
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
