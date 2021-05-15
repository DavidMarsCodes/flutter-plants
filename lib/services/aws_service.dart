import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:leafety/shared_preferences/auth_storage.dart';

import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:leafety/global/environment.dart';

import 'package:mime_type/mime_type.dart';

class AwsService with ChangeNotifier {
  final prefs = new AuthUserPreferences();

  String _image;

  bool _isUpload = false;

  bool _isUploadImagePlant = false;

  bool _isUploadImageProduct = false;

  bool _isUploadRecipe = false;

  String imageUpdateVisit;
  String imageUpdatePlant;

  // static String redirectUri = 'https://api.gettymarket.com/api/aws/';

  bool get isUploadImagePlant => this._isUploadImagePlant;
  set isUploadImagePlant(bool valor) {
    this._isUploadImagePlant = valor;
    notifyListeners();
  }

  bool get isUpload => this._isUpload;
  set isUpload(bool valor) {
    this._isUpload = valor;
    notifyListeners();
  }

  bool get isUploadRecipe => this._isUploadRecipe;
  set isUploadRecipe(bool valor) {
    this._isUploadRecipe = valor;
    notifyListeners();
  }

  bool get isUploadImageProduct => this._isUploadImageProduct;
  set isUploadImageProduct(bool valor) {
    this._isUploadImageProduct = valor;
    notifyListeners();
  }

  String get image => this._image;

  set image(String valor) {
    this._image = valor;
    notifyListeners();
  }

  // Getters del token de forma estática

  Future<String> uploadImageAvatar(
      String uid, String fileName, String fileType, File image) async {
    final url = Uri.https('${Environment.apiUrl}', '/api/aws/upload/avatar');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;
    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
      'uid': uid
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];

    return respUrl;
  }

  Future<String> uploadImageHeader(
      String uid, String fileName, String fileType, File image) async {
    final url = Uri.https('${Environment.apiUrl}', '/api/aws/upload/header');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
      'uid': uid
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);
    //isUpload = true;

    final respUrl = respBody['url'];
    this.image = respUrl.toString();
    return respUrl;
  }

  Future<String> uploadImageCoverVisit(
      String fileName, String fileType, File image) async {
    final url =
        Uri.https('${Environment.apiUrl}', '/api/aws/upload/cover-visit');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];
    this.imageUpdateVisit = respUrl;
    return respUrl;
  }

  Future<String> updateImageCoverPlant(
      String fileName, String fileType, File image, String id) async {
    final url = Uri.https(
        '${Environment.apiUrl}', '/api/aws/upload/update-cover-plant');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
      'id': id,
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];
    this.imageUpdatePlant = respUrl;
    return respUrl;
  }

  Future<String> updateImageCoverProduct(
      String fileName, String fileType, File image, String id) async {
    final url = Uri.https(
        '${Environment.apiUrl}', '/api/aws/upload/update-cover-product');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
      'id': id,
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];
    this.imageUpdatePlant = respUrl;
    return respUrl;
  }

  Future<String> uploadImageCoverPlant(
      String fileName, String fileType, File image) async {
    final url =
        Uri.https('${Environment.apiUrl}', '/api/aws/upload/cover-plant');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];
    this.imageUpdatePlant = respUrl;
    return respUrl;
  }

  Future<String> updateImageCoverVisit(
      String fileName, String fileType, File image, String id) async {
    final url = Uri.https(
        '${Environment.apiUrl}', '/api/aws/upload/update-cover-visit');

    final mimeType = mime(image.path).split('/'); //image/jpeg

    final token = prefs.token;

    Map<String, String> headers = {
      "Content-Type": "image/mimeType",
      "x-token": token,
      'id': id,
    };

    final imageUploadRequest = http.MultipartRequest('POST', url);

    final file = await http.MultipartFile.fromPath('file', image.path,
        contentType: MediaType(mimeType[0], mimeType[1]));

    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(headers);

    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);

    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salio mal');

      return null;
    }

    final respBody = jsonDecode(resp.body);

    //final respData = imageResponseToJson(resp.body);

    final respUrl = respBody['url'];
    this.imageUpdatePlant = respUrl;
    return respUrl;
  }
}
