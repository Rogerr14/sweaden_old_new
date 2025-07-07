import 'dart:convert';
import 'dart:developer';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/models/profiles_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';
import 'package:provider/provider.dart';

class LoginServices {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<List<Profile>>> getProfiles(
      BuildContext context) async {
    try {
      final option = {"opcion": "LISTAR_LOGIN_WEB"};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/tipo_usuario', option,
          showLoading: true);

      List<Profile> data = [];
      if (!response.error) {
        data = profileFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, error: response.error, data: data);
    } catch (e, s) {
      // print("Error en get profiles $e");
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener los perfiles', fatal: true);
    }
    return GeneralResponse(message: "error", error: true);
  }

  Future login(BuildContext context, dynamic data) async {
    // inspect(data);
    try {
      GeneralResponse response = await interceptorHttp.request(context, 'POST',
          '${AppConfig.appEnv.serviceUrl}seguridad/login', data);
      final fp = Provider.of<FunctionalProvider>(context, listen: false);

      late AuthResponse userData;
      if (!response.error) {
        userData = authResponseFromJson(jsonEncode(response.data));
        UserDataStorage().setUserData(userData);
        // Helper.timeUpdateLocation = userData.tiempoActualizarUbicacion;
        // Helper.kmDistance = userData.kmRecorrido;
        // Helper.timeUpdateDistance = userData.tiempoActualizarDistancia;
        UserDataStorage().setTKmDistance(userData.kmRecorrido);
        UserDataStorage().setTimeUpDistance(userData.tiempoActualizarDistancia);
        Helper.startBackgroundService();
        fp.setSession(true);
        //fp.setLoggedIn(true);
        Navigator.pushReplacementNamed(context, 'home');
      }
    } catch (e, s) {
      debugPrint("Error en Login $e");
      inspect(e);
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al iniciar sesión', fatal: true);
    }
  }
}
