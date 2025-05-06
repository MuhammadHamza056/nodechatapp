// To parse this JSON data, do
//
//     final userLoginModel = userLoginModelFromJson(jsonString);

import 'dart:convert';

UserLoginModel userLoginModelFromJson(String str) => UserLoginModel.fromJson(json.decode(str));

String userLoginModelToJson(UserLoginModel data) => json.encode(data.toJson());

class UserLoginModel {
    int? status;
    String? message;
    User? user;

    UserLoginModel({
        this.status,
        this.message,
        this.user,
    });

    factory UserLoginModel.fromJson(Map<String, dynamic> json) => UserLoginModel(
        status: json["status"],
        message: json["message"],
        user: json["user"] == null ? null : User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "user": user?.toJson(),
    };
}

class User {
    String? id;
    String? userId;
    String? email;
    String? password;
    DateTime? createdAt;

    User({
        this.id,
        this.userId,
        this.email,
        this.password,
        this.createdAt,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        userId: json["userId"],
        email: json["email"],
        password: json["password"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "email": email,
        "password": password,
        "createdAt": createdAt?.toIso8601String(),
    };
}
