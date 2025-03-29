import 'dart:convert';
import 'package:simon_final/models/car_brand_model.dart';
VehicleModel vehicleModelFromJson(String str) => VehicleModel.fromJson(json.decode(str));

String vehicleModelToJson(VehicleModel data) => json.encode(data.toJson());

class VehicleModel {
    int id;
    String name;
    int carBrandId;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    CarBrandModel? carBrand;

    VehicleModel({
        required this.id,
        required this.name,
        required this.carBrandId,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
         this.carBrand,
    });

    @override
    bool operator ==(Object other) =>
        identical(this, other) ||
            other is VehicleModel &&
                runtimeType == other.runtimeType &&
                id == other.id &&
                name == other.name &&
                carBrandId == other.carBrandId &&
                createdAt == other.createdAt &&
                updatedAt == other.updatedAt &&
                deletedAt == other.deletedAt &&
                carBrand == other.carBrand;

    @override
    int get hashCode => id.hashCode;

    factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json["id"],
        name: json["name"],
        carBrandId: json["car_brand_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        carBrand: CarBrandModel.fromJson(json["car_brand"]),
    );

    factory VehicleModel.fromJson2(Map<String, dynamic> json) => VehicleModel(
        id: json["id"],
        name: json["name"],
        carBrandId: json["car_brand_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],

    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "car_brand_id": carBrandId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "car_brand": carBrand!.toJson(),
    };
}

