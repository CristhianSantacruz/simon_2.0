import 'package:flutter/material.dart';
import 'package:simon_final/models/comment_model.dart';
import 'package:simon_final/models/comment_model_dto_request.dart';
import 'package:simon_final/services/document_comments.dart';

class DocumentCommentProvider with ChangeNotifier {
  List<CommentModel> _comments = [];
  bool _isLoading = true;
  bool _error = false;
  final DocumentCommentServices _documentCommentServices =
      DocumentCommentServices();

  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get error => _error;

  void addComment(CommentModel comment) {
    comments.add(comment);
    notifyListeners();
  }

  void getCommentsByDocumentId(int documentId) async {
    try {
      List<CommentModel> commentsByDocument =
          await _documentCommentServices.getCommentsByDocumentId(documentId);
      _comments = commentsByDocument;
    } catch (e) {
      _error = true;
      debugPrint(e.toString());
    }
    _isLoading = false;
    _error = false;
    notifyListeners();
  }

  void removeDocumentComment(int commentId, int documentId,int userId) async {
    try {
      await _documentCommentServices.deleteCommentById(commentId);
      getCommentsByDocumentId(documentId);
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  void updateDocumentComment(int commentId, String newMessage, int documentId,int userId,int profileId) async {
    try {
      _documentCommentServices.updateComment(commentId, newMessage,profileId);
      getCommentsByDocumentId(documentId);
    } catch (e) {
      debugPrint(e.toString());
    }
    notifyListeners();
  }

  void createComment(CommentModelDtoRequest commentPost, int documentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      CommentModel comment = await _documentCommentServices.createComment(commentPost);
      getCommentsByDocumentId(documentId);
    } catch (e) {
      debugPrint(e.toString());
    }
    Future.delayed(Duration(seconds: 2), () {
      _isLoading = false;
      notifyListeners();
    });
  }
}
