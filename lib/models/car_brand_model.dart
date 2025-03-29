// To parse this JSON data, do
//
//     final carBrandModel = carBrandModelFromJson(jsonString);

import 'dart:convert';

CarBrandModel carBrandModelFromJson(String str) => CarBrandModel.fromJson(json.decode(str));

String carBrandModelToJson(CarBrandModel data) => json.encode(data.toJson());

class CarBrandModel {
    int id;
    String name;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    CarBrandModel({
        required this.id,
        required this.name,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

  
    @override
    bool operator==(Object other) =>
        identical(this, other) ||
            other is CarBrandModel &&
                runtimeType == other.runtimeType &&
                id == other.id &&
                name == other.name &&
                createdAt == other.createdAt &&
                updatedAt == other.updatedAt &&
                deletedAt == other.deletedAt;

    @override
    int get hashCode => id.hashCode;

    factory CarBrandModel.fromJson(Map<String, dynamic> json) => CarBrandModel(
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

  toLowerCase() {}

    
}
