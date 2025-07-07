part of 'review_request_widgets.dart';

class PersonalDataFormWidget extends StatefulWidget {
  final ValueChanged<bool> onContinueFlag;
  final Lista inspection;
  final DataClientForm dataClientForm;

  const PersonalDataFormWidget({
    Key? key,
    required this.onContinueFlag,
    required this.inspection,
    required this.dataClientForm,
  }) : super(key: key);

  @override
  PersonalDataFormState createState() => PersonalDataFormState();
}

class PersonalDataFormState extends State<PersonalDataFormWidget>
    with AutomaticKeepAliveClientMixin {
  ContinueInspection inspectionData = ContinueInspection();
  List<S2Choice<String>> genderList = [];
  List<S2Choice<String>> civilStateList = [];
  //? ==== TIPO DE IDENTIFICACION ==== //
  List<S2Choice<String>> idetificationList = [
    S2Choice(title: "Cédula", value: "2"),
    S2Choice(title: "Pasaporte", value: "3"),
    S2Choice(title: "RUC", value: "1"),
  ];
  String selectedIdentificationType = '';
  String selectedIdentificationTypeValue = '';
  //? ==== TIPO DE IDENTIFICACION ==== //
  String selectedGenderType = 'Género';
  String selectedGenderTypeValue = '';
  String selectedCivilStateType = 'Estado Civil';
  String selectedCivilStateTypeValue = '';
  TextEditingController calendarController = TextEditingController();
  TextEditingController identificationController = TextEditingController();
  TextEditingController razonSocialController = TextEditingController();
  TextEditingController firstameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String identification = '';
  String tipoIdentificacion = '';
  bool isValidEmail = true;
  bool isValidDocument = true;
  bool formCompleted = false;
  bool identificationType = true;

  String startDateInspection = '';
  bool existError = false;

  //String? idTransaccion;

  @override
  void initState() {
   // _saveIdtransaction();
    //idTransaccion = const Uuid().v4();
    _getStartDateInspection();
    super.initState();
    _loadDataForm();
    _getDataStorage();
  }

  // _saveIdtransaction() async {
  //   // ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.inspection.idSolicitud.toString());
  //   // if(continueInspection != null){

  //   // }
  // }

  _getStartDateInspection() {
    final date = DateTime.now();

    final dateSplit = date.toString().split(".");
    startDateInspection = dateSplit[0];
  }

  @override
  void dispose() {
    calendarController.dispose();
    identificationController.dispose();
    razonSocialController.dispose();
    firstameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _loadIdentificationSelect(
      String typeIdentification, String identification) {
    switch (typeIdentification) {
      case "1":
        selectedIdentificationType = 'RUC';
        selectedIdentificationTypeValue = '1';
        tipoIdentificacion = '1';
        final rucType = Helper().identificationValidator(identification, 'ruc');
        if (rucType[1]) {
          identificationType = true;
        } else {
          identificationType = false;
        }
        isValidDocument = rucType[0];
        if (identificationController.text.length == 13 && !rucType[0]) {
          isValidDocument = true;
        }
        break;
      case "2":
        selectedIdentificationType = 'Cédula';
        selectedIdentificationTypeValue = '2';
        identificationType = true;
        tipoIdentificacion = '2';
        if (Helper().identificationValidator(identification, 'ci')) {
          isValidDocument = true;
        } else {
          isValidDocument = false;
        }
        break;
      case "3":
        selectedIdentificationType = 'Pasaporte';
        selectedIdentificationTypeValue = '3';
        tipoIdentificacion = '3';
        identificationType = true;
        break;
    }
    setState(() {});
  }

  _checkFormCompleted() {
    if (!existError &&
        identificationController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        isValidEmail &&
        calendarController.text.trim().isNotEmpty &&
        (selectedCivilStateTypeValue.isNotEmpty &&
            selectedCivilStateTypeValue != '') &&
        (selectedGenderTypeValue.isNotEmpty && selectedGenderTypeValue != '')) {
      if (isValidDocument) {
        if (identificationType) {
          if (firstameController.text.trim().isNotEmpty &&
              lastnameController.text.trim().isNotEmpty) {
            formCompleted = true;
          } else {
            formCompleted = false;
          }
        } else {
          if (razonSocialController.text.trim().isNotEmpty) {
            formCompleted = true;
          } else {
            formCompleted = false;
          }
        }
      } else {
        formCompleted = false;
      }
    } else {
      formCompleted = false;
    }
    setState(() {});
  }

  _loadDataForm() {
    identificationController.text = widget.inspection.identificacion;

    _loadIdentificationSelect(widget.inspection.idTipoIdentificacion.toString(),
        widget.inspection.identificacion);
    genderList = widget.dataClientForm.listaGenero
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
    civilStateList = widget.dataClientForm.listaEstadoCivil
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
    setState(() {});
  }

  _loadClientData() async {
    if (identificationController.text != '' && identificationController.text.isNotEmpty &&  identificationController.text != identification && isValidDocument) {
      queriedIdentification = identificationController.text;
      debugPrint("--- cargando datos del cliente ---");
      //final connection = await Helper.checkConnection();
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if(!fp.offline){
         final response = await RequestReviewService().getDataClient(context, identificationController.text);
        existError = response.error;
        if (response.data != null) {
          identification = identificationController.text;
          _setDataInForm(response.data!);
        } else {
          // identificationController.text = '';
          _checkFormCompleted();
        }
      }else{
        log(jsonEncode(widget.inspection));
        firstameController.text = widget.inspection.nombres;
        lastnameController.text = widget.inspection.apellidos;
        razonSocialController.text = widget.inspection.razonSocial;
        Helper.snackBar(context: context, message: 'No tienes acceso a internet, porque estas en modo offline.', colorSnackBar: Colors.red);
      }
    }
     
    setState(() {});
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
      Helper.logger.w('se hace esto');
      inspect(continueInspection);
      _setDataStorageInForm(continueInspection);
    } else {
      Helper.logger.w('no hay storage');
      _loadClientData();
    }
  }

  _setDataStorageInForm(ContinueInspection inspectionData) {
    tipoIdentificacion = inspectionData.tipoIdentificacion ?? '';
    identificationController.text = inspectionData.identificacion ?? '';

    _loadIdentificationSelect(
        inspectionData.tipoIdentificacion!, inspectionData.identificacion!);
    identification = inspectionData.identificacion ?? '';
    firstameController.text = inspectionData.nombres ?? '';
    lastnameController.text = inspectionData.apellidos ?? '';
    emailController.text = inspectionData.email ?? '';
    calendarController.text = inspectionData.fechaNacimiento ?? '';
    selectedGenderTypeValue = inspectionData.generoValue ?? '';
    selectedGenderType = inspectionData.genero ?? '';
    selectedCivilStateTypeValue = inspectionData.estadoCivilValue ?? '';
    selectedCivilStateType = inspectionData.estadoCivil ?? '';
    identificationType = inspectionData.identificationType ?? true;
    razonSocialController.text = inspectionData.razonSocial ?? '';
    setState(() {});
    _checkFormCompleted();
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      Helper.logger.w('entra en esto');
      inspectionData = continueInspection;
    }
    // inspectionData.direccion = di;
    // inspectionData.incomes =null;
    // inspectionData.telefono = null;
    // inspectionData.celular = null;
    inspectionData.fechaInspeccionReal = startDateInspection;
    inspectionData.identificacion = identificationController.text;
    inspectionData.tipoIdentificacion = tipoIdentificacion;
    inspectionData.nombres = firstameController.text.trim();
    inspectionData.apellidos = lastnameController.text.trim();
    inspectionData.razonSocial = razonSocialController.text.trim();
    inspectionData.fechaNacimiento = calendarController.text;
    inspectionData.genero = selectedGenderType;
    inspectionData.generoValue = selectedGenderTypeValue;
    inspectionData.estadoCivil = selectedCivilStateType;
    inspectionData.estadoCivilValue = selectedCivilStateTypeValue;
    inspectionData.identificationType = identificationType;
    inspectionData.email = emailController.text.trim();

    // Map<String, dynamic> body = {
    // "idSolicitud":  widget.inspection.idSolicitud.toString(),
    // "inspectionData.fechaInspeccionReal" : startDateInspection,
    // "inspectionData.identificacion" : identificationController.text,
    // "inspectionData.tipoIdentificacion" : tipoIdentificacion,
    // "inspectionData.nombres" :firstameController.text,
    // "inspectionData.apellidos" : lastnameController.text,
    // "inspectionData.razonSocial" :razonSocialController.text,
    // "inspectionData.fechaNacimiento" : calendarController.text,
    // "inspectionData.genero" : selectedGenderType,
    // "inspectionData.generoValue" : selectedGenderTypeValue,
    // "inspectionData.estadoCivil" : selectedCivilStateType,
    // "inspectionData.estadoCivilValue" : selectedCivilStateTypeValue,
    // "inspectionData.identificationType ": identificationType,
    // "inspectionData.email" : emailController.text,
    // "telefono": inspectionData.telefono
    // };

    //Helper.logger.e(jsonEncode(body));

    InspectionStorage().setDataInspection( inspectionData, widget.inspection.idSolicitud.toString());
  }

  _setDataInForm(DatosCliente dataClient) {
    debugPrint(dataClient.toString());
    inspectionData.direccion = dataClient.persona.direcciones;
    inspectionData.incomes = dataClient.persona.rangoIngresosTrabajo;
    inspectionData.telefono = dataClient.persona.telefonos;
    inspectionData.celular = dataClient.persona.celulares;
    inspectionData.pais = null;
    inspectionData.paisValue = null;
    inspectionData.provincia = null;
    inspectionData.provinciaValue = null;
    inspectionData.localidad = null;
    inspectionData.localidadValue = null;
    inspectionData.actividadEconomica = null;
    inspectionData.actividadEconomicaValue = null;
    inspectionData.personaPublica = null;
    inspectionData.personaPublicaValue = null;

    firstameController.text =
        dataClient.persona.nombre1 + ' ' + dataClient.persona.nombre2;
    lastnameController.text =
        dataClient.persona.apellido1 + ' ' + dataClient.persona.apellido2;

    calendarController.text = dataClient.persona.fechaNacimiento;
    emailController.text = dataClient.persona.email;

    selectedGenderType = widget.dataClientForm.listaGenero
        .firstWhere((e) => e.codigo == dataClient.persona.genero)
        .descripcion;
    selectedGenderTypeValue = dataClient.persona.genero;

    selectedCivilStateType = widget.dataClientForm.listaEstadoCivil
        .firstWhere((e) => e.descripcion
            .trim()
            .toLowerCase()
            .contains(dataClient.persona.estadoCivil.toLowerCase().trim()))
        .descripcion;

    selectedCivilStateTypeValue = widget.dataClientForm.listaEstadoCivil
        .firstWhere((e) => e.descripcion
            .trim()
            .toLowerCase()
            .contains(dataClient.persona.estadoCivil.toLowerCase().trim()))
        .codigo
        .toString();

    setState(() {});
    _checkFormCompleted();
  }

  @override
  Widget build(BuildContext context) {
    //Helper.logger.e("idTransaccion: $idTransaccion");
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          "DATOS PERSONALES",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
          textAlign: TextAlign.left,
        ),
        const Divider(),
        //  selectField(idetificationList, 'Tipo de identificación', selectedIdentificationType,
        //     selectedIdentificationTypeValue , null, _onchangeIdentificationType),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Tipo de identificación',
                options: idetificationList,
                selectedChoice: null,
                optionSelected: _onchangeIdentificationType,
                modalFilter: false,
                textShow: selectedIdentificationType,
                value: selectedIdentificationTypeValue)),
        const SizedBox(
          height: 10,
        ),
        if (selectedIdentificationTypeValue == "2") _cedulaField(),
        if (selectedIdentificationTypeValue == "1") _rucField(),
        if (selectedIdentificationTypeValue == "3") _passportField(),
        if (identificationType) _firstnameField(),
        if (identificationType) _lastnameField(),
        if (!identificationType) _razonSocialField(),
        const SizedBox(
          height: 10,
        ),
        FadeInRight(
          duration: const Duration(milliseconds: 600),
          child: DatePickerWidget(
              label: 'Fecha de nacimiento',
              firstDate: Helper().stringToDateTime('1900-01-01'),
              calendarController: calendarController),
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(genderList, 'Género', selectedGenderType,
        //     selectedGenderTypeValue, null, _onchangeGender),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Género',
                options: genderList,
                selectedChoice: null,
                optionSelected: _onchangeGender,
                modalFilter: false,
                textShow: selectedGenderType,
                value: selectedGenderTypeValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(civilStateList, 'Estado Civil', selectedCivilStateType,
        //     selectedCivilStateTypeValue, null, _onchangeCivilState),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Estado Civil',
                options: civilStateList,
                selectedChoice: null,
                optionSelected: _onchangeCivilState,
                modalFilter: false,
                textShow: selectedCivilStateType,
                value: selectedCivilStateTypeValue)),
        const Divider(),
        _emailField(),
        Container(
            height: 80,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (formCompleted)
                  Expanded(
                    child: FadeInRight(
                        child: Container(
                      margin: const EdgeInsets.all(4),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                AppConfig.appThemeConfig.primaryColor),
                        onPressed: () {
                          if (emailController.text
                              .contains("@sweadenseguros.com")) {
                            final fp = Provider.of<FunctionalProvider>(context,
                                listen: false);
                            fp.showAlert(
                                content: const AlertGenericError(
                              message:
                                  "El correo no puede pertenecer a Sweaden Seguros, debe ser el email del cliente",
                              messageButton: "Aceptar",
                            ));
                            return;
                          }
                          Helper.dismissKeyboard(context);
                          _saveDataStorage();
                          widget.onContinueFlag(true);
                        },
                        child: const Text(
                          'CONTINUAR',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )),
                  )
              ],
            )),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  // FadeInRight selectField(
  //     List<S2Choice<String>> options,
  //     String title,
  //     String textShow,
  //     String value,
  //     S2Choice<String>? selectedChoice,
  //     Function(S2Choice<String?>?) optionSelected) {
  //   return FadeInRight(
  //       duration: const Duration(milliseconds: 600),
  //       child: SelectWidget(
  //           title: title,
  //           options: options,
  //           selectedChoice: selectedChoice,
  //           optionSelected: optionSelected,
  //           modalFilter: false,
  //           textShow: textShow,
  //           value: value));
  // }

  String queriedIdentification = "";
  _cedulaField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Focus(
            onFocusChange: (hasFocus) {
              if (isValidDocument &&
                  !hasFocus &&
                  queriedIdentification != identificationController.text) {
                _loadClientData();
                
              }
            },
            child: TextFieldWidget(
              label: 'Cédula',
              controller: identificationController,
              inputFormatter: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              suffixIcon: isValidDocument
                  ? TextButton(
                      style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ))),
                      onPressed: () {
                        _loadClientData();
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                        size: 30.0,
                      ),
                    )
                  : null,
              textInputType: TextInputType.phone,
              isValid: isValidDocument,
              onChanged: (value) {
                if (Helper().identificationValidator(value, 'ci')) {
                  identificationType = true;
                  isValidDocument = true;
                  tipoIdentificacion = '2';
                } else {
                  isValidDocument = false;
                }
                setState(() {});
                _checkFormCompleted();
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  _rucField() {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Focus(
            onFocusChange: (hasFocus) {
              if (isValidDocument &&
                  !hasFocus &&
                  queriedIdentification != identificationController.text) {
                _loadClientData();
              }
            },
            child: TextFieldWidget(
              label: 'RUC',
              controller: identificationController,
              suffixIcon: isValidDocument
                  ? TextButton(
                      style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ))),
                      onPressed: () {
                        _loadClientData();
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                        size: 30.0,
                      ),
                    )
                  : null,
              textInputType: TextInputType.phone,
              isValid: isValidDocument,
              onChanged: (value) {
                //? En caso de Ruc este nos devuelve una List<bool>
                //? La posición 0 nos indica si el ruc ingresado es valido o no
                //? La posición 1 nos indica si el ruc es de tipo natural: true, jurídico y público: false
                final rucType = Helper().identificationValidator(value, 'ruc');
                if (rucType[1]) {
                  identificationType = true;
                  tipoIdentificacion = '1';
                } else {
                  identificationType = false;
                }
                isValidDocument = rucType[0];
                if (identificationController.text.length == 13 && !rucType[0]) {
                  Helper.dismissKeyboard(context);
                  fp.showAlert(
                      content: AlertGenericError(
                    message:
                        "Este RUC no fue detectado como valido, si esta de acuerdo continue con los datos",
                    messageButton: "Aceptar",
                    onPress: () {
                      isValidDocument = true;
                      setState(() {});
                      if (isValidDocument &&
                          queriedIdentification !=
                              identificationController.text) {
                        _loadClientData();
                      } else {
                        fp.dismissAlert();
                      }
                    },
                  ));
                }
                setState(() {});
                _checkFormCompleted();
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  _passportField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus &&
                  queriedIdentification != identificationController.text) {
                _loadClientData();
              }
            },
            child: TextFieldWidget(
              label: 'Pasaporte',
              controller: identificationController,
              textInputType: TextInputType.number,
              isValid: isValidDocument,
              onChanged: (value) {
                identificationType = true;
                isValidDocument = true;
                tipoIdentificacion = '3';
                setState(() {});
                _checkFormCompleted();
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  _firstnameField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Nombres',
            controller: firstameController,
            textInputType: TextInputType.text,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]'))
            ],
            onChanged: (value) {
              _checkFormCompleted();
              setState(() {});
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _lastnameField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Apellidos',
            controller: lastnameController,
            textInputType: TextInputType.text,
            inputFormatter: [
              // FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
              FilteringTextInputFormatter.allow(RegExp(r'[ a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]'))
            ],
            onChanged: (value) {
              _checkFormCompleted();
              setState(() {});
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _razonSocialField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Razon social',
            controller: razonSocialController,
            textInputType: TextInputType.text,
            onChanged: (value) {
              _checkFormCompleted();
              setState(() {});
            },
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9ñÑüÜ\.\. ]'))
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  _emailField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Email',
            controller: emailController,
            textInputType: TextInputType.emailAddress,
            isValid: isValidEmail,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-_.@]'))
            ],
            onChanged: (value) {
              isValidEmail = Helper().emailValidator(value);
              _checkFormCompleted();
              setState(() {});
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _onchangeIdentificationType(v) {
    _loadIdentificationSelect(
        v!.value.toString(), identificationController.text);
    setState(() {});
    _checkFormCompleted();
  }

  _onchangeGender(v) {
    selectedGenderTypeValue = v!.value.toString();
    selectedGenderType = v.title.toString();
    _checkFormCompleted();
    setState(() {});
  }

  _onchangeCivilState(v) {
    selectedCivilStateTypeValue = v!.value.toString();
    selectedCivilStateType = v.title.toString();
    _checkFormCompleted();
    setState(() {});
  }
}
