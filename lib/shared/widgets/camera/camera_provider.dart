import 'package:flutter/material.dart';

class CameraProvider extends ChangeNotifier {
  //? Validadciones de camara
  bool _isRecordind = false;
  bool get isRecording => _isRecordind;
  set isRecording(bool value) {
    _isRecordind = value;
    notifyListeners();
  }
}
