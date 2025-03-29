import 'package:flutter/material.dart';
import 'package:simon_final/models/user_generated_document.dart';
import 'package:simon_final/screens_export.dart';
import 'package:simon_final/services/user_generated_document_service.dart';

class DocumentsGenerateProvider extends ChangeNotifier {
   
  List<UserGeneratedDocumentModel> _documentGenerates = [];
  

  bool _isLoading = true;
  bool _isError = true;

  List<UserGeneratedDocumentModel> get documentGenerates => _documentGenerates;
  bool get isLoading => _isLoading;
  bool get error => _isError;

  Future<void> getDocumentGenerates(int userId, int profileId) async {
    try {
      final documentsGenerates = await UserGeneratedDocumentService().getUserGeneratedDocuments(userId,profileId);
      _documentGenerates = documentsGenerates;
    } catch (e) {
      debugPrint("Error al obtener documentos generados: $e");
      _isError = true;
    }
    _isLoading = false;
    _isError = false;
    notifyListeners();
  }

  Future<String> updateUserGeneratedDocuments(
      List<Map<String, dynamic>> fieldsData, int idDocument,int userId,int profileId) async {
    try {
      final message = await UserGeneratedDocumentService()
          .updateUserGeneratedDocuments(idDocument, fieldsData);
      await getDocumentGenerates(userId,profileId);

      return message;
    } catch (e) {
      debugPrint("Error al actualizar documento: $e");
      return "Ocurrió un error inesperado";
    }
  }

  Future<String> deleteUserGeneratedDocuments(int idDocument,int userId,int profileId) async {
    try {
      final message = await UserGeneratedDocumentService()
          .deleteUserGeneratedDocuments(idDocument);
      await getDocumentGenerates(userId,profileId);
      return message;
    } catch (e) {
      debugPrint("Error al eliminar documento: $e");
      return "Ocurrió un error inesperado";
    }
  }
}
