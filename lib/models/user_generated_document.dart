// To parse this JSON data, do
//
//     final userGeneratedDocumentModel = userGeneratedDocumentModelFromJson(jsonString);

import 'dart:convert';

UserGeneratedDocumentModel userGeneratedDocumentModelFromJson(String str) => UserGeneratedDocumentModel.fromJson(json.decode(str));

String userGeneratedDocumentModelToJson(UserGeneratedDocumentModel data) => json.encode(data.toJson());

class UserGeneratedDocumentModel {
    int id;
    int userId;
    int documentTypeId;
    int templateId;
    String? templateName;
    String documentNumber;
    int documentStatusesId;
    dynamic data;
    DateTime? createdAt;
    DateTime? updatedAt;
    String originalUrl;
    String? signedUrl;
    String? paymentUrl;
    List<GeneratedDocumentSection> generatedDocumentSections;
    DocumentStatuses documentStatuses;
    Payment payment; 
    UserGeneratedDocumentModel({
        required this.id,
        required this.userId,
        required this.documentTypeId,
        required this.templateId,
        required this.documentNumber,
        required this.documentStatusesId,
        this.data,
        this.templateName,
        required this.originalUrl,
        this.signedUrl,
        this.paymentUrl,
        required this.generatedDocumentSections,
        this.createdAt,
        this.updatedAt,
        required this.documentStatuses,
        required this.payment,
    });

    factory UserGeneratedDocumentModel.fromJson(Map<String, dynamic> json) => UserGeneratedDocumentModel(
        id: json["id"],
        userId: json["user_id"]??"",
        documentTypeId: json["document_type_id"]??"",
        templateId: json["template_id"]??"",
        documentNumber: json["document_number"]??"",
        documentStatusesId: json["document_statuses_id"]??"",
        data: json["data"]??"",
        templateName: json["template_name"] ?? "",
        originalUrl: json["original_url"]??"",
        signedUrl: json["signed_url"] ?? "",
        paymentUrl: json["payment_url"] ?? "",
        generatedDocumentSections: List<GeneratedDocumentSection>.from(json["generated_document_sections"].map((x) => GeneratedDocumentSection.fromJson(x))),
        createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
        updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
        documentStatuses:  DocumentStatuses.fromJson(json["document_statuses"]) ,
        payment: Payment.fromJson(json["payment"]),

    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "document_type_id": documentTypeId,
        "template_id": templateId,
        "document_number": documentNumber,
        "document_statuses_id": documentStatusesId,
        "data": data,
        "original_url": originalUrl,
        "signed_url" : signedUrl,
        
        "generated_document_sections": List<dynamic>.from(generatedDocumentSections.map((x) => x.toJson())),
        "payment": payment.toJson(),
    };
}

class GeneratedDocumentSection {
    int id;
    int templateSectionsId;
    int generatedDocumentId;
    String name;
    dynamic description;
    dynamic content;
    int userIsEditable;
    List<DocumentSectionField> documentSectionFields;

    GeneratedDocumentSection({
        required this.id,
        required this.templateSectionsId,
        required this.generatedDocumentId,
        required this.name,
        this.description,
        this.content,
        required this.userIsEditable,
        required this.documentSectionFields,
    });

    factory GeneratedDocumentSection.fromJson(Map<String, dynamic> json) => GeneratedDocumentSection(
        id: json["id"],
        templateSectionsId: json["template_sections_id"],
        generatedDocumentId: json["generated_document_id"],
        name: json["name"]??"",
        description: json["description"]??"",
        content: json["content"]??"",
        userIsEditable: json["user_is_editable"],
        documentSectionFields: List<DocumentSectionField>.from(json["document_section_fields"].map((x) => DocumentSectionField.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_sections_id": templateSectionsId,
        "generated_document_id": generatedDocumentId,
        "name": name,
        "description": description,
        "content": content,
        "user_is_editable": userIsEditable,
        "document_section_fields": List<dynamic>.from(documentSectionFields.map((x) => x.toJson())),
    };
}
class DocumentStatuses {
    int id;
    String name;
    dynamic description;
    int documentStatusesDefault;
    int completed;
    int canceled;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;

    DocumentStatuses({
        required this.id,
        required this.name,
        required this.description,
        required this.documentStatusesDefault,
        required this.completed,
        required this.canceled,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
    });

    factory DocumentStatuses.fromJson(Map<String, dynamic> json) => DocumentStatuses(
        id: json["id"],
        name: json["name"],
        description: json["description"] ?? "",
        documentStatusesDefault: json["default"],
        completed: json["completed"],
        canceled: json["canceled"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "default": documentStatusesDefault,
        "completed": completed,
        "canceled": canceled,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
    };
}

class DocumentSectionField {
    int id;
    int templateFieldsId;
    int documentSectionId;
    String fieldName;
    String fieldLabel;
    dynamic fieldType;
    int isRequired;
    dynamic fieldModel;
    int userIsEditable;
    String fieldValue;
    String? fileUpload;
    ModeloData? modeloData;
    

    DocumentSectionField({
        required this.id,
        required this.templateFieldsId,
        required this.documentSectionId,
        required this.fieldName,
        required this.fieldLabel,
        this.fieldType,
        required this.isRequired,
        this.fieldModel,
        required this.userIsEditable,
        required this.fieldValue,
        this.fileUpload,
        this.modeloData,
    });

    factory DocumentSectionField.fromJson(Map<String, dynamic> json) => DocumentSectionField(
        id: json["id"],
        templateFieldsId: json["template_fields_id"],
        documentSectionId: json["document_section_id"],
        fieldName: json["field_name"],
        fieldLabel: json["field_label"],
        fieldType: json["field_type"],
        isRequired: json["is_required"],
        fieldModel: json["field_model"],
        userIsEditable: json["user_is_editable"],
        fieldValue: json["field_value"],
        fileUpload: json["file"] ?? null,
        modeloData: json["modelo_data"] != null ? ModeloData.fromJson(json["modelo_data"]) : null,
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "template_fields_id": templateFieldsId,
        "document_section_id": documentSectionId,
        "field_name": fieldName,
        "field_label": fieldLabel,
        "field_type": fieldType,
        "is_required": isRequired,
        "field_model": fieldModel,
        "user_is_editable": userIsEditable,
        "field_value": fieldValue,
    };
}

abstract class ModeloData {
  final int id;
  final String? name;

  ModeloData({required this.id, this.name});

  factory ModeloData.fromJson(Map<String, dynamic> json) {
    // Aquí decides qué tipo de modelo_data crear basado en los campos disponibles
    if (json.containsKey('plate_number')) {
      return VehicleModelData.fromJson(json);
    } else if (json.containsKey('entity_type')) {
      return EntityModelData.fromJson(json);
    } else {
      throw Exception('Tipo de modelo_data no reconocido');
    }
  }
}

class EntityModelData extends ModeloData {
  final String entityType;
  final String address;
  final String contactPhone;
  final String contactEmail;
  final int countryId;
  final int stateId;
  final int cityId;
  final int districId;

  EntityModelData({
    required int id,
    String? name,
    required this.entityType,
    required this.address,
    required this.contactPhone,
    required this.contactEmail,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    required this.districId,
  }) : super(id: id, name: name);

  factory EntityModelData.fromJson(Map<String, dynamic> json) {
    return EntityModelData(
      id: json['id'],
      name: json['name'],
      entityType: json['entity_type'],
      address: json['address'],
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      countryId: json['country_id'],
      stateId: json['state_id'],
      cityId: json['city_id'],
      districId: json['distric_id'],
    );
  }
}

class VehicleModelData extends ModeloData {
  final String plateNumber;
  final String brand;
  final String model;
  final String year;
  final String color;
  final String? chassisNumber;
  final String? engineNumber;
  final String vehicleType;
  final String ownerName;
  final int userId;

  VehicleModelData({
    required int id,
    String? name,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.chassisNumber,
    required this.engineNumber,
    required this.vehicleType,
    required this.ownerName,
    required this.userId,
  }) : super(id: id, name: name);

  factory VehicleModelData.fromJson(Map<String, dynamic> json) {
    return VehicleModelData(
      id: json['id'],
      name: json['name'],
      plateNumber: json['plate_number']??"",
      brand: json['brand']??"",
      model: json['model']??"",
      year: json['year']??"",
      color: json['color']??"",
      chassisNumber: json['chassis_number'] ?? "",
      engineNumber: json['engine_number'] ?? "",
      vehicleType: json['vehicle_type']??"",
      ownerName: json['owner_name']??"",
      userId: json['user_id'],
    );
  }
}
class Payment {
    int id;
    int amount;
    dynamic paymentDate;
    String paymentMethod;
    dynamic transaction;
    String status;
    dynamic datafastRequest;
    dynamic datafastResponse;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    int userId;
    int documentId;
    dynamic addressId;
    String basePrice;
    String taxRate;
    String subtotalIva;

    Payment({
        required this.id,
        required this.amount,
        required this.paymentDate,
        required this.paymentMethod,
        required this.transaction,
        required this.status,
        required this.datafastRequest,
        required this.datafastResponse,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.userId,
        required this.documentId,
        required this.addressId,
        required this.basePrice,
        required this.taxRate,
        required this.subtotalIva,
    });

    factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        amount: json["amount"],
        paymentDate: json["payment_date"],
        paymentMethod: json["payment_method"],
        transaction: json["transaction"],
        status: json["status"],
        datafastRequest: json["datafast_request"],
        datafastResponse: json["datafast_response"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        userId: json["user_id"],
        documentId: json["document_id"],
        addressId: json["address_id"],
        basePrice: json["base_price"],
        taxRate: json["tax_rate"],
        subtotalIva: json["subtotal_iva"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "amount": amount,
        "payment_date": paymentDate,
        "payment_method": paymentMethod,
        "transaction": transaction,
        "status": status,
        "datafast_request": datafastRequest,
        "datafast_response": datafastResponse,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "user_id": userId,
        "document_id": documentId,
        "address_id": addressId,
        "base_price": basePrice,
        "tax_rate": taxRate,
        "subtotal_iva": subtotalIva,
    };
}
