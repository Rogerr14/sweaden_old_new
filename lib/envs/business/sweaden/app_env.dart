part of '../business.dart';

class AppEnvSweaden implements generic.AppEnv {
  @override
  String appName = 'Sweaden Inspección';

  @override
  String environmentLabel = 'PRODUCCIÓN';

  @override
  String protocol = "https";

 @override
  // ? PROD
  String serviceUrl = '://appmovil.sweadenseguros.com/ApiMascApp/';
   //ANTIGUO
 // String serviceUrl = '://appmovil.sweadenseguros.com:37082/';
  //! DEV
  // String serviceUrl = 'http://186.5.109.203:37087/';

  @override
  // ? PROD
  String serviceUrlMedia = '://appmovil.sweadenseguros.com/ApiWeb/';
  //ANTIGUO
  //String serviceUrlMedia = '://appmovil.sweadenseguros.com:37081/';
  // ! DEV
  // String serviceUrlMedia = 'http://186.5.109.203:37086/';
  @override
  String environmentName = 'PROD';
  // String environmentName = 'DEV';

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
