import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/services/media_service.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/text_rich_widget.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/models/params.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:provider/provider.dart';

class HelperRequestOffline {
  static const String idRequestHeadBoard = '9999';

  static const int notLoaded = 0;
  static const int loaded = 1;
  static const int error = 2;

  static Future<String> getDataInspectionStorage(
      {required String idSoliciutd}) async {
    Helper.logger.w('idSoliciutd: $idSoliciutd');
    final dataInspection =
        await InspectionStorage().getDataInspection(idSoliciutd);
    // log(jsonEncode(dataInspection));

    if (dataInspection != null) {
      log('entro hsy data');
      return dataInspection.identificacion!;
    }
    return '';
  }

  static Future<bool> loadMediaDataService(
      {required FunctionalProvider? fp,
      required BuildContext? context,
      required ParamsLoadMedia paramsLoadMedia}) async {
    try {
      //return true;
      if (fp != null) {
        fp.setLoadingInspection(true);
      }
      final dataMedia = await MediaDataStorage()
          .getMediaData(paramsLoadMedia.idSolicitudTemp);

      List<bool> uploaded = [];
      log("media data elements: ${dataMedia?.length ?? 00}");
      if (dataMedia != null && dataMedia.isNotEmpty) {
        final identification = await getDataInspectionStorage(
            idSoliciutd: paramsLoadMedia.idSolicitudTemp.toString());
        Helper.logger.w('identification: $identification');
        for (var item in dataMedia) {
          // log("${item.idArchiveType} - ${item.path} - ${item.status}");
          if (item.status != 'UPLOADED' && item.status != 'NO_MEDIA') {
            var image = Uint8List(0);
            if (item.type == 'image') {
              image = Uint8List.fromList(await File(item.path!).readAsBytes());
            }
            final response = await MediaService().uploadMedia(
              context: context,
              idRequest: paramsLoadMedia.idRequestReal,
              idArchiveType: item.idArchiveType,
              identification: identification,
              mediaType: item.type == 'image'
                  ? MediaType('image', 'jpg')
                  : MediaType('video', 'mp4'),
              mediaPhoto: (item.type == 'image') ? image : null,
              mediaVideo: (item.type == 'video') ? File(item.path!) : null,
              showAlertError: false,
              showLoading: true,
            );

            if (!response.error) {
              uploaded.add(true);
            } else {
              log(response.message);
              uploaded.add(false);
            }
          }
        }
        if (fp != null) {
          fp.setLoadingInspection(false);
        }
        //NO OLVIDAR DESCOMENTAR
        if (uploaded.length ==
            dataMedia
                .where((e) => e.status != 'UPLOADED' && e.status != 'NO_MEDIA')
                .toList()
                .length) {
          await MediaDataStorage()
              .removeMediaData(paramsLoadMedia.idSolicitudTemp);
          return true;
        } else {
          return false;
        }
      } else {
        if (fp != null) {
          fp.setLoadingInspection(false);
        }
        return true;
      }
    } catch (e) {
      Helper.logger.e('error media service: $e');
      if (fp != null) {
        fp.setLoadingInspection(false);
      }
      return false;
    }
  }

  static Future<GeneralResponse> loadInformationRequestService(
      {required ParamsLoadRequest paramsLoadRequest,
      required BuildContext? context}) async {
    final continueInspection = await InspectionStorage().getDataInspection(
        paramsLoadRequest.idSolicitudTemp.toString()); // ID TEMPPORAL

    log("entra a cargar la inspeccion, existe: ${continueInspection != null}");
    if (continueInspection != null) {
    
      // log(jsonEncode(continueInspection));
      final SaveInspection saveInspection = await getDataSave(
          continueInspection: continueInspection,
          inspectionParams: paramsLoadRequest.paramsRequest);

      saveInspection.idSolicitud =
          paramsLoadRequest.idRequestReal.toString(); //// ID REAL - RETORNA

      final response = await finishedInspecction(
          errorMediaLoad: paramsLoadRequest.errorMediaLoad,
          saveInspection: saveInspection,
          continueInspection: continueInspection,
          context: context,
          idRequest: paramsLoadRequest.idSolicitudTemp /* ID TEMPPORAL*/,
          showLoading: paramsLoadRequest.showLoading,
          showAlertError: false);
      // Helper.logger.e('response: ${jsonEncode(response)}');
      return response;
      //return response.error;
    } else {
     
      log("No existe ");
      return GeneralResponse(message: 'Ocurrio un error', error: true);
    }
  }

  static Future<SaveInspection> getDataSave(
      {required ContinueInspection continueInspection,
      required ParamsRequest inspectionParams /*Lista inspection*/}) async {
    final List<Tapiceria> tapiceria = [];

    tapiceria.add(Tapiceria(
        descripcion: 'Retapizado',
        marcado: continueInspection.retapizado ?? false));
    tapiceria.add(Tapiceria(
        descripcion: 'Forros', marcado: continueInspection.forros ?? false));
    tapiceria.add(Tapiceria(
        descripcion: 'Vidrios', marcado: continueInspection.vidrios ?? false));

    List<CobOriginale> cobOriginales = [];
    List<CobOriginale> cobAdicionales = [];

    if (continueInspection.accessoriesVehicles != null) {
      final lists = Helper.sortCoverages(
          accessoriesVehicles: continueInspection.accessoriesVehicles!,
          listName: "all");
      cobAdicionales = lists[0];
      cobOriginales = lists[1];
    }

    final AuthResponse? usuario = await UserDataStorage().getUserData();

    return SaveInspection(
        tokenFirma: continueInspection.tokenFirma ?? '', //OPT
        deducible: continueInspection.deducible ?? '',
        tipoFlujo: inspectionParams.idTipoFlujo.toString(),
        idSolicitud: inspectionParams.idSolicitud.toString(),
        idProceso: inspectionParams.idProceso.toString(),
        identificacion: continueInspection.identificacion ?? '',
        tipoIdentificacion: continueInspection.tipoIdentificacion ?? '',
        apellidos: continueInspection.apellidos ?? '',
        nombres: continueInspection.nombres ?? '',
        razonSocial: continueInspection.razonSocial ?? '',
        tratamiento: continueInspection.generoValue ?? '',
        codProvincia: continueInspection.provinciaValue ?? '',
        codLocalidad: continueInspection.localidadValue ?? '',
        domicilio: continueInspection.direccion ?? '',
        fechaNacimiento: continueInspection.fechaNacimiento ?? '',
        idEstadoCivil: continueInspection.estadoCivilValue ?? '',
        idSector: '1', // REVISAR DE DONDE VIENE
        codPais: continueInspection.paisValue ?? '',
        codBroker: inspectionParams.idBroker,
        email: continueInspection.email ?? '',
        codActividadEconomica: continueInspection.actividadEconomicaValue ?? '',
        codOcupacion: '0067', // REVISAR DE DONDE VIENE
        idPpe: continueInspection.personaPublicaValue ?? '',
        usuario: usuario?.informacion.usuario ?? '',
        //usuario: usuario?.informacion.nombre ?? '',
        telefono: continueInspection.telefono ?? '',
        celular: continueInspection.celular ?? '',
        valorIngresos: continueInspection.incomes ?? '',
        valorIngresosSecundarios: continueInspection.secondaryIncomes ?? '',
        valorActivos: continueInspection.actives ?? '',
        valorPasivos: continueInspection.pasives ?? '',
        codRamo: continueInspection.codRamo ?? '',
        codEjecutivoCuenta: inspectionParams.codEjecutivo,
        codAgencia: inspectionParams.idAgencia,
        fechaInicioVigencia: continueInspection.fechaInicioVigencia ?? '',
        fechaFinVigencia: continueInspection.fechaFinVigencia ?? '',
        valorSumaAsegurada: continueInspection.valorSumaAsegurada ?? '',
        placa: continueInspection.placa ?? '',
        codMarca: continueInspection.codMarca ?? '',
        nombreMarca: continueInspection.nombreMarca ?? '',
        codModelo: continueInspection.codModelo ?? '',
        nombreModelo: continueInspection.nombreModelo ?? '',
        codPaisO: continueInspection.codPaisO ?? '',
        anio: continueInspection.anio ?? '',
        chasis: continueInspection.chasis ?? '',
        motor: continueInspection.motor ?? '',
        codCarroceria: continueInspection.codCarroceria ?? '',
        color: continueInspection.color ?? '',
        codUso: continueInspection.codUso ?? '',
        codProducto: continueInspection.codProducto ?? '',
        producto: continueInspection.producto ?? '',
        capacidadPasajeros: continueInspection.capacidadPasajeros ?? '',
        codFormaPago: continueInspection.codFormaPago ?? '',
        cuotas: continueInspection.cuotas ?? '',
        idMedioCobro: continueInspection.idMedioCobro ?? '',
        emitirPoliza: continueInspection.emitPolize ?? false,
        observacionEmision: continueInspection.observacionEmision ?? '',
        enRevision: continueInspection.enRevision ?? false,
        rechazarRevision: continueInspection.rechazado ?? false,
        codInspector: usuario?.informacion.codigo ?? '',
        numPoliza: inspectionParams.polizaMadre ?? '',
        cobAdicionales: cobAdicionales,
        cantidadArchivosTratadoEnviar:
            continueInspection.cantidadArchivosTratadoEnviar ?? '0',
        cobOriginales: cobOriginales,
        hobby: '',
        mascotaPreferida: '',
        equipoFavorito: '',
        tapiceria: tapiceria,
        entregaForm: continueInspection.entregaForm ?? false,
        km: continueInspection.km ?? '',
        observacion: continueInspection.observacion ?? '',
        valorSugerido: continueInspection.valorSugerido ?? '',
        factura: continueInspection.factura ?? '',
        base64ReconocimientoF: continueInspection.base64Image ?? '',
        fechaInspeccionReal: continueInspection.fechaInspeccionReal ?? '',
        base64SignatureClientImage:
            continueInspection.base64SignatureClientImage ?? '',
        finishedInpectionOffline:
            continueInspection.finishedInpectionOffline ?? false,
        idArchiveType: '',
        idRequest: '',
        typeMedia: '');
  }

  static Future<GeneralResponse<String>> finishedInspecction(
      {bool? errorMediaLoad = false,
      bool? showAlertError = true,
      bool? showLoading = true,
      required SaveInspection saveInspection,
      required ContinueInspection continueInspection,
      required BuildContext? context,
      required int idRequest}) async {
    // if(context != null){

    FunctionalProvider? fp;
    if (context != null) {
      fp = Provider.of<FunctionalProvider>(context, listen: false);
      fp.setLoadingInspection(true);
    }
    // }
    final response = await RequestReviewService().saveInspection(
        context, saveInspection,
        showLoading: showLoading, showAlertError: showAlertError);

    if (!response.error) {
      //DESCOMENTAR LO DE ABAJO ES IMPORTENTEE
      if (continueInspection.cantidadArchivosTratadoEnviar == "0") {
        await MediaDataStorage().removeMediaData(idRequest);
      }

      //DESCOMENTAR ES ALGO IMPORTENTE OK
      if (!errorMediaLoad!) {
        Helper.logger.e('NO HUBO ERROR AL SUBIR MULTIMEDIA, ELIMINA...');
        await InspectionStorage().removeDataInspection(idRequest.toString());
      }
      // if(context != null){
      if (fp != null) {
        fp.setLoadingInspection(false);
      }
      // }
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: response.data);
    } else {
      if (fp != null) {
        fp.setLoadingInspection(false);
      }
      return GeneralResponse(
          message: response.message, error: response.error, data: null);
    }
  }

  // static int currentStep({required Request request}){
  //   if(request.solicitudRegistrada! && !request.multimediaRegistrada!){
  //     Helper.logger.w('1');
  //     return 0;
  //   }else if(request.solicitudRegistrada! && request.multimediaRegistrada! && !request.inspeccionRegistrada!){
  //     Helper.logger.w('2');
  //     return 1;
  //   }else if(request.solicitudRegistrada! && request.multimediaRegistrada! && request.inspeccionRegistrada!){
  //     Helper.logger.w('3');
  //     return 2;
  //   }else{
  //     Helper.logger.w('4');
  //     return 0;
  //   }
  // }

  static String nameButtonUploadRequest({required Request request}) {
    if (request.statusSolicitudRegistrada == error ||
        request.statusMultimediaRegistrada == error ||
        request.statusInspeccionRegistrada == error) {
      return 'Reintentar';
    } else {
      return 'Cargar Inspección';
    }
  }

  static int currentStep({required Request request}) {
    if (request.statusSolicitudRegistrada == 0 &&
        request.statusMultimediaRegistrada == 0 &&
        request.statusInspeccionRegistrada == 0) {
      //Helper.logger.w('1');
      return 0;
    } else if (request.statusSolicitudRegistrada == 1 &&
        request.statusMultimediaRegistrada == 0 &&
        request.statusInspeccionRegistrada == 0) {
      //Helper.logger.w('2');
      return 1;
    } else if (request.statusSolicitudRegistrada == 1 &&
        request.statusMultimediaRegistrada == 1 &&
        request.statusInspeccionRegistrada == 0) {
      // Helper.logger.w('3');
      return 2;
    } else if (request.statusSolicitudRegistrada == 1 &&
        request.statusMultimediaRegistrada == 1 &&
        request.statusInspeccionRegistrada == 1) {
      // Helper.logger.w('4');
      return 2;
    } else if (request.statusSolicitudRegistrada == 1 &&
        request.statusMultimediaRegistrada == 2 &&
        request.statusInspeccionRegistrada == 1) {
      //Helper.logger.w('4');
      return 1;
    } else {
      //Helper.logger.w('5');
      return 0;
    }
  }

  static StepState stepState({required int status}) {
    switch (status) {
      case 0:
        return StepState.indexed;
      case 1:
        return StepState.complete;
      case 2:
        return StepState.error;
      default:
        return StepState.indexed;
    }
  }

  static bool isStepActive({required int status}) {
    switch (status) {
      case 0:
        return false;
      case 1:
        return true;
      case 2:
        return true;
      default:
        return false;
    }
  }

  static TextStyle styles({Color? color}) {
    return TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 15,
        color: color ?? Colors.black);
  }

  static Widget statusRequest({required Request request}) {
    if (request.statusSolicitudRegistrada == HelperRequestOffline.loaded &&
        request.statusMultimediaRegistrada == HelperRequestOffline.loaded &&
        request.statusInspeccionRegistrada == HelperRequestOffline.loaded) {
      return const TextRichWidget(
          title: 'Estado',
          subtitle: 'Finalizada',
          colorSubtitle: Color(0xff198754),
          fontWeight: FontWeight.w500);
    } else {
      return const TextRichWidget(
          title: 'Estado',
          subtitle: 'Pendiente',
          colorSubtitle: Color(0xffffc107),
          fontWeight: FontWeight.w500);
    }
  }

  static Widget clientRequest({required Request request}) {
    if (request.dataSolicitud!.nombres != null) {
      return Text(
          '${request.dataSolicitud!.nombres!.toUpperCase()} ${request.dataSolicitud!.apellidos!.toUpperCase()}',
          style: TextStyle(
              color: AppConfig.appThemeConfig.secondaryColor,
              fontWeight: FontWeight.bold));
    } else if (request.dataSolicitud!.razonSocial != null) {
      return Text(request.dataSolicitud!.razonSocial!.toUpperCase(),
          style: TextStyle(
              color: AppConfig.appThemeConfig.secondaryColor,
              fontWeight: FontWeight.bold));
    } else {
      return const SizedBox();
    }
  }

  static Widget messageRequest({required Request request}) {
    switch (request.statusInspeccionRegistrada) {
      case 0:
        return const SizedBox();
      case 1:
        if (request.messageInspectionRegistrada != '') {
          return TextRichWidget(
              title: 'Mensaje',
              subtitle: request.messageInspectionRegistrada ?? '',
              colorSubtitle: Colors.black);
        } else {
          return const SizedBox();
        }
      case 2:
        return Text(
            request.mensageErrorRegistrarInspection ?? 'Ocurrio un error',
            style: HelperRequestOffline.styles(color: Colors.red));
      default:
        return const SizedBox();
    }
  }
}
