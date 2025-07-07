import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/deductible_response.dart';
import 'package:sweaden_old_new_version/shared/models/executive_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/policies_response.dart';
import 'package:sweaden_old_new_version/shared/models/product_response.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';

class NewRequestService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<InspectionDataResponse>> getInspectionData(
      BuildContext context) async {
    try {
      final option = {
        "opcion": "LISTAR",
        "idEstadoCab": "2",
        "ramoElegir": "M",
        "id_broker": null
      };
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_inspeccion', option,
          showLoading: true);

      InspectionDataResponse? inspectionData;
      if (!response.error) {
        inspectionData =
            inspectionDataResponseFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: inspectionData);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
        reason: 'Se produjo un error al obtener los datos de inspección', fatal: true);
      // print("Error en get profiles $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<Product>>> getProducts(
      BuildContext context, String idBroker, String branchCode) async {
    try {
      final data = {"codBroker": idBroker, "codRamo": branchCode};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/lista_productos', data);

      List<Product>? products;
      if (!response.error) {
        
        products = productFromJson(jsonEncode(response.data));
        //products = response.data == [] ? [] : productFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, data: products, error: response.error);
    } catch (e, s) {
      Helper.logger.e('error $e');
      FirebaseCrashlytics.instance.recordError(e, s,
        reason: 'Se produjo un error al obtener los datos del producto', fatal: true);
      // print("Error en get productos $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<Executive>>> getExecutives(
      BuildContext context, String idBroker, String idAgency) async {
    try {
      final data = {"idBroker": idBroker, "idAgencia": idAgency};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/ejecutivos', data);
      late List<Executive> executives;
      if (!response.error) {
        executives = executiveFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, data: executives, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
        reason: 'Se produjo un error al obtener los datos de ejecutivos', fatal: true);
      // print("Error en get executives $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<Deductible>>> getDeductibles(
      BuildContext context, double sumAssured) async {
    try {
      final data = {"sumaAsegurada": sumAssured};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/deducibles', data);
      late List<Deductible> deductibles;
      if (!response.error) {
        deductibles = deductibleFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, data: deductibles, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
        reason: 'Se produjo un error al obtener los datos deducibles', fatal: true);
      // print("Error en get deductibles $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<Policy>>> getPolicies(
      BuildContext context, String idBorker, String branchCode) async {
    try {
      final data = {"codBroker": idBorker, "codRamo": branchCode};
      GeneralResponse response = await interceptorHttp.request(context, 'POST',
          '${AppConfig.appEnv.serviceUrl}consultas/polizas_madres', data);
      List<Policy> policies = [];
      if (!response.error) {
        policies = policyFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, data: policies, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
        reason: 'Se produjo un error al obtener las polizas', fatal: true);
      debugPrint('Error en Polizas $e');
      return GeneralResponse(error: true, message: 'Error');
      
    }
  }

  Future<GeneralResponse> registerRequest(BuildContext? context, Request request,{bool? viewAlertError = true}) async {
      //debugPrint('entro al metodo registerRequest');
      //log(json.encode(request.toJson()));
      //return GeneralResponse(error: true, message: 'no se ejecuto para verificar el json desde postman');
    try {
      GeneralResponse response = await interceptorHttp.request(context, 'POST','${AppConfig.appEnv.serviceUrl}mantenimientos/registrar_inspeccion', request, showAlertError: viewAlertError!);
      
      if(!response.error){
        return GeneralResponse(message: response.message, error: response.error, data: response.data);
      }else{
        return GeneralResponse(message: response.message, error: response.error);
      }
      
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al registrar la solicitud', fatal: true);
      return GeneralResponse(error: true, message: 'Error');
    }
  }
}
