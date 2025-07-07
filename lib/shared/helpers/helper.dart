import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/models/catalogue_offline_general_response.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_storage.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/vehicles_data_inspection.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:uuid/uuid.dart';

import '../../modules/home/models/location_response.dart';
import '../../modules/home/pages/home_page.dart';
import '../../modules/home/service/user_location_service.dart';
import '../../modules/new_request/pages/new_request.dart';
import '../../modules/review_request/pages/request_review.dart';
import '../../modules/review_request/widgets/media form/models/media_response.dart';
import '../../modules/review_request/widgets/media form/services/media_service.dart';
import '../../modules/upload_inspections/helper/request_offline.dart';
import '../models/params.dart';
import '../models/request_model.dart';
import '../services/ceck_connection_service.dart';
import 'package:http_parser/http_parser.dart';

enum InspectionStatus { upload, loading, success, error }

enum InspectionCatalogue {
  catalogueRegisterRequest,
  cataloguePersonalInformation,
  catalogueVehicleData,
  catalogueVehicleModels,
  catalogueVehicleAccesories,
  catalogueFileType,
  catalogueExecutives
}

enum InspectionCatalogueDate {
  cataloguePersonalInformationDate,
  catalogueVehicleDataDate,
  catalogueVehicleModelsDate,
  catalogueVehicleAccesoriesDate,
  catalogueFileTypeDate
}

class Helper {
  static Route navigationFadeIn(
      BuildContext context, Widget page, int? milliseconds) {
    milliseconds ??= 800;

    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: milliseconds),
      pageBuilder: (_, animation, __) => FadeTransition(
        opacity: animation,
        child: page,
      ),
    );
  }

  //? Quita el teclado
  static dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<bool> tokenValidityCheck() async {
    //? LLamamos al storage para ver la fecha de caducidad y el parametro permitido
    final userData = await UserDataStorage().getUserData();
    if (userData != null) {
      if (userData.expiraToken != null) {
        final currentDate = DateTime.now();
        final dateTokenExpire = userData.expiraToken;
        Duration diference = dateTokenExpire!.difference(currentDate);
        //  print("Current Date: $currentDate");
        //  print("Date Expire token: $dateTokenExpire");
        //  print("Diference: ${diference.inMinutes}");
        if (diference.inMinutes > userData.anticipacionExpiraToken!) {
          return true;
        }
      }
    }
    return false;
  }

  // setNull() async {
  //   final userData = await  UserDataStorage().getUserData();
  //   userData!.anticipacionExpiraToken = null;
  //   userData.expiraToken = null;
  //   UserDataStorage().setUserData(userData);
  //   print("LISTOOOOO");
  // }

  //? TIPOS DE IDENTIFICACION
  identificationValidator(String ruc, String type) {
    switch (type) {
      case 'ci':
        return _ciValidator(ruc);
      case 'passport':
        return _passportValidator(ruc);
      case 'ruc':
        return _rucValidator(ruc);
      default:
        return false;
    }
  }

  bool _ciValidator(String cedula) {
    try {
      if (cedula.length == 10) {
        //Obtenemos el digito de la region que sonlos dos primeros digitos
        final digitoRegion = int.parse(cedula.substring(0, 2));

        //Pregunto si la region existe ecuador se divide en 24 regiones
        if (digitoRegion >= 1 && digitoRegion <= 24) {
          // Extraigo el ultimo digito
          final ultimoDigito = int.parse(cedula.substring(9, 10));

          //Agrupo todos los pares y los sumo
          var pares = int.parse(cedula.substring(1, 2)) +
              int.parse(cedula.substring(3, 4)) +
              int.parse(cedula.substring(5, 6)) +
              int.parse(cedula.substring(7, 8));

          //Agrupo los impares, los multiplico por un factor de 2, si la resultante es > que 9 le restamos el 9 a la resultante
          var numero1 = int.parse(cedula.substring(0, 1));
          numero1 = (numero1 * 2);
          if (numero1 > 9) {
            numero1 = (numero1 - 9);
          }

          var numero3 = int.parse(cedula.substring(2, 3));
          numero3 = (numero3 * 2);
          if (numero3 > 9) {
            numero3 = (numero3 - 9);
          }

          var numero5 = int.parse(cedula.substring(4, 5));
          numero5 = (numero5 * 2);
          if (numero5 > 9) {
            numero5 = (numero5 - 9);
          }

          var numero7 = int.parse(cedula.substring(6, 7));
          numero7 = (numero7 * 2);
          if (numero7 > 9) {
            numero7 = (numero7 - 9);
          }

          var numero9 = int.parse(cedula.substring(8, 9));
          numero9 = (numero9 * 2);
          if (numero9 > 9) {
            numero9 = (numero9 - 9);
          }

          var impares = numero1 + numero3 + numero5 + numero7 + numero9;

          //Suma total
          final sumaTotal = (pares + impares);

          //extraemos el primero digito
          final primerDigitoSuma = sumaTotal.toString().substring(0, 1);

          //Obtenemos la decena inmediata
          var decena = (int.parse(primerDigitoSuma) + 1) * 10;

          //Obtenemos la resta de la decena inmediata - la suma_total esto nos da el digito validador
          var digitoValidador = decena - sumaTotal;

          //Si el digito validador es = a 10 toma el valor de 0
          if (digitoValidador == 10) {
            digitoValidador = 0;
          }

          //Validamos que el digito validador sea igual al de la cedula
          if (digitoValidador == ultimoDigito) {
            return true;
          } else {
            return false;
          }
        } else {
          // imprimimos en consola si la region no pertenece
          return false;
        }
      } else {
        //imprimimos en consola si la cedula tiene mas o menos de 10 digitos
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  bool _passportValidator(String ruc) {
    return true;
  }

  bool moneyValidator(String value) {
    String pattern = '^\\d*(\\.\\d{2})?\$';
    RegExp regex = RegExp(pattern);
    if (value.isEmpty || !regex.hasMatch(value) || double.parse(value) < 1) {
      return false;
    } else {
      return true;
    }
  }

  List<bool> _rucValidator(String ruc) {
    try {
      if (ruc.length == 13) {
        final digitoRegion = int.parse(ruc.substring(0, 2));
        final numero3 = int.parse(ruc[2]);
        if (numero3 == 7 || numero3 == 8) return [false, false];

        final ultimos3 = ruc.substring(10, 13);
        final ultimos4 = ruc.substring(9, 13);
        if (digitoRegion >= 1 && digitoRegion <= 24) {
          if (numero3 > -1 && numero3 <= 5) {
            final ciValid = _ciValidator(ruc.substring(0, 10));
            if (ciValid && ultimos3 == '001') {
              return [true, true];
            }
            return [false, false];
          }
          if (numero3 == 6) {
            final spValid = _juridicaPublica(ruc, 'pub');
            if (spValid && ultimos4 == '0001') {
              return [true, false];
            }
            return [false, false];
          }
          if (numero3 == 9) {
            final jurValid = _juridicaPublica(ruc, 'jur');
            if (jurValid && ultimos3 == '001') {
              return [true, false];
            }
            return [false, false];
          }
          return [false, false];
        } else {
          return [false, false];
        }
      } else {
        return [false, false];
      }
    } catch (e) {
      return [false, false];
    }
  }

  bool _juridicaPublica(String ruc, String type) {
    int verificador = 0;
    List<int> coeficientes = [];
    switch (type) {
      case 'jur':
        verificador = 9;
        coeficientes = [4, 3, 2, 7, 6, 5, 4, 3, 2];
        break;
      case 'pub':
        verificador = 8;
        coeficientes = [3, 2, 7, 6, 5, 4, 3, 2];
        break;
    }
    var dVerificador = int.parse(ruc[verificador]);
    if (dVerificador > 0) {
      int prod;
      int aux = 0;

      for (int i = 0; i < verificador; i++) {
        var digito = int.parse(ruc[i]);
        prod = digito * coeficientes[i];
        aux += prod;
      }
      if (aux % 11 == 0) {
        dVerificador = 0;
      } else if (aux % 11 == 1) {
        return false;
      } else {
        aux = aux % 11;
        dVerificador = 11 - aux;
      }
      if (dVerificador == int.parse(ruc[verificador])) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool emailValidator(String email) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regex = RegExp(pattern);

    if (email.isEmpty || !regex.hasMatch(email)) {
      return false;
    } else {
      return true;
    }
  }

  String dateToStringFormat(DateTime dateTime, String format) {
    return DateFormat(format).format(dateTime);
  }

  DateTime stringToDateTime(String date) {
    try {
      return DateTime.parse(date);
    } on Exception catch (e) {
      debugPrint('Error: $e');
      return DateTime.now();
    }
  }

  TimeOfDay stringTimeToTime(String time) {
    final format = DateFormat.Hm(); //"24:00"
    return TimeOfDay.fromDateTime(format.parse(time));
  }

  String timeToString(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.Hm(); //"24:00 "
    return format.format(dt);
  }

  static List<List<CobOriginale>> sortCoverages(
      {required List<AccesoriesVehicle> accessoriesVehicles,
      required String listName}) {
    final List<CobOriginale> cobOriginales = [];
    final List<CobOriginale> cobAdicionales = [];
    bool extra;
    bool original;
    for (var element in accessoriesVehicles) {
      extra = element.extra ?? false;
      if (extra) {
        cobAdicionales.add(CobOriginale(
            descripcion: element.descripcion,
            accesorio: element.accesorio ?? '',
            marIncl: element.marIncl ?? '',
            cobertura: element.cobertura ?? '',
            cantidad: element.cantidad ?? '1',
            capAseg: element.valUnit ?? '0',
            bueno: element.bueno ?? false,
            medio: element.medio ?? false,
            regular: element.regular ?? false,
            marca: element.marca ?? '',
            modelo: element.modelo ?? ''));
      }
      original = element.original ?? false;
      if (original) {
        cobOriginales.add(CobOriginale(
            descripcion: element.descripcion,
            accesorio: element.accesorio ?? '',
            marIncl: element.marIncl ?? '',
            cobertura: element.cobertura ?? '',
            cantidad: element.cantidad ?? '1',
            capAseg: '',
            bueno: element.bueno ?? false,
            medio: element.medio ?? false,
            regular: element.regular ?? false,
            marca: element.marca ?? '',
            modelo: element.modelo ?? ''));
      }
    }
    switch (listName) {
      case "adicionales":
        return [cobAdicionales];
      case "originales":
        return [cobOriginales];
      case "all":
        return [cobAdicionales, cobOriginales];
    }
    return [];
  }

  static final logger = Logger(
      printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: false,));

  static String getCurrentDateAndTime() {
    DateTime now = DateTime.now();
    String formatDate = DateFormat('dd-MM-yyyy HH:mm').format(now);
    return formatDate;
    //return '01-07-2021 12:00';
  }

  static Future<bool> calculateDifferenceDays(
      {required String startDate}) async {
    final userData = await UserDataStorage().getUserData();
    DateFormat format = DateFormat('dd-MM-yyyy HH:mm');
    DateTime now = DateTime.now();
    DateTime startDateDateTime;
    startDateDateTime = format.parse(startDate);
    Duration difference = now.difference(startDateDateTime);
    int daysPassed = difference.inDays;
    // if(daysPassed >= AppConfig.appEnv.validCatalogDays){
    if (daysPassed >= userData!.vigenciaDiasCatalogo) {
      return true;
    } else {
      return false;
    }
  }

  static int coordinated = 2;
  static int emissionFreeProcesses = 49;
  static int processEmission = 50;

  static Future<bool> checkConnection() async {
    try {
      String url =
          'https://www.google.com'; //REVISAR EL SERVICIO A DONDE SE CONSULTE
      Uri uri = Uri.parse(url);
      final result = await http.get(uri);
      if (result.statusCode == 200) {
        Helper.logger.w('tienes acceso a internet');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Helper.logger.w('no tienes acceso a internet');
      return false;
    }
  }

  static Future<String> convertBase64(
      {required SignatureController signatureController}) async {
    final Uint8List? data = await signatureController.toPngBytes();
    final bytes = Uint8List.fromList(data!);
    String base64String = base64Encode(bytes);
    return base64String;
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> snackBar(
      {required BuildContext context,
      required String message,
      required Color colorSnackBar,
      void Function()? onPressed}) {
    final snackBar = SnackBar(
      backgroundColor: colorSnackBar,
      content: Text(message),
      action: SnackBarAction(
        textColor: Colors.white,
        label: 'Cerrar',
        onPressed: (onPressed == null) ? () {} : onPressed,
      ),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //MODIFICAR ESTE METODO PASARLO AL OTRO HELPER - PENDIENTEE
  static Future<GeneralResponse<String>> finishedInspecction(
      {bool? requiredRemoveDataInspection = true,
      bool? showAlertError = true,
      bool? showLoading = true,
      required SaveInspection saveInspection,
      required ContinueInspection continueInspection,
      required BuildContext? context,
      required int idRequest}) async {
    //  await Future.delayed(const Duration(seconds: 6));
    //  return GeneralResponse(message: 'proceso exitoso', error: true, data: 'sin emision - modo offline');
    // final fp = Provider.of<FunctionalProvider>(context, listen:false);
    // fp.setLoadingInspection(true);
    final response = await RequestReviewService().saveInspection(
        context, saveInspection,
        showLoading: showLoading, showAlertError: showAlertError);

    if (!response.error) {
      //ReviewRequestPage.listInspectionFinishedOffline.removeWhere((element) => element.idSolicitud == idRequest);

      //DESCOMENTAR LO DE ABAJO ES IMPORTENTEE
      if (continueInspection.cantidadArchivosTratadoEnviar == "0") {
        await MediaDataStorage().removeMediaData(idRequest);
      }

      //DESCOMENTAR LA LINEA D ABAJO ES IMPORTANTE
      if (requiredRemoveDataInspection!) {
        Helper.logger.w('es requerido, elimina informacion..');
        await InspectionStorage().removeDataInspection(idRequest.toString());
      }

      //fp.setLoadingInspection(false);
      return GeneralResponse(
          message: response.message,
          error: response.error,
          data: response.data);
      //await OfflineStorage().

      // fp.showAlert(
      //     content: AlertSuccess(
      //   message: 'Proceso exitoso!, ${response.data.toString()}',
      //   messageButton: 'Aceptar',
      //   onPress: () => {
      //     Navigator.pushReplacement(
      //         context,
      //         PageTransition(
      //             child: const ReviewRequestPage(),
      //             type: PageTransitionType.leftToRightWithFade))
      //   },
      // ));
    } else {
      //fp.setLoadingInspection(false);
      return GeneralResponse(
          message: response.message, error: response.error, data: null);
      // fp.showAlert(
      //     content: AlertGenericError(
      //   message: response.message,
      //   messageButton: 'Aceptar',
      //   onPress: () => {
      //     fp.dismissAlert(),
      //   },
      // ));
    }
  }

  // static finishedInspecction({required FunctionalProvider fp, required SaveInspection saveInspection, required ContinueInspection continueInspection, required BuildContext context, required int idRequest}) async{
  //    final response = await RequestReviewService().saveInspection(context, saveInspection);
  //     if (!response.error) {
  //       if (continueInspection.cantidadArchivosTratadoEnviar == "0") {
  //         await MediaDataStorage().removeMediaData(idRequest);
  //       }

  //       await InspectionStorage().removeDataInspection(idRequest.toString());
  //       //await OfflineStorage().

  //       fp.showAlert(
  //           content: AlertSuccess(
  //         message: 'Proceso exitoso!, ${response.data.toString()}',
  //         messageButton: 'Aceptar',
  //         onPress: () => {
  //           Navigator.pushReplacement(
  //               context,
  //               PageTransition(
  //                   child: const ReviewRequestPage(),
  //                   type: PageTransitionType.leftToRightWithFade))
  //         },
  //       ));
  //     } else {
  //       fp.showAlert(
  //           content: AlertGenericError(
  //         message: response.message,
  //         messageButton: 'Aceptar',
  //         onPress: () => {
  //           fp.dismissAlert(),
  //         },
  //       ));
  //     }
  // }

//OJO CAMBIAR ESTO AL OTRO HELPER - QUEDA PENDIENTEEE
  static Future<SaveInspection> getDataSave(
      {required ContinueInspection continueInspection,
      required Lista inspection}) async {
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
    // if (continueInspection.cantidadArchivosTratadoEnviar == "0") {
    //   await MediaDataStorage().removeMediaData(widget.inspection.idSolicitud);
    // }

    return SaveInspection(
        tokenFirma: continueInspection.tokenFirma ?? '', //OPT
        deducible: continueInspection.deducible ?? '',
        tipoFlujo: inspection.idTipoFlujo.toString(),
        idSolicitud: inspection.idSolicitud.toString(),
        idProceso: inspection.idProceso.toString(),
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
        codBroker: inspection.idBroker,
        email: continueInspection.email ?? '',
        codActividadEconomica: continueInspection.actividadEconomicaValue ?? '',
        codOcupacion: '0067', // REVISAR DE DONDE VIENE
        idPpe: continueInspection.personaPublicaValue ?? '',
        //usuario: usuario?.informacion.nombre ?? '',
        usuario: usuario?.informacion.usuario ?? '',
        telefono: continueInspection.telefono ?? '',
        celular: continueInspection.celular ?? '',
        valorIngresos: continueInspection.incomes ?? '',
        valorIngresosSecundarios: continueInspection.secondaryIncomes ?? '',
        valorActivos: continueInspection.actives ?? '',
        valorPasivos: continueInspection.pasives ?? '',
        codRamo: continueInspection.codRamo ?? '',
        codEjecutivoCuenta: inspection.codEjecutivo,
        codAgencia: inspection.idAgencia,
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
        numPoliza: inspection.polizaMadre ?? '',
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
        //idTransaccion: continueInspection.idTransaccion!, //Helper.uuid,
        idArchiveType: '',
        idRequest: '',
        typeMedia: '');
  }

  static Future<bool> verifyCatalogueStorage() async {
    OfflineStorage _offlineStorage = OfflineStorage();
    final InspectionDataResponse? inspectionDataResponse =
        await _offlineStorage.getCatalogueRegisterRequest();
    final DataClientForm? dataClientForm =
        await _offlineStorage.getCataloguePersonalInformation();
    final VehicleDataInspection? vehicleDataInspection =
        await _offlineStorage.getCatalogueVehicleData();
    final CatalogueOfflineGeneralResponse? catalogueVehicleModels =
        await _offlineStorage.getCatalogueVehiceModels();
    final CatalogueOfflineGeneralResponse? catalogueVehicleAccessories =
        await _offlineStorage.getCatalogueVehicleAccessories();
    final CatalogueOfflineGeneralResponse? catalogueFileType =
        await _offlineStorage.getCatalogueFileType();
    final CatalogueOfflineGeneralResponse? catalogueExecutives =
        await _offlineStorage.getCatalogueExecutives();
    if (dataClientForm != null &&
        vehicleDataInspection != null &&
        catalogueVehicleModels != null &&
        catalogueVehicleAccessories != null &&
        catalogueFileType != null &&
        inspectionDataResponse != null &&
        catalogueExecutives != null) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<String>> catalogDate() async {
    final List<String> dates = [];
    OfflineStorage _offlineStorage = OfflineStorage();
    final DataClientForm? dataClientForm =
        await _offlineStorage.getCataloguePersonalInformation();
    final InspectionDataResponse? inspectionDataResponse =
        await _offlineStorage.getCatalogueRegisterRequest();
    final VehicleDataInspection? vehicleDataInspection =
        await _offlineStorage.getCatalogueVehicleData();
    final CatalogueOfflineGeneralResponse? catalogueVehicleModels =
        await _offlineStorage.getCatalogueVehiceModels();
    final CatalogueOfflineGeneralResponse? catalogueVehicleAccessories =
        await _offlineStorage.getCatalogueVehicleAccessories();
    final CatalogueOfflineGeneralResponse? catalogueFileType =
        await _offlineStorage.getCatalogueFileType();
    final CatalogueOfflineGeneralResponse? catalogueExecutives =
        await _offlineStorage.getCatalogueExecutives();
    if (dataClientForm != null &&
        vehicleDataInspection != null &&
        catalogueVehicleModels != null &&
        catalogueVehicleAccessories != null &&
        catalogueFileType != null &&
        inspectionDataResponse != null &&
        catalogueExecutives != null) {
      dates.addAll([
        dataClientForm.dateCreation.toString(),
        vehicleDataInspection.date.toString(),
        catalogueVehicleModels.dateCreation,
        catalogueVehicleAccessories.dateCreation,
        catalogueFileType.dateCreation,
        inspectionDataResponse.dateCreation.toString(),
        catalogueExecutives.dateCreation
      ]);
      return dates;
    } else {
      return dates;
    }
  }

  static Future<bool> verifyCatalogueExpiration() async {
    final List<String> dates = await catalogDate();
    final List<bool> datesExpired = [];
    for (var date in dates) {
      datesExpired.add(await calculateDifferenceDays(startDate: date));
    }
    if (datesExpired.contains(true)) {
      return true;
    } else {
      return false;
    }
  }

  // static int inspection = 0;
  // static int loadingInspection  = 1;
  // static int errorInspection = 2;
  // static int successInspection = 3;

  static Future<bool> checkInternet() async {
    log('********************************* VERIFICANDO CONEXIÓN A INTERNET *********************************');
    final connectivityResult = await (Connectivity().checkConnectivity());
    bool connectionValidate = true;
    if (connectivityResult.contains(ConnectivityResult.mobile)) {
      log('******************** Conexión a internet por datos móviles ********************');
    } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
      log('******************** Conexión a internet por red inalámbrica Wifi ********************');
    } else if (connectivityResult.contains( ConnectivityResult.vpn)) {
      var envStr = AppConfig.appEnv.environmentName;
      connectionValidate =
          (envStr == 'DEV' || envStr == 'QA') ? await _checkInternet(1) : false;
      // I am connected to a vpn network.
      // Note for iOS and macOS:
      // There is no separate network interface type for [vpn].
      // It returns [other] on any device (also simulator)
    } else if (connectivityResult.contains( ConnectivityResult.bluetooth)) {
      log('******************** Conexión a internet por red inalámbrica Bluetooth ********************');
    } else if (connectivityResult .contains( ConnectivityResult.other)) {
      log('******************** Conectado a internet ********************');
    } else if (connectivityResult .contains( ConnectivityResult.none)) {
      log('******************** No conectado a internet ********************');
      connectionValidate = false;
    }

    return connectionValidate = await _checkInternet(1);
  }

  static Future<bool> _checkInternet(int numeroIntento) async {
    log('INTENTO: $numeroIntento');
    if (numeroIntento > Helper.urlServicesPublicIP.length) {
      return false;
    }
    String url = Helper.urlServicesPublicIP.keys.elementAt(numeroIntento - 1);
    List<String> splitUrl = url.split('/');
    if (splitUrl.length >= 3) {
      url = splitUrl[2];
    }

    try {
      final result =
          await InternetAddress.lookup(url).timeout(const Duration(seconds: 2));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (e) {
      //Do nothing}
    }
    await Future.delayed(const Duration(seconds: 1));
    return await _checkInternet(numeroIntento + 1);
  }

  static const Map<String, String> urlServicesPublicIP = {
    'https://api.myip.com': 'ip',
    'https://ipinfo.io/json': 'ip',
    'https://www.trackip.net/ip?json': 'IP',
    'https://ip4.seeip.org/json': 'ip',
  };

  static int timeUpdateLocation = 0; //SEGUNDOS
  static int kmDistance = 0; //METROS
  static int timeUpdateDistance = 0; //MINUTOS

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final uuid = const Uuid().v4();

  static String calculateTimeRemaining({required DateTime date}) {
    DateTime now = DateTime.now();
    DateTime startDateDateTime =
        DateTime(date.year, date.month, date.day, date.hour, date.minute);
    Duration difference = startDateDateTime.difference(now);
    int days = difference.inDays;
    // int hours = difference.inHours % 24;
    // int minutes = difference.inMinutes % 60;
    // int seconds = difference.inSeconds % 60;
    return '$days';
    //return 'faltan $days días, $hours horas, $minutes minutos y $seconds segundos';
  }

  static Pattern addressRegExp = RegExp(r'[a-zA-Z0-9ñÑáéíóúÁÉÍÓÚüÜ\-\.\# ]');
  static Pattern textRegExp = RegExp(r'[ a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]');

  static void startBackgroundService() {
    try {
      log('-----------INICIANDO SERVICIO EN SEGUNDO PLANO------------');
      final service = FlutterBackgroundService();
      service.startService();
    } catch (e) {
      log('Error al iniciar el servicio en segundo plano: $e');
    }
  }

  static void stopBackgroundService() {
    final service = FlutterBackgroundService();
    service.invoke("stop");
  }

  static bool session = false;

  static bool isProcessing = false;

  static String? idInspection;

  static String? get getIdInspection => idInspection;

  static List<MediaResponse> mediaStatus = [];

  initSubscriptionPendingMediaInspection() async {
    // final timeUpdateDistance = await UserDataStorage().getTimeUpDistance();
    Timer.periodic(const Duration(minutes: 3), (timer) async {
      bool offline = false;
      offline = await checkConnection();
      (offline ? initsubprocess() : null);
    });
  }

  Future<void> initsubprocess() async {
    log('Ejecucion de segundo plano');

    await verifyPendingMedia();
    await _processUploadInspecctionOffline();
  }

  // initUploadInspecctionOffline() async {
  //   Timer.periodic(const Duration(minutes: 1), (timer) async {
  //     bool offline = false;
  //     offline = await _verifyConnection();
  //     (offline ? _processUploadInspecctionOffline() : null);
  //   });
  // }
//---------------------------------------------------------
//Correccion de memoria Prueba

Future<void> _processUploadInspecctionOffline() async {
  List<Request> request = await OfflineStorage().getCreatingRequests();
  final listInspectionFinishedOffline = await OfflineStorage().getInspectionFinishedOffline();
  List<Lista> listInspectionOfline = listInspectionFinishedOffline?.first.lista ?? [];

  Helper.logger.i('Procesando: ${Helper.isProcessing}');
  if (!Helper.isProcessing) {
    Helper.isProcessing = true;
    if (listInspectionOfline.isNotEmpty && request.isNotEmpty) {
      // Crear copia profunda
      List<Request> requestCopy = request.map((r) => Request.fromJson(r.toJson())).toList();
      for (var i = 0; i < requestCopy.length; i += 10) {
        final batch = requestCopy.sublist(i, i + 10 < requestCopy.length ? i + 10 : requestCopy.length);
        for (Request inspectionRequest in batch) {
          bool errorRegisterRequest = false;
          bool errorLoadMedia = false;

          if (inspectionRequest.idSolicitudServicio == 0) {
            final response = await NewRequestService().registerRequest(
              null,
              inspectionRequest,
              viewAlertError: false,
            );

            if (!response.error && response.data != null) {
              Helper.logger.i('Solicitud registrada correctamente');
              inspectionRequest.idSolicitudServicio = response.data[0]["idSolicitud"];
              inspectionRequest.statusSolicitudRegistrada = HelperRequestOffline.loaded;
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
            } else {
              Helper.logger.e('Error al registrar solicitud: ${response.message}');
              inspectionRequest.statusSolicitudRegistrada = HelperRequestOffline.error;
              inspectionRequest.mensageErrorSolicitudRegistrar = response.message;
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
              errorRegisterRequest = true;
            }
          } else {
            Helper.logger.w('Solicitud ya registrada');
            errorRegisterRequest = false;
          }

          if (!errorRegisterRequest && inspectionRequest.statusMultimediaRegistrada != HelperRequestOffline.loaded) {
            bool loadMedia = await HelperRequestOffline.loadMediaDataService(
              fp: null,
              context: null,
              paramsLoadMedia: ParamsLoadMedia(
                idRequestReal: inspectionRequest.idSolicitudServicio!,
                idSolicitudTemp: inspectionRequest.idSolicitudTemp!,
              ),
            );

            if (loadMedia) {
              Helper.logger.i('Multimedia subida correctamente');
              inspectionRequest.statusMultimediaRegistrada = HelperRequestOffline.loaded;
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
            } else {
              Helper.logger.w('Error al registrar multimedia');
              inspectionRequest.statusMultimediaRegistrada = HelperRequestOffline.error;
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
              errorLoadMedia = true;
            }
          }

          if (!errorLoadMedia && inspectionRequest.statusInspeccionRegistrada != HelperRequestOffline.loaded) {
            final loadInformation = await HelperRequestOffline.loadInformationRequestService(
              context: null,
              paramsLoadRequest: ParamsLoadRequest(
                errorMediaLoad: inspectionRequest.statusMultimediaRegistrada == HelperRequestOffline.error,
                idRequestReal: inspectionRequest.idSolicitudServicio!,
                idSolicitudTemp: inspectionRequest.idSolicitudTemp!,
                paramsRequest: ParamsRequest(
                  codEjecutivo: inspectionRequest.dataSolicitud!.ejecutivo!.codEjecutivo!,
                  idAgencia: inspectionRequest.dataSolicitud!.idAgencia!,
                  idBroker: inspectionRequest.dataSolicitud!.idBroker!,
                  idProceso: inspectionRequest.dataSolicitud!.idProceso!,
                  idSolicitud: inspectionRequest.idSolicitudTemp!,
                  idTipoFlujo: inspectionRequest.dataSolicitud!.idTipoFlujo!,
                  polizaMadre: inspectionRequest.dataSolicitud!.polizaMadre,
                ),
              ),
            );

            if (!loadInformation.error) {
              Helper.logger.i('Inspección finalizada correctamente');
              inspectionRequest.statusInspeccionRegistrada = HelperRequestOffline.loaded;
              inspectionRequest.messageInspectionRegistrada = loadInformation.data.toString();
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
            } else {
              Helper.logger.e('Error al finalizar inspección: ${loadInformation.message}');
              inspectionRequest.statusInspeccionRegistrada = HelperRequestOffline.error;
              inspectionRequest.mensageErrorRegistrarInspection = loadInformation.message;
              await OfflineStorage().saveCreatingRequests(value: requestCopy);
              await InspectionStorage().removeDataInspection(inspectionRequest.idSolicitudTemp.toString());
              ReviewRequestPage.listInspectionFinishedOffline.removeWhere(
                (e) => e.idSolicitud == inspectionRequest.idSolicitudTemp,
              );
              await OfflineStorage().saveInspectionFinishedOffline(ReviewRequestPage.listInspectionFinishedOffline);
            }
          }

          if (inspectionRequest.statusSolicitudRegistrada == HelperRequestOffline.loaded &&
              inspectionRequest.statusMultimediaRegistrada == HelperRequestOffline.loaded &&
              inspectionRequest.statusInspeccionRegistrada == HelperRequestOffline.loaded) {
            listInspectionOfline.removeWhere((e) => e.idSolicitud == inspectionRequest.idSolicitudTemp);
            requestCopy.removeWhere((e) => e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
            await OfflineStorage().saveInspectionFinishedOffline(listInspectionOfline);
            await OfflineStorage().saveCreatingRequests(value: requestCopy);
            Helper.logger.i('Información enviada y eliminada correctamente');
          }

          await Future.delayed(Duration(milliseconds: 50)); // Reducir presión de memoria
        }
      }
      request = List.from(requestCopy); // Actualizar request al final
    }

    Logger().w('No hay solicitudes pendientes');
    if (listInspectionOfline.isNotEmpty) {
      List<Lista> listaFilter = listInspectionOfline.where((element) => element.creacionOffline == false).toList();
      Logger().w('Cantidad: ${listaFilter.length}');
      for (var e in listaFilter) {
        final continueInspection = await InspectionStorage().getDataInspection(e.idSolicitud.toString());
        Logger().w('continueInspection: $continueInspection');
        if (continueInspection != null) {
          final saveInspection = await Helper.getDataSave(
            continueInspection: continueInspection,
            inspection: e,
          );
          final response = await Helper.finishedInspecction(
            saveInspection: saveInspection,
            continueInspection: continueInspection,
            context: null,
            idRequest: e.idSolicitud,
            showLoading: false,
            showAlertError: false,
          );

          Logger().w('response: ${response.error}');
          if (!response.error) {
            bool ok = await loadMediaData(list: e);
            Logger().w('ok: $ok');
            if (ok) {
              await InspectionStorage().removeDataInspection(e.idSolicitud.toString());
              listInspectionOfline.removeWhere((data) => data.idSolicitud == e.idSolicitud);
              await OfflineStorage().saveInspectionFinishedOffline(listInspectionOfline);
            }
          }
        }
      }
    }
    Helper.isProcessing = false;
  }
}
//----------------------------
  // Future<void> _processUploadInspecctionOffline() async {
  //   List<Request> request = await OfflineStorage().getCreatingRequests();
  //   final listInspectionFinishedOffline =
  //       await OfflineStorage().getInspectionFinishedOffline();
  //   List<Lista> listInspectionOfline = [];
  //   if (listInspectionFinishedOffline != null) {
  //     listInspectionOfline = listInspectionFinishedOffline.first.lista;
  //   }
  //   Helper.logger.i(Helper.isProcessing);
  //   if (!Helper.isProcessing) {
  //     Helper.isProcessing = true;
  //     if (listInspectionOfline.isNotEmpty) {
  //       if (request.isNotEmpty) {
  //         List<Request> requestCopy = List.from(request);
  //         for (Request inspectionRequest in requestCopy) {
  //           bool errorRegisterRequest = false;
  //           bool errorLoadMedia = false;
  //           // if (!fp.offline) {
  //           // OfflineStorage().setLoadingInspection(true);
  //           //   //await Future.delayed(Duration(seconds: 5));
  //           //   int index = NewRequestPage.listCreatingrequests.indexWhere(
  //           //       (item) => item.idSolicitudTemp == request.idSolicitudTemp);

  //           if (inspectionRequest.idSolicitudServicio == 0) {
  //             final response = await NewRequestService().registerRequest(
  //                 null, inspectionRequest,
  //                 viewAlertError: false);

  //             if (!response.error && response.data != null) {
  //               Helper.logger.i('la solicitud se registro correctamente');
  //               // int idRequest = response.data[0]["idSolicitud"];
  //               // currentStep = 1; //REVISAR SI SE USA ESTA VARIABLE
  //               errorRegisterRequest = false;

  //               // if (index != -1) {
  //               inspectionRequest.idSolicitudServicio =
  //                   response.data[0]["idSolicitud"];
  //               inspectionRequest.statusSolicitudRegistrada =
  //                   HelperRequestOffline.loaded;
  //               OfflineStorage().saveCreatingRequests(value: requestCopy);
  //               // }
  //             } else {
  //               Helper.logger.e(
  //                   'Ocurrio un error al registrar la solicitud, guarda el error');
  //               // if (index != -1) {
  //               inspectionRequest.statusSolicitudRegistrada =
  //                   HelperRequestOffline.error;
  //               inspectionRequest.mensageErrorSolicitudRegistrar =
  //                   response.message;
  //               OfflineStorage().saveCreatingRequests(value: requestCopy);
  //               // }
  //             }
  //           } else {
  //             Helper.logger.w(
  //                 'esta solicitud ya fue registrada, tomar el id de la solicitud guardado en storage');
  //             // inspectionRequest.idSolicitudServicio = request.idSolicitudServicio!;
  //             errorRegisterRequest = false;
  //             // setState(() {});
  //           }

  //           if (!errorRegisterRequest) {
  //             if (inspectionRequest.statusMultimediaRegistrada !=
  //                 HelperRequestOffline.loaded) {
  //               bool loadMedia =
  //                   await HelperRequestOffline.loadMediaDataService(
  //                       fp: null,
  //                       context: null,
  //                       paramsLoadMedia: ParamsLoadMedia(
  //                           idRequestReal:
  //                               inspectionRequest.idSolicitudServicio!,
  //                           idSolicitudTemp:
  //                               inspectionRequest.idSolicitudTemp!));

  //               if (!loadMedia) {
  //                 Helper.logger.i('la multimedia se subio correctamente');
  //                 errorLoadMedia = false;
  //                 // currentStep = 2; //REVISAR SI SE USA ESTA VARIABLE
  //                 // if (index != -1) {
  //                 inspectionRequest.statusMultimediaRegistrada =
  //                     HelperRequestOffline.loaded;
  //                 await OfflineStorage()
  //                     .saveCreatingRequests(value: requestCopy);
  //               }

  //               if (inspectionRequest.statusInspeccionRegistrada ==
  //                   HelperRequestOffline.loaded) {
  //                 Helper.logger.w(
  //                     'entro e elimino la informacion de la inspeccion, porque reintento enviar multimedia y esta cargada la informacion de la solicitud');
  //                 await InspectionStorage().removeDataInspection(
  //                     inspectionRequest.idSolicitudTemp.toString());
  //               }

  //               // setState(() {});
  //             } else {
  //               // OfflineStorage().setLoadingInspection(false);
  //               Helper.logger.w(
  //                   'ocurrio un error al registrar la multimedia, guarda error y continua');
  //               errorLoadMedia =
  //                   false; //FALSO PORQUE CONTINUA CON EL PROCESO SI HAY ERROR
  //               //REVISAR SI SE USA ESTA VARIABLE
  //               // if (index != -1) {
  //               inspectionRequest.statusMultimediaRegistrada =
  //                   HelperRequestOffline.error;
  //               await OfflineStorage().saveCreatingRequests(value: requestCopy);
  //               // }
  //               // setState(() {});
  //             }
  //           }

  //           //SIGUIENTE VALIDACION QUE CONTINUE SI HAY ERROR DE MULTIMEDIA O NO

  //           if (!errorLoadMedia) {
  //             if (inspectionRequest.statusInspeccionRegistrada !=
  //                 HelperRequestOffline.loaded) {
  //               // OfflineStorage().setLoadingInspection(true);
  //               final loadInformation =
  //                   await HelperRequestOffline.loadInformationRequestService(
  //                 context: null,
  //                 paramsLoadRequest: ParamsLoadRequest(
  //                     errorMediaLoad:
  //                         inspectionRequest.statusMultimediaRegistrada ==
  //                             HelperRequestOffline.error,
  //                     idRequestReal: inspectionRequest.idSolicitudServicio!,
  //                     idSolicitudTemp: inspectionRequest.idSolicitudTemp!,
  //                     paramsRequest: ParamsRequest(
  //                         codEjecutivo: inspectionRequest
  //                             .dataSolicitud!.ejecutivo!.codEjecutivo!,
  //                         idAgencia:
  //                             inspectionRequest.dataSolicitud!.idAgencia!,
  //                         idBroker: inspectionRequest.dataSolicitud!.idBroker!,
  //                         idProceso:
  //                             inspectionRequest.dataSolicitud!.idProceso!,
  //                         idSolicitud: inspectionRequest.idSolicitudTemp!,
  //                         idTipoFlujo:
  //                             inspectionRequest.dataSolicitud!.idTipoFlujo!,
  //                         polizaMadre:
  //                             inspectionRequest.dataSolicitud!.polizaMadre)),
  //               );

  //               if (!loadInformation.error) {
  //                 // OfflineStorage().setLoadingInspection(false);
  //                 Helper.logger
  //                     .i('la inspeccion se cargo y finalizo correctamente');
  //                 // if (index != -1) {
  //                 inspectionRequest.statusInspeccionRegistrada =
  //                     HelperRequestOffline.loaded;
  //                 inspectionRequest.messageInspectionRegistrada =
  //                     loadInformation.data.toString();
  //                 await OfflineStorage()
  //                     .saveCreatingRequests(value: requestCopy);
  //                 // }
  //                 // setState(() {});
  //               } else {
  //                 // OfflineStorage().setLoadingInspection(false);
  //                 Helper.logger
  //                     .e('ocurrio un error al finalizar la inspeccion');
  //                 // fp.dismissAlert();
  //                 // if (index != -1) {
  //                 inspectionRequest.statusInspeccionRegistrada =
  //                     HelperRequestOffline.error;
  //                 // NewRequestPage.listCreatingrequests.removeWhere((e) =>
  //                 //     e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
  //                 // ReviewRequestPage.listInspectionFinishedOffline.removeWhere(
  //                 //     (e) => e.idSolicitud == inspectionRequest.idSolicitudTemp);
  //                 inspectionRequest.mensageErrorRegistrarInspection =
  //                     loadInformation.message;
  //                 // NewRequestPage.listCreatingrequests.removeWhere((e) =>
  //                 //     e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
  //                 await OfflineStorage()
  //                     .saveCreatingRequests(value: requestCopy);

  //                 await InspectionStorage().removeDataInspection(
  //                     inspectionRequest.idSolicitudTemp.toString());
  //                 ReviewRequestPage.listInspectionFinishedOffline.removeWhere(
  //                     (e) =>
  //                         e.idSolicitud == inspectionRequest.idSolicitudTemp);
  //                 await OfflineStorage().saveInspectionFinishedOffline(
  //                     ReviewRequestPage.listInspectionFinishedOffline);
  //                 NewRequestPage.listCreatingrequests.removeWhere((e) =>
  //                     e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
  //                 //NewRequestPage.listCreatingrequests.removeAt(index);
  //                 await OfflineStorage().saveCreatingRequests(
  //                     value: NewRequestPage.listCreatingrequests);
  //               }
  //               // setState(() {});
  //             }
  //             // }
  //           }
  //           // }

  //           Logger().w(
  //               'status solicitud registrada ${inspectionRequest.statusSolicitudRegistrada}');
  //           Logger().w(
  //               'statusMultimediaRegistrada ${inspectionRequest.statusMultimediaRegistrada}');
  //           Logger().w(
  //               'statusInspeccionRegistrada ${inspectionRequest.statusInspeccionRegistrada}');
  //           //ELIMINAR LA INFORMACION DEL ARREGLO DE INSPECCIONES OFFLINE
  //           if (inspectionRequest.statusSolicitudRegistrada ==
  //                   HelperRequestOffline.loaded &&
  //               inspectionRequest.statusMultimediaRegistrada ==
  //                   HelperRequestOffline.loaded &&
  //               inspectionRequest.statusInspeccionRegistrada ==
  //                   HelperRequestOffline.loaded) {
  //             // ReviewRequestPage.listInspectionFinishedOffline.removeWhere(
  //             //     (e) => e.idSolicitud == inspectionRequest.idSolicitudTemp);
  //             // NewRequestPage.listCreatingrequests.removeWhere(
  //             //     (e) => e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
  //             request = requestCopy;
  //             Helper.logger.i(
  //                 'se elimino toda la informacion todo se envio correctamente...');
  //             listInspectionOfline.removeWhere(
  //                 (e) => e.idSolicitud == inspectionRequest.idSolicitudTemp);
  //             await OfflineStorage()
  //                 .saveInspectionFinishedOffline(listInspectionOfline);
  //             request.removeWhere((e) =>
  //                 e.idSolicitudTemp == inspectionRequest.idSolicitudTemp);
  //             log('requestCopy: ${request.length}');
  //             //NewRequestPage.listCreatingrequests.removeAt(index);
  //             await OfflineStorage().saveCreatingRequests(value: requestCopy);

  //             // }
  //           }
  //         }
  //       }
  //     }

  //     Logger().w('no hay solicitudes pendientes');
  //     if (listInspectionOfline.isNotEmpty) {
  //       List<Lista> listaFilter = listInspectionOfline
  //           .where((element) => element.creacionOffline == false)
  //           .toList();
  //       Logger().w('cantidad :${listaFilter.length}');
  //       for (var e in listaFilter) {
  //         final continueInspection = await InspectionStorage()
  //             .getDataInspection(e.idSolicitud.toString());
  //         Logger().w('continueInspection: $continueInspection');
  //         if (continueInspection != null) {
  //           final saveInspection = await Helper.getDataSave(
  //               continueInspection: continueInspection, inspection: e);
  //           final response = await Helper.finishedInspecction(
  //             saveInspection: saveInspection,
  //             continueInspection: continueInspection,
  //             context: null,
  //             idRequest: e.idSolicitud,
  //             showLoading: false,
  //             showAlertError: false,
  //           );

  //           Logger().w('response: ${response.error}');
  //           if (!response.error) {
  //             bool ok = await loadMediaData(list: e);
  //             Logger().w('ok: $ok');
  //             if (ok) {
  //               await InspectionStorage()
  //                   .removeDataInspection(e.idSolicitud.toString());
  //               listInspectionOfline
  //                   .removeWhere((data) => data.idSolicitud == e.idSolicitud);
  //               await OfflineStorage()
  //                   .saveInspectionFinishedOffline(listInspectionOfline);
  //             }
  //           }
  //         }
  //       }
  //     }
  //     Helper.isProcessing = false;
  //   }
  // }

  initsubscriptionLocation() async {
    final kmDistance = await UserDataStorage().getKmDistance();
    final timeUpdateDistance = await UserDataStorage().getTimeUpDistance();

    final LocationSettings locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      // distanceFilter: 1,
      // intervalDuration: const Duration(seconds: 5),
      distanceFilter: kmDistance,
      timeLimit: null,
      intervalDuration: Duration(minutes: timeUpdateDistance),
    );
    HomePage.positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) async {
      // Helper.logger.w('positionStream: $position');
      Helper.logger.w('interval duration: $timeUpdateDistance');
      // Helper.logger.w('-----------');
      bool offline = false;
      String? idInspection = await UserDataStorage().getIdInspection();
      offline = await checkConnection();
      // Helper.logger.w('Session: $session');
      // Helper.logger.w('connection: $offline');

      (offline
          ? _locationUser(
              location: LocationResponse(
                  latitud: position.latitude.toString(),
                  longitud: position.longitude.toString(),
                  idSolicitud: idInspection))
          : null);
    });

    HomePage.positionStream!.onError((error, stackTrace) async {
      Helper.logger.e('positionStream error: $error');
      bool serviceLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceLocationEnabled) {
        //Helper.snackBar(context: context, message: 'Por favor, activa el servicio de ubicación en tu dispositivo.', colorSnackBar: Colors.red);
      }
    });
  }

  Future<bool> _verifyConnection() async {
    bool isConnected = await CheckConnectionService().hasInternetConnection();
    return isConnected;
  }

  final UserLocationService _userLocationService = UserLocationService();

  void _locationUser({required LocationResponse location}) async {
    // final staticContext = Helper.navigatorKey.currentContext;
    await _userLocationService.updateLocation(location);
  }

  Future<void> verifyPendingMedia() async {
    try {
      final response = await RequestReviewService().getListInspect(null);

      if (response.error || response.data == null) {
        log('Entra aqui');
        return;
      }

      final pendingInspections = _filterPendingInspections(response.data!);
      log('Inspecciones pendientes: ${pendingInspections.first.lista.length}');
      if (pendingInspections.isEmpty) {
        return;
      }

      await _processPendingMedia(pendingInspections.first.lista);
    } catch (e) {
      Helper.logger.e('Error verifying pending media: $e');
    }
  }

  List<ListInspectionDataResponse> _filterPendingInspections(
      List<ListInspectionDataResponse> inspections) {
    return inspections.where((item) => item.idEstadoInspeccion == 5).toList();
  }

  Future<void> _processPendingMedia(List<Lista> inspectionList) async {
    for (final inspection in inspectionList) {
      // final mediaData =
      // await MediaDataStorage().getMediaData(inspection.idSolicitud);
      await loadMediaData(list: inspection);
      // if (mediaData == null) continue;

      // final pendingMedia = _getPendingMediaUploads(mediaData);
      // await _uploadPendingMedia(inspection, pendingMedia);
    }
  }

  List<MediaStorage> _getPendingMediaUploads(List<MediaStorage> mediaData) {
    return mediaData
        .where((item) => item.status != 'UPLOADED' && item.status != 'NO_MEDIA')
        .toList();
  }

  Future<bool> loadMediaData({
    required Lista list,
  }) async {
    try {
      // fp.setLoadingInspection(true);
      final dataMedia = await MediaDataStorage().getMediaData(list.idSolicitud);
      log(jsonEncode(dataMedia));
      //final List<MediaResponse> mediaNotUploaded = [];
      List<bool> uploaded = [];
      final identification = list.identificacion;

      //await MediaDataStorage().removeMediaData(widget.idRequest);
      if (dataMedia != null) {
        for (var item in dataMedia) {
          if (item.status != 'UPLOADED' && item.status != 'NO_MEDIA') {
            debugPrint(
                'Archivo a reenviar: ${item.type} - ${item.idArchiveType} - ${item.status}');
            final response = await MediaService().uploadMedia(
              context: null,
              idRequest: list.idSolicitud,
              idArchiveType: item.idArchiveType,
              identification: identification,
              mediaType: item.type == 'image'
                  ? MediaType('image', 'jpg')
                  : MediaType('video', 'mp4'),
              mediaPhoto: (item.type == 'image')
                  ? Uint8List.fromList(item.data!)
                  : null,
              mediaVideo: (item.type == 'video') ? File(item.path!) : null,
              showAlertError: false,
            );

            if (!response.error) {
              // mediaNotUploaded.add(MediaResponse(idSolicitud: list.idSolicitud, idArchiveType: item.idArchiveType, status: Helper.statusMedia["2"].toString()));
              Helper.logger.w('response; ${jsonEncode(response)}');
              uploaded.add(true);
              //await MediaDataStorage().removeMediaData(list.idSolicitud);
            } else {
              Helper.logger.w('response; ${jsonEncode(response)}');
            }
          }
        }
        //fp.setLoadingInspection(false);

        //DESCOMENTAR
        if (uploaded.length ==
            dataMedia
                .where((e) => e.status != 'UPLOADED' && e.status != 'NO_MEDIA')
                .toList()
                .length) {
          await MediaDataStorage().removeMediaData(list.idSolicitud);
          Helper.logger.e('entroo todo es igual');
        }
      }

      Helper.logger.w('uploaded: ${jsonEncode(uploaded)}');

      return true;
    } catch (e) {
      return true;
    }
  }

  Future<void> _uploadPendingMedia(
      Lista inspection, List<MediaStorage> pendingMedia) async {
    List<MediaResponse> mediaStatus = [];

    void updateInspectionStatus(int idArchiveType, String newStatus) {
      final index =
          mediaStatus.indexWhere((item) => item.idArchiveType == idArchiveType);

      if (index != -1) {
        // setState(() {
        final updatedList = mediaStatus.toList();
        updatedList[index].status = newStatus.toString();
        mediaStatus = updatedList;
        // });
      }
    }

    final responseMedia = await OfflineStorage().getMediaStatus();
    if (responseMedia.isNotEmpty) {
      mediaStatus = responseMedia;
    }

    if (mediaStatus
        .any((element) => element.idSolicitud == inspection.idSolicitud)) {
      return;
    }
    for (final media in pendingMedia) {
      debugPrint(
          'File to resend: ${media.type} - ${media.idArchiveType} - ${media.status}');

      final mediaType = media.type == 'image'
          ? MediaType('image', 'jpg')
          : MediaType('video', 'mp4');

      //status cargando y fp.setloadingin en true, esto se
      //guarda en storage para que lo tome el timer

      mediaStatus.any((media) => media.idArchiveType == media.idArchiveType)
          ? updateInspectionStatus(media.idArchiveType, 'cargando')
          : mediaStatus.add(MediaResponse(
              idSolicitud: inspection.idSolicitud,
              idArchiveType: media.idArchiveType,
              status: 'cargando'));

      OfflineStorage().setMediaStatus(mediaStatus);

      final response = await MediaService().uploadMedia(
        context: null,
        idRequest: inspection.idSolicitud,
        idArchiveType: media.idArchiveType,
        identification: inspection.identificacion,
        mediaType: mediaType,
        mediaPhoto:
            media.type == 'image' ? Uint8List.fromList(media.data!) : null,
        mediaVideo: media.type == 'video' ? File(media.path!) : null,
        showAlertError: false,
      );

      if (!response.error) {
        updateInspectionStatus(media.idArchiveType, 'exito');
        OfflineStorage().setMediaStatus(mediaStatus);
      } else {
        updateInspectionStatus(media.idArchiveType, 'error');
        OfflineStorage().setMediaStatus(mediaStatus);
        await Future.delayed(const Duration(seconds: 1), () {
          // fp.setLoadingInspection(false);
          updateInspectionStatus(media.idArchiveType, 'upload');
          OfflineStorage().setMediaStatus(Helper.mediaStatus);
        });
      }

      if ((mediaStatus.where((e) => e.status == 'exito').toList().length) ==
          pendingMedia.length) {
        mediaStatus.clear();
        OfflineStorage().setMediaStatus(mediaStatus);
        await MediaDataStorage().removeMediaData(inspection.idSolicitud);
      }
    }
  }

  // void _logUploadResult(GeneralResponse response) {
  //   if (!response.error) {
  //     //actualizar status a exito y se elimina la lista, se elimina la data de storage
  //     //en base al id de la solicitud

  //     Helper.logger.w('Upload successful');
  //   } else {
  //     Helper.logger.w('Upload failed');
  //   }
  // }
}
