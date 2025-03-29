import 'package:dio/dio.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class DeviceTokenService {
  static const String baseUrl = ApiRoutes.baseUrl;
  static const String deviceTokenEndpoint = ApiRoutes.deviceToken;

  final dio = DioClient().dio;

  Future<void> registerDeviceToken(int userId, String deviceToken) async {
    try {
      final response = await dio.post(
        '$baseUrl$deviceTokenEndpoint',
        data: {
          "user_id": userId,
          "device_token": deviceToken,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == true) {
        print('Device token registrado correctamente');
      } else {
        print('Error al registrar el token: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error al enviar el token: ${e.message}');
      throw Exception('Failed to register device token');
    }
  }
}
