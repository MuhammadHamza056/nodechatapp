// To parse this JSON data, do
//
//     final getUsersModel = getUsersModelFromJson(jsonString);

import 'dart:convert';

GetUsersModel getUsersModelFromJson(String str) => GetUsersModel.fromJson(json.decode(str));

String getUsersModelToJson(GetUsersModel data) => json.encode(data.toJson());

class GetUsersModel {
    int? status;
    String? message;
    List<Datum>? data;

    GetUsersModel({
        this.status,
        this.message,
        this.data,
    });

    factory GetUsersModel.fromJson(Map<String, dynamic> json) => GetUsersModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class Datum {
    String? id;
    String? userId;
    String? name;
    String? email;
    String? password;
    DateTime? createdAt;
    DateTime? lastSeen;

    Datum({
        this.id,
        this.userId,
        this.name,
        this.email,
        this.password,
        this.createdAt,
        this.lastSeen,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        userId: json["userId"],
        name: json["name"],
        email: json["email"],
        password: json["password"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        lastSeen: json["lastSeen"] == null ? null : DateTime.parse(json["lastSeen"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "name": name,
        "email": email,
        "password": password,
        "createdAt": createdAt?.toIso8601String(),
        "lastSeen": lastSeen?.toIso8601String(),
    };
}
