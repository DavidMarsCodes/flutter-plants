import 'dart:async';
import 'package:leafety/bloc/validators.dart';
import 'package:leafety/models/aires_response.dart';
import 'package:leafety/models/visit.dart';
import 'package:leafety/models/visits_response.dart';
import 'package:leafety/repository/aires_repository.dart';
import 'package:leafety/repository/visits_repository.dart';
import 'package:rxdart/rxdart.dart';

class VisitBloc with Validators {
  final _degreesController = BehaviorSubject<String>();

  final _electroController = BehaviorSubject<String>();

  final _pHController = BehaviorSubject<String>();

  final _mLAbonoController = BehaviorSubject<String>();

  final _mLController = BehaviorSubject<String>();

  final _descriptionController = BehaviorSubject<String>();

  final _nameAbonoController = BehaviorSubject<String>();

  final _cutController = BehaviorSubject<bool>();

  final _gramController = BehaviorSubject<String>();

  final _cleanController = BehaviorSubject<bool>();

  final _temperatureController = BehaviorSubject<bool>();

  final _imageUpdateCtrl = BehaviorSubject<bool>();

  final _visitsController = BehaviorSubject<List<Visit>>();
  final AirRepository repository = AirRepository();

  final VisitRepository repositoryVisit = VisitRepository();

  final BehaviorSubject<VisitsResponse> _visitsUser =
      BehaviorSubject<VisitsResponse>();

  final BehaviorSubject<AiresResponse> _vist = BehaviorSubject<AiresResponse>();

  final BehaviorSubject<Visit> _visitSelect = BehaviorSubject<Visit>();

  BehaviorSubject<Visit> get visitSelect => _visitSelect;

  BehaviorSubject<AiresResponse> get vist => _vist;

  // Recuperar los datos del Stream
  Stream<String> get degreesStream =>
      _degreesController.stream.transform(validationGradosCRequired);
  Stream<String> get descriptionStream => _descriptionController.stream;

  Stream<String> get nameAbonoStream => _nameAbonoController.stream;

  Stream<bool> get cutStream => _cutController.stream;

  Stream<String> get phStream => _pHController.stream;

  Stream<String> get gramStream => _gramController.stream;

  Stream<String> get electroStream => _electroController.stream;

  Stream<String> get mlStream => _mLController.stream;

  Stream<String> get mlAbonoStream => _mLAbonoController.stream;
  BehaviorSubject<bool> get imageUpdate => _imageUpdateCtrl;

  getVisitsByUser(String uid) async {
    VisitsResponse response = await repositoryVisit.getVisits(uid);

    if (!_visitsUser.isClosed) _visitsUser.sink.add(response);
  }

  BehaviorSubject<VisitsResponse> get visitsUser => _visitsUser;

  Function(String) get changeDescription => _descriptionController.sink.add;
  Function(String) get changeDegrees => _degreesController.sink.add;

  Function(String) get changePh => _pHController.sink.add;

  Function(String) get changeElectro => _electroController.sink.add;

  Function(String) get changeMl => _mLController.sink.add;

  Function(String) get changeGram => _gramController.sink.add;

  Function(String) get changeMlAbono => _mLAbonoController.sink.add;
  Function(String) get changeNameAbono => _nameAbonoController.sink.add;

  // Obtener el último valor ingresado a los streams
  bool get cut => _cutController.value;

  String get ml => _mLController.value;
  String get mlAbono => _mLAbonoController.value;

  String get ph => _pHController.value;
  String get degrees => _degreesController.value;
  String get electro => _electroController.value;
  String get gram => _gramController.value;
  String get description => _descriptionController.value;
  String get nameAbono => _nameAbonoController.value;

  dispose() {
    _nameAbonoController?.close();
    _gramController?.close();
    _mLAbonoController?.close();
    _visitsUser?.close();
    _imageUpdateCtrl?.close();
    _vist?.close();
    _visitSelect?.close();
    _descriptionController.close();
    _degreesController?.close();
    _electroController?.close();
    _pHController?.close();
    _mLController?.close();
    _cutController?.close();
    _cleanController?.close();
    _temperatureController?.close();
    _visitsController?.close();

    //  _roomsController?.close();
  }

  disposeRoom() {
    // _roomSelect?.close();
  }

  disposeRooms() {
    _visitSelect?.close();
    _vist.close();
  }
}

final visitBloc = VisitBloc();
