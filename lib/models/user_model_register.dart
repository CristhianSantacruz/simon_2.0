// To parse this JSON data, do
//
//     final userModelRegiser = userModelRegiserFromJson(jsonString);

import 'dart:convert';

UserModelRegiser userModelRegiserFromJson(String str) => UserModelRegiser.fromJson(json.decode(str));

String userModelRegiserToJson(UserModelRegiser data) => json.encode(data.toJson());

class UserModelRegiser {
    String name;
    String lastName;
    String typeIdentification;
    String? password;
    String maritalStatus;
    String identification;
    int profession_id;
    String email;
    String phone;
    String sexo;
    DateTime birthDate;
    String? nombramiento;

    UserModelRegiser({
        required this.name,
        required this.lastName,
        required this.typeIdentification,
         this.password,
        required this.maritalStatus,
        required this.identification,
        required this.profession_id,
        required this.email,
        required this.phone,
        required this.birthDate,
        this.nombramiento,
        required this.sexo,
    });

    factory UserModelRegiser.fromJson(Map<String, dynamic> json) => UserModelRegiser(
        name: json["name"],
        lastName: json["last_name"],
        typeIdentification: json["type_identification"],
        password: json["password"],
        maritalStatus: json["marital_status"],
        identification: json["identification"],
        profession_id: json["profession_id"],
        email: json["email"],
        sexo: json["sexo"],
        phone: json["phone"],
        birthDate: DateTime.parse(json["birth_date"]),
        nombramiento: json["nombramiento"] ,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "last_name": lastName,
        "type_identification": typeIdentification,
        "password": password,
        "marital_status": maritalStatus,
        "identification": identification,
        "profession_id": profession_id,
        "email": email,
        "phone": phone,
        "sexo": sexo,
        "nombramiento" : nombramiento,
        "birth_date": "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
    };
    Map<String, dynamic> toJsonUpdate() => {
        "name": name,
        "last_name": lastName,
        "type_identification": typeIdentification,
        "marital_status": maritalStatus,
        "identification": identification,
        "profession_id": profession_id,
        "email": email,
        "sexo": sexo,
        "phone": phone,
        "nombramiento" : nombramiento,
        "birth_date": "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}",
    };  
}
