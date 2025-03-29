import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simon_final/models/user_model_register.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class RegisterService {
  static const String baseUrl = ApiRoutes.baseUrl;
  static const String REGISTER = ApiRoutes.register;  
    final dio = DioClient().dio;

  Future<Map<String, dynamic>> register(UserModelRegiser userRegister) async {
    try {
      final response = await dio.post('$baseUrl$REGISTER', data: userRegister.toJson());
      if (response.statusCode == 200) {
        debugPrint("Se ha registrado correctamente");
        return {'success': true, 'message': response.data['message']};
      } else {
        debugPrint("No se ha registrado correctamente");
        return {'success': false, 'error': response.data['error'] ?? 'No se encontró la URL'};
      }
    } on DioException catch (e) {
      if (e.response != null) {
        // El servidor respondió con un código de estado no 200
        debugPrint("Error en el servidor: ${e.response!.data['error']}");
        return {'success': false, 'error': e.response!.data['error'] ?? 'Error desconocido'};
      } else {
        // Error al enviar la solicitud
        debugPrint("Error al enviar la solicitud: ${e.message}");
        return {'success': false, 'error': e.message};
      }
    } catch (e) {
      // Otros errores
      debugPrint("Error desconocido: $e");
      return {'success': false, 'error': 'Hay un error en el servidor'};
    }
  }

Future<bool> updateUser(UserModelRegiser userRegister, int userId, {String? password}) async {
  try {
    Map<String, dynamic> userJson = userRegister.toJsonUpdate();
    
    // Si la contraseña no es nula ni vacía, agregarla al JSON
    if (password != null && password.isNotEmpty) {
      userJson['password'] = password;
    }

    debugPrint("Datos del usuario: $userJson");

    final response = await dio.put('$baseUrl$REGISTER/$userId', data: userJson);

    if (response.statusCode == 200 && response.data['status'] == true) {
      debugPrint("Se ha actualizado correctamente");
      return true;
    } else {
      debugPrint("No se ha actualizado correctamente");
      return false;
    }
  } on DioException catch (e) {
    if (e.response != null) {
      debugPrint("Error en el servidor: ${e.response!.data['error']}");
    } else {
      debugPrint("Error al enviar la solicitud: ${e.message}");
    }
    return false;
  }
}
}