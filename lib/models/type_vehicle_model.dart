import 'dart:convert';

TypeVehicleModel typeVehicleModelFromJson(String str) => TypeVehicleModel.fromJson(json.decode(str));

String typeVehicleModelToJson(TypeVehicleModel data) => json.encode(data.toJson());

class TypeVehicleModel {
    int id;
    String name;
    dynamic description;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    TypeVehicleModel({
        required this.id,
        required this.name,
        required this.description,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });
    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is TypeVehicleModel &&
                runtimeType == other.runtimeType &&
                id == other.id &&
                name == other.name &&
                description == other.description &&
                createdAt == other.createdAt &&
                updatedAt == other.updatedAt &&
                deletedAt == other.deletedAt;

    factory TypeVehicleModel.fromJson(Map<String, dynamic> json) => TypeVehicleModel(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}