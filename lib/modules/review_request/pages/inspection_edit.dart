import 'package:animate_do/animate_do.dart';
// import 'package:awesome_select/awesome_select.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/inspection_detail.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/review_request_widgets.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class InspectionEditPage extends StatefulWidget {
  final Lista inspection;
  final InspectionDataResponse catInspectionData;
  const InspectionEditPage(
      {Key? key, required this.inspection, required this.catInspectionData})
      : super(key: key);

  @override
  State<InspectionEditPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionEditPage> {
  List<S2Choice<String>> identificationsList = [];
  S2Choice<String>? documentSelected;
  TextEditingController documentTypeController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController calendarController = TextEditingController();
  TextEditingController timePickerController = TextEditingController();
  String selectedDocumentType = 'Selecciona el tipo de identificación';
  String selectedDocumentTypeValue = '';
  LatLng? selectedCoords;
  bool? isValidDocument; //? para input ci, passport y ruc
  bool? isValidPhone; //? para input telefono
  bool formCompleted = false;

  // final FocusNode _focusAddress = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'inspection-edit', context: context);
      _loadInspectionData();
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('inspection-edit');
    documentTypeController.dispose();
    addressController.dispose();
    phoneController.dispose();
    calendarController.dispose();
    timePickerController.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      // print("INSPECTION EDIT INTERCEPTOR-->");
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      fp.showAlert(content: const AlertLoseProcess());
    }
    return true;
  }

  _loadInspectionData() async {
    identificationsList = widget.catInspectionData.listaIdentif
        .map((e) => S2Choice(
            value: e.idEstadoSweaden.toString(),
            title: e.descripcion,
            meta: e.codigo.toString()))
        .toList();
    _loadDataInForm();
    setState(() {});
  }

  _loadDataInForm() {
    selectedDocumentType = widget.catInspectionData.listaIdentif
        .firstWhere(
            (e) => e.idEstadoSweaden == widget.inspection.idTipoIdentificacion)
        .descripcion;
    selectedDocumentTypeValue =
        widget.inspection.idTipoIdentificacion.toString();
    documentSelected = identificationsList.firstWhere(
        (e) => e.value == widget.inspection.idTipoIdentificacion.toString());

    // selectedBrokerType = widget.catInspectionData.listabroker
    //     .firstWhere((e) => e.codigo == widget.inspection.idBroker)
    //     .descripcion!;
    // selectedBrokerTypeValue = widget.inspection.idBroker.toString();
    // brokerSelected = brokerList
    //     .firstWhere((e) => e.value == widget.inspection.idBroker.toString());

    // selectedRamoType = widget.catInspectionData.listaramos
    //     .firstWhere((e) => e.codigo == widget.inspection.idRamo)
    //     .descripcion!;
    // selectedRamoTypeValue = widget.inspection.idRamo.toString();
    // ramoSelected = ramoList
    //     .firstWhere((e) => e.value == widget.inspection.idRamo.toString());

    documentTypeController.text = widget.inspection.identificacion;
    calendarController.text = (widget.inspection.fechaInspeccion != null)
        ? Helper().dateToStringFormat(
            widget.inspection.fechaInspeccion!, 'yyyy-MM-dd')
        : Helper().dateToStringFormat(DateTime.now(), 'yyyy-MM-dd');
    timePickerController.text = (widget.inspection.horaInspeccion != null)
        ? widget.inspection.horaInspeccion!
        : "${DateTime.now().hour}:${DateTime.now().minute}";
    addressController.text = widget.inspection.direccion;
    selectedCoords = LatLng(double.parse(widget.inspection.latitud),
        double.parse(widget.inspection.longitud));
    phoneController.text = widget.inspection.telefono;
    isValidDocument = true; //? para input ci, passport y ruc
    isValidPhone = true;
    formCompleted = true;
  }

  _onConfirmFlag(bool flag) {
    if (flag) {
      _checkIfFieldsAreComplete();
      if (formCompleted) {
        debugPrint("LLAMAR API EDIT");
        _editInspection();
      }
    } else {
      debugPrint('entra aqui');
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: InspectionDetailPage(inspection: widget.inspection),
              type: PageTransitionType.leftToRightWithFade));
    }
  }

  _editInspection() async {
    widget.inspection.identificacion = documentTypeController.text;
    widget.inspection.idTipoIdentificacion =
        int.parse(selectedDocumentTypeValue);
    widget.inspection.telefono = phoneController.text;
    widget.inspection.direccion = addressController.text;
    widget.inspection.fechaInspeccion =
        Helper().stringToDateTime(calendarController.text);
    // print(widget.inspection.fechaInspeccion);
    widget.inspection.horaInspeccion = timePickerController.text.split(" ")[0];
    // print(widget.inspection.horaInspeccion);
    debugPrint('------------hasta aquie funca ${widget.inspection}');
    final response = await RequestReviewService()
        .updateInspection(context, widget.inspection);
    if (!response.error) {
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      fp.showAlert(
          content: AlertSuccess(
        message: response.message,
        messageButton: 'Aceptar',
        onPress: () => {
          Navigator.pushReplacement(
              context,
              PageTransition(
                  child: const ReviewRequestPage(),
                  type: PageTransitionType.leftToRightWithFade))
        },
      ));
    } else {
      debugPrint('erororororo');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final inspection = widget.inspection;

    return Stack(
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
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  width: double.infinity,
                  child: Text(inspection.nombres + ' ' + inspection.apellidos,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppConfig.appThemeConfig.secondaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(child: _formState()),
                ButtonsInspectionConfirmWidget(
                    onConfirmFlag: _onConfirmFlag,
                    saveActivateFlag: formCompleted)
              ],
            ),
            bottomNavigationBar: const BottomInfo()),
        const AlertModal(),
        const NotificationModal()
      ],
    );
  }

  AppBar _appBarHome(BuildContext context) {
    return AppBar(
      backgroundColor: AppConfig.appThemeConfig.secondaryColor,
      title: const Text.rich(TextSpan(children: [
        TextSpan(
            text: 'Bandeja ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'de entrada', style: TextStyle(fontWeight: FontWeight.w300))
      ])),
      leading: IconButton(
          onPressed: () {
            _onConfirmFlag(false);
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
    );
  }

  SingleChildScrollView _formState() {
    return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: Column(
                children: [
                  const SizedBox(
                    height: 6,
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Broker: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConfig.appThemeConfig.secondaryColor,
                          )),
                      TextSpan(
                          text: widget.inspection.nombreBroker,
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.bold))
                    ]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: 'Ejecutivo: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConfig.appThemeConfig.secondaryColor,
                          )),
                      TextSpan(
                          text: widget.inspection.nombreEjecutivo,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConfig.appThemeConfig.secondaryColor,
                          ))
                    ]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: widget.inspection.proceso,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppConfig.appThemeConfig.secondaryColor,
                          ))
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: DatePickerWidget(
                  label: 'Fecha Inspección',
                  calendarController: calendarController,
                  validator: _checkIfFieldsAreComplete,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: TimePickerWidget(
                  label: 'Hora Inspección',
                  timePickerController: timePickerController,
                  validator: _checkIfFieldsAreComplete,
                  ),
            ),
            const SizedBox(
              height: 10,
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: documentSelected != null
                  ? SelectWidget(
                      title: 'Tipo de identificación',
                      options: identificationsList,
                      selectedChoice: documentSelected,
                      optionSelected: (v) {
                        setState(() {
                          selectedDocumentTypeValue = v!.value.toString();
                          selectedDocumentType = v.title.toString();
                        });
                        _checkIfFieldsAreComplete();
                      },
                      modalFilter: true,
                      textShow: selectedDocumentType,
                      value: selectedDocumentTypeValue)
                  : const SizedBox(),
            ),
            const SizedBox(
              height: 4,
            ),
            if (selectedDocumentTypeValue == '2') _ciField(),
            if (selectedDocumentTypeValue == '3') _passportField(),
            if (selectedDocumentTypeValue == '1') _rucField(),
            const SizedBox(
              height: 4,
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: _textFieldsPhone(),
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: _textFieldAddress(),
            ),
          ],
        ));
  }

  _ciField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _textFieldDocumentType('ci'),
        ],
      ),
    );
  }

  _passportField() {
    return FadeInLeftBig(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _textFieldDocumentType('pasaporte'),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _rucField() {
    return FadeInUpBig(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _textFieldDocumentType('ruc'),
        ],
      ),
    );
  }

  _addressField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Dirección',
            controller: addressController,
            textInputType: TextInputType.text,
            onChanged: (e) {
              _checkIfFieldsAreComplete();
            },
            inputFormatter: [
              LengthLimitingTextInputFormatter(255),
              FilteringTextInputFormatter.allow(Helper.addressRegExp)
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _textFieldDocumentType(String type) {
    switch (type) {
      case 'ci':
        return TextFieldWidget(
          label: 'Ingrese el número de cédula',
          controller: documentTypeController,
          maxLength: 10,
          textInputType: TextInputType.phone,
          inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
          isValid: isValidDocument,
          onChanged: (value) {
            isValidDocument = Helper().identificationValidator(value, 'ci');
            _checkIfFieldsAreComplete();
            setState(() {});
          },
        );
      case 'pasaporte':
        return TextFieldWidget(
          label: 'Ingrese el número de pasaporte',
          controller: documentTypeController,
          isValid: isValidDocument,
          onChanged: (value) {
            isValidDocument = true;
            _checkIfFieldsAreComplete();
            setState(() {});
          },
        );
      case 'ruc':
        return TextFieldWidget(
          label: 'Ingrese el número de RUC',
          controller: documentTypeController,
          maxLength: 13,
          textInputType: TextInputType.phone,
          inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
          isValid: isValidDocument,
          onChanged: (value) {
            //? En caso de Ruc este nos devuelve una List<bool>
            //? La posición 0 nos indica si el ruc ingresado es valido o no
            //? La posición 1 nos indica si el ruc es de tipo natural: true, jurídico y público: false
            final rucType = Helper().identificationValidator(value, 'ruc');
            isValidDocument = rucType[0];
            _checkIfFieldsAreComplete();
            setState(() {});
          },
        );
      default:
    }
  }

  _textFieldsPhone() {
    return Column(
      children: [
        TextFieldWidget(
          label: 'Teléfono',
          controller: phoneController,
          maxLength: 10,
          textInputType: TextInputType.phone,
          inputFormatter: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
          isValid: isValidPhone,
          onChanged: (value) {
            if (value.length == 10) {
              isValidPhone = true;
            } else {
              isValidPhone = false;
            }
            _checkIfFieldsAreComplete();
            setState(() {});
          },
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  bool _validateDateTimeInspection() {
    Helper.logger.w('fechaaa: ${widget.inspection.fechaInspeccion}');
    var dateTimeInspection = (widget.inspection.fechaInspeccion != null && widget.inspection.horaInspeccion != null)
      ? Helper().stringToDateTime(Helper().dateToStringFormat(widget.inspection.fechaInspeccion!, 'yyyy-MM-dd') +
            ' ' +
            widget.inspection.horaInspeccion!)
        : DateTime.now();

    var newDateTimeInspection = Helper().stringToDateTime(
        calendarController.text +
            ' ' +
            timePickerController.text.split(" ")[0]);

    // debugPrint(dateTimeInspection.toString());
    // debugPrint(newDateTimeInspection.toString());

    if (newDateTimeInspection.compareTo(dateTimeInspection) != 0) {
      if (newDateTimeInspection.compareTo(DateTime.now()) < 0) {
        final fp = Provider.of<FunctionalProvider>(context, listen: false);
        fp.showAlert(
            content: const AlertGenericError(
          message: 'Fecha y/o hora de inspección debe ser mayor a la actual',
        ));
        return false;
      }
    }

    return true;
  }

  _checkIfFieldsAreComplete() {
    if ((isValidPhone != null && isValidPhone!) &&
        (isValidDocument != null && isValidDocument!) &&
        (selectedDocumentTypeValue.isNotEmpty &&
            selectedDocumentTypeValue != '') &&
        _validateDateTimeInspection() &&
        documentTypeController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        selectedCoords != null) {
      formCompleted = true;
    } else {
      formCompleted = false;
    }
    setState(() {});
  }

  // _coordsSelected(LatLng coords) {
  //   selectedCoords = coords;
  //   widget.inspection.latitud = coords.latitude.toString();
  //   widget.inspection.longitud = coords.longitude.toString();
  //   _checkIfFieldsAreComplete();
  //   return Text('${coords.latitude} , ${coords.longitude}');
  // }

  // _buttonAddLocation() {
  //   final coordSelected =
  //       context.select((FunctionalProvider fp) => fp.selectedCoords);
  //   return Column(
  //     children: [
  //       if (coordSelected != null) _coordsSelected(coordSelected),
  //       SizedBox(
  //         height: 45,
  //         child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(30)),
  //                 primary: AppConfig.appThemeConfig.secondaryColor),
  //             onPressed: () async {
  //               final permission = await Geolocator.requestPermission();
  //               Helper.dismissKeyboard(context);
  //               if (permission == LocationPermission.denied) {
  //                 Geolocator.openAppSettings();
  //               } else {
  //                 final setLocation = LatLng(
  //                     double.parse(widget.inspection.latitud),
  //                     double.parse(widget.inspection.longitud));
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (_) => GoogleMapPage(
  //                               coords: setLocation,
  //                             )));
  //               }
  //             },
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: const [
  //                 Image(
  //                   image: AssetImage('assets/mapicon.png'),
  //                   height: 20,
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 Text("AGREGAR UBICACIÓN")
  //               ],
  //             )),
  //       ),
  //     ],
  //   );
  // }

  _textFieldAddress() {
    return Column(
      children: [
        _addressField(),
        const SizedBox(
          height: 4,
        ),
        // _buttonAddLocation()
      ],
    );
  }
}
