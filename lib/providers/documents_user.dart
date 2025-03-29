
import 'package:flutter/material.dart';
import 'package:simon_final/models/user_document_type_model.dart';
import 'package:simon_final/services/user_documents_types.services.dart';
import 'package:nb_utils/nb_utils.dart';

class DocumentUserProvider extends ChangeNotifier{
  List<UserDocumentTypeModel> _documentsUsers = [];
   UserDocumentsTypesServices _documentUsersService = UserDocumentsTypesServices();
  List<UserDocumentTypeModel> get documentsUsers => _documentsUsers;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> fetchDocumentsUsers(int userId,int profileId) async {
    _isLoading = true;
  //   notifyListeners();
    try {
      _documentsUsers = await _documentUsersService.getUserDocumentsTypes(userId,profileId);
    } catch (e) {
      _documentsUsers = [];
      toast("Error al obtener documentos");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadDocument(String nameDocument, String userDocumentFilePath, int idDocument, String? expirationDate, int userId,String? secondDocumentFilePath,int profileId) async {
    _isLoading = true;
    notifyListeners(); // Mostrar el loader antes de empezar

    try {
      await _documentUsersService.uploadDocument(nameDocument, userDocumentFilePath, idDocument, userId ,secondDocumentFilePath,profileId, expirationDate: expirationDate);
      await fetchDocumentsUsers(userId,profileId); 
    } catch (error) {
      toast("Error al enviar el documento");
    } finally {
      _isLoading = false;
      notifyListeners(); // Ocultar el loader
    }
  }

  Future<void> deleteDocument(int userDocumentId,int userId,int profileId) async {
    try {
      await _documentUsersService.deleteDocumentUpload(userDocumentId);
      await fetchDocumentsUsers(userId,profileId); 
    } catch (error) {
      toast("Error al eliminar el documento");
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

}