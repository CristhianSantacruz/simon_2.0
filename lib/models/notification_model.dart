// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
    final int id;
    String? alertTitle;
    String? alertText;
    dynamic alertLink;
    DateTime createdAt;
    DateTime updatedAt;
    dynamic deletedAt;
    Pivot pivot;

    NotificationModel({
        required this.id,
        this.alertTitle,
        this.alertText,
        this.alertLink,
        required this.createdAt,
        required this.updatedAt,
        this.deletedAt,
        required this.pivot,
    });

    factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        id: json["id"],
        alertTitle: json["alert_title"],
        alertText: json["alert_text"],
        alertLink: json["alert_link"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deletedAt: json["deleted_at"],
        pivot: Pivot.fromJson(json["pivot"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "alert_title": alertTitle,
        "alert_text": alertText,
        "alert_link": alertLink,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "deleted_at": deletedAt,
        "pivot": pivot.toJson(),
    };
}

class Pivot {
    final int userId;
    final int userAlertId;

    Pivot({
        required this.userId,
        required this.userAlertId,
    });

    factory Pivot.fromJson(Map<String, dynamic> json) => Pivot(
        userId: json["user_id"],
        userAlertId: json["user_alert_id"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "user_alert_id": userAlertId,
    };
}
