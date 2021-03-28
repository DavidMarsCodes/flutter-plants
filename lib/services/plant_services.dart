import 'package:chat/models/message_error.dart';
import 'package:chat/models/plant.dart';
import 'package:chat/models/plant_response.dart';
import 'package:chat/models/plants_response.dart';

import 'package:chat/models/room.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:chat/global/environment.dart';
import 'package:flutter/material.dart';

class PlantService with ChangeNotifier {
  Plant _plant;
  Plant get plant => this._plant;

  Set<Plant> _platsSelected = Set();

  Set<Plant> get platsSelected => this._platsSelected;

  set platsSelected(Set<Plant> valor) {
    this._platsSelected = valor;
    notifyListeners();
  }

  set plant(Plant valor) {
    this._plant = valor;
    // notifyListeners();
  }

  bool _plantsSelect = false;
  bool get plantsSelect => this._plantsSelect;

  set plantsSelect(bool valor) {
    this._plantsSelect = valor;
    notifyListeners();
  }

  final _storage = new FlutterSecureStorage();

  Future createPlant(Plant plant) async {
    // this.authenticated = true;

    final token = await this._storage.read(key: 'token');

    final urlFinal = Uri.https('${Environment.apiUrl}', '/api/plant/new');

    final resp = await http.post(urlFinal,
        body: jsonEncode(plant),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);
      final roomResponse = plantResponseFromJson(resp.body);
      // this.rooms = roomResponse.rooms;

      return roomResponse;
    } else {
      final respBody = errorMessageResponseFromJson(resp.body);

      return respBody;
    }
  }

  Future editPlant(Plant plant) async {
    // this.authenticated = true;

    final token = await this._storage.read(key: 'token');

    final urlFinal =
        Uri.https('${Environment.apiUrl}', '/api/plant/update/plant');

    final resp = await http.post(urlFinal,
        body: jsonEncode(plant),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);
      final plantResponse = plantResponseFromJson(resp.body);
      // this.rooms = roomResponse.rooms;

      return plantResponse;
    } else {
      final respBody = errorMessageResponseFromJson(resp.body);

      return respBody;
    }
  }

  Future deletePlant(String plantId) async {
    final token = await this._storage.read(key: 'token');

    final urlFinal =
        Uri.https('${Environment.apiUrl}', '/api/room/delete/$plantId');

    try {
      await http.delete(urlFinal,
          headers: {'Content-Type': 'application/json', 'x-token': token});

      return true;
    } catch (e) {
      return false;
    }
  }

  Future updatePositionRoom(
      List<Room> rooms, int position, String userId) async {
    // this.authenticated = true;

    final token = await this._storage.read(key: 'token');

    final urlFinal =
        Uri.https('${Environment.apiUrl}', '/api/room/update/position');

    //final data = {'name': name, 'email': description, 'uid': uid};
    final data = {'rooms': rooms, 'userId': userId};

    final resp = await http.post(urlFinal,
        body: json.encode(data),
        headers: {'Content-Type': 'application/json', 'x-token': token});

    if (resp.statusCode == 200) {
      // final roomResponse = roomsResponseFromJson(resp.body);

      // this.rooms = roomResponse.rooms;

      return true;
    } else {
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }
  }

  Future<List<Plant>> getLastPlantsByUser(String userId) async {
    try {
      final token = await this._storage.read(key: 'token');

      final urlFinal =
          Uri.https('${Environment.apiUrl}', '/api/plant/plants/user/$userId');

      final resp = await http.get(urlFinal,
          headers: {'Content-Type': 'application/json', 'x-token': token});

      final plantsResponse = plantsResponseFromJson(resp.body);

      return plantsResponse.plants;
    } catch (e) {
      return [];
    }
  }
}
