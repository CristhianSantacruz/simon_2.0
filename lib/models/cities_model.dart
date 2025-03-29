// To parse this JSON data, do
//
//     final citieModel = citieModelFromJson(jsonString);

import 'dart:convert';

CitieModel citieModelFromJson(String str) => CitieModel.fromJson(json.decode(str));

String citieModelToJson(CitieModel data) => json.encode(data.toJson());

class CitieModel {
    int id;
    String name;
    String shortCode;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int stateId;

    CitieModel({
        required this.id,
        required this.name,
        required this.shortCode,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.stateId,
    });

    factory CitieModel.fromJson(Map<String, dynamic> json) => CitieModel(
        id: json["id"],
        name: json["name"],
        shortCode: json["short_code"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        stateId: json["state_id"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "short_code": shortCode,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "state_id": stateId,
    };
}
