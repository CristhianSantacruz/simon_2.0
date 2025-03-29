import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:simon_final/firebase_and_notifications.dart';
import 'package:simon_final/main.dart';
import 'package:simon_final/models/user_generated_document.dart';
import 'package:simon_final/models/user_model.dart';
import 'package:simon_final/services/dio_client.dart';
import 'package:simon_final/utils/api_routes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class UserGeneratedDocumentService {
  static const String baseUrl = ApiRoutes.baseUrl;
  static const String userGenteratedDocuments =
      ApiRoutes.userGenteratedDocuments;

  final dio = DioClient().dio;

  //Metodo par juntas imagenes en un pdf
  Future<File> _convertImagesToPdf(
      List<String> imagePaths, String fileName) async {
    final pdf = pw.Document();
    const pdfPageFormat = PdfPageFormat.a4;

    for (final imagePath in imagePaths) {
      try {
        final imageFile = File(imagePath);
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(
          pw.Page(
            pageFormat: pdfPageFormat,
            build: (pw.Context context) {
              return pw.Column(children: [
               
                pw.Expanded(
                  child: pw.Image(image, fit: pw.BoxFit.contain),
                ),
                pw.Footer(
                    title: pw.Text("Imagen ${context.pageNumber}",
                        style: const pw.TextStyle(fontSize: 10)))
              ]);
            },
          ),
        );
      } catch (e) {
        debugPrint("Error procesando imagen $imagePath: $e");
      }
    }

    final outputDir = await getTemporaryDirectory();
    final outputFile = File(
        "${outputDir.path}/doc_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await outputFile.writeAsBytes(await pdf.save());

    return outputFile;
  }

 /* Future<Map<String, dynamic>> postUserGeneratedDocuments(
      int userId,
      int profileId,
      int templateId,
      List<Map<String, dynamic>> fieldsData,
      List<String> filePaths,
      int? addressId) async {
    debugPrint("User id  $userId");
    debugPrint("Template id  $templateId");
    debugPrint("FieldsData $fieldsData");
    debugPrint("FilePaths $filePaths");

    File? finalFile;
    List<MapEntry<String, MultipartFile>> fileEntries = [];

    dio.options = BaseOptions(followRedirects: true);
    FormData formData = FormData.fromMap({
      'user_id': userId,
      'profile_id': profileId,
      'template_id': templateId,
      'fields': jsonEncode(fieldsData),
      if (addressId != null) 'address_delivery_id': addressId,
    });
    if (filePaths.length > 1) {
      finalFile = await _convertImagesToPdf(filePaths, "documento");
      fileEntries.add(MapEntry(
        'file_1',
        await MultipartFile.fromFile(finalFile.path),
      ));
    } else if (filePaths.length == 1) {
      // Si solo hay un archivo, enviarlo directamente
      fileEntries.add(MapEntry(
        'file_1',
        await MultipartFile.fromFile(filePaths.first),
      ));
    }

    formData.files.addAll(fileEntries);

    debugPrint("FormData ${formData.fields}");
    debugPrint("FormData ${formData.files}");

    try {
      final response = await dio.post(
        "$baseUrl$userGenteratedDocuments",
        data: formData,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        /*FirebaseAndNotifications.showManualNotification(
            "Documento Generado", "Mantente alerta para el siguiente proceso");*/
        debugPrint("Respuesta del servidor: ${response.data}");
        return response.data;
      } else {
        debugPrint("Error en la respuesta del servidor: ${response.data}");
        return {"success": false, "error": "Respuesta inválida del servidor"};
      }
    } catch (e) {
      debugPrint("Error desconocido al crear documento: $e");
      return {'success': false, 'error': 'Hay un error en el servidor'};
    }
  }*/
  Future<Map<String, dynamic>> postUserGeneratedDocuments(
  int userId,
  int profileId,
  int templateId,
  List<Map<String, dynamic>> fieldsData,
  List<List<String>> sectionFiles, // Cambiado a List<List<String>>
  int? addressId,
) async {
  debugPrint("User id  $userId");
  debugPrint("Template id  $templateId");
  debugPrint("FieldsData $fieldsData");
  debugPrint("SectionFiles $sectionFiles");

  dio.options = BaseOptions(followRedirects: true);
  FormData formData = FormData.fromMap({
    'user_id': userId,
    'profile_id': profileId,
    'template_id': templateId,
    'fields': jsonEncode(fieldsData),
    if (addressId != null) 'address_delivery_id': addressId,
  });

  // Procesar archivos por sección
  for (int i = 0; i < sectionFiles.length; i++) {
    List<String> files = sectionFiles[i];
    if (files.isEmpty) continue;

    if (files.length > 1) {
      // Si hay múltiples archivos en la sección, convertirlos a PDF
      File finalFile = await _convertImagesToPdf(files, "seccion_${i + 1}");
      formData.files.add(MapEntry(
        'file_${i + 1}',
        await MultipartFile.fromFile(finalFile.path),
      ));
    } else {
      // Si solo hay un archivo en la sección, enviarlo directamente
      formData.files.add(MapEntry(
        'file_${i + 1}',
        await MultipartFile.fromFile(files.first),
      ));
    }
  }

  debugPrint("FormData ${formData.fields}");
  debugPrint("FormData ${formData.files}");

  try {
    final response = await dio.post(
      "$baseUrl$userGenteratedDocuments",
      data: formData,
    );

    if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
      debugPrint("Respuesta del servidor: ${response.data}");
      return response.data;
    } else {
      debugPrint("Error en la respuesta del servidor: ${response.data}");
      return {"success": false, "error": "Respuesta inválida del servidor"};
    }
  } catch (e) {
    debugPrint("Error desconocido al crear documento: $e");
    return {'success': false, 'error': 'Hay un error en el servidor'};
  }
}

  Future<List<UserGeneratedDocumentModel>> getUserGeneratedDocuments(
      int userId, int profileId) async {
    UserModel user = await appStore.getUser();
    dio.options = BaseOptions(
      followRedirects: true, // Habilitar seguimiento de redirecciones
    );
    try {
      final response = await dio.get("$baseUrl$userGenteratedDocuments",
          queryParameters: {"user_id": userId, "profile_id": profileId});
      // debugPrint("Respuesta del servidor es correcta: $response");
      // debugPrint("Respuesta del servidor es correcta: ${response.statusCode}");
      if (response.statusCode == 200 && response.data["status"] == true) {
        Map<String, dynamic> body = response.data;
        List<dynamic> documents = body['data']['documents'] ?? [];
        return documents
            .map((item) => UserGeneratedDocumentModel.fromJson(item))
            .toList();
      } else {
        return response.data["message"];
      }
    } catch (e) {
      debugPrint("Error desconocido en getUserGeneratedDocuments: $e");
      return [];
    }
  }

  Future<UserGeneratedDocumentModel> showUserGeneratedDocumentById(
      int documentId) async {
    try {
      final Response response =
          await dio.get("$baseUrl$userGenteratedDocuments/$documentId");

      if (response.statusCode == 200) {
        Map<String, dynamic> body = response.data;
        if (body.containsKey('data') && body['data'].containsKey('document')) {
          return UserGeneratedDocumentModel.fromJson(body['data']['document']);
        } else {
          throw Exception(
              'Respuesta inesperada del servidor: Falta la clave "data.document"');
        }
      } else {
        throw Exception(
            'Error en la solicitud: Código de estado ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudo obtener el documento: $e');
    }
  }

  Future<String> deleteUserGeneratedDocuments(
      int idUserGeneratedDocument) async {
    try {
      final response = await dio.delete(
          "$baseUrl$userGenteratedDocuments/${idUserGeneratedDocument}");

      if (response.statusCode == 200 && response.data["status"] == true) {
        Map<String, dynamic> body = response.data;
        return body['message'];
      } else {
        return response.data["message"];
      }
    } catch (e) {
      return "Error al eliminar el documento";
    }
  }

  Future<String> updateUserGeneratedDocuments(
      int idDocumentGenerated, List<Map<String, dynamic>> fieldsData) async {
    try {
      final response = await dio.put(
        "$baseUrl$userGenteratedDocuments/${idDocumentGenerated}",
        data: {'fields': fieldsData},
      );

      if (response.statusCode == 200) {
        return response.data['message'] ?? "Operación exitosa";
      } else {
        return response.data['message'] ?? "Error desconocido";
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!.data["message"] ??
            "Error inesperado"; // Captura el mensaje del error
      } else {
        return "Error de conexión con el servidor";
      }
    } catch (e) {
      return "Ocurrió un error inesperado";
    }
  }
}
