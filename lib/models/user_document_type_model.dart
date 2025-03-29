import 'dart:convert';

UserDocumentTypeModel UserDocumentTypeModelFromJson(String str) => UserDocumentTypeModel.fromJson(json.decode(str));

String UserDocumentTypeModelToJson(UserDocumentTypeModel data) => json.encode(data.toJson());

class UserDocumentTypeModel {
    final int id;
    final String code;
    final String name;
    final int required;
    final int required2;
    final UserDocument? userDocument;

    UserDocumentTypeModel({
        required this.id,
        required this.code,
        required this.name,
        required this.required,
        required this.required2,
        this.userDocument,
    });

    factory UserDocumentTypeModel.fromJson(Map<String, dynamic> json) => UserDocumentTypeModel(
        id: json["id"],
        code: json["code"],
        name: json["name"],
        required: json["required"],
        required2: json["required2"],
        userDocument: json['user_document'] != null
          ? UserDocument.fromJson(json['user_document'])
          : null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
        "required": required,
        "required2": required2,
        "user_document": userDocument?.toJson(),
    };
}

class UserDocument {
    int id;
    int userId;
    int UserDocumentTypeModelsId;
    String name;
    String status;
    String mime_type;
    String originalUrl;
    int? profileId;
    String previewUrl;
    String? originalUrl2;
    String? previewUrl2;
    String? expirationDate;

    UserDocument({
        required this.id,
        required this.userId,
        required this.UserDocumentTypeModelsId,
        required this.name,
        required this.status,
        required this.originalUrl,
        required this.previewUrl,
        required this.originalUrl2,
        required this.previewUrl2,
        this.expirationDate,
        this.profileId,
        required this.mime_type,
    });

    factory UserDocument.fromJson(Map<String, dynamic> json) => UserDocument(
        id: json["id"],
        userId: json["user_id"],
        UserDocumentTypeModelsId: json["user_document_types_id"],
        name: json["name"],
        status: json["status"],
        originalUrl: json["original_url"],
        previewUrl: json["preview_url"],
        profileId: json["profile_id"],
        originalUrl2 : json["original_url2"] ?? "",
        previewUrl2 : json["preview_url2"] ?? "",
        expirationDate: json["expiration_date"] ?? "",
        mime_type: json["mime_type"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "user_document_types_id": UserDocumentTypeModelsId,
        "name": name,
        "status": status,
        "original_url": originalUrl,
        "preview_url": previewUrl,
        "original_url2" : originalUrl2,
        "preview_url2" : previewUrl2,
        "mime_tyoe": mime_type,
    };
}
