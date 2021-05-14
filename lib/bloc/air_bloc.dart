import 'dart:async';
import 'package:flutter_plants/bloc/validators.dart';
import 'package:flutter_plants/models/air.dart';
import 'package:flutter_plants/models/aires_response.dart';
import 'package:flutter_plants/repository/aires_repository.dart';
import 'package:rxdart/rxdart.dart';

class AirBloc with Validators {
  final _nameController = BehaviorSubject<String>();

  final _descriptionController = BehaviorSubject<String>();

  final _wattsController = BehaviorSubject<String>();

  final _kelvinController = BehaviorSubject<String>();

  final _airesController = BehaviorSubject<List<Air>>();
  final AirRepository _repository = AirRepository();

  final BehaviorSubject<AiresResponse> _aires =
      BehaviorSubject<AiresResponse>();

  final BehaviorSubject<Air> _airSelect = BehaviorSubject<Air>();

  getAires(String roomId) async {
    AiresResponse response = await _repository.getAires(roomId);

    _aires.sink.add(response);
  }

  getAir(Air room) async {
    Air response = await _repository.getAir(room.id);
    _airSelect.sink.add(response);
  }

  BehaviorSubject<Air> get airSelect => _airSelect;

  BehaviorSubject<AiresResponse> get subject => _aires;

  // Recuperar los datos del Stream
  Stream<String> get nameStream =>
      _nameController.stream.transform(validationNameRequired);
  Stream<String> get descriptionStream => _descriptionController.stream;

  Stream<String> get wattsStream =>
      _wattsController.stream.transform(validationWattsRequired);

  Stream<String> get kelvinStream =>
      _kelvinController.stream.transform(validationKelvinRequired);

  Stream<bool> get formValidStream => Rx.combineLatest2(
      nameStream,
      wattsStream,

      //timeOnStream,
      //timeOffStream,
      (a, b) => true);

  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeDescription => _descriptionController.sink.add;

  Function(String) get changeWatts => _wattsController.sink.add;

  // Obtener el último valor ingresado a los streams
  String get name => _nameController.value;
  String get description => _descriptionController.value;
  String get watts => _wattsController.value;
  String get kelvin => _kelvinController.value;

  dispose() {
    _aires?.close();
    _airSelect?.close();
    _nameController?.close();
    _wattsController?.close();
    _kelvinController?.close();

    _descriptionController?.close();

    //  _roomsController?.close();
  }

  disposeRoom() {
    // _roomSelect?.close();
  }

  disposeRooms() {
    _airesController?.close();
    _aires.close();
  }
}

final airBloc = AirBloc();
