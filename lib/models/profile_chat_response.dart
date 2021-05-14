// To parse this JSON data, do
//
//     final usuariosResponse = usuariosResponseFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_plants/models/profile_chats.dart';

ProfileChatResponse profilesChatResponseFromJson(String str) =>
    ProfileChatResponse.fromJson(json.decode(str));

String profilesChatResponseToJson(ProfileChatResponse data) =>
    json.encode(data.toJson());

class ProfileChatResponse {
  ProfileChatResponse({this.ok, this.profiles});

  bool ok;
  List<ProfilesChat> profiles;

  factory ProfileChatResponse.fromJson(Map<String, dynamic> json) =>
      ProfileChatResponse(
        ok: json["ok"],
        profiles: List<ProfilesChat>.from(
            json["profiles"].map((x) => ProfilesChat.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ok": ok,
        "profiles": List<dynamic>.from(profiles.map((x) => x.toJson())),
      };

  ProfileChatResponse.withError(String errorValue);
}
