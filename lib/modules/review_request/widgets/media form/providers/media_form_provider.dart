import 'package:flutter/material.dart';

class MediaFormProvider extends ChangeNotifier {
  //? Se usa para detectar en MediaForm
  //? Si ya tomo o envio (fotos/videos)
  //? requeridos
  bool _formCompleted = false;
  bool get formCompleted => _formCompleted;
  set formCompleted(bool value) {
    _formCompleted = value;
    notifyListeners();
  }
}
