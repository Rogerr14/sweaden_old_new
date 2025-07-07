import 'dart:io';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/home/models/location_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';

class UserLocationService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse> updateLocation( LocationResponse location) async {
    try {
      GeneralResponse response = await interceptorHttp.request(null, "POST", '${AppConfig.appEnv.serviceUrl}mantenimientos/actualizar_ubicacion', location, showLoading: false, showAlertError: false);
      if (!response.error) {
        return GeneralResponse(message: response.message, error: response.error);
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }

    } on SocketException catch (socket) {
      debugPrint('Error por conexion en updateLocation $socket');
      return GeneralResponse(message: "Error de Conexión", error: true);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,  reason: 'Se produjo un error al registrar la ubicacion del usuario', fatal: true);
      debugPrint("Error en updateLocation: $e");
      return GeneralResponse(error: true, message: e.toString());
    }
  }
}
