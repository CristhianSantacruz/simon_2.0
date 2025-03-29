// To parse this JSON data, do
//
//     final stateModel = stateModelFromJson(jsonString);

import 'dart:convert';

StateModel stateModelFromJson(String str) => StateModel.fromJson(json.decode(str));

String stateModelToJson(StateModel data) => json.encode(data.toJson());

class StateModel {
    int id;
    String name;
    String shortCode;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int countryId;

    StateModel({
        required this.id,
        required this.name,
        required this.shortCode,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.countryId,
    });

    factory StateModel.fromJson(Map<String, dynamic> json) => StateModel(
        id: json["id"],
        name: json["name"],
        shortCode: json["short_code"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        countryId: json["country_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_code": shortCode,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "country_id": countryId,
    };
}
