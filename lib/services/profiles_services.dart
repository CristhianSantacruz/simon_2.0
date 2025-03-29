import 'package:dio/dio.dart';
import 'package:simon_final/models/profile_modal.dart';
import 'package:simon_final/models/profile_model_register.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';
import 'package:simon_final/utils/messages_toast.dart';

class ProfilesServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String profileEndpoint = ApiRoutes.profiles;

  final dio = DioClient().dio;

  Future<List<ProfileModel>> getProfiles(int userId) async {
    try {
      final response = await dio.get('$baseUrl$profileEndpoint?user_id=$userId');
      if (response.statusCode == 200 && response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        List<dynamic> profiles = body['data']['profiles'];
        return profiles.map((item) => ProfileModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load profiles. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load profiles: ${e.message}');
    }
  } 

  Future<void> createProfile(ProfileModelRegister profileModel) async {
    debugPrint("Datos del registro : ${profileModel.toJson()}");
    try {
      final response = await dio.post("$baseUrl$profileEndpoint", data: profileModel.toJson() );
      if (response.statusCode == 201 || response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        return body['message'];
      } else {
        throw Exception('Failed to create profile. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to create profile: ${e.message}');
    }
  }

  Future<ProfileModel> getProfile(int profileId) async {
    try {
      final response = await dio.get("$baseUrl$profileEndpoint/$profileId");
      if (response.statusCode == 200 || response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        return ProfileModel.fromJson(body['data']['profile']);
      } else {
        throw Exception('Failed to load profile. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load profile: ${e.message}');
    }
  }

  Future<void> deleteProfile(int profileId) async {
    try {
      final response = await dio.delete("$baseUrl$profileEndpoint/$profileId");
      if (response.statusCode == 200 && response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        MessagesToast.showMessageSuccess("${body['message']}");     
      } else {
        throw Exception('Failed to delete profile. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete profile: ${e.message}');
    }
  }

  Future<bool> updateProfile(ProfileModelRegister profileModel , int profileId) async {
    debugPrint("Actualizar perfil");
    debugPrint("Datos del perfil: ${profileModel.toJson()}");
    try {
      final response = await dio.put("$baseUrl$profileEndpoint/$profileId", data: profileModel.toJson());
      if (response.statusCode == 200 && response.data['status'] == true) {
        
        return true;
      } else {
        debugPrint("No se ha actualizado correctamente");
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint("Error en el servidor: ${e.response!.data['error']}");
        return false;
      } else {
        debugPrint("Error al enviar la solicitud: ${e.message}");
        return false;
      }
    }
  }

  

  

  
}