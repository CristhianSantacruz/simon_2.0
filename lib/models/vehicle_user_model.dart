import 'dart:convert';

import 'package:simon_final/models/car_brand_model.dart';
import 'package:simon_final/models/color_model.dart';
import 'package:simon_final/models/type_vehicle_model.dart';
import 'package:simon_final/models/vehicle_model.dart';

VehicleModelUser vehicleModelUserFromJson(String str) =>
    VehicleModelUser.fromJson(json.decode(str));
String vehicleModelUserToJson(VehicleModelUser data) =>
    json.encode(data.toJson());

class VehicleModelUser {
  int userId;
  String plateNumber;
  int carBrandId;
  int carModelId;
  String year;
  int carColorId;
  String? chassisNumber;
  String? engineNumber;
  int vehicleTypeId;
  String ownerName;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? id;
  CarBrandModel? carBrand;
  VehicleModel? vehicleModel;
  TypeVehicleModel? vehicleType;
  ColorModel? color;

  VehicleModelUser({
    required this.userId,
    required this.plateNumber,
    required this.carBrandId,
    required this.carModelId,
    required this.year,
    required this.carColorId,
    this.chassisNumber,
    this.engineNumber,
    required this.vehicleTypeId,
    required this.ownerName,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.carBrand,
    this.vehicleModel,
    this.vehicleType,
    this.color,
  });

  factory VehicleModelUser.fromJson(Map<String, dynamic> json) => VehicleModelUser(
  userId: json["user_id"],
  plateNumber: json["plate_number"],
  carBrandId: json["car_brand_id"],
  carModelId: json["vehicle_model_id"],
  year: json["year"],
  carColorId: json["color_id"],
  chassisNumber: json["chassis_number"],
  engineNumber: json["engine_number"],
  vehicleTypeId: json["vehicle_type_id"],
  ownerName: json["owner_name"],
  updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
  createdAt: DateTime.tryParse(json["created_at"] ?? ""),
  id: json["id"],
  carBrand: json["car_brand"] != null ? CarBrandModel.fromJson(json["car_brand"]) : null,
  vehicleModel: json["vehicle_model"] != null ? VehicleModel.fromJson2(json["vehicle_model"]) : null,
  vehicleType: json["vehicle_type"] != null ? TypeVehicleModel.fromJson(json["vehicle_type"]) : null,
  color: json["color"] != null ? ColorModel.fromJson(json["color"]) : null,
);

Map<String, dynamic> toJson() => {
  "user_id": userId,
  "plate_number": plateNumber,
  "car_brand_id": carBrandId,
  "vehicle_model_id": carModelId,
  "year": year,
  "color_id": carColorId,
  "chassis_number": chassisNumber,
  "engine_number": engineNumber,
  "vehicle_type_id": vehicleTypeId,
  "owner_name": ownerName,
  "id": id,
  if (carBrand != null) "car_brand": carBrand!.toJson(),
  if (vehicleModel != null) "vehicle_model": vehicleModel!.toJson(),
  if (vehicleType != null) "vehicle_type": vehicleType!.toJson(),
  if (color != null) "color": color!.toJson(),
};

}
