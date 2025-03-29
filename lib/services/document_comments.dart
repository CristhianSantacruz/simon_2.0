import 'package:dio/dio.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/comment_model.dart';
import 'package:simon_final/models/comment_model_dto_request.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';

class DocumentCommentServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String getCommentsByDocument = ApiRoutes.documentComments;

  final dio = DioClient().dio;

  Future<List<CommentModel>> getCommentsByDocumentId(int documentId) async {
    try {
      final response = await dio.get('$baseUrl$getCommentsByDocument?document_id=$documentId');

      if (response.statusCode == 200 || response.data['status'] == true) {
        Map<String, dynamic> body = response.data;
        List<dynamic> comments = body['data']['comments'];
     

        comments.map((item) => CommentModel.fromJson(item)).toList();
        return comments.map((item) => CommentModel.fromJson(item)).toList();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Si el código de estado es 404, devolvemos una lista vacía
        return [];
      }
      throw Exception('Failed to load comments: ${e.message}');
    }
    return [];
  }

  Future<String> deleteCommentById(int commentId) async {
    UserModel user = await appStore.getUser();
    try {
      final response = await dio.delete(
          '$baseUrl$getCommentsByDocument/$commentId?user_id=${user.id}');
      if (response.statusCode == 200) {
        return response.data['message'];
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return e.response?.data['message'];
      }
    }
    throw Exception('Failed to delete comment');
  }

  Future<CommentModel> createComment(CommentModelDtoRequest commentPost) async {
    try {
      // Crear un mapa para el cuerpo de la solicitud
      Map<String, dynamic> requestBody = {
        "user_id": commentPost.user_id,
        "document_id": commentPost.document_id,
        "comment": commentPost.comment,
        "profile_id": commentPost.profile_id
      };

      // Agregar parent_id solo si no es null
      if (commentPost.parent_id != null) {
        requestBody["parent_id"] = commentPost.parent_id;
      }

      // Realizar la solicitud POST
      final response = await dio.post(
        '$baseUrl$getCommentsByDocument',
        data: requestBody,
      );

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extraer el objeto "docComment" de la respuesta
        final Map<String, dynamic> docComment =
            response.data["data"]["docComment"];

        // Mapear el JSON a un objeto CommentModel
        return CommentModel.fromJson(docComment);
      } else {
        throw Exception("Error al crear el comentario: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception("Error 404: ${e.response?.data['message']}");
      } else {
        throw Exception("Error en la solicitud: ${e.message}");
      }
    }
  }

  Future<void> updateComment(
      int commentId, String newMessage, int profileId) async {
    final user = await appStore.getUser();
    try {
      final response = await dio
          .put('$baseUrl$getCommentsByDocument/$commentId', data: {
        'comment': newMessage,
        'user_id': user.id,
        "profile_id": profileId
      });
      if (response.statusCode == 200) {
        return response.data['message'];
      }
    } on DioException catch (e) {
      throw Exception('Failed to update comment: ${e.message}');
    }
  }
}
