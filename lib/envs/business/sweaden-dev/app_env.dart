part of '../business.dart';

class AppEnvDEVSweaden implements generic.AppEnv {

  @override
  String protocol = "http";

  @override
  String appName = 'Sweaden Inspección';

  @override
  String environmentLabel = 'Desarrollo';

  @override
  //! DEV
  // String serviceUrl = '://186.5.109.203:37087/';
  //String serviceUrl = '://172.16.1.117:8039/';
  //String serviceUrl = '://instantsuredev.sweadenseguros.com/ApiMascApp/';
  String serviceUrl = '://172.16.1.117:7623/'; //LARAGON LOCAL
  //String serviceUrl = '://172.16.1.117:2206/'; //COMANDO PHP

  @override
  // ! DEV
  // String serviceUrlMedia = '://186.5.109.203:37086/';
  //String serviceUrlMedia = '://172.16.1.117:8040/';
  //String serviceUrlMedia = '://instantsuredev.sweadenseguros.com/ApiWeb/';
  String serviceUrlMedia = '://172.16.1.117:7622/'; //LARAGON LOCAL
  //String serviceUrlMedia = '://172.16.1.117:2205/'; //COMANDO PHP

  @override
  String environmentName = 'DEV';

  @override
  List<Task> businessTask = [
    Task(
        imagePath: 'assets/nueva-solicitud.png',
        titleTask: 'Ingresar solicitud de inspección',
        navigateTo: 'new-request'),
    Task(
        imagePath: 'assets/revision-solicitud.png',
        titleTask: 'Revisar solicitudes de inspección',
        navigateTo: 'review-request'),
    Task(
        imagePath: 'assets/configuracion.png',
        titleTask: 'Configuraciones offline',
        navigateTo: 'offline-configuration'),
    Task(
        imagePath: 'assets/upload-request.png',
        titleTask: 'Cargar Inspecciones Finalizadas Offline',
        navigateTo: 'cargar-inspecciones'),
  ];

  @override
  bool gallerysImageEnabled = false;

  @override
  bool gallerysVideoEnabled = false;

  @override
  String apiKeyGooglePlaces = 'AIzaSyDaZscHjdB6Y03nxuLkeBUX9PDCPIyW5Og';

  @override
  FirebaseOptions firebaseOptionsAndroid = const FirebaseOptions(
    apiKey: "AIzaSyAVmQXAEMTuHbwtBx_MvWBHBubv7N0BrHE",
    appId: "1:364589936912:android:04e8b236d581a9447e3595",
    messagingSenderId: "364589936912",
    projectId: "sweaden-7806e",
  );

  @override
  FirebaseOptions firebaseOptionsIos = const FirebaseOptions(
    apiKey: "AIzaSyAVmQXAEMTuHbwtBx_MvWBHBubv7N0BrHE",
    appId: "1:364589936912:ios:04e8b236d581a9447e3595",
    messagingSenderId: "364589936912",
    projectId: "sweaden-7806e",
  );

  @override
  generic.Camera typeCamera = generic.Camera.widget;
}
