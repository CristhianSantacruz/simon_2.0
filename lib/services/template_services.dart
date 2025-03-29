import 'package:dio/dio.dart';
import 'package:simon_final/models/template_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class TemplateServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String templateEndpoint = ApiRoutes.templateEndpoint;

    final dio = DioClient().dio;

  Future<List<TemplateModel>> getTemplates() async {
    try {
      final response = await dio.get('$baseUrl$templateEndpoint');
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        List<dynamic> templates = body['data']['template'];
        return templates.map((item) => TemplateModel.fromJson(item)).toList();
      } else {
        throw Exception("Hubo un error" + response.data['message']);
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load templates: ${e.message}');
    }
  }

  Future<TemplateModel> getTemplateById(int id,int userId,int profileId) async {
    try {
      final response = await dio.get('$baseUrl$templateEndpoint/$id',queryParameters: {
        "user_id": userId,
        "profile_id": profileId
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        return TemplateModel.fromJson(body['data']['template']);
      } else {
        throw Exception(response.data['message']);
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load template: ${e.message}');
    }
  }
  
}