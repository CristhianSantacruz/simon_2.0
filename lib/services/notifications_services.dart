
import 'package:dio/dio.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/notification_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class NotificationsServices {

  final String baseUrl = ApiRoutes.baseUrl;
  final String notificationsUser = ApiRoutes.userNotifications;

    final dio = DioClient().dio;

  Future<List<NotificationModel>> notificationsByUser() async {
  final userModel = await appStore.getUser();
  try {
    final response = await dio.get("$baseUrl$notificationsUser?user_id=${userModel.id}");
    if (response.statusCode == 200 && response.data["status"] == true) {
      List<dynamic> data = response.data["data"]["notifications"];

      List<NotificationModel> notifications = data.map((json) => NotificationModel.fromJson(json)).toList();

      return notifications;
    } else {
      throw Exception(response.data["message"]);
    }
  } on DioException catch (e) {
    throw Exception('Failed to load notifications by user: ${e.message}');
  }
}
}
