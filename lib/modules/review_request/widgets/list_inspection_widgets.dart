part of 'review_request_widgets.dart';

class ListInspectionWidget extends StatefulWidget {
  final List<ListInspectionDataResponse>? listInspection;
  final String? type;
  final TextEditingController controllerSearch;

  const ListInspectionWidget(
      {Key? key,
      required this.listInspection,
      this.type,
      required this.controllerSearch})
      : super(key: key);

  @override
  State<ListInspectionWidget> createState() => _ListInspectionWidgetState();
}

class _ListInspectionWidgetState extends State<ListInspectionWidget> {
//1,2,5 pendientes
  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    if (widget.listInspection != null) {
      if (widget.listInspection!.isNotEmpty) {
        switch (widget.type) {
          case 'pendientes':
            widget.listInspection!
                .where((element) => (element.idEstadoInspeccion == 1 ||
                    element.idEstadoInspeccion == 2 ||
                    element.idEstadoInspeccion == 5))
                .map((e) => children.add(_CardWidget(
                    inspection: e, controllerSearch: widget.controllerSearch)))
                .toList();
            // widget.listInspection?.forEach((element) {
            //   if (element.idEstadoInspeccion == 1 ||
            //       element.idEstadoInspeccion == 2 ||
            //       element.idEstadoInspeccion == 5
            //       //||
            //       //element.idEstadoInspeccion != 12
            //       ) {
            //     children.add(_CardWidget(inspection: element,controllerSearch: widget.controllerSearch,));
            //   }
            // });
            break;
          case 'finalizadas':
            widget.listInspection!
                .where((element) => (element.idEstadoInspeccion != 1 &&
                        element.idEstadoInspeccion != 2 &&
                        element.idEstadoInspeccion != 5 ||
                    element.idEstadoInspeccion == 12))
                .map((e) => children.add(_CardWidget(
                    inspection: e, controllerSearch: widget.controllerSearch)))
                .toList();
            // widget.listInspection?.forEach((element) {
            //   if (element.idEstadoInspeccion != 1 &&
            //       element.idEstadoInspeccion != 2 &&
            //       element.idEstadoInspeccion != 5 ||
            //       element.idEstadoInspeccion == 12) {
            //     children.add(_CardWidget(inspection: element,controllerSearch: widget.controllerSearch));
            //   }
            // });
            break;
          default:
        }
        if (children.isEmpty) {
          children.add(_NoDataCardWidget(
            state: widget.type!,
          ));
        }
      } else {
        children.add(_NoDataCardWidget(
          state: widget.type!,
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Column(children: children),
    );
  }
}

class _CardWidget extends StatefulWidget {
  final ListInspectionDataResponse inspection;
  final TextEditingController controllerSearch;
  const _CardWidget(
      {Key? key, required this.inspection, required this.controllerSearch})
      : super(key: key);

  @override
  State<_CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<_CardWidget> {
  bool? customerSignature;

  @override
  void initState() {
    // _pendingShipping();
    super.initState();
  }

  Future<bool> pendingShipping({required int idSolicitud}) async {
    ContinueInspection? continueInspection =
        await InspectionStorage().getDataInspection(idSolicitud.toString());
    if (continueInspection != null) {
      Helper.logger.w('customerSignature local: ${continueInspection.finishedInpectionOffline}');
      return continueInspection.finishedInpectionOffline! ? true : false;
      //setState(() {});
    } else {
      Helper.logger.w('customerSignature variable: ${customerSignature}');
      return false;
      // customerSignature = false;
      // setState(() {});
    }
  }

  List<Widget> cardInspecction() {
    return widget.inspection.lista
        .where((search) =>
            search.nombres
                .toLowerCase()
                .contains(widget.controllerSearch.text.toLowerCase().trim()) ||
            search.apellidos
                .toLowerCase()
                .contains(widget.controllerSearch.text.toLowerCase().trim()) ||
            search.datosVehiculo.placa
                .toLowerCase()
                .contains(widget.controllerSearch.text.toLowerCase().trim()) ||
            search.proceso
                .toLowerCase()
                .contains(widget.controllerSearch.text.toLowerCase().trim()) ||
            search.direccion
                .toLowerCase()
                .contains(widget.controllerSearch.text.toLowerCase().trim()) ||
            search.telefono.contains(widget.controllerSearch.text.trim()) ||
            widget.controllerSearch.text == '')
        .map((e) => _CardListWidget(
            list: e,
            idEstadoInspeccion: widget.inspection.idEstadoInspeccion,
            customerSignature: pendingShipping(idSolicitud: e.idSolicitud)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    //final List<Widget> children = [];

    // for (var element in widget.inspection.lista){
    //   children.add(_CardListWidget(list: element, idEstadoInspeccion: widget.inspection.idEstadoInspeccion, customerSignature: customerSignature));
    //   //buttonDownloadInspection: (inspection.idEstadoInspeccion == Helper.coordinated && element.idProceso == Helper.emissionFreeProcesses)));
    // }

    return Card(
        elevation: 0,
        child: InkWell(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.inspection.estadoInspeccion.toUpperCase(),
                    style: TextStyle(
                        fontSize: 12,
                        color: AppConfig.appThemeConfig.primaryColor,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.right),
                Divider(
                  height: 10,
                  thickness: 1.5,
                  color: AppConfig.appThemeConfig.primaryColor,
                ),
                const SizedBox(height: 10),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: cardInspecction())
              ]),
        ));
  }
}

class _CardListWidget extends StatefulWidget {
  final Lista list;
  final int idEstadoInspeccion;
  final Future<bool>? customerSignature;
  //final bool buttonDownloadInspection;

  const _CardListWidget(
      {Key? key,
      required this.list,
      required this.idEstadoInspeccion,
      this.customerSignature})
      : super(key: key);
  //required this.buttonDownloadInspection

  @override
  State<_CardListWidget> createState() => _CardListWidgetState();
}

class _CardListWidgetState extends State<_CardListWidget> {
  TextEditingController bitacoraController = TextEditingController();

  int hayBitacorasButton = 0;
  bool? buttonDownload = true;
  bool? customerSignature;

  final OfflineStorage _offlineStorage = OfflineStorage();

  @override
  void initState() {
    Helper.logger.w(widget.customerSignature.toString());
    widget.customerSignature!.then((value) => customerSignature = value);
    //_pendingShipping();
    getValueButtonDownload();
    super.initState();
  }

  getValueButtonDownload() async {
    //REVISAR ESTE METODO PORQUE HAY PROBLEMAS AL MOSTRAR EL BOTON DE DESCARGAR
    final value = await _offlineStorage.getDownloadButtonInspecction(
        idSolicitud: widget.list.idSolicitud);
    if (value != false) {
      buttonDownload = value;
    } else {
      buttonDownload = false;
    }

    setState(() {});
  }

  // _pendingShipping() async {
  //   ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.list.idSolicitud.toString());
  //   if(continueInspection != null){
  //     //Helper.logger.w('customerSignature local: ${continueInspection.finishedInpectionOffline}');
  //     customerSignature = continueInspection.finishedInpectionOffline! ? true : false;
  //     setState(() {});
  //   }else{
  //     customerSignature = false;
  //     //Helper.logger.w('customerSignature variable: ${customerSignature}');
  //     setState(() {});
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    //final fp = Provider.of<FunctionalProvider>(context,listen: false);
    // Helper.logger.w('creacionOffline: ${widget.list.creacionOffline}');
    // Helper.logger.w('creacionOffline: ${widget.list.}');
    return InkWell(
        splashColor: AppConfig.appThemeConfig.secondaryColor,
        onTap: () {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                  builder: (_) =>
                      InspectionDetailPage(inspection: widget.list)));
        },
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ElevatedButton(
              //   onPressed: (){
              //     _pendingShipping();
              //   },
              //   child: Text('texto')
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Visibility(
                    visible: customerSignature ?? false,
                    child: Chip(
                      backgroundColor: Colors.black12,
                      label: Text('Finalizada offline',
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      avatar: Icon(Icons.label,
                          color: AppConfig.appThemeConfig.primaryColor),
                    ),
                  ),
                  //SizedBox(width: 20),
                  Visibility(
                    visible:
                        widget.list.haveAdvertObservation == 1 ? true : false,
                    child: WidgetAnimation(
                        child: CircleAvatar(
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(Icons.warning,
                                  color: Colors.white),
                              onPressed: () async {
                                final fp = Provider.of<FunctionalProvider>(
                                    context,
                                    listen: false);

                                if (!fp.offline) {
                                  final response =
                                      await PlateObservationService()
                                          .getObservationsPlate(context,
                                              plate: widget
                                                  .list.datosVehiculo.placa);

                                  if (!response.error) {
                                    fp.showAlert(
                                        content: AlertObservationsPlateWidget(
                                            observations: response.data!));
                                  } else {
                                    fp.showAlert(
                                        content: AlertGenericError(
                                            message: response.message));
                                  }
                                } else {
                                  Helper.snackBar(
                                      context: context,
                                      message: 'Te encuentras en modo offline.',
                                      colorSnackBar: Colors.red);
                                }
                              },
                            ))),
                  )
                ],
              ),
              const SizedBox(height: 5),
              // customerSignature == true ?
              //   Chip(
              //     backgroundColor: Colors.black12,
              //     label: Text('Finalizada offline', style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
              //     avatar: Icon(Icons.label, color: AppConfig.appThemeConfig.primaryColor),
              //   )
              //   // child: IconButton(
              //   //   color: AppConfig.appThemeConfig.primaryColor,
              //   //   onPressed: (){

              //   //   },
              //   //   icon: const Icon(Icons.label)
              //   // ),
              // : const SizedBox(),
              // WidgetAnimation(
              //   child: CircleAvatar(
              //     backgroundColor: const Color(0xffffc107),
              //     child: IconButton(
              //       icon: const Icon(Icons.warning, color: Colors.white),
              //       onPressed: (){

              //       },
              //     )
              //   )
              // ),
              //Text(customerSignature ? 'enviar': 'no enviar'),
              if (widget.list.nombres.isNotEmpty)
                Text(widget.list.nombres + ' ' + widget.list.apellidos,
                    style: TextStyle(
                        color: AppConfig.appThemeConfig.secondaryColor,
                        fontWeight: FontWeight.bold)),
              if (widget.list.razonSocial.isNotEmpty)
                Text(widget.list.razonSocial,
                    style: TextStyle(
                        color: AppConfig.appThemeConfig.secondaryColor,
                        fontWeight: FontWeight.bold)),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Fecha: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: (widget.list.fechaInspeccion != null)
                        ? Helper().dateToStringFormat(
                            widget.list.fechaInspeccion!, 'dd-MM-yyyy')
                        : "--/--/----",
                    style: const TextStyle(fontWeight: FontWeight.w300))
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Placa: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: widget.list.datosVehiculo.placa,
                    style: const TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.red))
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Proceso: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: widget.list.proceso,
                    style: const TextStyle(fontWeight: FontWeight.w300))
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Hora de Inspección: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: widget.list.horaInspeccion,
                    style: const TextStyle(fontWeight: FontWeight.w300))
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'Dirección: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: widget.list.direccion,
                    style: const TextStyle(fontWeight: FontWeight.w300))
              ])),
              Text.rich(TextSpan(children: [
                const TextSpan(
                    text: 'N° Teléfono: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: widget.list.telefono,
                    style: const TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.red))
              ])),
              //aqui debo colocar el boton
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  widget.list.hayBitacoras > 0 || hayBitacorasButton > 0
                      ? TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                              alignment: Alignment.centerRight,
                              backgroundColor:
                                  AppConfig.appThemeConfig.primaryColor),
                          onPressed: () async {
                            final fp = Provider.of<FunctionalProvider>(context,
                                listen: false);
                            if (!fp.offline) {
                              final response = await RequestBitacoraServices()
                                  .getlistBitacora(
                                      context, widget.list.idSolicitud);
                              if (!response.error) {
                                fp.showAlert(
                                    content: ListBitacoraWidget(
                                        bitacora: response.data!));
                              }
                            } else {
                              Helper.snackBar(
                                  context: context,
                                  message:
                                      'No tienes conexión a internet, porque estas en modo offline.',
                                  colorSnackBar: Colors.red);
                            }
                          },
                          child: const Text(
                            'Ver Gestiones',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const SizedBox(),
                  const SizedBox(width: 10),
                  widget.list.mostrarBotonRegistrarBitacora == 1
                      ? TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                              alignment: Alignment.centerRight,
                              backgroundColor:
                                  AppConfig.appThemeConfig.secondaryColor),
                          onPressed: () {
                            final fp = Provider.of<FunctionalProvider>(context,
                                listen: false);
                            fp.showAlert(
                                content: _RegistryBitacora(
                              bitacoraController: bitacoraController,
                              idSolicitud: widget.list.idSolicitud,
                              onPressed: () async {
                                debugPrint('hace algo');
                                final fp = Provider.of<FunctionalProvider>(
                                    context,
                                    listen: false);
                                debugPrint(
                                    'Solicitud: ${widget.list.idSolicitud}');
                                debugPrint(
                                    'detalle: ${bitacoraController.text}');
                                if (!fp.offline) {
                                  final response =
                                      await RequestBitacoraServices()
                                          .registryBitacora(
                                              context,
                                              widget.list.idSolicitud,
                                              bitacoraController.text);
                                  if (!response.error) {
                                    hayBitacorasButton++;
                                    setState(() {});
                                    fp.showAlert(
                                        content: const AlertSuccess(
                                            message:
                                                'Bitacora registrada con exito'));
                                    Future.delayed(
                                        const Duration(milliseconds: 2000), () {
                                      bitacoraController.clear();
                                      fp.dismissAlert();
                                    });
                                  } else {
                                    fp.showAlert(
                                        content: AlertGenericError(
                                      message: 'Ocurrio un error',
                                      onPress: () {
                                        fp.dismissAlert();
                                      },
                                    ));
                                  }
                                } else {
                                  bitacoraController.clear();
                                  fp.dismissAlert();
                                  Helper.snackBar(
                                      context: context,
                                      message:
                                          'No tienes conexión a internet, porque estas en modo offline.',
                                      colorSnackBar: Colors.red);
                                }
                              },
                            ));
                          },
                          child: const Text(
                            'Registrar Gestión',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(width: 10),
                  //widget.buttonDownloadInspection ?
                  (widget.idEstadoInspeccion == Helper.coordinated &&
                          widget.list.idProceso ==
                              Helper.emissionFreeProcesses &&
                          !widget.list.creacionOffline)
                      ? //!fp.offline
                      (buttonDownload == true
                          ? WidgetAnimation(
                              child: CircleAvatar(
                                backgroundColor:
                                    AppConfig.appThemeConfig.primaryColor,
                                child: IconButton(
                                  icon: const Icon(Icons.download,
                                      color: Colors.white),
                                  onPressed: () async {
                                    final fp = Provider.of<FunctionalProvider>(
                                        context,
                                        listen: false);
                                    bool exists =
                                        await Helper.verifyCatalogueStorage();

                                    if (exists) {
                                      fp.showAlert(
                                          content: AlertConfirm(
                                        message:
                                            '¿Desea descargar esta inspeccion para continuar en modo offline?',
                                        confirm: () async {
                                          //_offlineStorage.deleleteInspecctionOffline();
                                          bool exist = ReviewRequestPage
                                              .listInspectionCoordinated
                                              .any((element) =>
                                                  element.idSolicitud ==
                                                  widget.list.idSolicitud);
                                          if (!exist) {
                                            //ReviewRequestPage.listInspectionCoordinated.add(widget.list);
                                            ReviewRequestPage
                                                .listInspectionCoordinated
                                                .insert(0, widget.list);
                                            _offlineStorage
                                                .setListInspectionOffline(
                                                    ReviewRequestPage
                                                        .listInspectionCoordinated);
                                            _offlineStorage
                                                .setDownloadButtonInspecction(
                                                    idSolicitud: widget
                                                        .list.idSolicitud);
                                            setState(() {
                                              buttonDownload = false;
                                            });
                                            fp.showAlert(
                                                content: const AlertSuccess(
                                                    message:
                                                        'La inspección ha sido descargado con exito.',
                                                    messageButton: 'Aceptar'));
                                            // Future.delayed(const Duration(milliseconds: 2000),
                                            //     () {
                                            //      bitacoraController.clear();
                                            //   fp.dismissAlert();
                                            // });
                                            // debugPrint('registrada');
                                            // fp.dismissAlert();
                                          } else {
                                            fp.showAlert(
                                                content: const AlertGenericError(
                                                    message:
                                                        'La inspección que intentas descarga, ya se encuentra descargada.',
                                                    messageButton: 'Aceptar'));
                                            //fp.dismissAlert();
                                          }
                                        },
                                      ));
                                    } else {
                                      fp.showAlert(
                                          content: AlertGenericError(
                                        messageButton: 'Ir a los catalogos',
                                        message:
                                            'No se puede descargar la inspección, porque no has descargado algunos de los catalogos para continuar en modo offline.',
                                        onPress: () {
                                          fp.dismissAlert();
                                          Navigator.pushReplacement(
                                              context,
                                              Helper.navigationFadeIn(
                                                  context,
                                                  const OfflineConfigurationPage(),
                                                  500));
                                        },
                                      ));
                                    }
                                  },
                                ),
                              ),
                            )
                          : const SizedBox(height: 5))
                      // TextButton.icon(
                      //   style: TextButton.styleFrom(
                      //   //textStyle: const TextStyle(fontSize: 1000, color: Colors.white),
                      //     alignment: Alignment.centerRight,
                      //     backgroundColor: AppConfig.appThemeConfig.primaryColor),
                      //   icon: const Icon(Icons.download, color: Colors.white),
                      //   label: const Text('Descargar la inspección', style: TextStyle(fontSize: 12, color: Colors.white) ),
                      //   onPressed: ()  async{
                      //     final data = await _offlineStorage.getListInspectionOffline();
                      //       Helper.logger.log(Level.trace, data!.first.lista.length.toString());
                      //     //_CardListWidget.listBitacora.add(widget.list);
                      //     // bool exist = _CardListWidget.listBitacora.any((element) => element.idSolicitud == widget.list.idSolicitud);
                      //     // if(!exist){
                      //     //   _CardListWidget.listBitacora.add(widget.list);
                      //     //   _offlineStorage.setListInspectionOffline(_CardListWidget.listBitacora);
                      //     //   debugPrint('registrada');
                      //     // }else{
                      //     //   debugPrint('ya esta registrada');
                      //     // }

                      //   },
                      // )
                      : const SizedBox(height: 5),
                ],
              ),
              //aqui coloco si el estado es
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // widget.idEstadoInspeccion == 2 && widget.list.idProceso == 49 ?
                  // TextButton.icon(
                  //   style: TextButton.styleFrom(
                  //   //textStyle: const TextStyle(fontSize: 1000, color: Colors.white),
                  //     alignment: Alignment.centerRight,
                  //     backgroundColor: AppConfig.appThemeConfig.primaryColor),
                  //   icon: const Icon(Icons.download, color: Colors.white),
                  //   label: const Text('Descargar la inspección', style: TextStyle(fontSize: 12, color: Colors.white) ),
                  //   onPressed: ()  async{
                  //     final data = await _offlineStorage.getListInspectionOffline();
                  //       Helper.logger.log(Level.trace, data!.first.lista.length.toString());
                  //     //_CardListWidget.listBitacora.add(widget.list);
                  //     // bool exist = _CardListWidget.listBitacora.any((element) => element.idSolicitud == widget.list.idSolicitud);
                  //     // if(!exist){
                  //     //   _CardListWidget.listBitacora.add(widget.list);
                  //     //   _offlineStorage.setListInspectionOffline(_CardListWidget.listBitacora);
                  //     //   debugPrint('registrada');
                  //     // }else{
                  //     //   debugPrint('ya esta registrada');
                  //     // }

                  //   },
                  // ) : const SizedBox(height: 5),
                  widget.idEstadoInspeccion == 5
                      ? TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 12),
                              alignment: Alignment.centerRight,
                              backgroundColor:
                                  AppConfig.appThemeConfig.primaryColor),
                          onPressed: () async {
                            final fp = Provider.of<FunctionalProvider>(context,
                                listen: false);

                            try {
                              final dataMedia = await MediaDataStorage()
                                  .getMediaData(widget.list.idSolicitud);

                              if (dataMedia != null) {
                                final List<MediaStorage> mediaNotUploaded = [];
                                for (var item in dataMedia) {
                                  if (item.status != 'UPLOADED' &&
                                      item.status != 'NO_MEDIA') {
                                    debugPrint(
                                        'Archivo a reenviar: ${item.type} - ${item.idArchiveType} - ${item.status}');
                                    mediaNotUploaded.add(item);
                                  }
                                }
                                fp.showAlert(
                                    content: AlertResendMedia(
                                        idRequest: widget.list.idSolicitud,
                                        identification:
                                            widget.list.identificacion,
                                        mediaData: mediaNotUploaded));
                              } else {
                                debugPrint(
                                    'Error al obtener datos multimedia para reenviar');
                                fp.showAlert(
                                    content: const AlertGenericError(
                                        messageButton:
                                            'Intentar subir desde galería',
                                        message:
                                            'Ha ocurrido un error con los datos multimedia'));
                              }
                            } catch (error, stackTrace) {
                              FirebaseCrashlytics.instance.recordError(
                                  error, stackTrace,
                                  reason: 'Error al reenviar archivos',
                                  fatal: true);
                            }
                          },
                          child: const Text(
                            'Reenviar Archivos',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : const SizedBox(
                          height: 5,
                        ),
                  const Divider(
                    height: 10,
                    color: Colors.grey,
                  )
                ],
              ),
            ]));
  }
}

class _RegistryBitacora extends StatefulWidget {
  final int idSolicitud;
  final void Function()? onPressed;
  final TextEditingController bitacoraController;
  const _RegistryBitacora(
      {required this.idSolicitud,
      required this.onPressed,
      required this.bitacoraController});

  @override
  State<_RegistryBitacora> createState() => _RegistryBitacoraState();
}

class _RegistryBitacoraState extends State<_RegistryBitacora> {
  // TextEditingController bitacoraController = TextEditingController();
  bool isActive = false;

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   widget.bitacoraController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        height: size.height * 0.58,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Registro de Gestión',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.appThemeConfig.primaryColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: TextFieldWidget(
                  multiline: true,
                  label: 'Ingrese el detalle',
                  maxLength: 500,
                  controller: widget.bitacoraController,
                  maxLines: 9,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9.,\sñÑáéíóúÁÉÍÓÚüÜ\-]+'))
                    // FilteringTextInputFormatter.allow(
                    //     RegExp(r'[\-$/$a-zA-Z0-9.,\s]')),
                  ],
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      isActive = true;
                      setState(() {});
                    } else {
                      isActive = false;
                      setState(() {});
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        textStyle: const TextStyle(fontSize: 20),
                        alignment: Alignment.centerRight,
                        backgroundColor:
                            AppConfig.appThemeConfig.secondaryColor),
                    onPressed: () {
                      final fp = Provider.of<FunctionalProvider>(context,
                          listen: false);
                      fp.dismissAlert();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(10),
                        textStyle: const TextStyle(fontSize: 20),
                        alignment: Alignment.centerRight,
                        backgroundColor: isActive
                            ? AppConfig.appThemeConfig.primaryColor
                            : Colors.grey),
                    onPressed: isActive ? widget.onPressed : null,
                    // () async {
                    //   final fp = Provider.of<FunctionalProvider>(context,
                    //       listen: false);
                    //   debugPrint('Solicitud: ${widget.idSolicitud}');
                    //   debugPrint('detalle: ${bitacoraController.text}');
                    // final response = await RequestBitacoraServices()
                    //     .getlistBitacora(context, 200);
                    // if (!response.error) {
                    //   fp.showAlert(
                    //       content:
                    //           ListBitacoraWidget(bitacora: response.data!));

                    //   // debugPrint(response.data!.first.detalle);
                    // }
                    // },
                    child: const Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDataCardWidget extends StatelessWidget {
  final String state;
  const _NoDataCardWidget({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Text('Actualmente no cuentas con inspecciones ' + state,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        const SizedBox(
          height: 20,
        ),
        const Image(
          image: AssetImage('assets/revision-solicitud.png'),
          fit: BoxFit.contain,
          width: 100,
          height: 100,
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
