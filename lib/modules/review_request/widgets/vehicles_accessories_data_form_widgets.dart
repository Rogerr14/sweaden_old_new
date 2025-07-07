part of 'review_request_widgets.dart';

class VehiclesAccessoriesDataFormWidget extends StatefulWidget {
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final Lista inspection;

  const VehiclesAccessoriesDataFormWidget({
    Key? key,
    required this.onNextFlag,
    required this.onBackFlag,
    required this.inspection,
  }) : super(key: key);

  @override
  VehiclesAccessoriesDataFormState createState() =>
      VehiclesAccessoriesDataFormState();
}

class VehiclesAccessoriesDataFormState
    extends State<VehiclesAccessoriesDataFormWidget>
    with AutomaticKeepAliveClientMixin 
    {
  ContinueInspection inspectionData = ContinueInspection();
  List<AccesoriesVehicle> accesoriesVehicle = [];
  List<DataRow> accesoriesRows = [];
  bool action = false;
  bool formCompleted = false;
  bool existError = false;

  @override
  void initState() {
    _getDataStorage();
    super.initState();
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.inspection.idSolicitud.toString());
    if (continueInspection != null) {
      inspectionData = continueInspection;
      var flag = continueInspection.accessoriesVehicles ?? [];
      if (flag.isNotEmpty) {
        accesoriesVehicle = continueInspection.accessoriesVehicles!;
      } else {
        _getVehiclesAccesories();
      }
    }
    setState(() {});
    _checkFormCompleted();
  }

  _checkFormCompleted() {
    formCompleted = false;

    for (var element in accesoriesVehicle) {
      var extra = element.extra ?? false;
      var original = element.original ?? false;
      if (extra || original) {
        formCompleted = true;
        return;
      }
    }
    setState(() {});
  }

  Future<bool> _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    final fp = Provider.of<FunctionalProvider>(context,listen:false);   

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }
    //? La suma de los adicionales no debe ser mayor al 20% de la suma asegurada
    var isValid = false;
   isValid =  _verifyUnitValue(double.parse(inspectionData.valorSugerido!));

    if(isValid){
      inspectionData.accessoriesVehicles = accesoriesVehicle;
    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
    }else{
      fp.showAlert(content: AlertGenericError(message: "La suma de los accesorios no puede ser igual o mayor al 20% de la suma asegurada: \$${inspectionData.valorSugerido}"));
    }
    return isValid;
  }

  bool _verifyUnitValue(double sumAssured){
    final percentAllowed = sumAssured *0.20;
    // print(percentAllowed);
    double totalUnitValue = 0;
    for(var element in accesoriesVehicle){
       var value = double.parse(element.valUnit??'0')  * int.parse(element.cantidad ?? "1");
       totalUnitValue = totalUnitValue + value;
    }
    // print("EL VALOR TOTAL UNITARIO:");
    // print("\$$totalUnitValue");
    if(totalUnitValue>=percentAllowed){
      return false;
    }
    return true;
  }

  _getVehiclesAccesories() async {
    // if (accesoriesVehicle.isEmpty) {
    //bool connection = await Helper.checkConnection();
    final fp = Provider.of<FunctionalProvider>(context,listen:false);   
    if(!fp.offline){
      final response = await RequestReviewService().getAccesoriesVehicle(context, widget.inspection.idRamo);
      // if (response.data != null) {
      if (!response.error) {
        existError = false;
        debugPrint("--- cargando datos accesorios de vehiculos ---");
        accesoriesVehicle = response.data!;
      } else {
        existError = true;
      }
      setState(() {});
    }else{
      // accesoriesVehicle = [];
      _getAccesoriesVehicleStorage();
    }
    //setState(() {});
    // }
  }

  _getAccesoriesVehicleStorage() async {
      final response = await OfflineStorage().getCatalogueVehicleAccessories();
      //Helper.logger.w('response: ${jsonEncode(response)}');
      if(response != null){
        accesoriesVehicle = response.data.map((item) => AccesoriesVehicle.fromJson(item)).toList();
        existError = false;
      }else{
        existError = true;
      }
      setState(() {});
  }

  _openModalAccessories(AccesoriesVehicle accessoryVehicle, String type) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    fp.showAlert(
        content: AccessoriesModal(
      accessoryVehicle: accessoryVehicle,
      add: _updateAccessory,
      type: type,
    ));
  }

  _updateAccessory(AccesoriesVehicle accessoryVehicle) {
    for (var element in accesoriesVehicle) {
      if (element.descripcion == accessoryVehicle.descripcion) {
        if (accessoryVehicle.tipo == 'E') {
          accessoryVehicle.original = false;
          accessoryVehicle.extra = true;
        } else {
          accessoryVehicle.original = true;
          accessoryVehicle.extra = false;
        }
        accessoryVehicle.cantidad = accessoryVehicle.cantidad;
        accessoryVehicle.bueno = true;
        accessoryVehicle.medio = false;
        accessoryVehicle.regular = false;
        element = accessoryVehicle;
      }
    }
    setState(() {});
    _checkFormCompleted();
  }

  List<DataRow> _createRows() {
    return accesoriesVehicle
        .map((element) => DataRow(cells: [
              DataCell(
                InkWell(
                  onTap:(){
                    inspect(element);
                    if(element.tipo!=null){
                      switch (element.tipo) {
                        case "E":
                          _openModalAccessories(element, 'E');
                          break;
                        case "O":
                        _openModalAccessories(element, 'O');
                          break;
                      }
                    }
                  },
                  child: SizedBox(
                      width: 80,
                      child: Text(element.descripcion,
                          style: TextStyle(
                              fontSize: 10,
                              color: AppConfig.appThemeConfig.secondaryColor),
                          textAlign: TextAlign.center)),
                ),
              ),
              DataCell(
                SizedBox(width: 40, child: _checkBoxExtra(element)),
              ),
              DataCell(
                SizedBox(width: 50, child: _checkBoxOriginal(element)),
              ),
              DataCell(
                SizedBox(
                    width: 20,
                    child: Text(element.cantidad ?? '1',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor),
                        textAlign: TextAlign.center)),
              ),
              DataCell(
                SizedBox(width: 20, child: _radioButtonChanged(element, 'B')),
              ),
              DataCell(
                SizedBox(width: 20, child: _radioButtonChanged(element, 'M')),
              ),
              DataCell(
                SizedBox(width: 20, child: _radioButtonChanged(element, 'R')),
              ),
            ]))
        .toList();
  }

  _checkBoxExtra(AccesoriesVehicle accessoryVehicle) {
    var onChanged = accessoryVehicle.accesorio != null
        ? (v) => {
              if (v!)
                {_openModalAccessories(accessoryVehicle, 'E')}
              else
                {
                  accessoryVehicle.extra = v,
                  accessoryVehicle.original = false,
                  accessoryVehicle.cantidad = "1",
                  accessoryVehicle.marca = "",
                  accessoryVehicle.modelo = "",
                  accessoryVehicle.bueno = false,
                  accessoryVehicle.medio = false,
                  accessoryVehicle.regular = false,
                  accessoryVehicle.valUnit = null,
                  accessoryVehicle.tipo =null,
                  setState(() {}),
                  _checkFormCompleted()
                },
            }
        : null;
    return Checkbox(
        activeColor: AppConfig.appThemeConfig.secondaryColor,
        value: accessoryVehicle.extra ?? false,
        onChanged: onChanged);
  }

  _checkBoxOriginal(AccesoriesVehicle accessoryVehicle) {
    return Checkbox(
        activeColor: AppConfig.appThemeConfig.secondaryColor,
        value: accessoryVehicle.original ?? false,
        onChanged: (v) => {
              if (v!)
              { 
                _openModalAccessories(accessoryVehicle, 'O')}
              else
                {
                  accessoryVehicle.extra = false,
                  accessoryVehicle.original = v,
                  accessoryVehicle.cantidad = "1",
                  accessoryVehicle.marca = "",
                  accessoryVehicle.modelo = "",
                  accessoryVehicle.bueno = false,
                  accessoryVehicle.medio = false,
                  accessoryVehicle.regular = false,
                  accessoryVehicle.tipo =null,
                  setState(() {}),
                  _checkFormCompleted()
                },
            });
  }

  _radioButtonChanged(AccesoriesVehicle accessoryVehicle, String type) {
    bool value = false;
    var extra = accessoryVehicle.extra ?? false;
    var original = accessoryVehicle.original ?? false;
    Set<void> Function(dynamic v)? onChanged;
    if (extra || original) {
      onChanged = (v) => {
            if (v == 'B')
              {
                accessoryVehicle.bueno = true,
                accessoryVehicle.medio = false,
                accessoryVehicle.regular = false
              },
            if (v == 'M')
              {
                accessoryVehicle.bueno = false,
                accessoryVehicle.medio = true,
                accessoryVehicle.regular = false
              },
            if (v == 'R')
              {
                accessoryVehicle.bueno = false,
                accessoryVehicle.medio = false,
                accessoryVehicle.regular = true
              },
            setState(() {}),
          };
    } else {
      onChanged = null;
    }
    switch (type) {
      case 'B':
        value = accessoryVehicle.bueno ?? false;
        break;
      case 'M':
        value = accessoryVehicle.medio ?? false;
        break;
      case 'R':
        value = accessoryVehicle.regular ?? false;
        break;
    }
    return Radio(
        activeColor: AppConfig.appThemeConfig.secondaryColor,
        value: type,
        groupValue: value ? type : '',
        onChanged: onChanged);
  }

  _checkData() {
    for (var e in accesoriesVehicle) {
      if (action) {
        e.original = true;
        e.extra = false;
        e.cantidad = "1";
        e.bueno = true;
        e.medio = false;
        e.regular = false;
        e.tipo = "O";
        e.valUnit = "0";
      } else {
        e.original = false;
        e.extra = false;
        e.cantidad = "1";
        e.bueno = false;
        e.medio = false;
        e.regular = false;
        e.tipo = null;
        e.valUnit = "0";
      }
    }
    formCompleted = action ? true : false;
    setState(() {});
  }

  
  @override
  Widget build(BuildContext context) {
    
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Container(
          margin: const EdgeInsets.all(4),
          child: TextButton(
            style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: AppConfig.appThemeConfig.secondaryColor),
            onPressed: () {
              action = !action;
              setState(() {});
              _checkData();
            },
            child: !action
                ? const Text(
                    'Seleccionar todo',
                    style: TextStyle(color: Colors.white),
                  )
                : const Text(
                    'Deseleccionar todo',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ),
        Container(
            width: double.infinity,
            height: 50,
            color: Colors.blue.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 80,
                    child: Text('ACCESORIOS',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 40,
                    child: Text('EXTRAS',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 50,
                    child: Text('ORIGINAL',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 20,
                    child: Text('N°',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 20,
                    child: Text('B',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 20,
                    child: Text('M',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center)),
                SizedBox(
                    width: 20,
                    child: Text('R',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center))
              ],
            )),
        _accessories(),
        const SizedBox(
          height: 10,
        ),
        const Divider(),
        if(!existError)
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
                      onPressed: () async{
                        Helper.dismissKeyboard(context);
                        final canContinue = await _saveDataStorage();
                        if(canContinue){
                          widget.onNextFlag(true);
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
        ),
        if(existError)
        SizedBox(
          height: 50,
          child:ZoomIn(
                      child: Container(
                    margin: const EdgeInsets.all(4),
                    child: TextButton(
                      style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          backgroundColor: Colors.white
                          ),
                      onPressed: () async{
                        _getDataStorage();
                      },
                      child:  Row(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_outlined, color: AppConfig.appThemeConfig.secondaryColor),
                          const SizedBox(width: 10,),
                          Text(
                            'Volver a cargar'.toUpperCase(),
                            style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor),
                          ),
                        ],
                      ),
                    ),
                  )),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  _accessories() {
    return SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: DataTable(
              columnSpacing: 4,
              horizontalMargin: 0,
              checkboxHorizontalMargin: 0,
              headingRowHeight: 0,
              showBottomBorder: true,
              headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Colors.grey.shade300),
              columns: <DataColumn>[
                DataColumn(
                  label: SizedBox(
                      width: 80,
                      child: Text('ACCESORIOS',
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center)),
                ),
                DataColumn(
                    label: SizedBox(
                        width: 40,
                        child: Text('EXTRAS',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: SizedBox(
                        width: 50,
                        child: Text('ORIGINAL',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: SizedBox(
                        width: 20,
                        child: Text('N°',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: SizedBox(
                        width: 20,
                        child: Text('B',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: SizedBox(
                        width: 20,
                        child: Text('M',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
                DataColumn(
                    label: SizedBox(
                        width: 20,
                        child: Text('R',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center))),
              ],
              rows: accesoriesVehicle.isNotEmpty ? _createRows() : []),
        ));
  }
}
