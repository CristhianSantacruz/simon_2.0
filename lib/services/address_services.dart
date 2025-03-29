import 'package:dio/dio.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/addres_model.dart';
import 'package:simon_final/models/cities_model.dart';
import 'package:simon_final/models/country_model.dart';
import 'package:simon_final/models/states_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class AddressServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String address = ApiRoutes.address;
  final String countryEndpoint = ApiRoutes.country;
  final String stateEndpoint = ApiRoutes.states;
  final String cityEndpoint = ApiRoutes.cities;

 

  final _dio = DioClient().dio;

  Future<List<AddressModel>> getAddressByUser(int userId, int profileId) async {
  try {
    final response = await _dio.get('$baseUrl$address', queryParameters: {
      'user_id': userId,
      'profile_id': profileId
    });

    if (response.statusCode == 200 && response.data['status'] == true) {
      Map<String, dynamic> body = response.data;
      List<dynamic> addresses = body['data']['addresses'];
      return addresses.map((item) => AddressModel.fromJson(item)).toList();
    } 

    // Si la API responde con un error controlado, retornamos lista vacía
    if (response.statusCode == 400 || response.statusCode == 404) {
      debugPrint("No se encontraron direcciones: ${response.data['message']}");
      return []; // Retornamos lista vacía en lugar de un String
    }

  } on DioException catch (e) {
    // Si la API devuelve un error 404, devolver una lista vacía en lugar de un String
    if (e.response?.statusCode == 404) {
      debugPrint("Dirección no encontrada: ${e.response?.data['message']}");
      return []; 
    }
    
    debugPrint("Error en la solicitud: ${e.message}");
    throw Exception('Error obteniendo direcciones: ${e.message}');
  }

  throw Exception('Error inesperado obteniendo direcciones');
}

  Future<List<CountryModel>> getCountries() async {
    try {
      final response = await _dio.get('$baseUrl$countryEndpoint');
      if(response.statusCode == 200 && response.data['status'] == "success"){
        Map<String, dynamic> body = response.data;
        List<dynamic> countries = body['data']['countries'];
        return countries.map((item) => CountryModel.fromJson(item)).toList();
      }
    } on DioException catch (e) {
       if(e.response?.statusCode == 404) {
         return e.response?.data['message'];
       }
       throw Exception('No have message: ${e.message}');
    }
    throw Exception('Failed to load countries: ');
  }
  
  Future<List<StateModel>> getStates() async {
    try {
      final response = await _dio.get('$baseUrl$stateEndpoint');
      if(response.statusCode == 200 && response.data['status'] == "success"){
        Map<String, dynamic> body = response.data;
        List<dynamic> states = body['data']['provinces'];
        return states.map((item) => StateModel.fromJson(item)).toList();
      }
    } on DioException catch (e) {
       if(e.response?.statusCode == 404) {
         return e.response?.data['message'];
       }
       throw Exception('No have message: ${e.message}');
    }
    throw Exception('Failed to load states');
  }

  Future<List<CitieModel>> getCities() async {
    try {
      final response = await _dio.get('$baseUrl$cityEndpoint');
      if(response.statusCode == 200 && response.data['status'] == "success"){
        Map<String, dynamic> body = response.data;
        List<dynamic> cities = body['data']['cities'];
        return cities.map((item) => CitieModel.fromJson(item)).toList();
      }
    } on DioException catch (e) {
       if(e.response?.statusCode == 404) {
         return e.response?.data['message'];
       }
       throw Exception('No have message: ${e.message}');
    }
    throw Exception('Failed to load cities');
  }

  Future<void> createAddress(AddressModel addressModel) async {
    try {
      final response = await _dio.post('$baseUrl$address', data: addressModel.toJson());
      if(response.statusCode == 201 && response.data['status'] == true){
        debugPrint("Respuesta de crear dirección: ${response.data}");
      } else {
        throw Exception('Failed to create address. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to create address: ${e.error}');
    }
  }

  Future<void> updateAddress(AddressModel addressModel) async {
    debugPrint("Metodo updateAddress");
    debugPrint("address: ${addressModel.toJson()}");
    try {
      final response = await _dio.put('$baseUrl$address/${addressModel.id}', data: addressModel.toJson());
      if(response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        return body['message'];
      } else {
        throw Exception('Failed to update address. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to update address: ${e.message}');
    }
  }

  Future<String> deleteAdressById(int addressId) async {
    final user = await appStore.getUser();
    try {
      final response = await _dio.delete('$baseUrl$address/$addressId?user_id=${user.id}');
      if(response.statusCode == 200 && response.data['status']==true) {
        return response.data['message'];
      }
    } on DioException catch (e) {
      if(e.response?.statusCode == 404) {
        return e.response?.data['message'];
      }
    }
    return "Dirección no encontrada";
  }
}