import 'package:firebase_core/firebase_core.dart';
import 'package:sweaden_old_new_version/shared/models/task_model.dart';

class AppEnv {

  String appName = "";

  String environmentLabel = "";

  String protocol = "";

  String serviceUrl = "";

  String serviceUrlMedia = "";

  String environmentName = "";

  String apiKeyGooglePlaces = "";

  List<Task> businessTask = [];

  bool gallerysImageEnabled = false;

  bool gallerysVideoEnabled = false;

  Camera typeCamera = Camera.widget;

  FirebaseOptions firebaseOptionsAndroid = const FirebaseOptions(
    apiKey: "",
    appId: "",
    messagingSenderId: "",
    projectId: "",
  );

  FirebaseOptions firebaseOptionsIos = const FirebaseOptions(
    apiKey: "",
    appId: "",
    messagingSenderId: "",
    projectId: "",
  );

}
  enum Camera{ widget, native}
