// To parse this JSON data, do
//
//     final professionModel = professionModelFromJson(jsonString);

import 'dart:convert';

ProfessionModel professionModelFromJson(String str) => ProfessionModel.fromJson(json.decode(str));

String professionModelToJson(ProfessionModel data) => json.encode(data.toJson());

class ProfessionModel {
    int id;
    String name;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    ProfessionModel({
        required this.id,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

    factory ProfessionModel.fromJson(Map<String, dynamic> json) => ProfessionModel(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}
