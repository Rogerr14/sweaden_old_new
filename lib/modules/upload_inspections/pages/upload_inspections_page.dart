import 'dart:async';
import 'dart:developer';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/new_request.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/alert_inspection_offline_widget.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/services/media_service.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/button.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/card_inspection_ofline.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/text_rich_widget.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/helper/request_offline.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_status_response.dart';
import 'package:sweaden_old_new_version/shared/models/params.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/rotating_icon_widget.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:logger/logger.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

class UploadInspectionsPage extends StatefulWidget {
  const UploadInspectionsPage({super.key});

  @override
  State<UploadInspectionsPage> createState() => _UploadInspectionsPageState();
}

class _UploadInspectionsPageState extends State<UploadInspectionsPage> {
  late FunctionalProvider fp;
  final OfflineStorage _offlineStorage = OfflineStorage();

  int _currentOpenIndex = -1;
  int currentStep = 0;
  final NewRequestService _newRequestService = NewRequestService();

  int idRequest = 0;
  bool errorRegisterRequest = false;
  bool errorLoadMedia = false;
  late Timer vefifyUpload;
  List<InspectionStatusResponse> inspecctionStatus = [];

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'cargar-inspecciones', context: context);
      _verifyIsnpection();
    });
  }

  _verifyIsnpection() async {
    vefifyUpload = Timer.periodic(const Duration(seconds: 10), (timer) async {
      List<Request> request = await OfflineStorage().getCreatingRequests();
      final listInspectionfinishedOffline =
          await OfflineStorage().getInspectionFinishedOffline();
      log(request.length.toString() + 'jjj');
      // if (request.isNotEmpty) {
      NewRequestPage.listCreatingrequests = request;
      // }
      if (listInspectionfinishedOffline != null) {
        // if (listInspectionfinishedOffline.first.lista.isNotEmpty) {
          log(listInspectionfinishedOffline.length.toString() + 'jjj');
          ReviewRequestPage.listInspectionFinishedOffline.clear();
        for(var inspesction in listInspectionfinishedOffline){
          
          ReviewRequestPage.listInspectionFinishedOffline.addAll(inspesction.lista);
        }
        // }
      }
      setState(() {});
    });
  }

  List<Widget> requestsDownload() {
    log(jsonEncode(ReviewRequestPage.listInspectionFinishedOffline.first));
    return ReviewRequestPage.listInspectionFinishedOffline
        //widget.inspectionOffline
        .where((valid) => valid.creacionOffline == false)
        .map((elemento) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
        child: CardTitleInspectionOffline(
          inspecctionStatus: inspecctionStatus,
          information: elemento,
          onPressed: () async {
            Logger().w('elemento: ${elemento.idSolicitud}');
            //int pendingCount = ReviewRequestPage.listInspectionFinishedOffline.where((e) => e.creacionOffline == false).length;
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            fp.setLoadingInspection(true);
            fp.showAlert(content: const AlertLoading());

            inspecctionStatus.any((solicitud) =>
                    solicitud.idSolicitud == elemento.idSolicitud)
                ? updateInspectionStatus(
                    elemento.idSolicitud, InspectionStatus.loading)
                : inspecctionStatus.add(InspectionStatusResponse(
                    idSolicitud: elemento.idSolicitud,
                    status: InspectionStatus.loading.toString()));
            final continueInspection = await InspectionStorage()
                .getDataInspection(elemento.idSolicitud.toString());
            Logger().w('continueInspection: ${continueInspection}');

            if (continueInspection != null) {
              final SaveInspection saveInspection = await Helper.getDataSave(
                  continueInspection: continueInspection, inspection: elemento);
              final response = await Helper.finishedInspecction(
                  requiredRemoveDataInspection: false,
                  saveInspection: saveInspection,
                  continueInspection: continueInspection,
                  context: context,
                  idRequest: elemento.idSolicitud,
                  showLoading: false,
                  showAlertError: false);
              if (!response.error) {
                bool ok = await loadMediaData(list: elemento, fp: fp);
                if (ok) {
                  fp.setLoadingInspection(false);
                  fp.dismissAlert();
                  await InspectionStorage()
                      .removeDataInspection(elemento.idSolicitud.toString());
                  //await Future.delayed(const Duration(seconds: 1), () async {
                  ReviewRequestPage.listInspectionFinishedOffline.removeWhere(
                      (e) => e.idSolicitud == elemento.idSolicitud);
                  await OfflineStorage().saveInspectionFinishedOffline(
                      ReviewRequestPage.listInspectionFinishedOffline);
                  //  if (elemento.creacionOffline == false) {
                  //             pendingCount--;
                  //           }
                  setState(() {});
                  //});
                }

                //widget.inspectionOffline.isEmpty ? dismissAlertService(fp: fp) : null; //REVISARRR
                //widget.inspectionOffline.map((e) => e.creacionOffline == false).isEmpty ? dismissAlertService(fp: fp) : null;
                //  if (pendingCount <= 0) {
                //           dismissAlertService(fp: fp);
                //         }

              } else {
                fp.setLoadingInspection(false);
                fp.dismissAlert();
                updateInspectionStatus(
                    elemento.idSolicitud, InspectionStatus.error);
              }
            } else {
              fp.setLoadingInspection(false);
              fp.dismissAlert();
              ReviewRequestPage.listInspectionFinishedOffline
                  .removeWhere((e) => e.idSolicitud == elemento.idSolicitud);
            }
          },
        ),
      );
    }).toList();
  }

  void updateInspectionStatus(int idSolicitud, InspectionStatus newStatus) {
    final index =
        inspecctionStatus.indexWhere((item) => item.idSolicitud == idSolicitud);

    if (index != -1) {
      setState(() {
        final updatedList = inspecctionStatus.toList();
        updatedList[index].status = newStatus.toString();
        inspecctionStatus = updatedList;
      });
    }
  }

  loadAll() async {
    fp.setLoadingInspection(true);
    fp.showAlert(content: const AlertLoading());

    List<Lista> listaFilter = ReviewRequestPage.listInspectionFinishedOffline
        .where((element) => element.creacionOffline == false)
        .toList();
    List<Lista> listInspectionOfflineCopy = List.from(listaFilter);

    for (var e in listInspectionOfflineCopy) {
      inspecctionStatus.any((element) => element.idSolicitud == e.idSolicitud)
          ? updateInspectionStatus(e.idSolicitud, InspectionStatus.loading)
          : inspecctionStatus.add(InspectionStatusResponse(
              idSolicitud: e.idSolicitud,
              status: InspectionStatus.loading.toString()));
      final continueInspection =
          await InspectionStorage().getDataInspection(e.idSolicitud.toString());

      if (continueInspection != null) {
        final SaveInspection saveInspection = await Helper.getDataSave(
            continueInspection: continueInspection, inspection: e);

        final response = await Helper.finishedInspecction(
            requiredRemoveDataInspection: false,
            saveInspection: saveInspection,
            continueInspection: continueInspection,
            context: context,
            idRequest: e.idSolicitud,
            showLoading: false,
            showAlertError: false);
        if (!response.error) {
          bool ok = await loadMediaData(list: e, fp: fp);

          if (ok) {
            await InspectionStorage()
                .removeDataInspection(e.idSolicitud.toString());
            ReviewRequestPage.listInspectionFinishedOffline
                .removeWhere((data) => data.idSolicitud == e.idSolicitud);
            await OfflineStorage().saveInspectionFinishedOffline(
                ReviewRequestPage.listInspectionFinishedOffline);

            setState(() {});
          }
        } else {
          updateInspectionStatus(e.idSolicitud, InspectionStatus.error);
          Helper.logger.w("error: ${jsonEncode(response)}");
        }
      }
    }
    fp.setLoadingInspection(false);
    fp.dismissAlert();
  }

  //  dismissAlertService({required FunctionalProvider fp}) {
  //   fp.dismissAlert();
  //   //widget.uploadInspections();
  // }

  Future<bool> loadMediaData(
      {required Lista list, required FunctionalProvider fp}) async {
    try {
      fp.setLoadingInspection(true);
      final dataMedia = await MediaDataStorage().getMediaData(list.idSolicitud);
      //log(jsonEncode(dataMedia));
      //final List<MediaResponse> mediaNotUploaded = [];
      List<bool> uploaded = [];

      //await MediaDataStorage().removeMediaData(widget.idRequest);
      if (dataMedia != null) {
        for (var item in dataMedia) {
          if (item.status != 'UPLOADED' && item.status != 'NO_MEDIA') {
            debugPrint(
                'Archivo a reenviar: ${item.type} - ${item.idArchiveType} - ${item.status}');
            final response = await MediaService().uploadMedia(
              context: context,
              idRequest: list.idSolicitud,
              idArchiveType: item.idArchiveType,
              identification:
                  await HelperRequestOffline.getDataInspectionStorage(
                      idSoliciutd: list.idSolicitud.toString()),
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

  List<Widget> listInspection() {
    Logger().w(jsonEncode(NewRequestPage.listCreatingrequests.first));
    return NewRequestPage.listCreatingrequests.asMap().entries.map((entry) {
      int index = entry.key;
      Request request = entry.value;

      return Visibility(
        visible: request.completedOffline!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppConfig.appThemeConfig.secondaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 0.5, vertical: 0.5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExpansionPanelList(
                expansionCallback: !fp.loadingInspection
                    ? (int panelIndex, bool isExpanded) {
                        setState(() {
                          _currentOpenIndex = isExpanded ? -1 : index;
                          currentStep = 0;
                        });
                      }
                    : null,
                children: [
                  ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return GestureDetector(
                        onTap: !fp.loadingInspection
                            ? () {
                                setState(() {
                                  _currentOpenIndex = isExpanded ? -1 : index;
                                  currentStep = 0;
                                });
                              }
                            : null,
                        child: ListTile(
                          title: HelperRequestOffline.clientRequest(
                              request: request),
                          subtitle: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HelperRequestOffline.statusRequest(
                                    request: request),
                                TextRichWidget(
                                    title: 'Placa',
                                    subtitle: request
                                        .dataSolicitud!.datosVehiculo!.placa!,
                                    colorSubtitle: Colors.red),
                                const TextRichWidget(
                                    title: 'Proceso',
                                    subtitle: 'Proc sin Emisión'),
                                TextRichWidget(
                                    title: 'Dirección',
                                    subtitle:
                                        request.dataSolicitud!.direccion!),
                                TextRichWidget(
                                    title: 'N° Teléfono',
                                    subtitle: request.dataSolicitud!.telefono!),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    body: Column(
                      children: [
                        fp.loadingInspection
                            ? const Text(
                                'Estimado usuario mientras carga la informacion no realice ninguna otra acción.',
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center)
                            : const SizedBox(),
                        const SizedBox(height: 5),
                        Visibility(
                          visible: (request.statusSolicitudRegistrada !=
                                  HelperRequestOffline.loaded ||
                              request.statusMultimediaRegistrada !=
                                  HelperRequestOffline.loaded ||
                              request.statusInspeccionRegistrada !=
                                  HelperRequestOffline.loaded),
                          child: ElevatedButton.icon(
                            icon: fp.loadingInspection
                                ? const RotatingIcon(icon: Icon(Icons.sync))
                                : const Icon(Icons.upload_rounded),
                            label: Text(fp.loadingInspection
                                ? 'Cargando...'
                                : HelperRequestOffline.nameButtonUploadRequest(
                                    request: request)),
                            onPressed: !fp.loadingInspection
                                ? () async {
                                    if (!fp.offline) {
                                      fp.setLoadingInspection(true);
                                      //await Future.delayed(Duration(seconds: 5));
                                      int index = NewRequestPage
                                          .listCreatingrequests
                                          .indexWhere((item) =>
                                              item.idSolicitudTemp ==
                                              request.idSolicitudTemp);

                                      if (request.idSolicitudServicio == 0) {
                                        final response =
                                            await _newRequestService
                                                .registerRequest(
                                                    context, request,
                                                    viewAlertError: false);

                                        if (!response.error &&
                                            response.data != null) {
                                          Helper.logger.i(
                                              'la solicitud se registro correctamente');
                                          idRequest =
                                              response.data[0]["idSolicitud"];
                                          currentStep =
                                              1; //REVISAR SI SE USA ESTA VARIABLE
                                          errorRegisterRequest = false;

                                          if (index != -1) {
                                            NewRequestPage
                                                    .listCreatingrequests[index]
                                                    .idSolicitudServicio =
                                                idRequest;
                                            NewRequestPage
                                                    .listCreatingrequests[index]
                                                    .statusSolicitudRegistrada =
                                                HelperRequestOffline.loaded;
                                            _offlineStorage
                                                .saveCreatingRequests(
                                                    value: NewRequestPage
                                                        .listCreatingrequests);
                                          }
                                          setState(() {});
                                        } else {
                                          Helper.logger.e(
                                              'Ocurrio un error al registrar la solicitud, guarda el error');
                                          if (index != -1) {
                                            NewRequestPage
                                                    .listCreatingrequests[index]
                                                    .statusSolicitudRegistrada =
                                                HelperRequestOffline.error;
                                            NewRequestPage
                                                    .listCreatingrequests[index]
                                                    .mensageErrorSolicitudRegistrar =
                                                response.message;
                                            _offlineStorage
                                                .saveCreatingRequests(
                                                    value: NewRequestPage
                                                        .listCreatingrequests);
                                          }
                                          errorRegisterRequest = true;
                                          fp.setLoadingInspection(false);
                                          fp.dismissAlert();
                                          setState(() {});
                                        }
                                      } else {
                                        Helper.logger.w(
                                            'esta solicitud ya fue registrada, tomar el id de la solicitud guardado en storage');
                                        idRequest =
                                            request.idSolicitudServicio!;
                                        errorRegisterRequest = false;
                                        setState(() {});
                                      }

                                      if (!errorRegisterRequest) {
                                        if (request
                                                .statusMultimediaRegistrada !=
                                            HelperRequestOffline.loaded) {
                                          bool loadMedia = await HelperRequestOffline
                                              .loadMediaDataService(
                                                  fp: fp,
                                                  context: context,
                                                  paramsLoadMedia: ParamsLoadMedia(
                                                      idRequestReal: idRequest,
                                                      idSolicitudTemp: request
                                                          .idSolicitudTemp!));

                                          if (!loadMedia) {
                                            Helper.logger.i(
                                                'la multimedia se subio correctamente');
                                            errorLoadMedia = false;
                                            currentStep =
                                                2; //REVISAR SI SE USA ESTA VARIABLE
                                            if (index != -1) {
                                              NewRequestPage
                                                      .listCreatingrequests[index]
                                                      .statusMultimediaRegistrada =
                                                  HelperRequestOffline.loaded;
                                              _offlineStorage
                                                  .saveCreatingRequests(
                                                      value: NewRequestPage
                                                          .listCreatingrequests);
                                            }

                                            if (request
                                                    .statusInspeccionRegistrada ==
                                                HelperRequestOffline.loaded) {
                                              Helper.logger.w(
                                                  'entro e elimino la informacion de la inspeccion, porque reintento enviar multimedia y esta cargada la informacion de la solicitud');
                                              await InspectionStorage()
                                                  .removeDataInspection(request
                                                      .idSolicitudTemp
                                                      .toString());
                                            }

                                            setState(() {});
                                          } else {
                                            fp.setLoadingInspection(false);
                                            Helper.logger.w(
                                                'ocurrio un error al registrar la multimedia, guarda error y continua');
                                            errorLoadMedia =
                                                false; //FALSO PORQUE CONTINUA CON EL PROCESO SI HAY ERROR
                                            currentStep =
                                                2; //REVISAR SI SE USA ESTA VARIABLE
                                            if (index != -1) {
                                              NewRequestPage
                                                      .listCreatingrequests[index]
                                                      .statusMultimediaRegistrada =
                                                  HelperRequestOffline.error;
                                              _offlineStorage
                                                  .saveCreatingRequests(
                                                      value: NewRequestPage
                                                          .listCreatingrequests);
                                            }
                                            setState(() {});
                                          }
                                        }

                                        //SIGUIENTE VALIDACION QUE CONTINUE SI HAY ERROR DE MULTIMEDIA O NO

                                        if (!errorLoadMedia) {
                                          if (request
                                                  .statusInspeccionRegistrada !=
                                              HelperRequestOffline.loaded) {
                                            fp.setLoadingInspection(true);
                                            final loadInformation =
                                                await HelperRequestOffline
                                                    .loadInformationRequestService(
                                              context: context,
                                              paramsLoadRequest: ParamsLoadRequest(
                                                  errorMediaLoad: request
                                                          .statusMultimediaRegistrada ==
                                                      HelperRequestOffline
                                                          .error,
                                                  idRequestReal: idRequest,
                                                  idSolicitudTemp:
                                                      request.idSolicitudTemp!,
                                                  paramsRequest: ParamsRequest(
                                                      codEjecutivo: request
                                                          .dataSolicitud!
                                                          .ejecutivo!
                                                          .codEjecutivo!,
                                                      idAgencia: request
                                                          .dataSolicitud!
                                                          .idAgencia!,
                                                      idBroker: request
                                                          .dataSolicitud!
                                                          .idBroker!,
                                                      idProceso: request
                                                          .dataSolicitud!
                                                          .idProceso!,
                                                      idSolicitud: request
                                                          .idSolicitudTemp!,
                                                      idTipoFlujo: request
                                                          .dataSolicitud!
                                                          .idTipoFlujo!,
                                                      polizaMadre: request
                                                          .dataSolicitud!
                                                          .polizaMadre)),
                                            );

                                            if (!loadInformation.error) {
                                              fp.setLoadingInspection(false);
                                              Helper.logger.i(
                                                  'la inspeccion se cargo y finalizo correctamente');
                                              if (index != -1) {
                                                NewRequestPage
                                                        .listCreatingrequests[index]
                                                        .statusInspeccionRegistrada =
                                                    HelperRequestOffline.loaded;
                                                NewRequestPage
                                                        .listCreatingrequests[index]
                                                        .messageInspectionRegistrada =
                                                    loadInformation.data
                                                        .toString();
                                                _offlineStorage
                                                    .saveCreatingRequests(
                                                        value: NewRequestPage
                                                            .listCreatingrequests);
                                              }
                                              setState(() {});
                                            } else {
                                              fp.setLoadingInspection(false);
                                              Helper.logger.e(
                                                  'ocurrio un error al finalizar la inspeccion');
                                              fp.dismissAlert();
                                              if (index != -1) {
                                                NewRequestPage
                                                        .listCreatingrequests[index]
                                                        .statusInspeccionRegistrada =
                                                    HelperRequestOffline.error;
                                                NewRequestPage
                                                        .listCreatingrequests[index]
                                                        .mensageErrorRegistrarInspection =
                                                    loadInformation.message;
                                                _offlineStorage
                                                    .saveCreatingRequests(
                                                        value: NewRequestPage
                                                            .listCreatingrequests);
                                              }
                                              setState(() {});
                                            }
                                          }
                                        }
                                      }

                                      //ELIMINAR LA INFORMACION DEL ARREGLO DE INSPECCIONES OFFLINE
                                      if (request.statusSolicitudRegistrada ==
                                              HelperRequestOffline.loaded &&
                                          request.statusMultimediaRegistrada ==
                                              HelperRequestOffline.loaded &&
                                          request.statusInspeccionRegistrada ==
                                              HelperRequestOffline.loaded) {
                                        Helper.logger.i(
                                            'se elimino toda la informacion todo se envio correctamente...');
                                        ReviewRequestPage
                                            .listInspectionFinishedOffline
                                            .removeWhere((e) =>
                                                e.idSolicitud ==
                                                request.idSolicitudTemp);
                                        _offlineStorage
                                            .saveInspectionFinishedOffline(
                                                ReviewRequestPage
                                                    .listInspectionFinishedOffline);
                                        NewRequestPage.listCreatingrequests
                                            .removeWhere((e) =>
                                                e.idSolicitudTemp ==
                                                request.idSolicitudTemp);
                                        //NewRequestPage.listCreatingrequests.removeAt(index);
                                        _offlineStorage.saveCreatingRequests(
                                            value: NewRequestPage
                                                .listCreatingrequests);
                                        setState(() {});
                                      }
                                    } else {
                                      Helper.snackBar(
                                          context: context,
                                          message:
                                              'No tienes conexion a internet.',
                                          colorSnackBar: Colors.red);
                                    }
                                  }
                                : null,
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                              colorScheme: ColorScheme.light(
                                  primary:
                                      AppConfig.appThemeConfig.secondaryColor)),
                          child: Stepper(
                            physics: const NeverScrollableScrollPhysics(),
                            controlsBuilder: (context, details) {
                              return Row(
                                children: [
                                  if (currentStep != 0)
                                    Visibility(
                                      visible: false,
                                      child: TextButton(
                                        onPressed: details.onStepCancel,
                                        child: const Text('Anterior'),
                                      ),
                                    ),
                                  if (currentStep != 2)
                                    Visibility(
                                      visible: false,
                                      child: TextButton(
                                        onPressed: details.onStepContinue,
                                        child: const Text('Siguiente'),
                                      ),
                                    ),
                                ],
                              );
                            },
                            currentStep: currentStep,
                            //currentStep: fp.loadingInspection ? HelperRequestOffline.currentStep(request: request) : 2,
                            onStepContinue: onStepContinue,
                            onStepCancel: onStepCancel,
                            onStepTapped: (step) => onStepTapped(step),
                            steps: [
                              Step(
                                state: HelperRequestOffline.stepState(
                                    status: request.statusSolicitudRegistrada!),
                                isActive: HelperRequestOffline.isStepActive(
                                    status: request.statusSolicitudRegistrada!),
                                title: const Text('Registrar solicitud'),
                                content: request.statusSolicitudRegistrada ==
                                        HelperRequestOffline.error
                                    ? Center(
                                        child: Text(
                                            request.mensageErrorSolicitudRegistrar ??
                                                '',
                                            style: HelperRequestOffline.styles(
                                                color: Colors.red)))
                                    : const SizedBox(),
                              ),
                              Step(
                                state: HelperRequestOffline.stepState(
                                    status:
                                        request.statusMultimediaRegistrada!),
                                isActive: HelperRequestOffline.isStepActive(
                                    status:
                                        request.statusMultimediaRegistrada!),
                                title: const Text('Enviar multimedia'),
                                content: request.statusMultimediaRegistrada ==
                                        HelperRequestOffline.error
                                    ? Center(
                                        child: Text(
                                            request.mensageErrorMultimedia ??
                                                '',
                                            style: HelperRequestOffline.styles(
                                                color: Colors.red)))
                                    : const SizedBox(),
                              ),
                              Step(
                                  state: HelperRequestOffline.stepState(
                                      status:
                                          request.statusInspeccionRegistrada!),
                                  isActive: HelperRequestOffline.isStepActive(
                                      status:
                                          request.statusInspeccionRegistrada!),
                                  title: const Text(
                                      'Enviar información de la inspección'),
                                  content: Wrap(
                                    children: [
                                      request.statusInspeccionRegistrada ==
                                              HelperRequestOffline.error
                                          ? Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: ElevatedButton.icon(
                                                  style: ButtonStyle(
                                                      backgroundColor:
                                                          WidgetStateProperty
                                                              .all(Colors.red)),
                                                  label: const Text('Eliminar'),
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    fp.showAlert(
                                                        content: AlertConfirm(
                                                      message:
                                                          'Antes de eliminar verifique que la informacion se cargo correctamente, ¿Esta seguro de eliminar la información de esta solicitud locamente?',
                                                      confirm: () async {
                                                        Helper.logger.i(
                                                            'se elimino toda la informacion');
                                                        await InspectionStorage()
                                                            .removeDataInspection(
                                                                request
                                                                    .idSolicitudTemp
                                                                    .toString());
                                                        ReviewRequestPage
                                                            .listInspectionFinishedOffline
                                                            .removeWhere((e) =>
                                                                e.idSolicitud ==
                                                                request
                                                                    .idSolicitudTemp);
                                                        _offlineStorage
                                                            .saveInspectionFinishedOffline(
                                                                ReviewRequestPage
                                                                    .listInspectionFinishedOffline);
                                                        NewRequestPage
                                                            .listCreatingrequests
                                                            .removeWhere((e) =>
                                                                e.idSolicitudTemp ==
                                                                request
                                                                    .idSolicitudTemp);
                                                        //NewRequestPage.listCreatingrequests.removeAt(index);
                                                        _offlineStorage
                                                            .saveCreatingRequests(
                                                                value: NewRequestPage
                                                                    .listCreatingrequests);
                                                        setState(() {});
                                                        fp.dismissAlert();
                                                      },
                                                    ));
                                                  },
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      Center(
                                          child: Text(
                                              request.mensageErrorRegistrarInspection ??
                                                  'Ocurrio un error',
                                              style:
                                                  HelperRequestOffline.styles(
                                                      color: Colors.red)))
                                    ],
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                    isExpanded: _currentOpenIndex == index,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void onStepContinue() {
    setState(() {
      if (currentStep < 3 - 1) {
        currentStep = currentStep + 1;
      } else {
        currentStep = 0;
      }
    });
  }

  void onStepCancel() {
    setState(() {
      if (currentStep > 0) {
        currentStep = currentStep - 1;
      } else {
        currentStep = 0;
      }
    });
  }

  void onStepTapped(step) {
    setState(() {
      currentStep = step;
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('cargar-inspecciones');
    vefifyUpload.cancel();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      if (!fp.loadingInspection) {
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: const HomePage(),
                type: PageTransitionType.leftToRightWithFade));
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool loadingInspection =
        context.watch<FunctionalProvider>().loadingInspection;

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Stack(
        children: [
          BackGround(size: size),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBarHome(context),
              body: Builder(builder: (context) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: AppConfig.appThemeConfig.primaryColor,
                        indicatorColor: AppConfig.appThemeConfig.secondaryColor,
                        tabs: const <Widget>[
                          Tab(text: 'Solicitudes Creadas Offline'),
                          Tab(text: 'Inspecciones Descargadas'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          requestsOffline(),
                          ReviewRequestPage
                                  .listInspectionFinishedOffline.isNotEmpty
                              ? SingleChildScrollView(
                                  child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    children: [
                                      loadingInspection
                                          ? const Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                  'Estimado usuario mientras carga la informacion no realice ninguna otra acción.',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center),
                                            )
                                          : const SizedBox(),
                                      ReviewRequestPage
                                              .listInspectionFinishedOffline
                                              .any((e) =>
                                                  e.creacionOffline == false)
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 0, bottom: 12),
                                              child: button(
                                                  nameButton: !loadingInspection
                                                      ? 'Cargar todo'
                                                      : 'Cargando...',
                                                  colorButton: AppConfig
                                                      .appThemeConfig
                                                      .primaryColor,
                                                  onPressed: !loadingInspection
                                                      ? loadAll
                                                      : null),
                                            )
                                          : const SizedBox(),
                                      Column(children: requestsDownload()),
                                    ],
                                  ),
                                ))
                              : const Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                      'Actualmente no cuentas con inspecciones finalizadas, una vez finalizadas se visualizaran.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center),
                                )
                        ],
                      ),
                    )
                  ],
                );
              }),
              bottomNavigationBar: const BottomInfo()),
          const AlertModal(),
          const NotificationModal()
        ],
      ),
    );
  }

  Widget requestsOffline() {
    Logger().w(NewRequestPage.listCreatingrequests);
    return NewRequestPage.listCreatingrequests.isNotEmpty
        ? SingleChildScrollView(
            child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(children: listInspection()),
          ))
        : const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
                'Actualmente no cuentas con inspecciones finalizadas, una vez finalizadas se visualizaran.',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
          );
  }
}

AppBar _appBarHome(BuildContext context) {
  return AppBar(
    backgroundColor: AppConfig.appThemeConfig.secondaryColor,
    title: const Text.rich(TextSpan(children: [
      TextSpan(
          text: 'Cargar Inspecciones',
          style: TextStyle(fontWeight: FontWeight.w300))
    ])),
    leading: IconButton(
        onPressed: () {
          final fp = Provider.of<FunctionalProvider>(context, listen: false);

          !fp.loadingInspection
              ? Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: const HomePage(),
                      type: PageTransitionType.leftToRightWithFade))
              : null;
        },
        icon: const Icon(Icons.arrow_back_ios_new)),
  );
}
