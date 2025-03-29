// To parse this JSON data, do
//
//     final userVehicle = userVehicleFromJson(jsonString);

import 'dart:convert';

import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_model.dart';

UserVehicle userVehicleFromJson(String str) => UserVehicle.fromJson(json.decode(str));

String userVehicleToJson(UserVehicle data) => json.encode(data.toJson());

class UserVehicle {
    int id;
    String plateNumber;
    int carBrandId;
    int vehicleModelId;
    int vehicleTypeId;
    int colorId;
    String year;
    dynamic chassisNumber;
    dynamic engineNumber;
    String ownerName;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int userId;
    CarBrandModel carBrand;
    VehicleModel vehicleModel;
    TypeVehicleModel vehicleType;
    ColorModel color;

    UserVehicle({
        required this.id,
        required this.plateNumber,
        required this.carBrandId,
        required this.vehicleModelId,
        required this.vehicleTypeId,
        required this.colorId,
        required this.year,
        required this.chassisNumber,
        required this.engineNumber,
        required this.ownerName,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.userId,
        required this.carBrand,
        required this.vehicleModel,
        required this.vehicleType,
        required this.color,
    });

    factory UserVehicle.fromJson(Map<String, dynamic> json) => UserVehicle(
        id: json["id"],
        plateNumber: json["plate_number"],
        carBrandId: json["car_brand_id"],
        vehicleModelId: json["vehicle_model_id"],
        vehicleTypeId: json["vehicle_type_id"],
        colorId: json["color_id"],
        year: json["year"],
        chassisNumber: json["chassis_number"],
        engineNumber: json["engine_number"],
        ownerName: json["owner_name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        userId: json["user_id"],
        carBrand: CarBrandModel.fromJson(json["car_brand"]),
        vehicleModel: VehicleModel.fromJson(json["vehicle_model"]),
        vehicleType: TypeVehicleModel.fromJson(json["vehicle_type"]),
        color: ColorModel.fromJson(json["color"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plate_number": plateNumber,
        "car_brand_id": carBrandId,
        "vehicle_model_id": vehicleModelId,
        "vehicle_type_id": vehicleTypeId,
        "color_id": colorId,
        "year": year,
        "chassis_number": chassisNumber,
        "engine_number": engineNumber,
        "owner_name": ownerName,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "user_id": userId,
        "car_brand": carBrand.toJson(),
        "vehicle_model": vehicleModel.toJson(),
        "vehicle_type": vehicleType.toJson(),
        "color": color.toJson(),
    };
}

