import 'dart:convert';

FieldModel fieldModelFromJson(String str) => FieldModel.fromJson(json.decode(str));

String fieldModelToJson(FieldModel data) => json.encode(data.toJson());

class FieldModel {
    int sectionId;
    String key;
    String value;

    FieldModel({
        required this.sectionId,
        required this.key,
        required this.value,
    });

    factory FieldModel.fromJson(Map<String, dynamic> json) => FieldModel(
        sectionId: json["section_id"],
        key: json["key"],
        value: json["value"],
    );

    Map<String, dynamic> toJson() => {
        "section_id": sectionId,
        "key": key,
        "value": value,
    };
}
