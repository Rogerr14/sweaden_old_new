import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sweaden_old_new_version/shared/helpers/version_app.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';

class UserDataStorage {
  final storage = const FlutterSecureStorage();

  void activeBackgroundService(bool isActive) async {
    await storage.write(key: 'ActiveBackground', value: isActive.toString());
  }

  Future<bool> getActiveBackground() async {
    try {
      final isActive = await storage.read(key: 'ActiveBackground');
      if (isActive == 'false') {
        return false;
      } else {
        return true;
      }
    } catch (e) {}
    return true;
  }

  Future<AuthResponse?> getUserData() async {
    try {
      final versionAppStorage = await UserDataStorage().getVersionApp();
      if (VersionApp.numberVersionApp != versionAppStorage) return null;
      final data = await storage.read(key: 'userData');
      if (data != null) {
        AuthResponse response = authResponseFromJson(data);
        return response;
      }
    } catch (e) {}
    return null;
    // final data = await storage.read(key: 'userData');
    // if (data != null) {
    //   AuthResponse response = authResponseFromJson(data);
    //   return response;
    // }
    // return null;
  }

  void setUserData(AuthResponse userData) async {
    setVersionApp(VersionApp.numberVersionApp);
    final data = jsonEncode(userData);
    await storage.write(key: 'userData', value: data);
  }

  Future<bool> verifyToken() async {
    try {
      final userData = await getUserData();
      if (userData != null) {
        //?: comprobamos si el token ya ha expirado
        bool hasExpired = JwtDecoder.isExpired(userData.token);
        if (!hasExpired) {
          return true;
        }
        return false;
      }
    } catch (e) {}
    return false;
  }

  removeUserData() async {
    // await storage.deleteAll();
    await storage.delete(key: 'userData');
  }

  Future<String?> getVersionApp() async {
    final versionApp = await storage.read(key: 'versionApp');
    return versionApp;
  }

  void setVersionApp(String versionApp) async {
    await storage.write(key: 'versionApp', value: versionApp);
  }

  Future<String?> getIdInspection() async {
    final idInspection = await storage.read(key: 'idInspection');
    return idInspection;
  }

  void setIdInspection(String idInspection) async {
    await storage.write(key: 'idInspection', value: idInspection);
  }

  removeIdInspection() async {
    await storage.delete(key: 'idInspection');
  }

  Future<int> getTimeUpDistance() async {
    final time = await storage.read(key: 'timeUpDistance');
    if (time != null) {
      return int.parse(time);
    }
    return 0;
  }

  void setTimeUpDistance(int time) async {
    await storage.write(key: 'timeUpDistance', value: time.toString());
  }

  Future<int> getKmDistance() async {
    final time = await storage.read(key: 'KmDistance');
    if (time != null) {
      return int.parse(time);
    }
    return 0;
  }

  void setTKmDistance(int time) async {
    await storage.write(key: 'kmDistance', value: time.toString());
  }
}
