import 'package:dio/dio.dart';
import 'package:simon_final/models/pop_up_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class PopUpService {

  final String baseUrl = ApiRoutes.baseUrl;
  final String getBannerEndpoint = ApiRoutes.popUp;


    final dio = DioClient().dio;

  Future<PopUpModel> getPopUp(int  idPopUp) async {
    try {
      final response = await dio.get('$baseUrl$getBannerEndpoint/$idPopUp');
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        return PopUpModel.fromJson(body['data']['popUp']);
      } else {
        throw Exception(
            'Failed to load popUp. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load popUp: ${e.message}');
    }
    
}
Future<PopUpModel> getPopUpRandom() async {
  debugPrint("Cargando popUp aleatorio");
    try {
      final response = await dio.get('$baseUrl/pop-ups-random');
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        return PopUpModel.fromJson(body['data']['popUp']);
      } else {
        throw Exception(
            'Failed to load popUp. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load popUp: ${e.message}');
    }
    
}
}