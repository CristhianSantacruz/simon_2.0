import 'package:simon_final/models/faq_question_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class FaqQuestionServices {

  final String baseUrl = ApiRoutes.baseUrl;
  final String getBannerEndpoint = ApiRoutes.faquestion;
  final dio = DioClient().dio;
  Future<List<FaQuestionModel>> getFaqQuestions() async {
    try {
      final response = await dio.get("$baseUrl$getBannerEndpoint");
      if (response.statusCode == 200 || response.data["status"] == true) {
        Map<String, dynamic> body = response.data;
        List<dynamic> faqQuestions = body['data']['faq_questions'];
        return faqQuestions.map((item) => FaQuestionModel.fromJson(item)).toList();
      } else {
        return response.data["message"];
      }
    } catch (e) {
      throw Exception('Failed to load faq questions');
    }
       
  }
}