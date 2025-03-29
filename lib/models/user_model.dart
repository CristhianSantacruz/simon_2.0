import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  int id;
  String name;
  String email;
  String? lastName;
  String? sexo;
  String? typeIdentification;
  String? maritalStatus;
  String? identification;
  String? profession;
  int? professionId;
  String? nombramiento;
  String? phone;
  String? birthDate;
  DateTime? emailVerifiedAt;
  int? approved;
  int? verified;
  DateTime? verifiedAt;
  String? verificationToken;
  int? twoFactor;
  DateTime? twoFactorExpiresAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  DateTime? deletedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.lastName,
    this.typeIdentification,
    this.maritalStatus,
    this.identification,
    this.profession,
    this.professionId,
    this.nombramiento,
    this.phone,
    this.birthDate,
    this.emailVerifiedAt,
    this.approved,
    this.verified,
    this.verifiedAt,
    this.verificationToken,
    this.twoFactor,
    this.twoFactorExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.sexo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        lastName: json["last_name"],
        typeIdentification: json["type_identification"],
        maritalStatus: json["marital_status"],
        identification: json["identification"],
        profession: json["profession"],
        professionId:  json["profession_id"],
        nombramiento: json["nombramiento"],
        phone: json["phone"],
        sexo: json["sexo"] ?? "",
        birthDate: json["birth_date"] != null ? json["birth_date"] : "",
        emailVerifiedAt: json["email_verified_at"] != null ? DateTime.parse(json["email_verified_at"]): null,
        approved: json["approved"],
        verified: json["verified"],
        verifiedAt: json["verified_at"] != null ? DateTime.parse(json["verified_at"]) : null,
        verificationToken: json["verification_token"],
        twoFactor: json["two_factor"],
        twoFactorExpiresAt: json["two_factor_expires_at"] != null ? DateTime.parse(json["two_factor_expires_at"])
            : null,
        createdAt: json["created_at"] != null? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        deletedAt: json["deleted_at"] != null
            ? DateTime.parse(json["deleted_at"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "sexo": sexo,
        "last_name": lastName,
        "type_identification": typeIdentification,
        "marital_status": maritalStatus,
        "identification": identification,
        "profession": profession,
        "phone": phone,
        "birth_date": birthDate,
        "email_verified_at": emailVerifiedAt?.toIso8601String(),
        "approved": approved,
        "verified": verified,
        "verified_at": verifiedAt?.toIso8601String(),
        "verification_token": verificationToken,
        "two_factor": twoFactor,
        "two_factor_expires_at": twoFactorExpiresAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt?.toIso8601String(),
        "nombramiento": nombramiento,
        "profession_id": professionId,
      };
}
