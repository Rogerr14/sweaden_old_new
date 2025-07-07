import 'dart:convert';
import 'dart:developer';
import 'dart:io';

// import 'package:awesome_select/awesome_select.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/client_response.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/deductible_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/models/invoice_response.dart';
import 'package:sweaden_old_new_version/shared/models/media_info_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/update_state_response.dart';
import 'package:sweaden_old_new_version/shared/models/vehicles_data_inspection.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';

class RequestReviewService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse<List<ListInspectionDataResponse>>> getListInspect(
      BuildContext? context) async {
    try {
      final option = {"opcion": "C_APP "};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/lista_inspecciones', option,
          showLoading: true);

      late List<ListInspectionDataResponse> listInspectionData;
      if (!response.error) {
        listInspectionData =
            listInspectionDataResponseFromJson(jsonEncode(response.data));
        return GeneralResponse(
            message: response.message,
            error: response.error,
            data: listInspectionData);
      }
      return GeneralResponse(
        message: response.message,
        error: response.error,
      );
    } on SocketException catch (socket) {
      debugPrint("Error por conexion en get lista_inspecciones $socket");
      inspect(socket);
      return GeneralResponse(error: true, message: "Error de Conexión");
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener las lista de inspecciones',
          fatal: true);
      debugPrint("Error en get lista_inspecciones $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<UpdateState>>> updateInspection(
    BuildContext context,
    Lista inpection,
  ) async {
    try {
      debugPrint('----------------------- entro');
      final option = {
        "opcion": "U",
        "dataSolicitud": inpection,
      };

      inspect(option);
      debugPrint('entro al metodo updateInspection');
      // log(json.encode(inpection.toJson()));
      // return GeneralResponse(error: true, message: 'no se ejecuto para verificar el json desde postman');
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/registrar_inspeccion',
          option,
          showLoading: true);

      //log(jsonEncode(option.toString()));

      late List<UpdateState> updateState;
      if (!response.error) {
        updateState = updateStateFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, error: response.error, data: updateState);
    } on SocketException catch (socket) {
      debugPrint("Error por conexion en updateInspection $socket");
      inspect(socket);
      return GeneralResponse(error: true, message: "Error de Conexión");
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al actualizar la inspección',
          fatal: true);
      inspect(e);
      debugPrint("Error en get update  inspection $e");

      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<UpdateState>>> updateStateInspection(
      BuildContext context,
      int idSolicitud,
      int idEstadoInspeccion,
      String? observacion) async {
    try {
      final option = {
        "idSolicitud": idSolicitud,
        "idEstadoInspeccion": idEstadoInspeccion,
        "observacion": observacion
      };

      debugPrint("parametros: $option");

      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/actualizar_estado_inspeccion',
          option,
          showLoading: true);

      late List<UpdateState> updateState;
      if (!response.error) {
        updateState = updateStateFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, error: response.error, data: updateState);
    } catch (e) {
      debugPrint("Error en get update state inspection $e");
      return GeneralResponse(error: true, message: 'Ocurrio un error, vuelva intentarlo.');
    }
  }

  Future<GeneralResponse<DataClientForm>> getDataClientForm(
      BuildContext context, String codBroker) async {
    try {
      final option = {
        "opcion": "LISTAR",
        "idEstadoCab": "2",
        "ramoElegir": "M",
        "codRamo": "*",
        "codBroker": codBroker,
      };
      // print('Cod BROKER: $codBroker');

      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/formulario_cliente', option,
          showLoading: true);

      DataClientForm? dataClientForm;
      if (!response.error) {
        dataClientForm = dataClientFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: dataClientForm);
    } catch (e) {
      inspect(e);
      debugPrint("Error en get data client form inspection $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<String>> getRescheduleConfirmation(
      BuildContext context, int idSolicitud) async {
    try {
      final option = {
        "idSolicitud": idSolicitud,
      };

      GeneralResponse response = await interceptorHttp.request(
          context,
          'POST',
          '${AppConfig.appEnv.serviceUrl}mantenimientos/reagendarSolicitud',
          option,
          showLoading: true);

      return GeneralResponse(
        message: response.message,
        error: response.error,
        data: response.data,
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al Reagendar la inspección',
          fatal: true);
      debugPrint("Error en Reagendar inspección $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<DatosCliente?>> getDataClient(
      BuildContext context, String identificacion) async {
    try {
      final option = {
        "identificacion": identificacion,
      };

      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_cliente', option,
          showLoading: true);
      Helper.logger.w('data: ${response.existData}');
      // print("Esto llega de respuesta en la solicitud de ruc ${response.data}");
      // print("Este es el body de la solicitud $option");

      DatosCliente? dataClient;
      if (!response.error && response.data != null) {
        dataClient = datosClienteFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: dataClient,
          existData: response.existData);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener la data del cliente',
          fatal: true);
      debugPrint("Error en get data client form inspection $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<MediaInfo>>> getMediaInfo(BuildContext context) async {
    try {
      final data = {"opcion": "TIPO_ARCHIVO"};
      GeneralResponse response = await interceptorHttp.request(context, 'POST', '${AppConfig.appEnv.serviceUrl}consultas/datos_archivos', data);
      late List<MediaInfo> mediaInfo;
      if (!response.error) {
        mediaInfo = mediaInfoFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(message: response.message, data: mediaInfo, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al obtener la información', fatal: true);
      return GeneralResponse(error: true, message: e.toString());
    }
  }

  Future<GeneralResponse<VehicleDataInspection>> getVehicleDataInspection(
      BuildContext context) async {
    try {
      final option = {};
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/formulario_inspeccion',
          option,
          showLoading: true);

      late VehicleDataInspection vehicleDataInspection;
      if (!response.error) {
          vehicleDataInspection = vehicleDataInspectionFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: vehicleDataInspection);
    } catch (e) {
      debugPrint("Error en get vehicle data inspection $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<VehicleModel>>> getVehicleModels(
      BuildContext context, String codMarca) async {
    try {
      final option = {"codMarca": codMarca};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_modelos', option,
          showLoading: true);

      late List<VehicleModel> vehicleModel;
      if (!response.error) {
        vehicleModel = vehicleModelFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, error: response.error, data: vehicleModel);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener los modelos de vehículos',
          fatal: true);
      debugPrint("Error en get vehicle models $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<VehicleClientData>> getVehicleClientData(
      BuildContext context, String identificacion) async {
    try {
      final option = {"identificacion": identificacion};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_vehiculo', option,
          showLoading: true);

      VehicleClientData? vehicleClientData;
      if (!response.error) {
        vehicleClientData = response.data != null
            ? vehicleClientDataFromJson(jsonEncode(response.data))
            : null;
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: vehicleClientData);
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason:
              'Se produjo un error al obtener los datos de cliente del vehículo',
          fatal: true);
      debugPrint("Error en get vehicle client data $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<AccesoriesVehicle>>> getAccesoriesVehicle(
      BuildContext context, String codRamo) async {
    try {
      final option = {"codRamo": codRamo};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_accesorios', option,
          showLoading: true);

      late List<AccesoriesVehicle> accesoriesVehicle;
      if (!response.error) {
        accesoriesVehicle =
            accesoriesVehicleFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: accesoriesVehicle);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener los accesorios de vehículos',
          fatal: true);
      debugPrint("Error en get vehicle accesories $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<InvoiceResponse>> getInvoiceData(
      BuildContext context, Map<String, dynamic> data) async {
    // print("DATA INVOICE");
    // inspect(data);
    try {
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/datos_borrador', data);
      late InvoiceResponse invoiceResponse;
      //  final datas = response.data;
      //  print(datas);
      if (!response.error) {
        invoiceResponse = invoiceResponseFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message,
          data: invoiceResponse,
          error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener los datos de la factura',
          fatal: true);
      debugPrint("Error en get borrador $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error en borrador');
    }
  }

  Future<GeneralResponse<List<Deductible>>> getDeductibles(
      BuildContext context, double sumAssured) async {
    try {
      final data = {"sumaAsegurada": sumAssured};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/deducibles', data,
          showLoading: false);
      late List<Deductible> deductibles;
      if (!response.error) {
        deductibles = deductibleFromJson(jsonEncode(response.data));
      }
      return GeneralResponse(
          message: response.message, data: deductibles, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener los deducibles', fatal: true);
      // print("Error en get deductibles $e");
      return GeneralResponse(error: true, message: 'Error en Deducible');
    }
  }

  Future<GeneralResponse<List<S2Choice<String>>>> getCuotas(
      BuildContext context, String idAgencia) async {
    try {
      final data = {"idAgencia": idAgencia};
      GeneralResponse response = await interceptorHttp.request(context, "POST",
          '${AppConfig.appEnv.serviceUrl}consultas/getCuotas', data);
      List<S2Choice<String>> cuotas = [];
      if (!response.error) {
        response.data
            .map((e) =>
                cuotas.add(S2Choice(value: e.toString(), title: e.toString())))
            .toList();
      }
      return GeneralResponse(
          message: response.message, data: cuotas, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener las cuotas', fatal: true);
      debugPrint('Fallo en get cuotas $e');
      return GeneralResponse(message: 'ERROR', error: true);
    }
  }

  Future<GeneralResponse<List<dynamic>>> getOpt(BuildContext context,
      String idSolicitud, String email, String celular) async {
    try {
      final option = {
        "idSolicitud": idSolicitud,
        "celular": celular,
        "email": email
      };
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/genera_codigo_firma',
          option,
          showLoading: false);

      return GeneralResponse(
          message: response.message, error: response.error, data: []);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al obtener el codigo de la firma',
          fatal: true);
      debugPrint("Error en get opt $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<List<dynamic>>> validOtp(
      BuildContext context, String idSolicitud, String codigo) async {
    try {
      final option = {"idSolicitud": idSolicitud, "codigo": codigo};
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/validar_codigo_firma',
          option,
          showLoading: true);

      return GeneralResponse(
          message: response.message, error: response.error, data: []);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al validar el codigo de las firmas',
          fatal: true);
      debugPrint("Error en validar otp $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }

  Future<GeneralResponse<String>> saveInspection(BuildContext? context, SaveInspection saveInspection, {bool? showLoading= true, bool? showAlertError = true}) async {
    //log(json.encode(saveInspection.toJson()));
     //return GeneralResponse(error: true, message: 'Error');

    try {
      GeneralResponse response = await interceptorHttp.request(
          context,
          "POST",
          '${AppConfig.appEnv.serviceUrl}mantenimientos/registrar_cliente',
          saveInspection,
          showLoading: showLoading!,
          showAlertError: showAlertError!
          );

      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: response.data);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s,
          reason: 'Se produjo un error al guardar la inspección', fatal: true);
      debugPrint("Error en guardar inspección $e");
      return GeneralResponse(error: true, message: 'Error');
    }
  }
}
