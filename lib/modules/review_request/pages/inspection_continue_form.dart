import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:sweaden_old_new_version/modules/login/pages/login_page.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/new_request.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/providers/review_request_provider.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/review_request_widgets.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/media_info_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

class InspectionContinueFormPage extends StatefulWidget {
  final Lista inspection;
  final DataClientForm dataClientForm;
  const InspectionContinueFormPage({
    Key? key,
    required this.inspection,
    required this.dataClientForm,
  }) : super(key: key);

  @override
  State<InspectionContinueFormPage> createState() =>
      _InspectionContinueFormPageState();
}

//! PONEMOS ESTA DATA AFUERA PARA QUE SEA PERSISTENTE
//! Y ASI SOLO LLAMARLA UNA VEZ EN TODo EL CICLO DE VIDA
//! DE LA APP
//? DATA PARA MEDIA(FOTOS-VIDEOS)
List<MediaInfo> mediaInfo = [];

class _InspectionContinueFormPageState
    extends State<InspectionContinueFormPage> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 1,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    // onDrawStart: () => log('onDrawStart called!'),
    // onDrawEnd: () => log('onDrawEnd called!'),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'inspection-continue', context: context);
      _loadMediaInfo();
    });
  }

  _loadMediaInfo() async {
    if (mediaInfo.isEmpty) {
      //bool connection = await Helper.checkConnection();
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if (fp.offline) {
        final response = await OfflineStorage().getCatalogueFileType();
        if (response != null) {
          mediaInfo =
              response.data.map((item) => MediaInfo.fromJson(item)).toList();
          setState(() {});
        }
      } else {
        final response = await RequestReviewService().getMediaInfo(context);
        if (!response.error) {
          mediaInfo = response.data!;
          setState(() {});
        }
      }
    }
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('inspection-continue');
    _pageController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      debugPrint("INSPECTION CONTINUE INTERCEPTOR");

      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if (fp.valReverse) {
        fp.setReverse = false;
      } else {
        fp.showAlert(content: const AlertLoseProcess());
      }
    }
    return true;
  }

  _saveInspection() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    Helper.logger
        .w('aqui se guarda la inspeccion ${continueInspection?.emitPolize}');
    if (continueInspection != null) {
      debugPrint('---- CONTINUE INSPECTION ----');
      final SaveInspection saveInspection =
          await _getDataSave(continueInspection);
      debugPrint('Cargando guardar inspección');

      //VALIDACION DE CONEXION A INTERNET SI HAY CONEXION SIGUE EL PROCESO NORMAL, CASO CONTRARIO NUEVA VALIDACION

      //bool internet = await Helper.checkConnection();

      if (fp.offline) {
        fp.showAlert(
            content: AlertSignature(
                signatureController: _signatureController,
                message:
                    'Para finalizar con la inspeccion es necesario que el cliente firme.',
                onPress: () async {
                  if (_signatureController.isNotEmpty) {
                    final base64Signature = await Helper.convertBase64(
                        signatureController: _signatureController);
                    bool response =
                        await _saveDataStorage(base64: base64Signature);
                    if (response) {
                      bool exist = ReviewRequestPage
                          .listInspectionFinishedOffline
                          .any((element) =>
                              element.idSolicitud ==
                              widget.inspection.idSolicitud);
                      //Helper.logger.w('existe inspeccion en el arreglo de finalizado offline: $exist');

                      if (!exist) {
                        debugPrint('ok avanza');
                        final index = NewRequestPage.listCreatingrequests
                            .indexWhere((e) =>
                                e.idSolicitudTemp ==
                                widget.inspection.idSolicitud);
                        Helper.logger.w('index: $index');
                        if (index != -1) {
                          NewRequestPage.listCreatingrequests[index]
                              .completedOffline = true;
                          OfflineStorage().saveCreatingRequests(
                              value: NewRequestPage.listCreatingrequests);
                        }

                        ReviewRequestPage.listInspectionCoordinated.removeWhere(
                            (e) =>
                                e.idSolicitud == widget.inspection.idSolicitud);
                        await OfflineStorage().setListInspectionOffline(
                            ReviewRequestPage.listInspectionCoordinated);
                        widget.inspection.idEstadoInspeccion = 12;
                        widget.inspection.mostrarBotonRegistrarBitacora = 0;
                        ReviewRequestPage.listInspectionFinishedOffline
                            .insert(0, widget.inspection);
                        await OfflineStorage().saveInspectionFinishedOffline(
                            ReviewRequestPage.listInspectionFinishedOffline);
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                child: const ReviewRequestPage(),
                                type: PageTransitionType.leftToRightWithFade));
                      } else {
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                child: const ReviewRequestPage(),
                                type: PageTransitionType.leftToRightWithFade));
                      }

                      //ORIGINAL
                      //aavanza ala pantalladal
                      //debugPrint('ok avanza');
                      //  Navigator.pushReplacement(
                      //   context,
                      //   PageTransition(
                      //       child: const ReviewRequestPage(),
                      //       type: PageTransitionType.leftToRightWithFade));
                    }
                  } else {}
                }));
      } else {
        final response = await Helper.finishedInspecction(
            saveInspection: saveInspection,
            continueInspection: continueInspection,
            context: context,
            idRequest: widget.inspection.idSolicitud);
        if (!response.error) {
          fp.showAlert(
              content: AlertSuccess(
            message: 'Proceso exitoso!, ${response.data.toString()}',
            messageButton: 'Aceptar',
            onPress: () {
              // fp.setIdInspection(null),
              if (widget.inspection.idEstadoInspeccion == 4){MediaDataStorage().removeMediaData(widget.inspection.idSolicitud);}
              UserDataStorage().removeIdInspection();
              Navigator.pushReplacement(
                  context,
                  PageTransition(
                      child: const ReviewRequestPage(),
                      type: PageTransitionType.leftToRightWithFade));
            },
          ));
        } else {
          fp.showAlert(
              content: AlertGenericError(
            message: response.message,
            messageButton: 'Aceptar',
            onPress: () => {
              fp.dismissAlert(),
            },
          ));
        }
      }

      // if (!response.error) {
      //   await InspectionStorage()
      //       .removeDataInspection(widget.inspection.idSolicitud.toString());
      //   fp.showAlert(
      //       content: AlertSuccess(
      //     message: 'Proceso exitoso!, ${response.data.toString()}',
      //     messageButton: 'Aceptar',
      //     onPress: () => {
      //       Navigator.pushReplacement(
      //           context,
      //           PageTransition(
      //               child: const ReviewRequestPage(),
      //               type: PageTransitionType.leftToRightWithFade))
      //     },
      //   ));
      // } else {
      //   fp.showAlert(
      //       content: AlertGenericError(
      //     message: response.message,
      //     messageButton: 'Aceptar',
      //     onPress: () => {
      //       fp.dismissAlert(),
      //     },
      //   ));
      // }
    }
  }

  Future<bool> _saveDataStorage({required String base64}) async {
    try {
      ContinueInspection inspectionData = ContinueInspection();
      ContinueInspection? continueInspection = await InspectionStorage()
          .getDataInspection(widget.inspection.idSolicitud.toString());
      if (continueInspection != null) {
        inspectionData = continueInspection;
      }
      inspectionData.base64SignatureClientImage = base64;
      inspectionData.finishedInpectionOffline = true;
      inspectionData.tokenFirma = '';
      InspectionStorage().setDataInspection(
          inspectionData, widget.inspection.idSolicitud.toString());
      return true;
    } on Exception catch (e) {
      Helper.logger.e('Error al guardar la inspeccion en el storage: $e');
      return false;
    }
  }

  // _normalProcessContinue({required FunctionalProvider fp, required SaveInspection saveInspection, required ContinueInspection continueInspection}) async {
  //   final response = await RequestReviewService().saveInspection(context, saveInspection);
  //     if (!response.error) {
  //       if (continueInspection.cantidadArchivosTratadoEnviar == "0") {
  //         await MediaDataStorage().removeMediaData(widget.inspection.idSolicitud);
  //       }

  //       await InspectionStorage().removeDataInspection(widget.inspection.idSolicitud.toString());
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

  Future<SaveInspection> _getDataSave(
      ContinueInspection continueInspection) async {
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
        tipoFlujo: widget.inspection.idTipoFlujo.toString(),
        idSolicitud: widget.inspection.idSolicitud.toString(),
        idProceso: widget.inspection.idProceso.toString(),
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
        codBroker: widget.inspection.idBroker,
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
        codEjecutivoCuenta: widget.inspection.codEjecutivo,
        codAgencia: widget.inspection.idAgencia,
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
        numPoliza: widget.inspection.polizaMadre ?? '',
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
        //idTransaccion: continueInspection.idTransaccion!,
        idArchiveType: '',
        idRequest: '',
        typeMedia: '');
  }

  //! verif
  _nextPage(bool value) async {
    //? VERIFICAMOS FECHA DE CADUCIDAD DEL TOKEN
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final validToken = await Helper.tokenValidityCheck();

    if (!validToken) {
      fp.showAlert(
          content: AlertGenericError(
        message:
            "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
        messageButton: "Entendido!",
        onPress: () async {
          fp.dismissAlert();
          await UserDataStorage().removeUserData();
          Navigator.pushReplacement(context,
              Helper.navigationFadeIn(context, const LoginPage(), 800));
        },
      ));
    } else {
      if (_pageController.hasClients) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 1000), curve: Curves.easeIn);
      }
      setState(() {
        currentPage = currentPage - 1;
      });
    }
  }

  //! verif
  _jumpPage(int value) async {
    //? VERIFICAMOS FECHA DE CADUCIDAD DEL TOKEN
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final validToken = await Helper.tokenValidityCheck();

    if (!validToken) {
      fp.showAlert(
          content: AlertGenericError(
        message:
            "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
        messageButton: "Entendido!",
        onPress: () async {
          fp.dismissAlert();
          await UserDataStorage().removeUserData();
          Navigator.pushReplacement(context,
              Helper.navigationFadeIn(context, const LoginPage(), 800));
        },
      ));
    } else {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(value);
        // _pageController.jumpTo(value);
      }
    }
  }

  //! verifZo
  _backPage(bool value) async {
    //? VERIFICAMOS FECHA DE CADUCIDAD DEL TOKEN
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final validToken = await Helper.tokenValidityCheck();

    if (!validToken) {
      fp.showAlert(
          content: AlertGenericError(
        message:
            "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
        messageButton: "Entendido!",
        onPress: () async {
          fp.dismissAlert();
          await UserDataStorage().removeUserData();
          Navigator.pushReplacement(context,
              Helper.navigationFadeIn(context, const LoginPage(), 800));
        },
      ));
    } else {
      if (_pageController.hasClients) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOut);
      }
      setState(() {
        currentPage = currentPage + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final inspection = widget.inspection;

    return ChangeNotifierProvider(
      create: (newContextRRP) => ReviewRequestProvider(),
      child: Stack(
        children: [
          BackGround(size: size),
          Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBarHome(context),
              body: Column(
                children: [
                  Container(
                    height: 5,
                    color: AppConfig.appThemeConfig.primaryColor,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: size.width,
                      child: Column(
                        children: [
                          Expanded(
                              child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              //? DATA PERSONAL
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: PersonalDataFormWidget(
                                    inspection: inspection,
                                    dataClientForm: widget.dataClientForm,
                                    onContinueFlag: _nextPage),
                              ),
                              //? INFORMACION DE CONTACTO
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: ContactInformationFormWidget(
                                    inspection: inspection,
                                    dataClientForm: widget.dataClientForm,
                                    onNextFlag: _nextPage,
                                    onBackFlag: _backPage),
                              ),
                              //? DATOS DE ACTIVOS
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: ActivesDataFormWidget(
                                    inspection: inspection,
                                    onBackFlag: _backPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? DATOS DE VEHICULO
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: VehiclesDataFormWidget(
                                    inspection: inspection,
                                    onBackFlag: _backPage,
                                    onJumpFlag: _jumpPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? ACCESORIOS DE VEHICULO
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: VehiclesAccessoriesDataFormWidget(
                                    inspection: inspection,
                                    onBackFlag: _backPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? FOTOS/VIDEO
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                child: MediaFormWidget(
                                    durationVideo: inspection.duracionVideo,
                                    idRequest: inspection.idSolicitud,
                                    mediaInfo: mediaInfo,
                                    onBackFlag: _backPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? DATOS DE VEHICULO 2
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: VehicleData2FormWidget(
                                    inspection: widget.inspection,
                                    dataClientForm: widget.dataClientForm,
                                    onBackFlag: _backPage,
                                    onJumpFlag: _jumpPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? BORRADOR - DATOS FACTURA
                              Container(
                                height: size.height,
                                width: size.width,
                                margin: const EdgeInsets.all(16),
                                color: Colors.white,
                                child: InvoiceDetailForm(
                                    inspection: widget.inspection,
                                    dataClientForm: widget.dataClientForm,
                                    onBackFlag: _backPage,
                                    onJumpFlag: _jumpPage,
                                    onNextFlag: _nextPage),
                              ),
                              //? FOTO FACTURA
                              if (widget.inspection.idTipoFlujo == 6)
                                Container(
                                  height: size.height,
                                  width: size.width,
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.white,
                                  child: FacturaForm(
                                      onNextFlag: _nextPage,
                                      onBackFlag: _backPage,
                                      idRequest: widget.inspection.idSolicitud),
                                ),
                              //?RECONOCIMIENTO FACIAL
                              Container(
                                height: size.height,
                                width: size.width,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(10),
                                color: Colors.white,
                                child: FacialRecognitionForm(
                                    onBackFlag: _backPage,
                                    onSetFlag: _saveInspection,
                                    idRequest: widget.inspection.idSolicitud),
                              )
                            ],
                          )),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: const BottomInfo()),
          const AlertModal(),
          const NotificationModal()
        ],
      ),
    );
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }

  AppBar _appBarHome(BuildContext context) {
    return AppBar(
      backgroundColor: AppConfig.appThemeConfig.secondaryColor,
      title: const Text.rich(TextSpan(children: [
        TextSpan(
            text: 'Inspección ',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextSpan(
            text: '- Informacion del cliente',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300))
      ])),
      leading: IconButton(
          onPressed: () {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            fp.showAlert(content: const AlertLoseProcess());
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
      actions: [
        if (widget.inspection.pdfAdjunto != "")
          IconButton(
              onPressed: () {
                //debugPrint(widget.inspection.pdfAdjunto);
                //debugPrint('----------------------------');
                //go to open file
                _launchInBrowser(Uri.parse(widget.inspection.pdfAdjunto));
              },
              color: Colors.white,
              icon: const Icon(Icons.picture_as_pdf))
      ],
    );
  }
}
