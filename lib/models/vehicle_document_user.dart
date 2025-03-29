import 'dart:convert';

VehicleDocumentTypeModel vehicleDocumentTypeModelFromJson(String str) => VehicleDocumentTypeModel.fromJson(json.decode(str));

String vehicleDocumentTypeModelToJson(VehicleDocumentTypeModel data) => json.encode(data.toJson());

class VehicleDocumentTypeModel {
  final int id;
  final String code;
  final String name;
  final int required;
  final int required2;
  final VehicleDocument? vehicleDocument;

  VehicleDocumentTypeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.required,
    required this.required2,
    this.vehicleDocument,
  });

  factory VehicleDocumentTypeModel.fromJson(Map<String, dynamic> json) => VehicleDocumentTypeModel(
    id: json["id"],
    code: json["code"],
    name: json["name"],
    required: json["required"],
    required2: json["required2"],
    vehicleDocument: json['vehicle_document'] != null
        ? VehicleDocument.fromJson(json['vehicle_document'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "name": name,
    "required": required,
    "required2": required2,
    "vehicle_document": vehicleDocument?.toJson(),
  };
}

class VehicleDocument {
  int id;
  int userId;
  int vehicleDocumentTypeId;
  int vehicleId;
  String name;
  String status;
  String originalUrl;
  String previewUrl;
  String? originalUrl2;
  String? previewUrl2;
  String? expirationDate;
  String mimeType;

  VehicleDocument({
    required this.id,
    required this.userId,
    required this.vehicleDocumentTypeId,
    required this.vehicleId,
    required this.name,
    required this.status,
    required this.originalUrl,
    required this.previewUrl,
    required this.originalUrl2,
    required this.previewUrl2,
    required this.mimeType,
    this.expirationDate
  });

  factory VehicleDocument.fromJson(Map<String, dynamic> json) => VehicleDocument(
    id: json["id"],
    userId: json["user_id"],
    vehicleDocumentTypeId: json["vehicle_document_types_id"],
    vehicleId: json["vehicle_id"],
    name: json["name"],
    status: json["status"],
    originalUrl: json["original_url"],
    previewUrl: json["preview_url"],
    originalUrl2 : json["original_url2"] ?? "",
    previewUrl2 : json["preview_url2"] ?? "",
    expirationDate: json["expiration_date"] ?? "",
    mimeType: json["mime_type"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "vehicle_document_types_id": vehicleDocumentTypeId,
    "vehicle_id": vehicleId,
    "name": name,
    "status": status,
    "original_url": originalUrl,
    "preview_url": previewUrl,
     "original_url2" : originalUrl2,
        "preview_url2" : previewUrl2,
        "mime_type" : mimeType,
  };
}