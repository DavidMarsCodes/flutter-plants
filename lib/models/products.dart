// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

import 'package:chat/models/profiles.dart';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

String productToJson(Product data) => json.encode(data.toJson());

class Product {
  Product({
    this.id,
    this.user,
    this.name = "",
    this.description = "",
    this.dateCreate,
    //this.products,
    this.dateUpdate,
    this.totalProducts,
    this.coverImage = "",
    this.catalogo,
    this.ratingInit,
    this.cbd = "",
    this.thc = "",
    this.profile,
    //this.products
  });
  String id;
  String user;
  String name;
  String description;
  // List<Product> products;
  String dateCreate;
  String dateUpdate;
  int totalProducts;
  String catalogo;
  String ratingInit;

  String cbd;
  String thc;
  Profiles profile;

  String coverImage;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        user: json["user"],
        name: json["name"],
        description: json["description"],
        //products: List<Room>.from(json["products"].map((x) => x)),
        dateCreate: json["dateCreate"],
        dateUpdate: json["dateUpdate"],
        totalProducts: json["totalProducts"],
        coverImage: json["coverImage"],
        catalogo: json["catalogo"],
        ratingInit: json["ratingInit"],
        cbd: json["cbd"],
        thc: json["thc"],
        profile: Profiles.fromJson(json["profile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user": user,
        "name": name,
        "description": description,
        "dateCreate": dateCreate,
        "dateUpdate": dateUpdate,
        "totalProducts": totalProducts,
        "coverImage": coverImage,
        "catalogo": catalogo,
        "ratingInit": ratingInit,
        "cbd": cbd,
        "thc": thc,
        "profile": profile.toJson(),

        // "products": List<dynamic>.from(products.map((x) => x)),
      };

  getCoverImg() {
    if (coverImage == "") {
      var imageDefault =
          "http://images-cdn-br.s3-sa-east-1.amazonaws.com/default_banner.jpeg";
      return imageDefault;
    } else {
      return coverImage;
    }
  }
}
