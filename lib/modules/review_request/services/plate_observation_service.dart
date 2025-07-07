import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/models/plate_observation_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';

class PlateObservationService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<List<PlateObservationsResponse>>> getObservationsPlate(BuildContext context, {required String plate}) async {
    try {

      final body = {"placa": plate};

      GeneralResponse response = await interceptorHttp.request(context,"POST", '${AppConfig.appEnv.serviceUrl}consultas/observacionesPlaca', body);

      late List<PlateObservationsResponse> plateObservationsResponse;

      if (!response.error) {
        plateObservationsResponse = plateObservationsResponseFromJson(jsonEncode(response.data));
        
      }

      return GeneralResponse(message: response.message, error: response.error, data: plateObservationsResponse);

      
    } on SocketException catch (socket) {
      inspect(socket);
      return GeneralResponse(message: "Error de Conexión", error: true);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al obtener las observaciones por placa', fatal: true);
      debugPrint("Error en registryBitacora $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }
}
