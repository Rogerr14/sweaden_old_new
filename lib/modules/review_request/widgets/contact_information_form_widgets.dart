part of 'review_request_widgets.dart';

class ContactInformationFormWidget extends StatefulWidget {
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final DataClientForm dataClientForm;
  final Lista inspection;

  const ContactInformationFormWidget({
    Key? key,
    required this.onNextFlag,
    required this.onBackFlag,
    required this.inspection,
    required this.dataClientForm,
  }) : super(key: key);

  @override
  ContactInformationFormState createState() => ContactInformationFormState();
}

class ContactInformationFormState extends State<ContactInformationFormWidget>
    with AutomaticKeepAliveClientMixin {
  ContinueInspection inspectionData = ContinueInspection();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneCelularController = TextEditingController();
  List<S2Choice<String>> countryList = [];
  List<S2Choice<String>> provinceList = [];
  List<S2Choice<String>> localityList = [];
  List<S2Choice<String>> exposePersonList = [];
  List<S2Choice<String>> economicActivityList = [];
  String selectedCountryText = 'País';
  String selectedCountryTextValue = '';
  String selectedProvinceText = 'Provincia';
  String selectedProvinceTextValue = '';
  String selectedLocalityText = 'Localidad';
  String selectedLocalityTextValue = '';
  // String selectedExposePersonText = 'No';
  // String selectedExposePersonTextValue = '0';
  String selectedExposePersonText = 'Persona expuesta públicamente';
  String selectedExposePersonTextValue = '';
  String selectedEconomicActivityText = 'Actividad económica';
  String selectedEconomicActivityTextValue = '';
  bool formCompleted = false;
  bool isValidPhoneCel = false;

  @override
  void initState() {
    super.initState();
    _loadDataForm();
    _getDataStorage();
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    phoneCelularController.dispose();
    super.dispose();
  }

  _setDataStorageInForm(ContinueInspection continueInspection) {
    inspectionData = continueInspection;

    // Helper.logger.w('telefono: ${continueInspection.telefono != null ? '0924112618' : ''}');

    addressController.text = continueInspection.direccion ?? widget.inspection.direccion;
    phoneController.text =
        continueInspection.telefono?.replaceAll('null', '') ?? '';
    phoneCelularController.text = continueInspection.celular ?? '';
    continueInspection.celular != null ? isValidPhoneCel = true : null;
    selectedCountryTextValue = continueInspection.paisValue ?? '011';
    selectedCountryText =
        continueInspection.pais ?? countryList.first.title.toString();
    selectedProvinceTextValue = continueInspection.provinciaValue ?? '';
    selectedProvinceText = continueInspection.provincia ?? selectedProvinceText;
    selectedLocalityTextValue = continueInspection.localidadValue ?? '';
    selectedLocalityText = continueInspection.localidad ?? selectedLocalityText;
    selectedEconomicActivityTextValue =
        continueInspection.actividadEconomicaValue ?? '';
    selectedEconomicActivityText =
        continueInspection.actividadEconomica ?? selectedEconomicActivityText;
    selectedExposePersonTextValue =
        continueInspection.personaPublicaValue ?? '0';
    selectedExposePersonText = continueInspection.personaPublica ?? 'No';

    _loadProvince('011');
    inspectionData.provinciaValue != null
        ? _loadLocality(continueInspection.provinciaValue!)
        : null;
    setState(() {});
    _checkFormCompleted();
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }

    inspectionData.direccion = addressController.text.trim();
    inspectionData.telefono = phoneController.text.trim();
    inspectionData.celular = phoneCelularController.text.trim();
    inspectionData.pais = selectedCountryText;
    inspectionData.paisValue = selectedCountryTextValue;
    inspectionData.provincia = selectedProvinceText;
    inspectionData.provinciaValue = selectedProvinceTextValue;
    inspectionData.localidad = selectedLocalityText;
    inspectionData.localidadValue = selectedLocalityTextValue;
    inspectionData.actividadEconomica = selectedEconomicActivityText;
    inspectionData.actividadEconomicaValue = selectedEconomicActivityTextValue;
    inspectionData.personaPublica = selectedExposePersonText;
    inspectionData.personaPublicaValue = selectedExposePersonTextValue;

    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
      inspect(continueInspection);
      _setDataStorageInForm(continueInspection);
    }
    setState(() {});
  }

  _loadDataForm() {
    countryList = widget.dataClientForm.listaPais
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
    economicActivityList = widget.dataClientForm.listaActividadEconomica
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
    exposePersonList.add(S2Choice(value: '1', title: 'Si'));
    exposePersonList.add(S2Choice(value: '0', title: 'No'));
    setState(() {});
  }

  _loadLocality(String codProvincia) {
    List<ListaProvincia> filter = [];
    filter.addAll(widget.dataClientForm.listaProvincia);
    filter.retainWhere((province) {
      return province.codigo == codProvincia;
    });

    localityList = filter[0]
        .listaLocalidad
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
  }

  _loadProvince(String codPais) {
    List<ListaProvincia> filter = [];
    filter.addAll(widget.dataClientForm.listaProvincia);
    filter.retainWhere((province) {
      return province.idPais == codPais;
    });

    provinceList = filter
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          "INFORMACIÓN DE CONTACTO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
          textAlign: TextAlign.left,
        ),
        const Divider(),
        _addressField(),
        const SizedBox(
          height: 10,
        ),
        // selectField(countryList, 'País', selectedCountryText,
        //     selectedCountryTextValue, null, _onchangeCountry),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'País',
                options: countryList,
                selectedChoice: null,
                optionSelected: _onchangeCountry,
                modalFilter: true,
                modalFilterAuto: true,
                // useConfirm: true,
                textShow: selectedCountryText,
                isAlreadySelected: false,
                value: selectedCountryTextValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(provinceList, 'Provincia', selectedProvinceText,
        //     selectedProvinceTextValue, null, _onchangeProvince),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Provincia',
                options: provinceList,
                selectedChoice: null,
                optionSelected: _onchangeProvince,
                modalFilter: true,
                modalFilterAuto: true,
                // useConfirm: true,
                textShow: selectedProvinceText,
                isAlreadySelected: false,
                value: selectedProvinceTextValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(localityList, 'Localidad', selectedLocalityText,
        //     selectedLocalityTextValue, null, _onchangeLocality),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Localidad',
                options: localityList,
                selectedChoice: null,
                optionSelected: _onchangeLocality,
                modalFilter: true,
                modalFilterAuto: true,
                textShow: selectedLocalityText,
                isAlreadySelected: false,
                value: selectedLocalityTextValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(
        //     economicActivityList,
        //     'Actividad económica',
        //     selectedEconomicActivityText,
        //     selectedEconomicActivityTextValue,
        //     null,
        //     _onchangeEconomicActivity),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Actividad económica',
                options: economicActivityList,
                selectedChoice: null,
                optionSelected: _onchangeEconomicActivity,
                modalFilter: true,
                modalFilterAuto: true,
                textShow: selectedEconomicActivityText,
                isAlreadySelected: false,
                value: selectedEconomicActivityTextValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        Container(
            margin: const EdgeInsets.only(left: 8),
            child: Text('Persona Expuesta',
                style: TextStyle(
                    color: AppConfig.appThemeConfig.primaryColor,
                    fontSize: 12))),
        const SizedBox(
          height: 8,
        ),
        // selectField(
        //     exposePersonList,
        //     'Persona Expuesta Públicamente',
        //     selectedExposePersonText,
        //     selectedExposePersonTextValue,
        //     exposePersonList.firstWhere((e) => e.value == '0'),
        //     _onchangeExposePerson,
        //     filter: false),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Persona Expuesta Públicamente',
                options: exposePersonList,
                selectedChoice:
                    exposePersonList.firstWhere((e) => e.value == '0'),
                optionSelected: _onchangeExposePerson,
                modalFilter: false,
                modalFilterAuto: true,
                textShow: selectedExposePersonText,
                isAlreadySelected: (exposePersonList.isNotEmpty) ? true : false,
                value: selectedExposePersonTextValue)),
        const Divider(),
        _phoneField(),
        _phoneCelField(),
        SizedBox(
          height: 50,
          child: Row(
            children: [
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
                              AppConfig.appThemeConfig.secondaryColor),
                      onPressed: () {
                        widget.onBackFlag(true);
                      },
                      child: const Text(
                        'REGRESAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
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
                        Helper.dismissKeyboard(context);
                        _saveDataStorage();
                        widget.onNextFlag(true);
                      },
                      child: const Text(
                        'CONTINUAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
                )
            ],
          ),
        )
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
  //     Function(S2Choice<String?>?) optionSelected,
  //     {bool? filter = true}) {
  //   return FadeInRight(
  //       duration: const Duration(milliseconds: 600),
  //       child: SelectWidget(
  //           title: title,
  //           options: options,
  //           selectedChoice: selectedChoice,
  //           optionSelected: optionSelected,
  //           modalFilter: filter,
  //           modalFilterAuto: true,
  //           // useConfirm: true,
  //           textShow: textShow,
  //           isAlreadySelected: (selectedChoice != null) ? true : false,
  //           value: value));
  // }

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
            onChanged: (value) {
              _checkFormCompleted();
              setState(() {});
            },
            inputFormatter: [
              LengthLimitingTextInputFormatter(255),
              FilteringTextInputFormatter.allow(Helper.addressRegExp)
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  _phoneField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Teléfono Convencional',
            controller: phoneController,
            maxLength: 12,
            // isValid: isValidPhone,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
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

  _phoneCelField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Teléfono Celular',
            controller: phoneCelularController,
            maxLength: 10,
            isValid: isValidPhoneCel,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            onChanged: (value) {
              if (value.length == 10) {
                isValidPhoneCel = true;
              } else {
                isValidPhoneCel = false;
              }
              _checkFormCompleted();
              setState(() {});
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _checkFormCompleted() {
    if ((selectedCountryTextValue.isNotEmpty &&
            selectedCountryTextValue != '') &&
        (selectedProvinceTextValue.isNotEmpty &&
            selectedProvinceTextValue != '') &&
        (selectedLocalityTextValue.isNotEmpty &&
            selectedLocalityTextValue != '') &&
        (selectedExposePersonTextValue.isNotEmpty &&
            selectedExposePersonTextValue != '') &&
        (selectedEconomicActivityTextValue.isNotEmpty &&
            selectedEconomicActivityTextValue != '') &&
        phoneCelularController.text.trim().isNotEmpty &&
        isValidPhoneCel &&
        addressController.text.trim().isNotEmpty) {
      formCompleted = true;
    } else {
      formCompleted = false;
    }
    setState(() {});
  }

  _onchangeCountry(v) {
    if (v!.value != selectedCountryTextValue) {
      selectedCountryTextValue = v!.value.toString();
      selectedCountryText = v.title.toString();
      selectedProvinceText = 'Provincia';
      selectedCountryTextValue = '';
      _loadProvince(v.value);
      _checkFormCompleted();
      setState(() {});
    }
  }

  _onchangeProvince(v) {
    if (v!.value != selectedProvinceTextValue) {
      selectedProvinceTextValue = v!.value.toString();
      selectedProvinceText = v.title.toString();
      selectedLocalityText = 'Localidad';
      selectedLocalityTextValue = '';
      _loadLocality(v.value);
      _checkFormCompleted();
      setState(() {});
    }
  }

  _onchangeLocality(v) {
    selectedLocalityTextValue = v!.value.toString();
    selectedLocalityText = v.title.toString();
    _checkFormCompleted();
    setState(() {});
  }

  _onchangeExposePerson(v) {
    selectedExposePersonTextValue = v!.value.toString();
    selectedExposePersonText = v.title.toString();
    _checkFormCompleted();
    setState(() {});
  }

  _onchangeEconomicActivity(v) {
    selectedEconomicActivityTextValue = v!.value.toString();
    selectedEconomicActivityText = v.title.toString();
    _checkFormCompleted();
    setState(() {});
  }
}
