import 'package:dio/dio.dart';
import 'package:simon_final/models/banner_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class BannerServices {

  final String baseUrl = ApiRoutes.baseUrl;
  final String getBannerEndpoint = ApiRoutes.getBanners;

  final dio = DioClient().dio;
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await dio.get('$baseUrl$getBannerEndpoint');
      if (response.statusCode == 200|| response.data['status'] == 'true') {
        Map<String, dynamic> body = response.data;
        List<dynamic> banners = body['data']['banners'];
        return banners.map((item) => BannerModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load banners. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load banners: ${e.message}');
    }
  }

}
