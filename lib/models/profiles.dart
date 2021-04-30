// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

import 'package:chat/models/usuario.dart';

Profiles profilesFromJson(String str) => Profiles.fromJson(json.decode(str));

String profilesToJson(Profiles data) => json.encode(data.toJson());

class Profiles {
  Profiles(
      {this.id,
      this.rutClub,
      this.name,
      this.lastName,
      this.createdAt,
      this.updatedAt,
      this.imageHeader,
      this.imageAvatar,
      this.user,
      this.imageRecipe,
      this.message = "",
      this.messageDate,
      this.subId = "0",
      this.isClub = false,
      this.subscribeApproved = false,
      this.subscribeActive = false,
      this.about = ""});

  String id;
  String name;

  String rutClub;
  String lastName;
  DateTime createdAt;
  DateTime updatedAt;
  String imageHeader;
  String about;
  String imageAvatar;
  String imageRecipe;
  User user;
  String message;
  DateTime messageDate;
  String subId;
  bool isClub;
  bool subscribeApproved;
  bool subscribeActive;

  factory Profiles.fromJson(Map<String, dynamic> json) => Profiles(
      id: json["id"],
      name: json["name"],
      lastName: json["lastName"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      imageAvatar: json["imageAvatar"],
      about: json["about"],
      message: json["message"],
      messageDate: DateTime.parse(json["messageDate"]),
      imageHeader: json["imageHeader"],
      user: User.fromJson(json["user"]),
      imageRecipe: json["imageRecipe"],
      subId: json["subId"],
      isClub: json["isClub"],
      subscribeApproved: json["subscribeApproved"],
      subscribeActive: json["subscribeActive"],
      rutClub: json["rutClub"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "lastName": lastName,
        "dateCreate": createdAt,
        "dateUpdate": updatedAt,
        "messageDate": messageDate,
        "about": about,
        "message": message,
        "imageAvatar:": imageAvatar,
        "imageHeader": imageHeader,
        "user": user.toJson(),
        "imageRecipe": imageRecipe,
        "subId": subId,
        "isClub": isClub,
        "subscribeApproved": subscribeApproved,
        "subscribeActive": subscribeActive,
        "rutClub": rutClub
      };

  getAvatarImg() {
    if (imageAvatar == "") {
      return null;
    } else {
      return imageAvatar;
    }
  }

  getHeaderImg() {
    if (imageHeader == "") {
      var imageDefault =
          "https://leafety-images.s3.us-east-2.amazonaws.com/header/default-header.png";

      return imageDefault;
    } else {
      return imageHeader;
    }
  }

  getRecipeImg() {
    if (imageRecipe == "") {
      var imageDefault =
          "https://leafety-images.s3.us-east-2.amazonaws.com/global/default_banner.jpeg";

      return imageDefault;
    } else {
      return imageRecipe;
    }
  }
}
