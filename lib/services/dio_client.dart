import 'package:dio/dio.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio();
    dio.options.validateStatus = (status) {
      return status != null && status < 500; // Solo lanza excepciones para errores 5xx
    };
  }
}
