// To parse this JSON data, do
//
//     final profileModelRegister = profileModelRegisterFromJson(jsonString);

import 'dart:convert';

ProfileModelRegister profileModelRegisterFromJson(String str) => ProfileModelRegister.fromJson(json.decode(str));

String profileModelRegisterToJson(ProfileModelRegister data) => json.encode(data.toJson());

class ProfileModelRegister {
    String name;
    String lastName;
    String typeIdentification;
    String maritalStatus;
    String identification;
    int? professionId;
    String email;
    String phone;
    DateTime birthDate;
    String nombramiento;
    int userId;
    String? sexo;

    ProfileModelRegister({
        required this.name,
        required this.lastName,
        required this.typeIdentification,
        required this.maritalStatus,
        required this.identification,
         this.professionId,
        required this.email,
        required this.phone,
        required this.birthDate,
        required this.nombramiento,
        required this.userId,
        required this.sexo,
    });

    factory ProfileModelRegister.fromJson(Map<String, dynamic> json) => ProfileModelRegister(
        name: json["name"],
        lastName: json["last_name"],
        typeIdentification: json["type_identification"],
        maritalStatus: json["marital_status"],
        identification: json["identification"],
        professionId: json["profession_id"],
        email: json["email"],
        phone: json["phone"],
        birthDate: DateTime.parse(json["birth_date"]),
        nombramiento: json["nombramiento"],
        userId: json["user_id"],
        sexo: json["sexo"] ?? "" ,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "last_name": lastName,
        "type_identification": typeIdentification,
        "marital_status": maritalStatus,
        "identification": identification,
        "profession_id": professionId,
        "email": email,
        "phone": phone,
        "birth_date": "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
        "nombramiento": nombramiento,
        "user_id": userId,
        "sexo": sexo,
    };
}
