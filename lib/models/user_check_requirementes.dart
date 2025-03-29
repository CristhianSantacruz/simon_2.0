import 'dart:convert';

UserCheckRequirmentesModel userCheckRequirmentesModelFromJson(String str) => UserCheckRequirmentesModel.fromJson(json.decode(str));

String userCheckRequirmentesModelToJson(UserCheckRequirmentesModel data) => json.encode(data.toJson());

class UserCheckRequirmentesModel {
    int userId;
    bool requirementsMet;
    List<MissingItem> missingItems;

    UserCheckRequirmentesModel({
        required this.userId,
        required this.requirementsMet,
        required this.missingItems,
    });

    factory UserCheckRequirmentesModel.fromJson(Map<String, dynamic> json) => UserCheckRequirmentesModel(
        userId: json["user_id"],
        requirementsMet: json["requirements_met"],
        missingItems: List<MissingItem>.from(json["missing_items"].map((x) => MissingItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "requirements_met": requirementsMet,
        "missing_items": List<dynamic>.from(missingItems.map((x) => x.toJson())),
    };
}

class MissingItem {
    String type;
    String message;
    List<Document>? documents;

    MissingItem({
        required this.type,
        required this.message,
        this.documents,
    });

    factory MissingItem.fromJson(Map<String, dynamic> json) => MissingItem(
        type: json["type"],
        message: json["message"],
        documents: json["documents"] == null ? [] : List<Document>.from(json["documents"]!.map((x) => Document.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "message": message,
        "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
    };
}

class Document {
    int documentTypeId;
    String documentName;

    Document({
        required this.documentTypeId,
        required this.documentName,
    });

    factory Document.fromJson(Map<String, dynamic> json) => Document(
        documentTypeId: json["document_type_id"],
        documentName: json["document_name"],
    );

    Map<String, dynamic> toJson() => {
        "document_type_id": documentTypeId,
        "document_name": documentName,
    };
}
