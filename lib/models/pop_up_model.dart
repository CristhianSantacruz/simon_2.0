// To parse this JSON data, do
//
//     final popUpModel = popUpModelFromJson(jsonString);

import 'dart:convert';

PopUpModel popUpModelFromJson(String str) => PopUpModel.fromJson(json.decode(str));

String popUpModelToJson(PopUpModel data) => json.encode(data.toJson());

class PopUpModel {
    int id;
    String name;
    String? redirect;
    DateTime dateFrom;
    DateTime dateTo;
    int monday;
    int tuesday;
    int wednesday;
    int thursday;
    int friday;
    int saturday;
    int sunday;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    String photoUrl;

    PopUpModel({
        required this.id,
        required this.name,
         this.redirect,
        required this.dateFrom,
        required this.dateTo,
        required this.monday,
        required this.tuesday,
        required this.wednesday,
        required this.thursday,
        required this.friday,
        required this.saturday,
        required this.sunday,
        required this.createdAt,
        required this.updatedAt,
        required this.deletedAt,
        required this.photoUrl,
    });

    factory PopUpModel.fromJson(Map<String, dynamic> json) => PopUpModel(
        id: json["id"],
        name: json["name"],
        redirect: json["redirect"] ?? "",
        dateFrom: DateTime.parse(json["date_from"]),
        dateTo: DateTime.parse(json["date_to"]),
        monday: json["monday"],
        tuesday: json["tuesday"],
        wednesday: json["wednesday"],
        thursday: json["thursday"],
        friday: json["friday"],
        saturday: json["saturday"],
        sunday: json["sunday"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        photoUrl: json["photo_url"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "redirect": redirect,
        "date_from": "${dateFrom.year.toString().padLeft(4, '0')}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}",
        "date_to": "${dateTo.year.toString().padLeft(4, '0')}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}",
        "monday": monday,
        "tuesday": tuesday,
        "wednesday": wednesday,
        "thursday": thursday,
        "friday": friday,
        "saturday": saturday,
        "sunday": sunday,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "photo_url": photoUrl,
    };
}
