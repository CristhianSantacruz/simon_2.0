import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simon_final/models/cities_model.dart';
import 'package:simon_final/models/country_model.dart';
import 'package:simon_final/models/states_model.dart';
import 'package:simon_final/utils/colors.dart';

class AddressPicker {
  // Método para mostrar el selector de países
  static void showCountryPicker({
    required BuildContext context,
    required List<CountryModel> countries,
    required Function(String countryName, int countryId) onCountrySelected,
    required List<StateModel> states,
    required Function(String stateName, int stateId) onStateSelected,
    required List<CitieModel> cities,
    required Function(String cityName, int cityId) onCitySelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Selecciona un país"),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: countries.length,
                itemBuilder: (context, index) {
                  final country = countries[index];
                  return ListTile(
                    leading: Icon(FontAwesomeIcons.globe, color: simon_finalPrimaryColor),
                    title: Text("${country.name}"),
                    onTap: () {
                      onCountrySelected(country.name, country.id);
                      Navigator.pop(context);
                      showStatePicker(
                        context: context,
                        states: states,
                        countryId: country.id,
                        onStateSelected: onStateSelected,
                        cities: cities,
                        onCitySelected: onCitySelected,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar el selector de estados
  static void showStatePicker({
    required BuildContext context,
    required List<StateModel> states,
    required int countryId,
    required Function(String stateName, int stateId) onStateSelected,
    required List<CitieModel> cities,
    required Function(String cityName, int cityId) onCitySelected,
  }) {
    final statesForCountry = states.where((state) => state.countryId == countryId).toList();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Selecciona un estado"),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: statesForCountry.length,
                itemBuilder: (context, index) {
                  final state = statesForCountry[index];
                  return ListTile(
                    leading: Icon(Icons.location_on, color: simon_finalPrimaryColor),
                    title: Text(state.name),
                    onTap: () {
                      onStateSelected(state.name, state.id);
                      Navigator.pop(context);
                      showCityPicker(
                        context: context,
                        cities: cities,
                        stateId: state.id,
                        onCitySelected: onCitySelected,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar el selector de ciudades
  static void showCityPicker({
    required BuildContext context,
    required List<CitieModel> cities,
    required int stateId,
    required Function(String cityName, int cityId) onCitySelected,
  }) {
    final citiesForState = cities.where((city) => city.stateId == stateId).toList();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Selecciona una ciudad"),
              trailing: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: citiesForState.length,
                itemBuilder: (context, index) {
                  final city = citiesForState[index];
                  return ListTile(
                    leading: Icon(Icons.location_city, color: simon_finalPrimaryColor),
                    title: Text(city.name),
                    onTap: () {
                      onCitySelected(city.name, city.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}