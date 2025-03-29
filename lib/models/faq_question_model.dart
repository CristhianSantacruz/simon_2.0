// To parse this JSON data, do
//
//     final faQuestionModel = faQuestionModelFromJson(jsonString);

import 'dart:convert';

FaQuestionModel faQuestionModelFromJson(String str) => FaQuestionModel.fromJson(json.decode(str));

String faQuestionModelToJson(FaQuestionModel data) => json.encode(data.toJson());

class FaQuestionModel {
    int id;
    String question;
    String answer;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int categoryId;
    Category category;

    FaQuestionModel({
        required this.id,
        required this.question,
        required this.answer,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.categoryId,
        required this.category,
    });

    factory FaQuestionModel.fromJson(Map<String, dynamic> json) => FaQuestionModel(
        id: json["id"],
        question: json["question"],
        answer: json["answer"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        categoryId: json["category_id"],
        category: Category.fromJson(json["category"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "answer": answer,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "category_id": categoryId,
        "category": category.toJson(),
    };
}

class Category {
    int id;
    String category;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    Category({
        required this.id,
        required this.category,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        category: json["category"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "category": category,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}