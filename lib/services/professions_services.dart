import 'package:dio/dio.dart';
import 'package:simon_final/models/profession_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class ProfessionServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String professionServices = ApiRoutes.profesions;

  final _dio = DioClient().dio;

  Future<List<ProfessionModel>> getProfessions() async {
    try {
      final response = await _dio.get('$baseUrl$professionServices');
      if (response.statusCode == 200 && response.data['status'] == true) {
        final List<dynamic> professions = response.data['data']['professions'];
            return professions.map((profession) => ProfessionModel.fromJson(profession))
            .toList();
        
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load professions: ${e.message}');
    }
    throw Exception('Failed to load professions');
  }
}
