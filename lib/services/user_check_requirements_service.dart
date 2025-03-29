import 'package:dio/dio.dart';
import 'package:simon_final/models/user_check_requirementes.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';


class UserCheckRequirementsService {
   String baseUrl = ApiRoutes.baseUrl;
   String userCheckRequirementes = ApiRoutes.userCheckRequirementes;
   
     final dio = DioClient().dio;

   Future<UserCheckRequirmentesModel> getUserCheckRequirements(int userId,int profileId) async {
      try {
        final response = await dio.get("${baseUrl}$userCheckRequirementes",queryParameters: {
          "user_id": userId,
          "profile_id": profileId
        });
        if (response.statusCode == 200) {
          Map<String, dynamic> body = response.data;
        
          return UserCheckRequirmentesModel.fromJson(body['data']);
        } else {
          throw Exception('Failed to load user check requirements. Status code: ${response.statusCode}');
        }
      } on DioException catch (e) {
        // Manejo de errores específicos de Dio
        throw Exception('Exception check requirements: ${e.message}');
      }
   }
}