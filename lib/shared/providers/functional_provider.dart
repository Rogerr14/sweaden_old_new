import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';

class FunctionalProvider extends ChangeNotifier {
  Widget _alertContent = const SizedBox();
  Widget get alertContent => _alertContent;
  bool reverse = false;
  bool offline = false;
  bool locationPermission = false;
  bool loadingInspection = false;
  bool session = false;
  bool activeBackground = false;

  String? idInspeccion;
  // InspectionStatus inspectionStatus = InspectionStatus.upload;

  // setInspectionStatus(InspectionStatus value){
  //   inspectionStatus = value;
  //   notifyListeners();
  // }

  setActiveBackground(bool isActive) {
    activeBackground = isActive;
    notifyListeners();
  }

  bool getActiveBackground() {
    return activeBackground;
  }

  setIdInspection(String? value) {
    idInspeccion = value;
    Helper.idInspection = value;
    notifyListeners();
  }

  String? getIdInspection() {
    return idInspeccion;
  }

  setSession(bool value) {
    session = value;
    Helper.session = value;
    notifyListeners();
  }

  setLoadingInspection(bool value) async {
    loadingInspection = value;
    notifyListeners();
  }

  setOffline(bool value) {
    offline = value;

    notifyListeners();
  }

  bool getOffline() {
    return offline;
  }

  set setReverse(bool valor) {
    reverse = valor;
    notifyListeners();
  }

  get valReverse {
    return reverse;
  }

  set alertContent(Widget content) {
    _alertContent = content;
    notifyListeners();
  }

  //? Paginas normales
  AnimationController? alertController;
  AnimationController? alertControllerContent;
  //? Pagina GoogleMap
  AnimationController? alertControllerGMap;
  AnimationController? alertControllerContentGmap;
  //? Notificaciones
  AnimationController? notificationController;
  AnimationController? notificationControllerCatalogue;

  showAlert({required Widget content, String? summoner}) {
    print('showAlert called with summoner: $summoner');
    alertContent = content;
  }

  animationForWard(String summoner) {
    switch (summoner) {
      case 'google-map':
        alertControllerGMap!.forward();
        alertControllerContentGmap!.forward();
        break;
      case 'normal':
        alertController!.forward();
        alertControllerContent!.forward();
        break;
      default:
        alertController!.forward();
        alertControllerContent!.forward();
    }
  }

  showNotification() {
    notificationController!.forward();
  }

  dismissNotification() {
    notificationController!.reverse();
  }

  showNotificationCatalogue() {
    notificationControllerCatalogue!.forward();
  }

  dismissNotificationCatalogue() {
    notificationControllerCatalogue!.reverse();
  }

  // void disposeControllerNotificationCatalogue() {
  //   notificationControllerCatalogue?.dispose();
  // }

  animationReverse(String summoner) {
    switch (summoner) {
      case 'google-map':
        alertControllerGMap!.reverse();
        alertControllerContentGmap!.reverse();
        break;
      case 'normal':
        alertController!.reverse();
        alertControllerContent!.reverse();
        break;
      default:
        alertController!.reverse();
        alertControllerContent!.reverse();
    }
  }

  dismissAlert({String? summoner}) {
    print('dismissAlert called with summoner: $summoner');
    alertContent = const SizedBox();
  }

  // dismissAlert({String? summoner}) {
  //   final type = summoner ?? 'normal';
  //   animationReverse(type);
  //   alertContent = const SizedBox();
  // }

  //? Ubicacion selecciona en el mapa
  LatLng? _selectedCoords;
  LatLng? get selectedCoords => _selectedCoords;
  set selectedCoords(LatLng? coord) {
    _selectedCoords = coord;
    notifyListeners();
  }

  bool _buttonMapEnable = true;
  bool get buttonMapEnable => _buttonMapEnable;
  set buttonMapEnable(bool value) {
    _buttonMapEnable = value;
    notifyListeners();
  }
}
