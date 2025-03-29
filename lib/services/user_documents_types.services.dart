import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simon_final/models/user_document_type_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';
import 'package:simon_final/utils/messages_toast.dart';
import 'package:nb_utils/nb_utils.dart';

class UserDocumentsTypesServices {
  final String baseUrl = ApiRoutes.baseUrl;
  final String getUserDocumentsTypesEndpoint = ApiRoutes.getUserDocumentsTypes;
  final String uploadDocumentEndpoint = ApiRoutes.uploadDocument;
    final dio = DioClient().dio;
  

  Future<List<UserDocumentTypeModel>> getUserDocumentsTypes(int userId,int profileId) async {

    try {
      final response = await dio.get('$baseUrl$getUserDocumentsTypesEndpoint',queryParameters: {
        'user_id': userId,
        'profile_id': profileId
      });
      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;;
        List<dynamic> documents = body['data']['userDocumentTypes'];
        return documents.map((item) => UserDocumentTypeModel.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load documents. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Manejo de errores específicos de Dio
      throw Exception('Failed to load documents: ${e.message}');
    }
  }


 Future<void> uploadDocument(String nameDocument, String documentFilePath, int idDocument,int userId,String? secondDocumentFilePath,int profileId,{String? expirationDate}) async {
  try {
    if (documentFilePath.isEmpty) {
      toast("No se ha seleccionado ningún archivo.");
      return;
    }
    Map<String, dynamic> formDataMap = {
      'name': nameDocument,
      'user_id': userId,
      'profile_id': profileId, 
      'user_document_types_id': idDocument,
      'file': await MultipartFile.fromFile(documentFilePath, filename: nameDocument),
    };

    if (expirationDate != null && expirationDate.isNotEmpty) {
      formDataMap['expiration_date'] = expirationDate;
    }

    if (secondDocumentFilePath != null && secondDocumentFilePath.isNotEmpty) {
      formDataMap['file2'] = await MultipartFile.fromFile(secondDocumentFilePath, filename: nameDocument);
    }

    FormData formData = FormData.fromMap(formDataMap);
    Response response = await dio.post(
      '$baseUrl$uploadDocumentEndpoint',
      data: formData,
    );

    debugPrint("response.data: ${response.data}");
    debugPrint("El user id es ${userId}");

    if (response.statusCode == 200) {
      final message = response.data['message'];
      MessagesToast.showMessageSuccess(message);
    } else {
      throw Exception('Failed to load documents. Status code: ${response.statusCode}');
    }
  } catch (e) {
    toast("Error al enviar la solicitud: $e");
  }
}

Future<bool> deleteDocumentUpload(int userDocumentId) async {
  try {
    Response response = await dio.delete(
      '$baseUrl$uploadDocumentEndpoint/$userDocumentId',
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete document. Status code: ${response.statusCode}');
    }
  } on DioException catch (e) {
    throw Exception('Fallo al intentar elimianr el documento: ${e.message}');
  }

}


}