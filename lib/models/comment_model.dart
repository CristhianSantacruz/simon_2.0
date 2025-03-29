// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);


class CommentModel {
  int id;
  String? comment;  // Cambié a String? para permitir null
  int private;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? deletedAt;
  int userId;
  int? profileId;
  int documentId;
  int? parentId;
  List<CommentModel> children;
  User user;

  CommentModel({
    required this.id,
    this.comment,  // Aceptar null
    required this.private,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.userId,
    required this.documentId,
    required this.profileId,
    this.parentId,
    required this.children,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        id: json["id"],
        comment: json["comment"] ?? "",  // Valor predeterminado si comment es null
        private: json["private"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"] != null ? DateTime.parse(json["deleted_at"]) : null,
        userId: json["user_id"],
        documentId: json["document_id"],
        profileId: json["profile_id"] != null ? json["profile_id"] : 0,
        parentId: json["parent_id"],
        children: List<CommentModel>.from(
            json["children"]?.map((x) => CommentModel.fromJson(x)) ?? []),  // Asegúrate de que "children" no sea null
        user: User.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment ?? "",  // Usar valor vacío si comment es null
        "private": private,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt?.toIso8601String(),
        "user_id": userId,
        "document_id": documentId,
        "parent_id": parentId,
        "children": List<dynamic>.from(children.map((x) => x.toJson())),
        "user": user.toJson(),
      };
}

class User {
  int id;
  String? name;  // Cambié a String? para permitir null
  String? email;  // Cambié a String? para permitir null

  User({
    required this.id,
    this.name,  // Aceptar null
    this.email,  // Aceptar null
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"] ??"",  
        email: json["email"] ?? "", 
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name ?? "",  
        "email": email ?? "",  
      };
}
