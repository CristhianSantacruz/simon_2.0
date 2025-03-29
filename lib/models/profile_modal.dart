// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
    int id;
    String name;
    String lastName;
    String typeIdentification;
    String maritalStatus;
    String identification;
    String? nombramiento;
    int professionId;
    String email;
    String phone;
    DateTime birthDate;
    int profileModelDefault;
    int userId;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    String? sexo;

    ProfileModel({
        required this.id,
        required this.name,
        required this.lastName,
        required this.typeIdentification,
        required this.maritalStatus,
        required this.identification,
        required this.nombramiento,
        required this.professionId,
        required this.email,
        required this.phone,
        required this.birthDate,
        required this.profileModelDefault,
        required this.userId,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        this.sexo,
    });

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"],
        name: json["name"],
        lastName: json["last_name"],
        typeIdentification: json["type_identification"],
        maritalStatus: json["marital_status"],
        identification: json["identification"],
        nombramiento: json["nombramiento"],
        professionId: json["profession_id"],
        email: json["email"],
        phone: json["phone"],
        birthDate: DateTime.parse(json["birth_date"]),
        profileModelDefault: json["default"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        sexo: json["sexo"],
    );

    Map<String, dynamic> toJson() => {

        "id": id,
        "name": name,
        "last_name": lastName,
        "type_identification": typeIdentification,
        "marital_status": maritalStatus,
        "identification": identification,
        "nombramiento": nombramiento,
        "profession_id": professionId,
        "email": email,
        "phone": phone,
        "birth_date": "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
        "default": profileModelDefault,
        "user_id": userId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "sexo"  : sexo,
    };
}