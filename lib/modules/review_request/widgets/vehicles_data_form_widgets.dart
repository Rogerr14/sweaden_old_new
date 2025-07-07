part of 'review_request_widgets.dart';

class VehiclesDataFormWidget extends StatefulWidget {
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final ValueChanged<int> onJumpFlag;
  final Lista inspection;

  const VehiclesDataFormWidget({
    Key? key,
    required this.onNextFlag,
    required this.onBackFlag,
    required this.onJumpFlag,
    required this.inspection,
  }) : super(key: key);

  @override
  VehiclesDataFormState createState() => VehiclesDataFormState();
}

class VehiclesDataFormState extends State<VehiclesDataFormWidget> with AutomaticKeepAliveClientMixin {
  //final int _currentYear = DateTime.now().year;

  ContinueInspection inspectionData = ContinueInspection();

  VehicleDataInspection? vehicleDataInspection;
  List<VehicleModel>? vehicleDataModels;

  List<S2Choice<String>> markList = [];
  List<S2Choice<String>> modelList = [];
  List<S2Choice<String>> countryOList = [];
  List<S2Choice<String>> useList = [];
  List<S2Choice<String>> typeList = [];
  List<S2Choice<String>> colorList = [];

  String selectedMarkText = 'Marca';
  String selectedMarkValue = '';
  String selectedModelText = 'Modelo';
  String selectedModelValue = '';
  String selectedTypeText = 'Tipo';
  String selectedTypeValue = '';
  String selectedUseText = 'Uso';
  String selectedUseValue = '';
  String selectedColorText = 'Color';
  String selectedColorValue = '';
  String selectedCountryOText = 'País de origen';
  String selectedCountryOValue = '';

  String plaque = '';

  TextEditingController dateInController = TextEditingController();
  TextEditingController dateOutController = TextEditingController();
  TextEditingController kmController = TextEditingController();
  TextEditingController cantPassengersController = TextEditingController();
  TextEditingController priceSuggestedController = TextEditingController();
  TextEditingController motorController = TextEditingController();
  TextEditingController chasisController = TextEditingController();
  TextEditingController plaqueController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: 'en').currencySymbol;

  bool formCompleted = false;
  bool isValidYear = false;
  bool isValidPlaque = false;
  bool isValidCant = false;
  bool isValidPrice = false;
  bool existError = false;
  bool pdfUploaded = false;
  //FilePickerResult? _filePickerResult;

  @override
  void initState() {
    //Helper.logger.w('entro en el initState de nuevo');
    super.initState();

    _getDataStorage();
  }

  @override
  void dispose() {
    dateInController.dispose();
    dateOutController.dispose();
    kmController.dispose();
    cantPassengersController.dispose();
    priceSuggestedController.dispose();
    motorController.dispose();
    chasisController.dispose();
    plaqueController.dispose();
    yearController.dispose();
    super.dispose();
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    if (vehicleDataInspection == null) {
      Helper.logger.w('consulta htstp');
      await _loadVehiclesDataInspection();
    } else {
      _loadDataToSelectInForm();
    }
    if (continueInspection != null) {
      Helper.logger.w('diferente de null');
      inspectionData = continueInspection;
      var flagCompleted = continueInspection.isCompletedVehiculesForm ?? false;
      if (!flagCompleted) {
        plaqueController.text = widget.inspection.datosVehiculo.placa;
        isValidPlaque = widget.inspection.datosVehiculo.placa.length > 5 &&
                widget.inspection.datosVehiculo.placa.length < 8
            ? true
            : false;
        setState(() {});
        _loadVehiclesDataClient();
      } else {
        Helper.logger.w(' null');
        _setDataStorageInForm(continueInspection);
      }
    }
  }

  _setDataStorageInForm(ContinueInspection inspectionData) async {
    plaqueController.text = inspectionData.placa ?? '';
    plaque = inspectionData.placa ?? '';
    motorController.text = inspectionData.motor ?? '';
    chasisController.text = inspectionData.chasis ?? '';
    yearController.text = inspectionData.anio ?? '';
    cantPassengersController.text = inspectionData.capacidadPasajeros ?? '';
    kmController.text = inspectionData.km ?? '';
    Helper.logger.w(
        'valor seteado: ${inspectionData.valorSugerido} - ${widget.inspection.datosVehiculo.sumaAsegurada}');
    priceSuggestedController.text = inspectionData.valorSugerido ??
        widget.inspection.datosVehiculo.sumaAsegurada;
    dateInController.text = inspectionData.fechaInicioVigencia ?? '';
    dateOutController.text = inspectionData.fechaFinVigencia ?? '';
    selectedMarkText = inspectionData.nombreMarca ?? '';
    selectedMarkValue = inspectionData.codMarca ?? '';
    selectedModelText = inspectionData.nombreModelo ?? '';
    selectedModelValue = inspectionData.codModelo ?? '';

    selectedTypeText = inspectionData.carroceria ?? '';
    selectedTypeValue = inspectionData.codCarroceria ?? '';

    selectedUseText = inspectionData.uso ?? '';
    selectedUseValue = inspectionData.codUso ?? '';

    selectedColorValue = inspectionData.codColor ?? '';
    selectedColorText = inspectionData.color ?? '';

    selectedCountryOText = inspectionData.paisO ?? '';
    selectedCountryOValue = inspectionData.codPaisO ?? '';

    await _getVehicleModels(selectedMarkValue);

    isValidPlaque = true;
    isValidPrice = true;
    isValidYear = true;
    isValidCant = true;
    setState(() {});
    _checkFormCompleted();
  }

  _setDataInForm(VehicleClientData vehicleClientData) async {
    DateTime now = DateTime.now();
    dateInController.text =
        Helper().dateToStringFormat(DateTime.now(), 'yyyy-MM-dd');
    dateOutController.text = Helper().dateToStringFormat(
        DateTime(now.year + 1, now.month, now.day), 'yyyy-MM-dd');
    plaqueController.text = vehicleClientData.placa;
    plaque = vehicleClientData.placa;
    motorController.text = vehicleClientData.motor;
    chasisController.text = vehicleClientData.chasis;
    yearController.text = vehicleClientData.anio;

    selectedMarkValue = vehicleDataInspection!.listaMarca
        .firstWhere((e) => e.descripcion == vehicleClientData.marca,
            orElse: () => ListaMarca(codMarca: "", descripcion: ""))
        .codMarca;
    if (selectedMarkValue.isNotEmpty) {
      selectedMarkText = vehicleClientData.marca;
    }
    priceSuggestedController.text =
        widget.inspection.datosVehiculo.sumaAsegurada;
    isValidPrice = true;
    if (selectedMarkValue.isNotEmpty) {
      await _getVehicleModels(selectedMarkValue);
    }
    isValidPlaque =
        vehicleClientData.placa.length > 5 && vehicleClientData.placa.length < 8
            ? true
            : false;
    isValidYear = vehicleClientData.anio.length == 4 ? true : false;

    selectedColorText = 'Color';
    selectedColorValue = '';

    selectedModelText = 'Modelo';
    selectedModelValue = '';

    selectedCountryOText = 'País de origen';
    selectedCountryOValue = '';

    selectedUseText = 'Uso';
    selectedUseValue = '';

    selectedTypeText = 'Tipo';
    selectedTypeValue = '';

    setState(() {});
    _checkFormCompleted();
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }

    inspectionData.placa = plaqueController.text.trim();
    inspectionData.motor = motorController.text.trim();
    inspectionData.chasis = chasisController.text.trim();
    inspectionData.anio = yearController.text.trim();
    inspectionData.capacidadPasajeros = cantPassengersController.text.trim();
    inspectionData.km = kmController.text.trim();
    inspectionData.valorSugerido = priceSuggestedController.text.trim();
    inspectionData.fechaInicioVigencia = dateInController.text;
    inspectionData.fechaFinVigencia = dateOutController.text;
    inspectionData.codMarca = selectedMarkValue;
    inspectionData.nombreMarca = selectedMarkText;
    inspectionData.codModelo = selectedModelValue;
    inspectionData.nombreModelo = selectedModelText;
    inspectionData.codPaisO = selectedCountryOValue;
    inspectionData.paisO = selectedCountryOText;
    inspectionData.codUso = selectedUseValue;
    inspectionData.uso = selectedUseText;
    inspectionData.codCarroceria = selectedTypeValue;
    inspectionData.carroceria = selectedTypeText;
    inspectionData.color = selectedColorText;
    inspectionData.codColor = selectedColorValue;
    inspectionData.valorSumaAsegurada = priceSuggestedController.text.trim();

    inspectionData.isCompletedVehiculesForm = true;

    if (widget.inspection.idTipoFlujo == 6) {
      //? AQUI EL FLUJO ES SIN INSPECCION PERO DEBEMOS SABER
      //? SI ES CON O SIN EMISION
      if (widget.inspection.idProceso == 50) {
        //? ES PROCESO CON EMISION
        inspectionData.emitPolize = true;
      } else {
        //? ES PROCESO SIN EMISION
        inspectionData.emitPolize = false;
      }
    }

    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
  }

  _getVehicleModels(String codMarca) async {
    if (vehicleDataModels == null) {
      //final connection = await Helper.checkConnection();
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if(!fp.offline){
        debugPrint("--- cargando datos modelos de vehiculos ---");
        final response =await RequestReviewService().getVehicleModels(context, codMarca);
        if (response.data != null) {
          vehicleDataModels = response.data;
          modelList = vehicleDataModels!.map((e) => S2Choice(value: e.codModelo.toString(),title: e.descripcion, meta: 'model')).toList();
        }
      // setState(() {});
      }else{
        final response = await OfflineStorage().getCatalogueVehiceModels();
        if(response != null){
          vehicleDataModels = response.data.map((item) => VehicleModel.fromJson(item)).toList();
          //.where((element) => element.codMarca == codMarca).toList();
          modelList = vehicleDataModels!.where((e) => e.codMarca == codMarca).map((e) => S2Choice(value: e.codModelo.toString(),title: e.descripcion, meta: 'model')).toList();
        }

      }
    }
    setState(() {});
  }

  _loadDataToSelectInForm() {
    if(vehicleDataInspection != null){

    markList = vehicleDataInspection!.listaMarca
        .map((e) => S2Choice(
              value: e.codMarca.toString(),
              title: e.descripcion,
              meta: 'mark',
            ))
        .toList();
    countryOList = vehicleDataInspection!.listaPaisOrigen
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
              meta: 'country',
            ))
        .toList();
    typeList = vehicleDataInspection!.listaTipoV
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
              meta: 'type',
            ))
        .toList();
    useList = vehicleDataInspection!.listaUso
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
              meta: 'use',
            ))
        .toList();
    colorList = vehicleDataInspection!.listaColor
        .map((e) => S2Choice(
              value: e.codigo.toString(),
              title: e.descripcion,
              meta: 'color',
            ))
        .toList();

    }
    setState(() {});
  }

  // Future<void> _pickPDF() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['pdf'],
  //   );

  //   setState(() {
  //     _filePickerResult = result;

  //     // Si el usuario ha seleccionado y subido un PDF, establecer pdfUploaded en true.
  //     pdfUploaded = result != null && result.files.isNotEmpty;
  //   });
  // }

  _loadVehiclesDataClient() async {
    if (plaqueController.text != '' &&
        plaqueController.text.isNotEmpty &&
        plaqueController.text != plaque &&
        isValidPlaque) {
      consultedPlate = plaqueController.text;
      debugPrint("--- cargando datos vehiculo cliente ---");
      //final connection = await Helper.checkConnection();
      final fp = Provider.of<FunctionalProvider>(context, listen: false);

      if(!fp.offline){
        final response = await RequestReviewService().getVehicleClientData(context, plaqueController.text.trim());
        existError = response.error;
        if(response.data != null && response.existData != false){
           _setDataInForm(response.data!);
        }else{
          _loadDataVhYear();
        }
      }else {
        _loadDataVhYear();
        Helper.snackBar(context: context, message: 'No tienes conexión a internet, porque estas en modo offline.', colorSnackBar: Colors.red);
        //Helper.logger.e('precarga datos de que no hay internet');
        //existError = false;
        // DateTime now = DateTime.now();
        // yearController.text = widget.inspection.datosVehiculo.anio;
        // priceSuggestedController.text = widget.inspection.datosVehiculo.sumaAsegurada;
        // isValidPrice = true;
        // isValidYear = true;
        // dateInController.text = Helper().dateToStringFormat(DateTime.now(), 'yyyy-MM-dd');
        // dateOutController.text = Helper().dateToStringFormat(DateTime(now.year + 1, now.month, now.day), 'yyyy-MM-dd');
        // // Helper.snackBar(context: context, message: 'No tienes acceso a internet.', colorSnackBar: Colors.red);
        // setState(() {});
      }
    }
  }

  _loadDataVhYear(){
      DateTime now = DateTime.now();
        yearController.text = widget.inspection.datosVehiculo.anio;
        priceSuggestedController.text = widget.inspection.datosVehiculo.sumaAsegurada;
        isValidPrice = true;
        isValidYear = true;
        dateInController.text = Helper().dateToStringFormat(DateTime.now(), 'yyyy-MM-dd');
        dateOutController.text = Helper().dateToStringFormat(DateTime(now.year + 1, now.month, now.day), 'yyyy-MM-dd');
        setState(() {});
  }

  _loadVehiclesDataInspection() async {
    //final connection = await Helper.checkConnection();
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    if(!fp.offline){
       debugPrint("--- cargando datos inspeccion vehiculos ---");
      final response = await RequestReviewService().getVehicleDataInspection(context);
      if (response.data != null) {
        vehicleDataInspection = response.data!;
        _loadDataToSelectInForm();
      }
    }else{
      final response = await OfflineStorage().getCatalogueVehicleData();
      if(response != null){
         vehicleDataInspection = response;
        _loadDataToSelectInForm();
      }
    }
   
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          "DATOS DEL VEHÍCULO",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
          textAlign: TextAlign.left,
        ),
        const Divider(),
        _plaqueField(),
        Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          // selectField(context,markList, 'Marca', selectedMarkText,
                          //     selectedMarkValue, null, _onchangeSelect),
                          FadeInRight(
                              duration: const Duration(milliseconds: 600),
                              child: SelectWidget(
                                  title: 'Marca',
                                  options: markList,
                                  selectedChoice: null,
                                  optionSelected: _onchangeSelect,
                                  modalFilter: true,
                                  modalFilterAuto: true,
                                  // useConfirm: true,
                                  textShow: selectedMarkText,
                                  value: selectedMarkValue)),
                          const Divider(),
                        ],
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          // selectField(context,modelList, 'Modelo', selectedModelText,
                          //     selectedModelValue, null, _onchangeSelect),
                          FadeInRight(
                              duration: const Duration(milliseconds: 600),
                              child: SelectWidget(
                                  title: 'Modelo',
                                  options: modelList,
                                  selectedChoice: null,
                                  optionSelected: _onchangeSelect,
                                  modalFilter: true,
                                  modalFilterAuto: true,
                                  // useConfirm: true,
                                  textShow: selectedModelText,
                                  value: selectedModelValue)),
                          const Divider(),
                        ],
                      )),
                )
              ],
            )),
        _motorField(),
        _chasisField(),
        _yearField(),
        const SizedBox(
          height: 10,
        ),
        // selectField(context,countryOList, 'País de origen', selectedCountryOText,
        //     selectedCountryOValue, null, _onchangeSelect),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'País de origen',
                options: countryOList,
                selectedChoice: null,
                optionSelected: _onchangeSelect,
                modalFilter: true,
                modalFilterAuto: true,
                // useConfirm: true,
                textShow: selectedCountryOText,
                value: selectedCountryOValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(context,typeList, 'Tipo', selectedTypeText, selectedTypeValue, null,
        //     _onchangeSelect),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Tipo',
                options: typeList,
                selectedChoice: null,
                optionSelected: _onchangeSelect,
                modalFilter: true,
                modalFilterAuto: true,
                textShow: selectedTypeText,
                value: selectedTypeValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(context,useList, 'Uso', selectedUseText, selectedUseValue, null,
        //     _onchangeSelect),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Uso',
                options: useList,
                selectedChoice: null,
                optionSelected: _onchangeSelect,
                modalFilter: true,
                modalFilterAuto: true,
                // useConfirm: true,
                textShow: selectedUseText,
                value: selectedUseValue)),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        // selectField(context,colorList, 'Color', selectedColorText, selectedColorValue,
        //     null, _onchangeSelect),
        FadeInRight(
            duration: const Duration(milliseconds: 600),
            child: SelectWidget(
                title: 'Color',
                options: colorList,
                selectedChoice: null,
                optionSelected: _onchangeSelect,
                modalFilter: true,
                modalFilterAuto: true,
                // useConfirm: true,
                textShow: selectedColorText,
                value: selectedColorValue)),
        const Divider(),
        Container(
            // height: 80,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          _cantPassengersField(),
                        ],
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [_kilometerField()],
                      )),
                )
              ],
            )),
        _priceSuggestedField(),
        const SizedBox(
          height: 20,
        ),
        Text(
          "DATOS DE VIGENCIA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
          textAlign: TextAlign.left,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        Container(
            // height: 80,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          FadeInRight(
                            duration: const Duration(milliseconds: 600),
                            child: DatePickerWidget(
                                label: 'Fecha inicio',
                                calendarController: dateInController,
                                validator: _checkFormCompleted,
                                ),
                          ),
                          const Divider()
                        ],
                      )),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                      color: Colors.white,
                      child: Column(
                        children: [
                          FadeInRight(
                            duration: const Duration(milliseconds: 600),
                            child: DatePickerWidget(
                                label: 'Fecha fin',
                                isDateOut: true,
                                calendarController: dateOutController,
                                validator: _checkFormCompleted,
                                ),
                          ),
                          const Divider()
                        ],
                      )),
                )
              ],
            )),
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
                        Helper.logger.w('hola hola');
                        if (widget.inspection.idTipoFlujo == 5) {
                          //? flujo con inspeccion
                          //? va a accesorios de vehiculo
                          widget.onNextFlag(true);
                        } else {
                          //? va directo al borrador
                          widget.onJumpFlag(7); // sin inspeccion
                        }
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
  //   BuildContext context,
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
  //           modalFilter: true,
  //           modalFilterAuto: true,
  //           // useConfirm: true,
  //           textShow: textShow,
  //           value: value));
  // }

  String consultedPlate = "";
  _plaqueField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Focus(
            onFocusChange: (hasFocus) {
              if (!hasFocus && consultedPlate != plaqueController.text) {
                _loadVehiclesDataClient();
              }
            },
            child: TextFieldWidget(
              label: 'Placa',
              controller: plaqueController,
              suffixIcon: isValidPlaque
                  ? TextButton(
                      style: ButtonStyle(
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ))),
                      onPressed: () {
                        Helper.dismissKeyboard(context);
                        _loadVehiclesDataClient();
                      },
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.grey,
                        size: 30.0,
                      ),
                    )
                  : null,
              maxLength: 7,
              textInputType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              isValid: isValidPlaque,
              onChanged: (value) {
                if (value.length > 5 && value.length < 8) {
                  isValidPlaque = true;
                } else {
                  isValidPlaque = false;
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

  _motorField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Motor',
            controller: motorController,
            textInputType: TextInputType.text,
            textCapitalization: TextCapitalization.characters,
            inputFormatter: [
              LengthLimitingTextInputFormatter(50),
              // FilteringTextInputFormatter.allow(RegExp('[A-Z0-9-_.]'))
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              setState(() {});
              _checkFormCompleted();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _chasisField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Chasis',
            controller: chasisController,
            textInputType: TextInputType.emailAddress,
            textCapitalization: TextCapitalization.characters,
            inputFormatter: [
              LengthLimitingTextInputFormatter(30),
              // FilteringTextInputFormatter.allow(RegExp('[A-Z0-9-_.]'))
              FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
            ],
            onChanged: (value) {
              setState(() {});
              _checkFormCompleted();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _priceSuggestedField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Valor sugerido',
            controller: priceSuggestedController,
            prefixText: _currency,
            hinText: '0.00',
            isValid: isValidPrice,
            textInputType: TextInputType.number,
            onChanged: (value) {
              isValidPrice = Helper().moneyValidator(value);
              setState(() {});
              _checkFormCompleted();
              priceSuggestedController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
            inputFormatter: [
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  _cantPassengersField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Pasajeros',
            controller: cantPassengersController,
            textInputType: TextInputType.number,
            inputFormatter: [
              LengthLimitingTextInputFormatter(3),
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            isValid: isValidCant,
            onChanged: (value) {
              if (value != '') {
                if (int.parse(value) > 0) {
                  isValidCant = true;
                } else {
                  isValidCant = false;
                }
              } else {
                isValidCant = false;
              }
              setState(() {});
              _checkFormCompleted();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _kilometerField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'KM',
            controller: kmController,
            textInputType: TextInputType.number,
            inputFormatter: [
              LengthLimitingTextInputFormatter(7),
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            onChanged: (value) {
              setState(() {});
              _checkFormCompleted();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

// Widget _yearField() {
//   return FadeInRight(
//     duration: const Duration(milliseconds: 600),
//     child: Column(
//       children: [
//         const SizedBox(
//           height: 10,
//         ),
//         TextFieldWidget(
//           label: 'Año',
//           controller: yearController,
//           maxLength: 4,
//           textInputType: TextInputType.number,
//           inputFormatter: [
//             FilteringTextInputFormatter.allow(RegExp('[0-9]'))
//           ],
//           isValid: isValidYear,
//           onChanged: (value) {
//             // Omitir la validación del año si pdfUploaded es true.
//             if (pdfUploaded) {
//               isValidYear = true;
//             } else {
//               if (value != '' && value.length == 4) {
//                 int currentYear = DateTime.now().year;
//                 if (int.parse(value) >= (currentYear - 12)) {
//                   isValidYear = true;
//                 } else {
//                   isValidYear = false;
//                 }
//               } else {
//                 isValidYear = false;
//               }
//             }

//             setState(() {});

//             // Mostrar la alerta si la validación del año funciona normalmente y pdfUploaded es false.
//             if (!pdfUploaded && !isValidYear && value.length == 4) { // Verificar que se ingresen 4 caracteres.
//               final fp = Provider.of<FunctionalProvider>(context, listen: false);
//               fp.showAlert(
//                   content: const AlertGenericError(
//                       message:
//                           'El año del vehículo no puede ser mayor al año permitido!'));
//             }

//             _checkFormCompleted();
//           },
//         ),
//         const Divider(),
//       ],
//     ),
//   );
// }

  _yearField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Año',
            controller: yearController,
            maxLength: 4,
            textInputType: TextInputType.number,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            isValid: isValidYear,
            onChanged: (value) {
              // Si hay un PDF cargado, omitir la validación del año
              if (pdfUploaded) {
                isValidYear = true;
              } else {
                if (value != '' && value.length == 4) {
                  int currentYear = DateTime.now().year;
                  if (int.parse(value) >= (currentYear - 12)) {
                    isValidYear = true;
                  } else {
                    isValidYear = false;
                  }
                } else {
                  isValidYear = false;
                }
              }

              setState(() {});

              // Mostrar la alerta si la validación del año funciona normalmente y pdfUploaded es false.
              if (!pdfUploaded && !isValidYear && value.length == 4) {
                // final fp =
                //     Provider.of<FunctionalProvider>(context, listen: false);
                // fp.showAlert(
                //     content: const AlertGenericError(
                //         message:
                //             'El año del vehículo no puede ser mayor al año permitido!'));
                final fp =
                    Provider.of<FunctionalProvider>(context, listen: false);
                fp.showAlert(
                    content: const AlertGenericError(
                        message:
                            'El año del vehiculo excede el permitido de ser asi se enviara a revisión.'));
                isValidYear = true;
                setState(() {});
              }

              _checkFormCompleted();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _onchangeSelect(v) {
    switch (v!.meta) {
      case 'mark':
        if (selectedMarkValue != v.value) {
          selectedMarkText = v.title;
          selectedMarkValue = v.value;
          selectedModelText = 'Modelo';
          selectedModelValue = '';
          vehicleDataModels = null;
          setState(() {});
          _getVehicleModels(v.value);
        }
        break;
      case 'model':
        selectedModelText = v.title;
        selectedModelValue = v.value;
        break;
      case 'country':
        selectedCountryOText = v.title;
        selectedCountryOValue = v.value;
        break;
      case 'type':
        selectedTypeText = v.title;
        selectedTypeValue = v.value;

        break;
      case 'use':
        selectedUseText = v.title;
        selectedUseValue = v.value;
        break;
      case 'color':
        selectedColorText = v.title;
        selectedColorValue = v.value;
        break;
    }

    setState(() {});

    _checkFormCompleted();
  }

  _checkFormCompleted() {
    if (!existError &&
        (plaqueController.text.isNotEmpty && plaqueController.text != '') &&
        selectedMarkValue != '' &&
        selectedModelValue != '' &&
        selectedCountryOValue != '' &&
        selectedColorValue != '' &&
        selectedUseValue != '' &&
        selectedTypeValue != '' &&
        isValidPlaque &&
        isValidPrice &&
        isValidYear &&
        isValidCant &&
        (motorController.text.trim().isNotEmpty && motorController.text.trim() != '') &&
        (chasisController.text.trim().isNotEmpty && chasisController.text.trim() != '') &&
        (cantPassengersController.text.trim().isNotEmpty &&
            cantPassengersController.text.trim() != '') &&
        (kmController.text.trim().isNotEmpty && kmController.text.trim() != '') &&
        (priceSuggestedController.text.trim().isNotEmpty &&
            priceSuggestedController.text.trim() != '') &&
        (dateInController.text.isNotEmpty && dateInController.text != '') &&
        (dateOutController.text.isNotEmpty && dateOutController.text != '') &&
        (yearController.text.trim().isNotEmpty && yearController.text.trim() != '')) {
      formCompleted = true;
    } else {
      formCompleted = false;
    }
    setState(() {});
  }
}
