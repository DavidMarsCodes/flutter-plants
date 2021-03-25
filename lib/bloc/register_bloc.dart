import 'dart:async';
import 'package:chat/bloc/validators.dart';
import 'package:rxdart/rxdart.dart';

class RegisterBloc with Validators {
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _usernameController = BehaviorSubject<String>();
  final _nameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();

  // Recuperar los datos del Stream
  Stream<String> get emailStream =>
      _emailController.stream.transform(validationOk);
  Stream<String> get passwordStream =>
      _passwordController.stream.transform(validarPassword);

  Stream<String> get usernameSteam =>
      _usernameController.stream.transform(validationNameRequired);

  Stream<String> get nameStream => _nameController.stream;
  Stream<String> get lastNameStream => _lastNameController.stream;

  Stream<bool> get formValidStream => Rx.combineLatest3(
      emailStream, usernameSteam, passwordStream, (e, b, c) => true);

  // Insertar valores al Stream
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changeUsername => _usernameController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeName => _nameController.sink.add;
  Function(String) get changeLastName => _lastNameController.sink.add;

  // Obtener el último valor ingresado a los streams
  String get email => _emailController.value;
  String get password => _passwordController.value;
  String get username => _usernameController.value;
  String get name => _nameController.value;
  String get lastName => _lastNameController.value;

  dispose() {
    _emailController?.close();
    _passwordController?.close();
    _usernameController?.close();
    _nameController?.close();
    _lastNameController?.close();
  }
}
