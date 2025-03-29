import 'dart:convert';

AddressModel addresModelFromJson(String str) =>
    AddressModel.fromJson(json.decode(str));

String addresModelToJson(AddressModel data) => json.encode(data.toJson());

class AddressModel {
  int? id;
  String type;
  String? alias;
  String lastname;
  String firstname;
  String address;
  String? postcode;
  String? phone;
  String? phoneMobile;
  String identification;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? profileId;
  dynamic deletedAt;
  int userId;
  int countryId;
  int stateId;
  int cityId;
  int? districtId;

  AddressModel({
    this.id,
    required this.type,
    this.alias,
    required this.lastname,
    required this.firstname,
    required this.address,
    this.postcode,
    this.phone,
    this.phoneMobile,
    required this.identification,
     this.createdAt,
     this.updatedAt,
     this.deletedAt,
    required this.userId,
    required this.countryId,
    required this.stateId,
    required this.cityId,
    this.districtId,
    this.profileId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json["id"] as int,
        type: json["type"] as String, // No es necesario convertirlo a TypeAdressModel
        alias: json["alias"] as String?,
        lastname: json["lastname"] as String,
        firstname: json["firstname"] as String,
        address: json["address"] as String,
        postcode: json["postcode"] as String?,
        phone: json["phone"] as String?,
        phoneMobile: json["phone_mobile"] as String?,
        identification: json["identification"] as String,
        createdAt: DateTime.parse(json["created_at"] as String),
        updatedAt: DateTime.parse(json["updated_at"] as String),
        deletedAt: json["deleted_at"],
        userId: json["user_id"] as int,
        countryId: json["country_id"] as int,
        stateId: json["state_id"] as int,
        cityId: json["city_id"] as int,
        districtId: json["district_id"] as int?,
      );
  Map<String, dynamic> toJson() => {
        "id": id ?? "",
        "type": type,
        "alias": alias ?? "",
        "lastname": lastname,
        "firstname": firstname,
        "address": address,
        "postcode": postcode ?? "",
        "phone": phone ?? "",
        "phone_mobile": phoneMobile ?? "",
        "identification": identification,
        "user_id": userId,
        "country_id": countryId,
        "state_id": stateId,
        "city_id": cityId,
        "district_id": districtId ?? "",
        "profile_id": profileId ?? "",
      };
}

enum TypeAdressModel { ADDRESS, INVOICE }
