class CommentModelDtoRequest {
  final int user_id;
  final int document_id;
  final String comment;
  final int profile_id;
  int? parent_id;
  

  CommentModelDtoRequest(
      {required this.user_id,
      required this.document_id,
      required this.comment,
       this.parent_id,
      required this.profile_id 
      });


}