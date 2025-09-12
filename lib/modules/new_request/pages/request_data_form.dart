import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
// import 'package:awesome_select/awesome_select.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/new_request.dart';
// import 'package:sweaden_old_new_version/modules/new_request/providers/new_request_provider.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/new_request/widgets/new_request_widgets.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/helper/request_offline.dart';
import 'package:sweaden_old_new_version/shared/models/executive_response.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart'
    as list_request;
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/request_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class RequestDataForm extends StatefulWidget {
  final void Function(int) navigateToPage;
  final List<ListabrokerElement> brokerList;
  final List<ListaIdentifElement> processList;
  final ConfiguracionInicial initialConfig;
  final List<ListaRamoElement> branchesList;
  final List<Listaagencia> agenciesList;
  final List<ListaIdentifElement> requestsList;
  const RequestDataForm(
      {Key? key,
      required this.brokerList,
      required this.processList,
      required this.initialConfig,
      required this.branchesList,
      required this.agenciesList,
      required this.requestsList,
      required this.navigateToPage})
      : super(key: key);

  @override
  State<RequestDataForm> createState() => _RequestDataFormState();
}

class _RequestDataFormState extends State<RequestDataForm>
    with AutomaticKeepAliveClientMixin {
  TextEditingController pruebaControl = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool checkBoxReassignment = false;
  String reassignment = 'NO';
  //? SELECT DE BROKER
  String selectedBroker = '¿Cual es el broker del cliente?';
  String selectedBrokerValue = '';
  bool brokerSelected = false;
  //? SELECT DE PROCESO
  String selectedProcessType = 'Seleccione el tipo de proceso';
  String selectedProcessTypeValue = '';
  bool processTypeSelected = false;
  //? SELECT DE RAMO
  String selectedBranchType = 'Seleccione el tipo de Ramo';
  String selectedBranchTypeValue = '';
  bool branchSelected = false;
  //? SELECT DE PRODUCTO
  String selectedProductType = '¿Cual es el producto adquirido?';
  String selectedProductTypeValue = '';
  bool productSelected = false;
  //? SELECT DE AGENCIA
  String selectedAgencyType = 'Agencia de emisión';
  String selectedAgencyTypeValue = '';
  // bool agencySelected = false;
  bool showAllAgencies = false;
  //? SELECT DE AGENCIA
  String selectedExecutiveType = 'Seleccione ejecutivo';
  String selectedExecutiveTypeValue = '';
  Ejecutivo? selectedExecutiveMeta;
  //? SELECT DE AGENCIA
  String selectedInspectionAgencyType = 'Agencia inspección';
  String selectedInspectionAgencyTypeValue = '';
  //? SELECT DE TIPO DE FLUJO
  String selectedFlowType = 'Seleccione el tipo de flujo';
  String selectedFlowTypeValue = '';
  //? SELECT DE POLIZA MADRE(cuando el tipo de flujo es "sin inspeccion")
  String selectedMotherPolicyType = 'Seleccione póliza madre';
  String selectedMotherPolicyValue = '';
  //? SELECT DE Deducibles
  String selectedDeductibleType = 'Seleccione el deducible';
  String selectedDeductibleTypeValue = '';

  //? Para saber si soy un Broker
  bool amBroker = false;
  String? idBroker;
  String? deductibleValue;
  String isQuotedProduct = 'NO';
  // String? polizaMadre;

  //? LISTAS PARA SELECT
  List<S2Choice<String>> brokersList = [];
  List<S2Choice<String>> processList = [];
  ConfiguracionInicial? initialConfig;
  List<S2Choice<String>> branchesList = [];
  List<S2Choice<String>> productsList = [];
  //? TODAS LAS AGENCIAS
  List<S2Choice<String>> agenciesList = [];
  //? EN CASO DE QUE LA AGENCIA DE EMISION SOLO SEA UNA
  List<S2Choice<String>> agency = [];
  //? TODOS LOS EJECUTIVOS
  List<S2Choice<String>> exectutivesList = [];
  List<S2Choice<String>> inspectionAgencyList = [];
  List<S2Choice<String>> policiescList = [];
  List<S2Choice<String>> requestsList = [];
  List<S2Choice<String>> deductiblesList = [];
  TextEditingController sumAssuredController = TextEditingController();
  TextEditingController vehiclePlateController = TextEditingController();
  TextEditingController vehicleYearController = TextEditingController();

  TextEditingController correo1 = TextEditingController();
  TextEditingController correo2 = TextEditingController();
  //! TextEditingController calendarController = TextEditingController();
  //! TextEditingController timepickerController = TextEditingController();
  String sumAssuredAux = '';
  // bool canRegister = false;
  bool formCompleted = false;
  int ageAllowed = 0;

  int durationVideo = 0;

  bool existErrorVehiclePlate = true;

  bool isCorreo2 = true;

  late FunctionalProvider fp;

  final OfflineStorage _offlineStorage = OfflineStorage();

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    _loadSpecificData();
    //! _loadDatePicker();

    super.initState();
  }

  @override
  void dispose() {
    sumAssuredController.dispose();
    vehiclePlateController.dispose();
    vehicleYearController.dispose();
    //! calendarController.dispose();
    //! timepickerController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  // ! CARGA DE DATEPICKER CON UNA +HORA
  // _loadDatePicker() {
  //   calendarController.text = DateTime.now().toString().split(" ")[0];
  //   var hour = (TimeOfDay.now().hour + 1).toString();
  //   hour = (int.parse(hour) > 9) ? hour : '0$hour';
  //   var minute = TimeOfDay.now().minute.toString();
  //   minute = (int.parse(minute) > 9) ? minute : '0$minute';
  //   final amPm = (int.parse(hour) < 12) ? 'AM' : 'PM';
  //   timepickerController.text = '$hour:$minute $amPm';
  // }

  _loadSpecificData() async {
    //? 1. Cargamos los Brokers
    await _loadBrokers();
    _loadProcess();
    _loadInitialConfig();
    _loadBranches();
    _loadAgencies();
    _loadRequests();
    setState(() {});
  }

  _loadBrokers() async {
    final userData = await UserDataStorage().getUserData();
    if (userData!.informacion.idBroker != null) {
      amBroker = true;
      idBroker = userData.informacion.idBroker;
    } else {
      brokersList = widget.brokerList
          .map((e) =>
              S2Choice(value: e.codigo, title: e.descripcion, meta: e.estado))
          .toList();
      amBroker = false;
    }
  }

  _loadProcess() {
    processList = widget.processList
        .map((e) => S2Choice(value: e.codigo.toString(), title: e.descripcion))
        .toList();
  }

  _loadInitialConfig() {
    initialConfig = widget.initialConfig;
  }

  _loadBranches() {
    branchesList = widget.branchesList
        .map((e) =>
            S2Choice(value: e.codigo, title: e.descripcion, meta: e.estado))
        .toList();
  }

  _loadAgencies() {
    agenciesList = widget.agenciesList
        .map((e) => S2Choice(value: e.codigo, title: e.descripcion))
        .toList();
  }

  _loadRequests() {
    requestsList = widget.requestsList
        .map((e) => S2Choice(value: e.codigo.toString(), title: e.descripcion))
        .toList();
  }

  FilePickerResult? _filePickerResult;
  bool pdfUploaded = false;

  Future<void> _pickPDF() async {
    //final fp = Provider.of<FunctionalProvider>(context, listen: false);

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    setState(() {
      _filePickerResult = result;

      if (result != null && result.files.isNotEmpty) {
        int maxSizeInBytes = 5 * 1024 * 1024; // 5 MB

        if (result.files.single.size <= maxSizeInBytes &&
            result.files.single.extension!.toLowerCase() == 'pdf') {
          pdfUploaded = true;
        } else {
          pdfUploaded = false;

          if (result.files.single.size > maxSizeInBytes) {
            fp.showAlert(
                content: const AlertGenericError(
                    message: 'El peso máximo permitido es de 5MB'));
          } else {
            fp.showAlert(
                content: const AlertGenericError(
                    message: 'Por favor, seleccione un archivo PDF'));
          }
        }
      } else {
        pdfUploaded = false;
      }
    });
  }

  //Funcion para convertir el archivo PDF seleccionado a base64
  Future<String?> _convertPDFToBase64() async {
    if (_filePickerResult != null) {
      PlatformFile file = _filePickerResult!.files.first;
      List<int> bytes = await File(file.path!).readAsBytes();
      String base64PDF = base64Encode(bytes);
      return base64PDF;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: FadeInDown(
        child: Column(
          children: [
            _inspectionReassignment(),
            if (brokersList.isNotEmpty) _brokerSelect(),
            if (processList.isNotEmpty) _processType(),
            //!BOTONES DE NAVEGACION
            _navigationButtons()
          ],
        ),
      ),
    );
  }

  Column _navigationButtons() {
    // final nrp = Provider.of<NewRequestProvider>(context, listen: false);
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                onPressed: () {
                  // nrp.navigateToScreen(0);
                  widget.navigateToPage(0);
                },
                child: Row(
                  children: const [
                    Icon(Icons.arrow_back),
                    SizedBox(
                      width: 5,
                    ),
                    Text('Atras'),
                  ],
                )),
            const SizedBox(
              width: 10,
            ),
            if (formCompleted && !existErrorVehiclePlate) _registerButton()
          ],
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }

  final _emailRegExp =
      RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$');

  bool _isEmailValid(String email) {
    return _emailRegExp.hasMatch(email);
  }

  Expanded _registerButton() {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: FadeInUp(
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  backgroundColor: AppConfig.appThemeConfig.primaryColor),
              onPressed: () async {
                Helper.dismissKeyboard(context);
                //final fp =  Provider.of<FunctionalProvider>(context, listen: false);

                // Obtener el contenido base64 del PDF, si se ha seleccionado uno.
                String? pdfAdjunto = await _convertPDFToBase64();

                // Crear la solicitud
                Request request = await RequestDataStorage().getRequestData();
                if (request.dataSolicitud != null) {
                  // Si se ha seleccionado un archivo PDF, incluir el contenido base64 en la solicitud.
                  if (pdfAdjunto != null) {
                    request.dataSolicitud!.pdfAdjunto =
                        'data:application/pdf;base64,$pdfAdjunto';

                    // Verificar el resultado en consola antes de enviar la solicitud
                    debugPrint('Contenido base64 del PDF: $pdfAdjunto');
                  } else {
                    request.dataSolicitud!.pdfAdjunto = '';
                  }

                  final data = await UserDataStorage().getUserData();
                  if (amBroker) {
                    selectedBroker = data!.informacion.nombre;
                    request.dataSolicitud!.idAgenciaInspeccion =
                        (reassignment == "SI")
                            ? "01"
                            : selectedInspectionAgencyTypeValue;
                  } else {
                    request.dataSolicitud!.idAgenciaInspeccion =
                        (reassignment == "SI")
                            ? data!.informacion.agencia
                            : selectedInspectionAgencyTypeValue;
                  }
                  // Resto del código para configurar la solicitud...

                  if (request.dataSolicitud != null) {
                    final data = await UserDataStorage().getUserData();
                    if (amBroker) {
                      selectedBroker = data!.informacion.nombre;
                      request.dataSolicitud!.idAgenciaInspeccion =
                          (reassignment == "SI")
                              ? "01"
                              : selectedInspectionAgencyTypeValue;
                    } else {
                      request.dataSolicitud!.idAgenciaInspeccion =
                          (reassignment == "SI")
                              ? data!.informacion.agencia
                              : selectedInspectionAgencyTypeValue;
                    }
                    request.dataSolicitud!.idBroker =
                        (amBroker) ? idBroker : selectedBrokerValue;
                    request.dataSolicitud!.nombreBroker = selectedBroker;
                    request.dataSolicitud!.idProceso = selectedProcessTypeValue;
                    request.dataSolicitud!.idRamo = selectedBranchTypeValue;
                    request.dataSolicitud!.ramo = selectedBranchType;
                    request.dataSolicitud!.idProducto =
                        (selectedProcessTypeValue == "49")
                            ? null
                            : selectedProductTypeValue;
                    request.dataSolicitud!.producto =
                        (selectedProcessTypeValue == "49")
                            ? null
                            : selectedProductType;
                    request.dataSolicitud!.idAgencia = selectedAgencyTypeValue;
                    request.dataSolicitud!.agencia = selectedAgencyType;
                    request.dataSolicitud!.ejecutivo = selectedExecutiveMeta;

                    request.dataSolicitud!.idTipoFlujo = selectedFlowTypeValue;
                    request.dataSolicitud!.datosVehiculo = DatosVehiculo(
                        anio: vehicleYearController.text,
                        placa: vehiclePlateController.text,
                        deducible: (selectedDeductibleTypeValue.isEmpty)
                            ? '0'
                            : selectedDeductibleTypeValue,
                        sumaAsegurada: sumAssuredController.text);
                    request.dataSolicitud!.idTipoSolicitud = "7";
                    //! request.dataSolicitud!.fechaInspeccion =
                    //!     calendarController.text;
                    //! request.dataSolicitud!.horaInspeccion =
                    //!     timepickerController.text.split(' ')[0];
                    request.dataSolicitud!.reasignado = reassignment;
                    request.dataSolicitud!.idEstado = 1;
                    request.dataSolicitud!.polizaMadre =
                        (selectedMotherPolicyValue.isNotEmpty)
                            ? selectedMotherPolicyValue
                            : '0';
                    request.dataSolicitud!.correo1 =
                        correo1.text.isNotEmpty ? correo1.text : null;
                    request.dataSolicitud!.correo2 =
                        correo2.text.isNotEmpty ? correo2.text : null;
                  }
                  // Enviar la solicitud
                  //Verificar conexion a internet
                  if (!fp.offline) {
                    final response = await NewRequestService()
                        .registerRequest(context, request);
                    if (!response.error) {
                      fp.showAlert(
                          content: const AlertSuccess(
                              message: 'Solicitud creada con éxito!'));
                      Future.delayed(const Duration(milliseconds: 2000), () {
                        fp.dismissAlert();
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: const HomePage(),
                            type: PageTransitionType.leftToRightWithFade,
                          ),
                        );
                      });
                    } else {
                      fp.showAlert(
                        content: AlertGenericError(
                          messageButton: 'Entendido',
                          onPress: () {
                            //final fp = Provider.of<FunctionalProvider>(context, listen: false);
                            RequestDataStorage().removeRequestData();
                            fp.dismissAlert();
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const HomePage(),
                                type: PageTransitionType.leftToRightWithFade,
                              ),
                            );
                          },
                          message:
                              'Algo salió mal. Por favor, inténtalo de nuevo más tarde.',
                        ),
                      );
                    }
                  } else {
                    try {
                      if (NewRequestPage.listCreatingrequests.isNotEmpty) {
                        Request requestIdSolicitudTemp =
                            NewRequestPage.listCreatingrequests.reduce((a, b) =>
                                a.idSolicitudTemp! > b.idSolicitudTemp!
                                    ? a
                                    : b);
                        request.idSolicitudTemp =
                            requestIdSolicitudTemp.idSolicitudTemp! + 1;
                      } else {
                        request.idSolicitudTemp = int.parse(
                            "${HelperRequestOffline.idRequestHeadBoard}00001");
                      }

                      request.opcion = 'I_OFFLINE';
                      request.uuidRequest = const Uuid().v4();
                      request.dataSolicitud!.idEstadoInspeccion =
                          Helper.coordinated;
                      request.dataSolicitud!.idInspector =
                          NewRequestPage.idInspector != ''
                              ? NewRequestPage.idInspector
                              : null;
                      // log(jsonEncode({'request': (request)}));

                      NewRequestPage.listCreatingrequests.insert(0, request);

                      bool response =
                          await _offlineStorage.saveCreatingRequests(
                              value: NewRequestPage.listCreatingrequests);

                      if (!response) {
                        list_request.Lista requestOffline = list_request.Lista(
                            duracionVideo: durationVideo,
                            idSolicitud: request.idSolicitudTemp!,
                            idTipoSolicitud: int.parse(
                                request.dataSolicitud!.idTipoSolicitud!),
                            tipoSolicitud:
                                request.dataSolicitud!.idTipoSolicitud! == "7"
                                    ? 'Móvil'
                                    : '',
                            idBroker: request.dataSolicitud!.idBroker!,
                            nombreBroker: request.dataSolicitud!.nombreBroker!,
                            idRamo: request.dataSolicitud!.idRamo!,
                            ramo: request.dataSolicitud!.ramo!,
                            idAgencia: request.dataSolicitud!.idAgencia!,
                            agencia: request.dataSolicitud!.agencia!,
                            valorAsegurado: request
                                .dataSolicitud!.datosVehiculo!.sumaAsegurada!,
                            idTipoIdentificacion: int.parse(
                                request.dataSolicitud!.idTipoIdentificacion!),
                            identificacion:
                                request.dataSolicitud!.identificacion!,
                            nombres: request.dataSolicitud!.nombres ?? '',
                            apellidos: request.dataSolicitud!.apellidos ?? '',
                            razonSocial:
                                request.dataSolicitud!.razonSocial ?? '',
                            fechaInspeccionCompleta: null,
                            fechaInspeccion: null,
                            horaInspeccion: null,
                            telefono: request.dataSolicitud!.telefono!,
                            direccion: request.dataSolicitud!.direccion!,
                            latitud: "0",
                            longitud: "0",
                            idUsuarioCreacion:
                                4, //request.dataSolicitud!.idUsuarioCreacion,
                            usuarioCreacion:
                                'offline', //request.dataSolicitud!.usuarioCreacion,
                            idEstadoInspeccion:
                                request.dataSolicitud!.idEstadoInspeccion!,
                            idTipoFlujo:
                                int.parse(request.dataSolicitud!.idTipoFlujo!),
                            tipoFlujo:
                                request.dataSolicitud!.idTipoFlujo! == "5"
                                    ? 'Con inspección'
                                    : 'Sin inspección', //REVISAR
                            idProducto:
                                request.dataSolicitud!.idProducto ?? "0",
                            polizaMadre: request.dataSolicitud!.polizaMadre,
                            reasignado: request.dataSolicitud!.reasignado,
                            numPoliza: null,
                            pdfAdjunto: request.dataSolicitud!.pdfAdjunto!,
                            idProceso:
                                int.parse(request.dataSolicitud!.idProceso!),
                            proceso: 'Proc sin Emisión',
                            codEjecutivo:
                                request.dataSolicitud!.ejecutivo!.codEjecutivo!,
                            nombreEjecutivo:
                                request.dataSolicitud!.ejecutivo!.nombre!,
                            datosVehiculo: list_request.DatosVehiculo(
                                anio:
                                    request.dataSolicitud!.datosVehiculo!.anio!,
                                placa: request
                                    .dataSolicitud!.datosVehiculo!.placa!,
                                deducible: request.dataSolicitud!.datosVehiculo!.deducible!,
                                sumaAsegurada: request.dataSolicitud!.datosVehiculo!.sumaAsegurada!,
                                id: request.idSolicitudTemp! //REVISAR
                                ),
                            ejecutivo: list_request.Ejecutivo(
                              mail: request.dataSolicitud!.ejecutivo!.mail,
                              nombre: request.dataSolicitud!.ejecutivo!.nombre!,
                              usuario:
                                  request.dataSolicitud!.ejecutivo!.usuario,
                              codEjecutivo: request
                                  .dataSolicitud!.ejecutivo!.codEjecutivo!,
                            ),
                            hayBitacoras: 0,
                            mostrarBotonRegistrarBitacora: 0,
                            creacionOffline: true,
                            idSolicitudReal: 0,
                            haveAdvertObservation: 0);

                        //log('requestOffline: ${jsonEncode(requestOffline)}');

                        ReviewRequestPage.listInspectionCoordinated
                            .insert(0, requestOffline);
                        await _offlineStorage.setListInspectionOffline(
                            ReviewRequestPage.listInspectionCoordinated);
                        fp.showAlert(
                            content: const AlertSuccess(
                                message: 'Solicitud creada con éxito!'));
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          fp.dismissAlert();
                          Navigator.pushReplacement(
                            context,
                            PageTransition(
                              child: const HomePage(),
                              type: PageTransitionType.leftToRightWithFade,
                            ),
                          );
                        });
                      }
                    } on Exception catch (e) {
                      Helper.logger.e('Error: ${e.toString()}');
                      fp.showAlert(
                        content: AlertGenericError(
                          messageButton: 'Entendido',
                          onPress: () {
                            //final fp = Provider.of<FunctionalProvider>(context, listen: false);
                            // RequestDataStorage().removeRequestData();
                            fp.dismissAlert();
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                child: const HomePage(),
                                type: PageTransitionType.leftToRightWithFade,
                              ),
                            );
                          },
                          message:
                              'Algo salió mal. Por favor, inténtalo de nuevo más tarde.',
                        ),
                      );
                    }

                    // validar si existe mas solicitudes creadas en el arreglo de inspecciones coordinadas - offline
                    // if(ReviewRequestPage.listInspectionCoordinated.isNotEmpty){
                    //   Helper.logger.i('1');
                    //   // validar si hay mas registros en el arreglo de creacion de solicitudes - offline
                    //   if(NewRequestPage.listCreatingrequests.isNotEmpty){
                    //     Helper.logger.i('2');
                    //   }

                    // }else{
                    //   final response = await _offlineStorage.getCreatingRequests();
                    //   log("informacion guardada en storage: ${jsonEncode(response)}");
                    //   //log(jsonEncode( NewRequestPage.listCreatingrequests));
                    //   // Helper.logger.i('3');
                    //   // NewRequestPage.listCreatingrequests.insert(0, request);
                    //   // _offlineStorage.saveCreatingRequests(value: NewRequestPage.listCreatingrequests);

                    // }

                    // final response = await OfflineStorage().getInspectionFinishedOffline();
                    // if(response != null){
                    //   Helper.logger.w('response: ${jsonEncode(response)}');
                    //   Helper.logger.w('request: ${jsonEncode(request)}');
                    // }else{
                    //   Helper.logger.w('request: ${jsonEncode(ReviewRequestPage.listInspectionCoordinated)}');
                    //   Lista requestOffline = Lista(
                    //     idTipoIdentificacion: int.parse(request.dataSolicitud!.idTipoIdentificacion!),
                    //     identificacion: request.dataSolicitud!.identificacion!,
                    //     nombres: request.dataSolicitud!.nombres!,
                    //     apellidos: request.dataSolicitud!.apellidos!,
                    //     razonSocial: request.dataSolicitud!.razonSocial!,
                    //     telefono: request.dataSolicitud!.telefono!,
                    //     direccion: request.dataSolicitud!.direccion!,
                    //     idBroker: request.dataSolicitud!.idBroker!,
                    //     idRamo: request.dataSolicitud!.idRamo!,
                    //     idAgencia: request.dataSolicitud!.idAgencia!,
                    //     //idAgenciaInspeccion: request.dataSolicitud!.idAgenciaInspeccion,
                    //     idProducto: request.dataSolicitud!.idProducto!,
                    //     pdfAdjunto: request.dataSolicitud!.pdfAdjunto!,
                    //     idProceso: int.parse(request.dataSolicitud!.idProceso!),
                    //     nombreBroker: request.dataSolicitud!.nombreBroker!,
                    //     ramo: request.dataSolicitud!.ramo!,
                    //     agencia: request.dataSolicitud!.agencia!,
                    //     ejecutivo: request.dataSolicitud!.ejecutivo,
                    //     //producto: request.dataSolicitud!.producto,
                    //     idTipoSolicitud: int.parse(request.dataSolicitud!.idTipoSolicitud!),
                    //     idTipoFlujo: int.parse(request.dataSolicitud!.idTipoFlujo!),
                    //     datosVehiculo: request.dataSolicitud!.datosVehiculo,
                    //     latitud: request.dataSolicitud!.latitud!,
                    //     longitud: request.dataSolicitud!.longitud!,
                    //     fechaInspeccion: DateTime.parse(request.dataSolicitud!.fechaInspeccion!),
                    //     horaInspeccion: request.dataSolicitud!.horaInspeccion,
                    //     reasignado: request.dataSolicitud!.reasignado,
                    //     //idEstado: request.dataSolicitud!.idEstado,
                    //     polizaMadre: request.dataSolicitud!.polizaMadre,
                    //     //correo1: request.dataSolicitud!.correo1,
                    //     //correo2: request.dataSolicitud!.correo2
                    //   );

                    //   Helper.logger.w('response: ${jsonEncode(response)}');
                    //   Helper.logger.w('request: ${jsonEncode(request)}');
                    // }
                  }
                }
              },
              child: const Text(
                'REGISTRAR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
        ),
      ),
    );
  }

  Row _inspectionReassignment() {
    return Row(
      children: [
        Checkbox(
            value: checkBoxReassignment,
            onChanged: (value) {
              checkBoxReassignment = value!;
              if (value) {
                reassignment = 'SI';
              } else {
                reassignment = 'NO';
              }
              setState(() {});
              _checkIfFieldsAreCompleted();
            }),
        const Text("Reasignarse para inspección")
      ],
    );
  }

  //! TRATAR DE OPTIMIZAR
  _checkIfFieldsAreCompleted() {
    Helper.logger.w('verificacion');
    switch (amBroker) {
      case true:
        if (idBroker != null &&
            selectedProcessTypeValue.isNotEmpty &&
            selectedBranchTypeValue.isNotEmpty &&
            (selectedProductTypeValue.isNotEmpty ||
                selectedProcessTypeValue == "49") &&
            selectedAgencyTypeValue.isNotEmpty &&
            selectedExecutiveTypeValue.isNotEmpty &&
            vehicleYearController.text.trim().length == 4 &&
            // selectedInspectionAgencyTypeValue.isNotEmpty &&
            selectedFlowTypeValue.isNotEmpty &&
            sumAssuredController.text.trim().isNotEmpty &&
            vehiclePlateController.text.trim().isNotEmpty &&
            vehicleYearController.text.trim().isNotEmpty) {
          _validationOtherFields();
        } else {
          formCompleted = false;
        }

        break;
      case false:
        if (selectedBrokerValue.isNotEmpty &&
            selectedProcessTypeValue.isNotEmpty &&
            selectedBranchTypeValue.isNotEmpty &&
            (selectedProductTypeValue.isNotEmpty ||
                selectedProcessTypeValue == "49") &&
            selectedAgencyTypeValue.isNotEmpty &&
            selectedExecutiveTypeValue.isNotEmpty &&
            vehicleYearController.text.trim().length == 4 &&
            // selectedInspectionAgencyTypeValue.isNotEmpty &&
            selectedFlowTypeValue.isNotEmpty &&
            sumAssuredController.text.trim().isNotEmpty &&
            vehiclePlateController.text.trim().isNotEmpty &&
            vehicleYearController.text.trim().isNotEmpty) {
          _validationOtherFields();
          //print(formCompleted);
        } else {
          formCompleted = false;
          //print(formCompleted);
        }
        break;
    }
    setState(() {});
  }

  void _validationOtherFields() {
    if (selectedFlowTypeValue != '6') {
      debugPrint("SOY DIFERENTE DE 6");
      if (_validationInspectionAgency()) {
        debugPrint("reasignado o agencia selccionada true");
        if (_validationDeductible()) {
          debugPrint("deducible seleccionado");
          // ! YA NO SE ESTÁ VALIDANDO LA FECHA
          // !if (_validationInspectionDate()) {
          debugPrint("FORM COMPLETO ----------------------");
          if ((correo1.text.trim().isEmpty ||
                  _isEmailValid(correo1.text.trim())) &&
              (correo2.text.trim().isEmpty ||
                  _isEmailValid(correo2.text.trim()))) {
            formCompleted = true;
            Future.delayed(const Duration(milliseconds: 2000), () {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastOutSlowIn);
            });
          }
          // formCompleted = true;
          // Future.delayed(const Duration(milliseconds: 2000), () {
          //   scrollController.animateTo(
          //       scrollController.position.maxScrollExtent,
          //       duration: const Duration(milliseconds: 1000),
          //       curve: Curves.fastOutSlowIn);
          // });
          // !} else {
          // !  debugPrint("sin fecha seleccionada");
          // !  formCompleted = false;
          // !}
        } else {
          debugPrint("deductible no seleccionado");
          formCompleted = false;
        }
      } else {
        debugPrint("ni reasignado ni agencia selccionada");
        formCompleted = false;
      }
    } else {
      debugPrint("SOY IGUAL DE 6 flujo sin inspeccion");
      //? Cuando el tipo de flujo es sin inspeccion
      if (selectedMotherPolicyValue.isNotEmpty) {
        if (_validationInspectionAgency()) {
          debugPrint("Reasignado o agencia escogida");
          if (_validationDeductible()) {
            debugPrint("deducible escogido true");
            // ! YA NO SE ESTÁ VALIDANDO SI LA FECHA ES CORRECTA
            // !if (_validationInspectionDate()) {
            debugPrint("FORM COMPLETO ----------------------");
            Helper.logger.w('correo 1: ${correo1.text}');
            Helper.logger.w('correo 2: ${correo2.text}');
            if ((correo1.text.trim().isEmpty ||
                    _isEmailValid(correo1.text.trim())) &&
                (correo2.text.trim().isEmpty ||
                    _isEmailValid(correo2.text.trim()))) {
              formCompleted = true;
              Future.delayed(const Duration(milliseconds: 2000), () {
                scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.fastOutSlowIn);
              });
            }
            // !} else {
            // !  debugPrint("fecha mal");
            // !  formCompleted = false;
            // ! }
          } else {
            debugPrint("sin deducible");
            formCompleted = false;
          }
        } else {
          debugPrint("ni reasigando ni agencia escogida");
          formCompleted = false;
        }
      } else {
        debugPrint("SIN POLIZA MADRE ESCOGIDA");
        formCompleted = false;
      }
    }
  }

  // ! VALIDACION PARA LA FECHA DE INSPECCION( PARA QUE SEA MAYOR A LA HORA ACTUAL EJ: +1H)
  // bool _validationInspectionDate() {
  //   final fecha = calendarController.text;
  //   final hora = timepickerController.text.split(" ")[0];
  //   final unido = '$fecha $hora:00';
  //   final fechaSelected = DateTime.parse(unido);

  //   if (fechaSelected.isBefore(DateTime.now())) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  bool _validationDeductible() {
    if (isQuotedProduct == 'SI') {
      //! SI EL PRODUCTO ES COTIZADOR
      if (deductibleValue != null && deductibleValue!.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } else {
      //? CAMBIO EL VIERNES 25 de Nov 2022: se puede seguir el flujo sin que el producto sea cotizador
      //? y sin seleccionar deducible. "El portal si lo hace" .- Diana
      return true;
      //? en este caso sera un producto no cotizador
      // if(selectedProcessTypeValue == '49'){
      //  return true;
      // }else{
      //   return false;
      // }
    }
  }

  bool _validationInspectionAgency() {
    if (reassignment == "SI") {
      return true;
    } else {
      if (selectedInspectionAgencyTypeValue.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  SelectWidget _brokerSelect() {
    return SelectWidget(
        title: 'Broker',
        options: brokersList,
        modalFilterAuto: true,
        modalFilter: true,
        
        // useConfirm: true,
        modalType: S2ModalType.popupDialog,
        optionSelected: (v) {
          selectedBroker = v!.title!;
          selectedBrokerValue = v.value!;
          brokerSelected = true;

          if (selectedProcessTypeValue == "50") {
            //? Solo si el proceso es con emision traemos productos
            _getProducts();
          }
          if (deductiblesList.isNotEmpty) {
            //? Aqui limpiamos el combo de deductibles si esta lleno
            _cleanDeductibles();
          }
          setState(() {});
        },
        textShow: selectedBroker,
        value: selectedBrokerValue);
  }

  Column _processType() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        // ? SELECCIONA EL TIPO DE PROCESO
        SelectWidget(
            title: 'Tipo de proceso',
            options: processList,
            optionSelected: (v) {
              setState(() {
                selectedProcessType = v!.title!;
                selectedProcessTypeValue = v.value!;
                processTypeSelected = true;
                if (v.value != '50') {
                  // deductibleValue = '0';
                  _cleanProductSelect();
                  _showAgencyByProduct("99");
                  selectedFlowType = "Con inspección";
                  selectedFlowTypeValue = "5";

                  // _cleanDeductibles();
                } else {
                  Helper.logger.w('con emision');
                  _cleanBranchSelect();
                }
                _checkIfFieldsAreCompleted();
              });
            },
            textShow: selectedProcessType,
            value: selectedProcessTypeValue),
        // if (selectedProcessTypeValue == '50') _processWithEmission(),
        // if (selectedProcessTypeValue == '49') _processWithOutEmission(),
        // ? TIPO DE PROCESO SELECCIONADO (CON/SIN EMISIÓN)
        if (selectedProcessTypeValue.isNotEmpty) _processSelected(),
        // ? DATOS DEL VEHICULO
        if (processTypeSelected) _vehicleData(),
        // ? FECHA DE INSPECCIÓN
        // !if (processTypeSelected) _inspectionDate()
      ],
    );
  }

  Widget _processSelected() {
    return FadeInRight(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _typeBranchSelect(),
          const SizedBox(
            height: 10,
          ),
          if (productsList.isNotEmpty && selectedProcessTypeValue != '49')
            _purchasedProductSelect(),
          if (productSelected || selectedProcessTypeValue == '49')
            _comboSelectsbyProductSelected()
        ],
      ),
    );
  }

  SelectWidget _typeBranchSelect() {
    return SelectWidget(
        title: 'Tipo de ramo',
        options: branchesList,
        optionSelected: (v) {
          //Helper.logger.e(jsonEncode(widget.branchesList));
          ageAllowed = widget.branchesList
              .firstWhere((e) => e.codigo.toString() == v?.value!)
              .anioAntiguedad!;
          durationVideo = widget.branchesList
              .firstWhere((e) => e.codigo.toString() == v?.value!)
              .duracionVideo!;
          selectedBranchType = v!.title!;
          selectedBranchTypeValue = v.value!;
          branchSelected = true;

          if (selectedProcessTypeValue == "50") {
            Helper.logger.e('Entro validacion 50');
            //? Solo si el proceso es con emision traemos productos
            !fp.offline
                ? _getProducts()
                : Helper.snackBar(
                    context: context,
                    message:
                        'No puedes continuar con este proceso porque estas en modo offline.',
                    colorSnackBar: Colors.red);
          }
          Helper.logger.e('No entro');
          if (deductiblesList.isNotEmpty) {
            //? Aqui limpiamos el combo de deductibles si esta lleno
            _cleanDeductibles();
          }
          _checkIfFieldsAreCompleted();
          setState(() {});
        },
        textShow: selectedBranchType,
        value: selectedBranchTypeValue);
  }

  _getProducts() async {
    _cleanProductSelect();
    switch (amBroker) {
      case true:
        final response = await NewRequestService()
            .getProducts(context, idBroker!, selectedBranchTypeValue);
        if (!response.error) {
          productsList = response.data!
              .map((e) => S2Choice(
                      value: e.codProducto,
                      title: e.descripcion,
                      meta: {
                        'codAgencia': e.codAgencia,
                        'es_prod_cotizador': e.esProdCotizador
                      }))
              .toList();
        }
        break;
      case false:
        if (brokerSelected && branchSelected) {
          final response = await NewRequestService().getProducts(
              context, selectedBrokerValue, selectedBranchTypeValue);
          if (!response.error) {
            //if(response.data!.isNotEmpty || response.data != null){
            productsList = response.data!
                .map((e) => S2Choice(
                        value: e.codProducto,
                        title: e.descripcion,
                        meta: {
                          'codAgencia': e.codAgencia,
                          'es_prod_cotizador': e.esProdCotizador
                        }))
                .toList();
            // }
          } else {
            _cleanBranchSelect();
          }
        }

        break;
    }
    setState(() {});
  }

  _getExecutives() async {
    _cleanExecutiveSelect();
    switch (amBroker) {
      case true:
        final response = await NewRequestService()
            .getExecutives(context, idBroker!, selectedAgencyTypeValue);
        if (!response.error) {
          exectutivesList = response.data!
              .map((e) => S2Choice(
                  value: e.codEjecutivo.toString(),
                  title: e.nombre,
                  meta: Ejecutivo(
                      codEjecutivo: e.codEjecutivo.toString(),
                      mail: e.mail,
                      nombre: e.nombre,
                      usuario: e.usuario)))
              .toList();
        }
        break;
      case false:
        if (brokerSelected) {
          if (!fp.offline) {
            final response = await NewRequestService().getExecutives(
                context, selectedBrokerValue, selectedAgencyTypeValue);
            if (!response.error) {
              exectutivesList = response.data!
                  .map((e) => S2Choice(
                      value: e.codEjecutivo.toString(),
                      title: e.nombre,
                      meta: Ejecutivo(
                          codEjecutivo: e.codEjecutivo.toString(),
                          mail: e.mail,
                          nombre: e.nombre,
                          usuario: e.usuario)))
                  .toList();
            } else {
              //? SE HACE UN CLEAN DEL SELECT PORQUE AQUI SI SE PUEDE SELECCIONAR UN NUEVO BROKER
              //? CUANDO SOY BROKER: EL SELECT DE BROKER NO SE MUESTRA

              _cleanAgency();
              _cleanExecutiveSelect();
            }
          } else {
            // _cleanAgency();
            // _cleanExecutiveSelect();
            Helper.logger.w('valida aqui la conexion a internedddt'); //VALIDARR
            final response = await OfflineStorage().getCatalogueExecutives();
            if (response != null) {
              List<Executive> listExecutives = response.data
                  .map((item) => Executive.fromJson(item))
                  .toList();
              //listExecutives.where((e) => e.codEjecutivo == int.parse(selectedAgencyTypeValue)).toList();
              exectutivesList = listExecutives
                  .map((e) => S2Choice(
                      value: e.codEjecutivo.toString(),
                      title: e.nombre,
                      meta: Ejecutivo(
                          codEjecutivo: e.codEjecutivo.toString(),
                          mail: e.mail,
                          nombre: e.nombre,
                          usuario: e.usuario)))
                  .toList();
            } else {
              _cleanAgency();
              _cleanExecutiveSelect();
            }
          }
        }
        break;
    }
    setState(() {});
  }

  _getPolicies() async {
    switch (amBroker) {
      case true:
        final response = await NewRequestService()
            .getPolicies(context, idBroker!, selectedBranchTypeValue);
        if (!response.error) {
          policiescList = response.data!
              .map((e) => S2Choice(value: e.poliza, title: e.descripcion))
              .toList();
          setState(() {});
        } else {
          _cleanFlowType();
          setState(() {});
        }
        break;
      case false:
        final response = await NewRequestService()
            .getPolicies(context, selectedBrokerValue, selectedBranchTypeValue);
        if (!response.error) {
          policiescList = response.data!
              .map((e) => S2Choice(value: e.poliza, title: e.descripcion))
              .toList();
          setState(() {});
        } else {
          _cleanFlowType();
          setState(() {});
        }
        break;
    }
  }

  //? LIMPIEZA DE CAMPOS
  _cleanBranchSelect() {
    selectedBranchType = 'Seleccione el tipo de Ramo';
    selectedBranchTypeValue = '';
    branchSelected = false;
  }

  _cleanProductSelect() {
    selectedProductType = '¿Cual es el producto adquirido?';
    selectedProductTypeValue = '';
    productSelected = false;
    productsList = [];
    isQuotedProduct = 'NO';
    _cleanAgency();
    _cleanExecutiveSelect();
    if (selectedProcessTypeValue != "49") {
      _cleanFlowType();
    }
    _cleanDeductibles();
  }

  _cleanAgency() {
    selectedAgencyType = 'Agencia de emisión';
    selectedAgencyTypeValue = '';
    // agencySelected = false;

    selectedInspectionAgencyType = 'Agencia inspección';
    selectedInspectionAgencyTypeValue = '';
  }

  _cleanExecutiveSelect() {
    selectedExecutiveType = 'Seleccione ejecutivo';
    selectedExecutiveTypeValue = '';
    selectedExecutiveMeta = null;
    exectutivesList = [];
  }

  _cleanFlowType() {
    selectedFlowType = 'Seleccione el tipo de flujo';
    selectedFlowTypeValue = '';
    _cleanPolicies();
  }

  _cleanPolicies() {
    selectedMotherPolicyType = 'Seleccione póliza madre';
    selectedMotherPolicyValue = '';
    policiescList = [];
  }

  _cleanDeductibles() {
    //? Limpiamos el texto de suma asegurada
    sumAssuredController.text = '';
    //? Limpiamos el select de deducibles
    selectedDeductibleType = 'Seleccione el deducible';
    selectedDeductibleTypeValue = '';
    deductiblesList = [];
  }

  //? FIN LIMPIEZA DE CAMPOS

  Widget _purchasedProductSelect() {
    return FadeInRight(
      child: SelectWidget(
          title: 'Tipo de producto',
          options: productsList,
          optionSelected: (v) {
            selectedProductType = v!.title!;
            selectedProductTypeValue = v.value!;
            isQuotedProduct = v.meta['es_prod_cotizador'];
            // print("==== ESPROD COT: $isQuotedProduct =======");
            _showAgencyByProduct(v.meta['codAgencia']);
            productSelected = true;
            _checkIfFieldsAreCompleted();
            setState(() {});
          },
          textShow: selectedProductType,
          value: selectedProductTypeValue),
    );
  }

  _showAgencyByProduct(String codAgencia) async {
    if (codAgencia == '99') {
      showAllAgencies = true;
    } else {
      showAllAgencies = false;
      final agencyFiltered =
          agenciesList.firstWhere((element) => element.value == codAgencia);
      agency = [agencyFiltered];
      selectedAgencyType = agencyFiltered.title!;
      selectedAgencyTypeValue = agencyFiltered.value;
      await _getExecutives();
    }
  }

  Widget _comboSelectsbyProductSelected() {
    //? Aqui se cargan los selects despues de haber escogido un producto adquirido
    return FadeInRight(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SelectWidget(
              title: 'Agencia emisión',
              disabled: (showAllAgencies) ? false : true,
              options: (showAllAgencies) ? agenciesList : agency,
              optionSelected: (v) {
                selectedAgencyType = v!.title!;
                selectedAgencyTypeValue = v.value!;
                // agencySelected = true;
                _getExecutives();
                _checkIfFieldsAreCompleted();
                setState(() {});
              },
              textShow: selectedAgencyType,
              value: selectedAgencyTypeValue),
          const SizedBox(
            height: 10,
          ),
          if (exectutivesList.isNotEmpty)
            SelectWidget(
                title: 'Ejecutivo',
                modalFilterAuto: true,
                modalFilter: true,
                // useConfirm: true,
                modalType: S2ModalType.popupDialog,
                options: exectutivesList,
                optionSelected: (v) {
                  selectedExecutiveType = v!.title!;
                  selectedExecutiveTypeValue = v.value!;
                  selectedExecutiveMeta = v.meta!;
                  _checkIfFieldsAreCompleted();
                  setState(() {});
                },
                textShow: selectedExecutiveType,
                value: selectedExecutiveTypeValue),
          const SizedBox(
            height: 10,
          ),
          if (reassignment == "NO")
            SelectWidget(
                title: 'Agencia inspección',
                options: agenciesList,
                optionSelected: (v) {
                  selectedInspectionAgencyType = v!.title!;
                  selectedInspectionAgencyTypeValue = v.value!;
                  _checkIfFieldsAreCompleted();
                  setState(() {});
                },
                textShow: selectedInspectionAgencyType,
                value: selectedInspectionAgencyTypeValue),
          const SizedBox(
            height: 10,
          ),
          //! MOSTRAMOS EL TIPO DE FLUJO SOLO CUANDO EL PROC. ES CON EMISION
          if (selectedProcessTypeValue == "50")
            SelectWidget(
                title: 'Tipo de flujo',
                options: requestsList,
                optionSelected: (v) {
                  selectedFlowType = v!.title!;
                  selectedFlowTypeValue = v.value!;
                  _checkIfFieldsAreCompleted();
                  if (selectedFlowTypeValue == '6') {
                    //?Sin inspeccion llamamos las polizas
                    _getPolicies();
                    _checkIfFieldsAreCompleted();
                  } else {
                    //? Con inspeccion limpiamos campos de poliza
                    _cleanPolicies();
                  }
                  setState(() {});
                },
                textShow: selectedFlowType,
                value: selectedFlowTypeValue),

          const SizedBox(height: 10),

          _comboPDF(),

          if (selectedFlowTypeValue == '6' && policiescList.isNotEmpty)
            const SizedBox(
              height: 10,
            ),
          if (selectedFlowTypeValue == '6' && policiescList.isNotEmpty)
            FadeInRight(
              child: SelectWidget(
                  title: 'Póliza madre',
                  options: policiescList,
                  optionSelected: (v) {
                    selectedMotherPolicyType = v!.title!;
                    selectedMotherPolicyValue = v.value!;
                    _checkIfFieldsAreCompleted();

                    setState(() {});
                  },
                  textShow: selectedMotherPolicyType,
                  value: selectedMotherPolicyValue),
            ),
        ],
      ),
    );
  }

  Widget _comboPDF() {
    Widget boxContent;

    if (_filePickerResult == null) {
      // Mostrar el icono y el texto "Subir PDF" si no se ha seleccionado ningún archivo PDF
      boxContent = GestureDetector(
        onTap: _pickPDF,
        child: Container(
          width: double.infinity,
          height: 125,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.file_upload, size: 50, color: Colors.grey),
              Text(
                'SUBIR PDF',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } else {
      String fileName = _filePickerResult!.files.first.name;

      if (_filePickerResult!.files.first.size <= 5 * 1024 * 1024 &&
          _filePickerResult!.files.first.extension!.toLowerCase() == 'pdf') {
        boxContent = GestureDetector(
          onTap: _pickPDF,
          child: Container(
            width: double.infinity,
            height: 125,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description, size: 50, color: Colors.grey),
                const SizedBox(height: 8),
                Text(
                  fileName,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      } else {
        boxContent = GestureDetector(
          onTap: _pickPDF,
          child: Container(
            width: double.infinity,
            height: 125,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(width: 1, color: Colors.grey),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.file_upload, size: 50, color: Colors.grey),
                Text(
                  'SUBIR PDF',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }
    }

    return FadeInRight(
      child: Column(
        children: [
          boxContent,
        ],
      ),
    );
  }

  _verifyVehiclePlate() async {
    final response = await RequestReviewService()
        .getVehicleClientData(context, vehiclePlateController.text);
    setState(() {
      existErrorVehiclePlate = response.error;

      if (!existErrorVehiclePlate && response.data != null) {
        vehicleYearController.text = response.data!.anio;
        _verifyYearVehicule(response.data!.anio);
        return;
      }
      vehicleYearController.text = "";
    });
  }

  String tmpPlateCons = "";
  Column _vehicleData() {
    //final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        const InfoTileWidget(
          informativeTitle: 'INGRESE LOS DATOS DEL VEHICULO',
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          controller: sumAssuredController,
          textInputType: TextInputType.phone,
          inputFormatter: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
          ],
          onChanged: (value) {
            // _checkIfFieldsAreCompleted();
            // _cleanDeductibles();
            deductiblesList = [];
            selectedDeductibleTypeValue = '';
            selectedDeductibleType = 'Seleccione el deducible';
            // formCompleted = false;
            _checkIfFieldsAreCompleted();
            setState(() {});
          },
          label: 'Ingresar la suma asegurada',
          onEditingComplete: () {
            if (sumAssuredController.text.isNotEmpty &&
                // (isQuotedProduct == 'SI' || selectedProcessTypeValue == '49')) {
                isQuotedProduct == 'SI') {
              Helper.dismissKeyboard(context);
              if (sumAssuredAux != sumAssuredController.text) {
                sumAssuredAux = sumAssuredController.text;

                _loadDeductibles();
              }
            }
            _checkIfFieldsAreCompleted();
          },
          suffixIcon: (sumAssuredController.text.isNotEmpty &&
                  // (isQuotedProduct == 'SI' || selectedProcessTypeValue == '49'))
                  isQuotedProduct == 'SI')
              ? FadeInRight(
                  duration: const Duration(milliseconds: 700),
                  child: IconButton(
                      onPressed: () async {
                        Helper.dismissKeyboard(context);
                        _loadDeductibles();
                      },
                      icon: Icon(
                        Icons.search_rounded,
                        color: AppConfig.appThemeConfig.secondaryColor,
                      )),
                )
              : null,
        ),
        const SizedBox(
          height: 10,
        ),

        Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              if (!fp.offline) {
                if (vehiclePlateController.text.trim().isNotEmpty &&
                    tmpPlateCons != vehiclePlateController.text.trim()) {
                  tmpPlateCons = vehiclePlateController.text.trim();
                  _verifyVehiclePlate();
                }
              } else {
                existErrorVehiclePlate = false;
                setState(() {});
              }
            }
          },
          child: TextFieldWidget(
            controller: vehiclePlateController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 7,
            onChanged: (value) {
              // _checkIfFieldsAreCompleted();
              setState(() {
                existErrorVehiclePlate = true;
              });
            },
            onEditingComplete: () {
              _checkIfFieldsAreCompleted();
            },
            suffixIcon: !fp.offline
                ? (vehiclePlateController.text.isNotEmpty)
                    ? TextButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                        onPressed: () {
                          Helper.dismissKeyboard(context);
                          _verifyVehiclePlate();
                        },
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      )
                    : null
                : null,
            ontap: () {
              if (sumAssuredController.text.isNotEmpty &&
                  // (isQuotedProduct == 'SI' || selectedProcessTypeValue == '49')) {
                  isQuotedProduct == 'SI') {
                Helper.dismissKeyboard(context);
                if (sumAssuredAux != sumAssuredController.text.trim()) {
                  sumAssuredAux = sumAssuredController.text.trim();

                  _loadDeductibles();
                }
              }
              // _checkIfFieldsAreCompleted();
            },
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[A-Z0-9]'))
            ],
            label: 'Ingresar placa del vehículo',
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          controller: vehicleYearController,
          maxLength: 4,
          textInputType: TextInputType.phone,

          onEditingComplete: () {
            _checkIfFieldsAreCompleted();
          },
          ontap: () {
            if (sumAssuredController.text.trim().isNotEmpty &&
                // (isQuotedProduct == 'SI' || selectedProcessTypeValue == '49')) {
                isQuotedProduct == 'SI') {
              Helper.dismissKeyboard(context);
              if (sumAssuredAux != sumAssuredController.text.trim()) {
                sumAssuredAux = sumAssuredController.text.trim();

                _loadDeductibles();
              }
            }
            // _checkIfFieldsAreCompleted();
          },
          inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
          onChanged: (value) {
            if (value.trim().length == 4) {
              Helper.logger.w('entra aqui');
              _verifyYearVehicule(value);
            } else {
              // _verifyYearVehicule(value);
              formCompleted = false;
            }
            setState(() {});
          },

          // }
          /*{
            if (value.length == 4) {
              if (int.parse(value) > (int.parse(initialConfig!.anioActual)+initialConfig!.futuroVhPermitido)) {
                Helper.dismissKeyboard(context);
                vehicleYearController.text = '';
                fp.showAlert(
                    content: const AlertGenericError(
                        message:
                            'el año del vehículo no puede ser mayor al año permitido!'));
              }
              final result =
                  int.parse(initialConfig!.anioActual) - int.parse(value);
              // print(result)
              final ageAllowed = int.parse(initialConfig!.antiguedadPermitida);
              if (result > ageAllowed) {
                Helper.dismissKeyboard(context);
                vehicleYearController.text = '';
                fp.showAlert(
                    content: const AlertGenericError(
                        message:
                            'el año del vehículo no cumple con la antigüedad permitida!'));
              } else {
                Helper.dismissKeyboard(context);
                _checkIfFieldsAreCompleted();
                setState(() {});
              }
            } else {
              setState(() {
                formCompleted = false;
              });
            }
          },*/
          label: 'Ingrese el año',
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          controller: correo1,
          textInputType: TextInputType.emailAddress,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              _checkIfFieldsAreCompleted();
            } else {
              if (_isEmailValid(value)) {
                _checkIfFieldsAreCompleted();
              } else {
                formCompleted = false;
              }
            }
            setState(() {});
          },
          label: 'Correo 1',
          onEditingComplete: () {
            _checkIfFieldsAreCompleted();
          },
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          controller: correo2,
          textInputType: TextInputType.emailAddress,
          onChanged: (value) {
            if (value.trim().isEmpty) {
              _checkIfFieldsAreCompleted();
            } else {
              if (_isEmailValid(value)) {
                _checkIfFieldsAreCompleted();
              } else {
                formCompleted = false;
              }
            }
            setState(() {});
          },
          label: 'Correo 2',
          onEditingComplete: () {
            _checkIfFieldsAreCompleted();
          },
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          initialConfig!.descriptivoVehiculo,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppConfig.appThemeConfig.secondaryColor.withOpacity(0.6)),
        ),
        //? SI LA LISTA DE DEDUCIBLES NO ESTA VACIA Y EL PROCESO ES CON EMISION
        //? MOSTRAMOS EL SELECT DE DEDUCIBLES
        if (deductiblesList.isNotEmpty &&
            // (isQuotedProduct == 'SI' || selectedProcessTypeValue == '49'))
            isQuotedProduct == 'SI')
          _deductibles()
      ],
    );
  }

  _verifyYearVehicule(String value) {
    Helper.logger.w('entra a la validacion de año');
    //final fp = Provider.of<FunctionalProvider>(context, listen: false);

    if (value.length == 4) {
      if (int.parse(value) >
          (int.parse(initialConfig!.anioActual) +
              initialConfig!.futuroVhPermitido)) {
        Helper.dismissKeyboard(context);
        vehicleYearController.text = '';
        formCompleted = false;
        fp.showAlert(
            content: const AlertGenericError(
                message:
                    'El año del vehículo no puede ser mayor al año permitido!'));
      }
      if (int.parse(value) < 1900) {
        Helper.dismissKeyboard(context);
        vehicleYearController.text = '';
        formCompleted = false;
        fp.showAlert(
            content: const AlertGenericError(
                message:
                    'El año del vehículo no puede ser menor al año permitido!'));
        return;
      }
      if (pdfUploaded) {
        _checkIfFieldsAreCompleted();
        setState(() {});
        return;
      }
      final result = int.parse(initialConfig!.anioActual) - int.parse(value);
      // print(result)

      if (ageAllowed == 0) {
        setState(() {
          ageAllowed = int.parse(initialConfig!.antiguedadPermitida);
        });
      }

      if (result > ageAllowed) {
        Helper.dismissKeyboard(context);
        vehicleYearController.text = '';
        formCompleted = false;
        fp.showAlert(
            content: AlertGenericError(
                messageButton: 'Continuar',
                message:
                    'El año ingresado supera los $ageAllowed años de antiguedad, ¿Para continuar con el año ingresado, deberá subir el archivo pdf de autorización?'));
      } else {
        Helper.dismissKeyboard(context);
        _checkIfFieldsAreCompleted();
        setState(() {});
      }
    } else {
      setState(() {
        formCompleted = false;
      });
    }
  }

  _loadDeductibles() async {
    final response = await NewRequestService()
        .getDeductibles(context, double.parse(sumAssuredController.text));
    if (!response.error) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn);
      deductiblesList = response.data!
          .map((e) => S2Choice(
              value: e.valDeducible.toString(),
              title: e.valDeducible.toString(),
              meta: e.descuento))
          .toList();

      setState(() {});
    }
  }

  Widget _deductibles() {
    return FadeInRight(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          SelectWidget(
              title: 'Deducible',
              options: deductiblesList,
              optionSelected: (v) {
                deductibleValue = v!.value!;
                selectedDeductibleType = v.title!;
                selectedDeductibleTypeValue = v.value!;
                _checkIfFieldsAreCompleted();
                setState(() {});
              },
              textShow: selectedDeductibleType,
              value: selectedDeductibleTypeValue)
        ],
      ),
    );
  }

  // ! FECHA DE INSPECCION
  // Column _inspectionDate() {
  //   return Column(
  //     children: [
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       const InfoTileWidget(
  //         informativeTitle: 'AGENDE LA FECHA DE INSPECCIÓN',
  //       ),
  //       const SizedBox(
  //         height: 15,
  //       ),
  //       Row(
  //         children: [
  //           Expanded(
  //             child: DatePickerWidget(
  //                 label: 'seleccione fecha',
  //                 calendarController: calendarController),
  //           ),
  //           const SizedBox(
  //             width: 10,
  //           ),
  //           Expanded(
  //               child: TimePickerWidget(
  //             label: 'seleccione hora',
  //             timePickerController: timepickerController,
  //             // choosenDate: DateTime.parse(calendarController.text),
  //           ))
  //         ],
  //       )
  //     ],
  //   );
  // }

  @override
  bool get wantKeepAlive => true;
}
