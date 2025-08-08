import 'package:animate_do/animate_do.dart';
// import 'package:awesome_select/awesome_select.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
// import 'package:sweaden_old_new_version/modules/new_request/providers/new_request_provider.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/client_response.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/request_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';

class CustomerDataForm extends StatefulWidget {
  final void Function(int) navigateToPage;
  final List<ListaIdentifElement> identificationList;
  const CustomerDataForm({
    Key? key,
    required this.identificationList,
    required this.navigateToPage,
  }) : super(key: key);

  @override
  State<CustomerDataForm> createState() => _CustomerDataFormState();
}

class _CustomerDataFormState extends State<CustomerDataForm>
    with AutomaticKeepAliveClientMixin {
  ScrollController scrollController = ScrollController();
  TextEditingController documentTypeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  bool isNatural = false;
  bool? isValidDocument; //? para input ci, passport y ruc
  bool? isValidPhone; //? para input telefono
  bool canContinue = false;
  bool existError = true;
  bool formCompleted =
      false; //? valida que el fomulario este completo para no repetir animaciones
  LatLng? coordSelected;
  String selectedDocumentType = 'Selecciona el tipo de identificación';
  String selectedDocumentTypeValue = '';
  List<S2Choice<String>> identificationsList = [];
  LatLng? selectedCoords = const LatLng(0.0, 0.0);

  late FunctionalProvider fp;

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);

    identificationsList = widget.identificationList
        .map((e) => S2Choice(
            value: e.idEstadoSweaden.toString(),
            title: e.descripcion,
            meta: e.idEstadoSweaden.toString()))
        .toList();
    super.initState();
  }

  @override
  void dispose() {
    documentTypeController.dispose();
    nameController.dispose();
    lastNameController.dispose();
    businessNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Helper.logger.w('selectedDocumentTypeValue: $selectedDocumentTypeValue');
    //Helper.logger.w('isValidDocument: $isValidDocument');
    //Helper.logger.w('existError: $existError');
    //Helper.logger.w('isValidPhone: $isValidPhone');

    super.build(context);
    return SingleChildScrollView(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(
            height: 13,
          ),
          if (identificationsList.isNotEmpty)
            FadeInRight(
              child: SelectWidget(
                  title: 'tipo de identificación',
                  options: identificationsList,
                  optionSelected: (v) {
                    setState(() {
                      _removeContentOfTextFields();
                      selectedDocumentType = v!.title!;
                      selectedDocumentTypeValue = v.value.toString();
                      if (v.value != '1') {
                        isNatural = true;
                      } else {
                        isNatural = false;
                      }
                    });
                  },
                  textShow: selectedDocumentType,
                  value: selectedDocumentTypeValue),
            ),
          if (selectedDocumentTypeValue == '2') _ciForm(),
          if (selectedDocumentTypeValue == '3') _passportFom(),
          if (selectedDocumentTypeValue == '1') _rucForm(),
          const SizedBox(
            height: 20,
          ),
          if (canContinue && !existError) _nextButtom(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  _ciForm() {
    return FadeInRightBig(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _textFieldDocumentType('ci'),
          const SizedBox(
            height: 10,
          ),
          _textFieldsNameLast(),
          const SizedBox(
            height: 10,
          ),
          _textFieldsPhoneAddress(),
          const SizedBox(
            height: 20,
          ),
          // _buttonAddLocation()
        ],
      ),
    );
  }

  _passportFom() {
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
          _textFieldsNameLast(),
          const SizedBox(
            height: 10,
          ),
          _textFieldsPhoneAddress(),
          const SizedBox(
            height: 20,
          ),
          // _buttonAddLocation()
        ],
      ),
    );
  }

  _rucForm() {
    return FadeInUpBig(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          _textFieldDocumentType('ruc'),
          const SizedBox(
            height: 10,
          ),
          if (!isNatural) _textFieldBusinessName(),
          if (isNatural) FadeInRight(child: _textFieldsNameLast()),
          const SizedBox(
            height: 10,
          ),
          _textFieldsPhoneAddress(),
          const SizedBox(
            height: 20,
          ),
          // _buttonAddLocation()
        ],
      ),
    );
  }

  _nextButtom() {
    return FadeInUp(
      child: SizedBox(
        height: 50,
        width: 150,
        child: ElevatedButton(
            onPressed: () {
              Helper.dismissKeyboard(context);
              _saveCustomerData();
              widget.navigateToPage(1);
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                backgroundColor: AppConfig.appThemeConfig.primaryColor),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("SIGUIENTE"),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.arrow_forward_ios_rounded)
              ],
            )),
      ),
    );
  }

  _saveCustomerData() {
    //? Se cuenta como naturales a cedulas, pasaportes y ruc naturales
    Request data = Request(
        opcion: 'I',
        dataSolicitud: DataSolicitud(
            idTipoIdentificacion: selectedDocumentTypeValue,
            identificacion: documentTypeController.text.trim(),
            nombres: (isNatural) ? nameController.text.trim() : null,
            apellidos: (isNatural) ? lastNameController.text.trim() : null,
            razonSocial:
                (!isNatural) ? businessNameController.text.trim() : null,
            telefono: phoneController.text.trim(),
            direccion: addressController.text.trim(),
            latitud: selectedCoords?.latitude.toString(),
            longitud: selectedCoords?.longitude.toString()));
    RequestDataStorage().setRequestData(data);
  }

  _removeContentOfTextFields() {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    isValidDocument = null;
    isValidPhone = null;
    isNatural = false;
    documentTypeController.text = '';
    nameController.text = '';
    lastNameController.text = '';
    businessNameController.text = '';
    phoneController.text = '';
    addressController.text = '';
    fp.selectedCoords = null;
    selectedCoords = null;
  }

  _loadClientData() async {
    final response = await RequestReviewService()
        .getDataClient(context, documentTypeController.text.trim());
    setState(() {
      existError = response.error;
    });
    if (!existError && response.data != null) {
      fillFields(response.data!);
      _checkIfFieldsAreComplete();
    }
  }

  // _loadClientData() async {
  //   final response = await RequestReviewService()
  //       .getDataClient(context, documentTypeController.text);
  //   setState(() {
  //     existError = response.error;
  //   });

  //   if (!existError && response.data != null) {
  //     fillFields(response.data!);
  //   } else {
  //     setState(() {
  //       canContinue = true;
  //     });

  //     if (selectedDocumentTypeValue == '1') {
  //       businessNameController.clear();
  //       setState(() {});
  //     }
  //   }
  //     print('canContinue: $canContinue, _existError: $existError');

  // }

  fillFields(DatosCliente dc) {
    switch (selectedDocumentTypeValue) {
      case '2':
        //LLENAMOS LOS DATOS DE CÉDULA
        fillPersonData(dc);
        break;
      case '3':
        //LLENAMOS LOS DATOS DE PASAPORTE
        fillPersonData(dc);
        break;
      case '1':
        (isNatural) ? fillPersonData(dc) : fillBusinessData(dc);
        break;
    }
    setState(() {});
  }

  fillPersonData(DatosCliente dc) {
    nameController.text = dc.persona.nombre1;
    lastNameController.text = dc.persona.apellido1 ?? '';
    phoneController.text = (dc.persona.telefonoCelular != null &&
            dc.persona.telefonoCelular!.isNotEmpty &&
            dc.persona.telefonoCelular!.length == 10)
        ? dc.persona.telefonoCelular?.substring(0, 10) ?? ''
        : "";
    addressController.text =
        dc.persona.direccionDomicilio ?? (dc.persona.direcciones ?? "");
    //addressController.text = dc.persona.direccionDomicilio ?? "";
    if (
        phoneController.text.isNotEmpty &&
        phoneController.text.length == 10) {
      isValidPhone = true;
    } else {
      isValidPhone = false;
    }
    _checkIfFieldsAreComplete();
  }

  fillBusinessData(DatosCliente dc) {
    businessNameController.text = dc.persona.nombre ?? "";
    phoneController.text =  (dc.persona.telefonoCelular != null &&
            dc.persona.telefonoCelular!.isNotEmpty &&
            dc.persona.telefonoCelular!.length == 10)
        ? dc.persona.telefonoCelular?.substring(0, 10) ?? ''
        : "";
        addressController.text =
        dc.persona.direccionDomicilio ?? (dc.persona.direcciones ?? "");
    //addressController.text = dc.persona.direccionDomicilio ?? "";
    if (
        phoneController.text.isNotEmpty &&
        phoneController.text.length == 10) {
      isValidPhone = true;
    } else {
      isValidPhone = false;
    }
  }

  //? Reusable TextField's
  String tmpIdentificationCons = '';
  _textFieldDocumentType(String type) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    switch (type) {
      case 'ci':
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              if (!fp.offline) {
                if (isValidDocument != null &&
                    isValidDocument == true &&
                    tmpIdentificationCons != documentTypeController.text) {
                  tmpIdentificationCons = documentTypeController.text;
                  _loadClientData();
                }
              } else {
                Helper.logger.i(
                    'documentTypeController.text: ${documentTypeController.text}');
                isValidDocument = Helper()
                    .identificationValidator(documentTypeController.text, 'ci');
                existError = !isValidDocument!;
                setState(() {});
                _checkIfFieldsAreComplete();
                //  if (isValidDocument != null && isValidDocument == true &&  tmpIdentificationCons != documentTypeController.text) {
                //     tmpIdentificationCons = documentTypeController.text;
                //      existError = false;
                //     setState(() {});
                //   //_loadClientData();
                // }
              }
            }
          },
          child: TextFieldWidget(
            label: 'Ingrese el número de cédula',
            controller: documentTypeController,
            suffixIcon: !fp.offline
                ? ((isValidDocument != null && isValidDocument == true)
                    ? TextButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                        onPressed: () {
                          Helper.dismissKeyboard(context);
                          _loadClientData();
                        },
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      )
                    : null)
                : null,
            maxLength: 10,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            isValid: isValidDocument,
            onChanged: (value) {
              isValidDocument = Helper().identificationValidator(value, 'ci');
              setState(() {
                existError = true;
              });
              //_checkIfFieldsAreComplete();
            },
          ),
        );
      case 'pasaporte':
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              if (!fp.offline) {
                if (tmpIdentificationCons.trim() !=
                    documentTypeController.text.trim()) {
                  tmpIdentificationCons = documentTypeController.text.trim();
                  documentTypeController.text.trim() != ''
                      ? _loadClientData()
                      : null;
                }
              } else {
                if (documentTypeController.text.trim().isNotEmpty) {
                  isValidDocument = true;
                  existError = false;
                } else {
                  isValidDocument = false;
                  existError = true;
                }
                setState(() {});
                _checkIfFieldsAreComplete();
              }
            }
          },
          child: TextFieldWidget(
            label: 'Ingrese el número de pasaporte',
            controller: documentTypeController,
            isValid: isValidDocument,
            textInputType: TextInputType.text,
            suffixIcon: !fp.offline
                ? (documentTypeController.text.trim().isNotEmpty)
                    ? TextButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                        onPressed: () {
                          Helper.dismissKeyboard(context);
                          _loadClientData();
                        },
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      )
                    : null
                : null,
            maxLength: 20,
            onChanged: (value) {
              isValidDocument = true;
              setState(() {
                existError = true;
              });
            },
            inputFormatter: [
              LengthLimitingTextInputFormatter(20),
            ],
          ),
        );
      case 'ruc':
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              if (!fp.offline) {
                if (isValidDocument != null &&
                    isValidDocument == true &&
                    tmpIdentificationCons != documentTypeController.text) {
                  tmpIdentificationCons = documentTypeController.text;
                  _loadClientData();
                }
              } else {
                final rucType = Helper().identificationValidator(
                    documentTypeController.text, 'ruc');
                Helper.logger.e('rucType: $rucType');
                isValidDocument = rucType[0];
                isNatural = rucType[1];
                if (documentTypeController.text.length == 13 && !rucType[0]) {
                  Helper.dismissKeyboard(context);
                  fp.showAlert(
                      content: AlertGenericError(
                    message:
                        "Este RUC no fue detectado como valido, si esta de acuerdo continue con los datos",
                    messageButton: "Aceptar",
                    onPress: () {
                      //Navigator.pop(context);
                      isValidDocument = true;
                      if (isValidDocument != null &&
                          isValidDocument == true &&
                          tmpIdentificationCons !=
                              documentTypeController.text) {
                        //tmpIdentificationCons = documentTypeController.text;
                        setState(() {
                          existError = false;
                        });
                        _checkIfFieldsAreComplete();
                        fp.dismissAlert();
                      } else {
                        fp.dismissAlert();
                      }
                    },
                  ));
                } else {
                  isValidDocument = rucType[0];
                  setState(() {
                    existError = false;
                  });
                  _checkIfFieldsAreComplete();
                }
                // Helper.logger.i('documentTypeController.text: ${documentTypeController.text}');
                // final rucType = Helper().identificationValidator(documentTypeController.text, 'ruc');
                // isValidDocument = rucType[0];
                // existError = !isValidDocument!;
                // setState(() {});

                // _checkIfFieldsAreComplete();
              }
            }
          },
          child: TextFieldWidget(
            label: 'Ingrese el número de RUC',
            controller: documentTypeController,
            maxLength: 13,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            isValid: isValidDocument,
            suffixIcon: !fp.offline
                ? (isValidDocument != null && isValidDocument == true)
                    ? TextButton(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ))),
                        onPressed: () {
                          Helper.dismissKeyboard(context);
                          _loadClientData();
                        },
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.grey,
                          size: 30.0,
                        ),
                      )
                    : null
                : null,
            onChanged: (value) {
              //? En caso de Ruc este nos devuelve una List<bool>
              //? La posición 0 nos indica si el ruc ingresado es valido o no
              //? La posición 1 nos indica si el ruc es de tipo natural: true, jurídico y público: false
              final rucType = Helper().identificationValidator(value, 'ruc');
              isValidDocument = rucType[0];
              isNatural = rucType[1];
              if (documentTypeController.text.length == 13 && !rucType[0]) {
                Helper.dismissKeyboard(context);
                fp.showAlert(
                    content: AlertGenericError(
                  message:
                      "Este RUC no fue detectado como valido, si esta de acuerdo continue con los datos",
                  messageButton: "Aceptar",
                  onPress: () {
                    //Navigator.pop(context);
                    isValidDocument = true;
                    if (isValidDocument != null &&
                        isValidDocument == true &&
                        tmpIdentificationCons != documentTypeController.text) {
                      tmpIdentificationCons = documentTypeController.text;
                      !fp.offline ? _loadClientData() : fp.dismissAlert();
                    } else {
                      fp.dismissAlert();
                    }
                  },
                ));
                //isValidDocument = true;
              }
              setState(() {
                existError = true;
              });
            },
          ),
        );
      default:
    }
  }

  _textFieldsNameLast() {
    return Column(
      children: [
        TextFieldWidget(
          label: 'Nombres',
          controller: nameController,
          inputFormatter: [
            FilteringTextInputFormatter.allow(Helper.textRegExp),
          ],
          onChanged: (value) {
            _checkIfFieldsAreComplete();
          },
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          label: 'Apellidos',
          controller: lastNameController,
          inputFormatter: [
            FilteringTextInputFormatter.allow(Helper.textRegExp),
          ],
          onChanged: (value) {
            _checkIfFieldsAreComplete();
          },
        ),
      ],
    );
  }

  _textFieldBusinessName() {
    return TextFieldWidget(
      label: 'Razón Social',
      controller: businessNameController,
      onChanged: (value) {
        _checkIfFieldsAreComplete();
      },
      inputFormatter: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9ñÑüÜ\.\. ]'))
      ],
    );
  }

  _textFieldsPhoneAddress() {
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
              _checkIfFieldsAreComplete();
            } else {
              isValidPhone = false;
              _checkIfFieldsAreComplete();
            }
            setState(() {});
          },
        ),
        const SizedBox(
          height: 10,
        ),
        TextFieldWidget(
          label: 'Dirección',
          controller: addressController,
          onChanged: (value) {
            //debugPrint(value);
            _checkIfFieldsAreComplete();
          },
          inputFormatter: [
            LengthLimitingTextInputFormatter(255),
            FilteringTextInputFormatter.allow(Helper.addressRegExp)
          ],
        ),
      ],
    );
  }

  // _buttonAddLocation() {
  //   final coordSelected =
  //       context.select((FunctionalProvider fp) => fp.selectedCoords);
  //   final fp = Provider.of<FunctionalProvider>(context);
  //   return Column(
  //     children: [
  //       if (coordSelected != null) _coordsSelected(coordSelected),
  //       const SizedBox(
  //         height: 10,
  //       ),
  //       SizedBox(
  //         width: 230,
  //         height: 45,
  //         child: ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //                 shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(30)),
  //                 primary: AppConfig.appThemeConfig.secondaryColor),
  //             onPressed:(fp.buttonMapEnable)? () async {
  //               final permission = await Geolocator.requestPermission();
  //               Helper.dismissKeyboard(context);
  //               if (permission == LocationPermission.denied) {
  //                 Geolocator.openAppSettings();
  //               } else {
  //                 fp.buttonMapEnable=false;
  //                 final location = await Geolocator.getCurrentPosition();
  //                 final setLocation =
  //                     LatLng(location.latitude, location.longitude);
  //                 Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (_) => GoogleMapPage(
  //                               coords: setLocation,
  //                             )));
  //               }
  //             }:null,
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

  // _coordsSelected(LatLng coords) {
  //   selectedCoords = coords;
  //   _checkIfFieldsAreComplete();
  //   return Text('${coords.latitude} , ${coords.longitude}');
  // }

  _checkIfFieldsAreComplete() {
    switch (selectedDocumentTypeValue) {
      case '2':
        _validationFields('normal');
        break;
      case '3':
        _validationFields('normal');
        break;
      case '1':
        _validationFields('variation');
        break;
      default:
        canContinue = false;
    }
    debugPrint('_canContinue: $canContinue, existError: $existError');
    setState(() {});
  }

  _validationFields(String type) {
    switch (type) {
      case 'normal':
        if ((isValidDocument != null && isValidDocument!) &&
            nameController.text.trim().isNotEmpty &&
            lastNameController.text.trim().isNotEmpty &&
            (isValidPhone != null && isValidPhone!) &&
            addressController.text.trim().isNotEmpty &&
            // selectedCoords != null &&
            existError == false) {
          if (!formCompleted) {
            Future.delayed(const Duration(seconds: 1), () {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastOutSlowIn);
            });
            formCompleted = true;
            canContinue = true;
          }
        } else {
          formCompleted = false;
          canContinue = false;
        }
        break;
      case 'business':
        if ((isValidDocument != null && isValidDocument!) &&
            businessNameController.text.trim().isNotEmpty &&
            (isValidPhone != null && isValidPhone!) &&
            addressController.text.trim().isNotEmpty) {
          // selectedCoords != null) {
          if (!formCompleted) {
            Future.delayed(const Duration(seconds: 1), () {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastOutSlowIn);
            });
            formCompleted = true;
            canContinue = true;
          }
        } else {
          formCompleted = false;
          canContinue = false;
        }
        break;
      case 'variation':
        if (isNatural) {
          _validationFields('normal');
        } else {
          _validationFields('business');
        }
    }
  }
}
