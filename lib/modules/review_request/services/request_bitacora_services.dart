import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/shared/models/bitacora_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';

class RequestBitacoraServices {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<List<ListBitacoraResponse>>> getlistBitacora(
      BuildContext context, int idSolicitud) async {
    try {
      final option = {"idSolicitud": idSolicitud};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/consultar_gestiones', option,
          showLoading: true);

      late List<ListBitacoraResponse> listBitacoraData;

      if (!response.error) {
        listBitacoraData =
            listBitacoraResponseFromJson(jsonEncode(response.data));
        return GeneralResponse(
          message: response.message,
          error: response.error,
          data: listBitacoraData,
        );
      }
      return GeneralResponse(message: response.message, error: response.error);
    } on SocketException catch (socket) {
      debugPrint('Error por conexion en get list_bitacora $socket');
      inspect(socket);
      return GeneralResponse(message: "Error de Conexión", error: true);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener las bitacoras', fatal: true);
      debugPrint("Error en get lista_bitacoras $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<ListBitacoraResponse>>> registryBitacora(
      BuildContext context, int idSolicitud, String detalle) async {
    try {
      final option = {
        "idSolicitud": idSolicitud,
        "detalle": detalle,
      };
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/registrar_gestiones',
          option,
          showLoading: true);

      //late List<ListBitacoraResponse> listBitacoraData;

      if (!response.error) {
        debugPrint('datos: ${response.data}');
        // listBitacoraData =
        //     listBitacoraResponseFromJson(jsonEncode(response.data));
        // debugPrint('bitacora data: $listBitacoraData');
        return GeneralResponse(
          message: response.message,
          error: response.error,
          // data: listBitacoraData,
        );
      }
      return GeneralResponse(message: response.message, error: response.error);
    } on SocketException catch (socket) {
      debugPrint('Error por conexion en get registryBitacora $socket');
      inspect(socket);
      return GeneralResponse(message: "Error de Conexión", error: true);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al registrar la bitacora', fatal: true);
      debugPrint("Error en registryBitacora $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }
}
