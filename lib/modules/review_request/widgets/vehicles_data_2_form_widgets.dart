part of 'review_request_widgets.dart';

class VehicleData2FormWidget extends StatefulWidget {
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final ValueChanged<int> onJumpFlag;
  final Lista inspection;
  final DataClientForm dataClientForm;

  const VehicleData2FormWidget({
    Key? key,
    required this.onNextFlag,
    required this.onBackFlag,
    required this.onJumpFlag,
    required this.inspection,
    required this.dataClientForm,
  }) : super(key: key);

  @override
  VehicleData2FormState createState() => VehicleData2FormState();
}

class VehicleData2FormState extends State<VehicleData2FormWidget>
    with AutomaticKeepAliveClientMixin {
  ContinueInspection inspectionData = ContinueInspection();
  TextEditingController observationController = TextEditingController();
  bool _selectedTapiceria = false;
  bool _selectedForros = false;
  bool _selectedVidrios = false;
  bool _selectedRevision = false;
  bool _rejectedRevision = false;
  String? _selectedPaint;
  bool? _selectedSubmitActivesForm = false;
  bool formCompleted = true;
  int anioVehiculo = 0;
  int anioPermitido = 0;
  bool anioPermitidoBoolean = true;

  @override
  void initState() {
    super.initState();
    _getDataStorage();
  }

  @override
  void dispose() {
    observationController.dispose();
    super.dispose();
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    Helper.logger.w(
        'valor que tiene guardado: ${widget.inspection.idEstadoInspeccion}}');

    if (continueInspection != null) {
      _setDataStorageInForm(continueInspection);

      setState(() {
        inspectionData = continueInspection;
        anioVehiculo = int.parse(continueInspection.anio!);
        anioPermitido = widget.dataClientForm.listaRamo!
            .firstWhere((e) => e.codigo.toString() == widget.inspection.idRamo)
            .anioAntiguedad!;
        //inspectionData.codRamo = widget.inspection.idRamo;
        //  ageAllowed = widget.branchesList .firstWhere((e) => e.codigo.toString() == v?.value!).anioAntiguedad!;
      });
    }
  }

  _setDataStorageInForm(ContinueInspection continueInspection) {
    inspectionData = continueInspection;

    observationController.text = inspectionData.observacion ?? '';

    _selectedRevision = inspectionData.enRevision ?? false;

    _rejectedRevision = inspectionData.rechazado ?? false;

    _selectedSubmitActivesForm = inspectionData.entregaForm ?? false;

    _selectedPaint = inspectionData.pintura ?? '';

    _selectedTapiceria = inspectionData.retapizado ?? false;

    _selectedForros = inspectionData.forros ?? false;

    _selectedVidrios = inspectionData.vidrios ?? false;
    setState(() {});
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());
    if (continueInspection != null) {
      continueInspection.emitPolize = inspectionData.emitPolize;
      continueInspection.observacion = inspectionData.observacion;
      continueInspection.observacionEmision = inspectionData.observacionEmision;
      inspectionData = continueInspection;
      // inspectionData.emitPolize = inspectionData.emitPolize;
    }

    Helper.logger.w('se guarda emitir: ${inspectionData.emitPolize}');
    inspectionData.observacion = observationController.text.trim();
    inspectionData.enRevision = _selectedRevision;
    inspectionData.rechazado = _rejectedRevision;
    inspectionData.entregaForm = _selectedSubmitActivesForm;
    inspectionData.pintura = _selectedPaint;
    inspectionData.retapizado = _selectedTapiceria;
    inspectionData.forros = _selectedForros;
    inspectionData.vidrios = _selectedVidrios;

    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
  }

  _openModalEmitPolize() {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    fp.showAlert(
        content: EmitPolizeModal(
      continueProcess: widget.onJumpFlag,
      anioPermitidoBoolean: anioPermitidoBoolean,
      // anioPermitido: anioPermitido,
      // anioVehiculo: anioVehiculo,
      rejectRevision: false,
      onConfirmFlag: _emitPolize,
      observationForm: observationController.text,
    ));
  }

  _openModalObservation() {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    fp.showAlert(
        content: EmitPolizeModal(
      continueProcess: widget.onJumpFlag,
      anioPermitidoBoolean: anioPermitidoBoolean,
      rejectRevision: true,
      onConfirmFlag: _emitPolize,
      observationForm: observationController.text,
    ));
  }

  _emitPolize(EmitPolize emitPolize) async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }
    Helper.logger.w('emitPolize.observacion: ${emitPolize.observacion}');
    final rrp = Provider.of<ReviewRequestProvider>(context, listen: false);
    Helper.logger.w('emitir poliza: ${emitPolize.emit}');
    inspectionData.emitPolize = emitPolize.emit;
    inspectionData.observacionEmision = emitPolize.observacion;
    log(json.encode(inspectionData));
    setState(() {});
    Helper.logger.w('emitir poliza: ${widget.inspection.idEstadoInspeccion}');
    if (emitPolize.emit) {
      //? Elegí si emitir poliza
      if (rrp.loadInvoiceData == false) {
        rrp.loadInvoiceData = true;
      }
      _saveDataStorage();
      widget.onNextFlag(true);
    } else {
      //? Elegì no emitir poliza
      inspectionData.codRamo = widget.inspection.idRamo;
      inspectionData.codProducto = widget.inspection.idProducto;
      rrp.loadInvoiceData = false;
      _saveDataStorage();
      widget.onJumpFlag(9);
    }
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
        _paintField(),
        const Divider(),
        _tapestryField(),
        const Divider(),
        _submitActivesFormField(),
        const Divider(),
        _observationField(),
        _revisionField(),
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
                          Helper.logger.e('anio permitido: $anioPermitido ');
                          Helper.logger.e('anio anioVehiculo: $anioVehiculo ');
                          _verifyYearVh();
                        },
                        child: const Text(
                          'CONTINUAR',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  _verifyYearVh() {
    final nowYear = DateTime.now().year;
    Helper.logger.w("nowYear: $nowYear");
    // final yearDate = (nowYear - anioVehiculo) * - 1;
    int yearDate = (nowYear - anioVehiculo);
    yearDate = yearDate < 0 ? 0 : yearDate;

    Helper.logger.w("anioPermitido: $anioPermitido");
    Helper.logger.w("yearDate: $yearDate");

    if (anioPermitido < yearDate) {
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      Helper.logger.e('muestra mensaje de alerta');
      fp.showAlert(
          content: AlertConfirm(
        message:
            'El año del vehiculo supera al año permitido de caso ser asi modifique el año del vehiculo si no la inspección se enviara a revisión.',
        confirm: () {
          inspectionData.codRamo = widget.inspection.idRamo;
          _selectedRevision = true;
          anioPermitidoBoolean = false;
//         final rrp = Provider.of<ReviewRequestProvider>(context, listen: false);
// rrp.loadInvoiceData = false;
          setState(() {});
          fp.dismissAlert();
          _processContinuePoliza();
          //fp.dismissAlert();
          //   final emitPolize = EmitPolize(emit: false, observacion: "");
          // _emitPolize(emitPolize);
        },
      ));
    } else {
      _processContinuePoliza();
    }
  }

  _processContinuePoliza() {
    _saveDataStorage();
    if (widget.inspection.idProceso == 50) {
      //Helper.logger.e(!_rejectedRevision);
      if (!_rejectedRevision) {
        _openModalEmitPolize();

        //Helper.logger.e('Anio vehiculo: $anioVehiculo');
        //Helper.logger.e('Anio permitido: $anioPermitido');
        //Helper.logger.log(Level.trace, json.encode(inspectionData));
        //  final emitPolize =
        //   EmitPolize(emit: false, observacion: "");
        //   _emitPolize(emitPolize);

      } else {
        Helper.logger.e('ingreso de aqui');
        _openModalObservation();
      }
    } else {
      log('*******SIN EMISION*****');
      // final rrp = Provider.of<ReviewRequestProvider>(context, listen:false);
      // rrp.loadInvoiceData = false;

      // widget.onJumpFlag(9);
      final emitPolize = EmitPolize(emit: false, observacion: "");
      if (!_rejectedRevision) {
        _emitPolize(emitPolize);
      } else {
        _openModalObservation();
      }
      //_openModalObservation();
      //_openModalObservation();
    }
  }

  _observationField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text("OBSERVACIONES",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: AppConfig.appThemeConfig.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Observaciones',
            controller: observationController,
            textInputType: TextInputType.text,
            maxLines: 7,
            inputFormatter: [
              LengthLimitingTextInputFormatter(5000),
              FilteringTextInputFormatter.allow(
                  RegExp(r'[A-Za-z0-9.,\sñÑáéíóúÁÉÍÓÚüÜ\-]+'))
            ],
            onChanged: (value) {},
          ),
          const Divider(),
        ],
      ),
    );
  }

  _paintField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Text("Pintura",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: AppConfig.appThemeConfig.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _optionRadioField('B', _selectedPaint, 'Bueno', 'pintura'),
                _optionRadioField('R', _selectedPaint, 'Regular', 'pintura'),
                _optionRadioField('M', _selectedPaint, 'Malo', 'pintura'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _submitActivesFormField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Text("Entrega del formulario de lavado activos a la compañia",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: AppConfig.appThemeConfig.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _optionRadioField(
                    true, _selectedSubmitActivesForm, 'Si', 'lavado-activos'),
                _optionRadioField(
                    false, _selectedSubmitActivesForm, 'No', 'lavado-activos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _tapestryField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Text("Tapicería",
              textAlign: TextAlign.left,
              style: TextStyle(
                  color: AppConfig.appThemeConfig.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _optionCheckField(
                    _selectedTapiceria, 'Retapizado', 'retapizado'),
                _optionCheckField(_selectedForros, 'Forros', 'forros'),
                _optionCheckField(_selectedVidrios, 'Vidrios', 'vidrios')
              ],
            ),
          ),
        ],
      ),
    );
  }

  _revisionField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _optionCheckField(
                    _selectedRevision, 'Mandar a revisión', 'revision'),
                _optionCheckField(
                    _rejectedRevision, 'Rechazar inspección', 'rechazar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _optionRadioField(value, groupValue, title, type) {
    return Expanded(
      child: InkWell(
        splashColor: AppConfig.appThemeConfig.secondaryColor,
        onTap: () {
          _onChangedRadios(value, type);
        },
        child: Row(
          children: [
            Radio(
                value: value,
                groupValue: groupValue,
                activeColor: AppConfig.appThemeConfig.secondaryColor,
                onChanged: (dynamic value) {
                  _onChangedRadios(value, type);
                }),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
      flex: 1,
    );
  }

  Expanded _optionCheckField(value, title, type) {
    return Expanded(
      child: InkWell(
        splashColor: AppConfig.appThemeConfig.secondaryColor,
        onTap: () {
          _onChangedCheckbox(!value, type);
        },
        child: Row(
          children: [
            Checkbox(
                value: value,
                activeColor: AppConfig.appThemeConfig.secondaryColor,
                onChanged: (bool? newValue) {
                  _onChangedCheckbox(newValue, type);
                }),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            )
          ],
        ),
      ),
      flex: 1,
    );
  }

  _onChangedCheckbox(value, type) {
    switch (type) {
      case 'retapizado':
        _selectedTapiceria = value;
        break;
      case 'forros':
        _selectedForros = value;
        break;
      case 'vidrios':
        _selectedVidrios = value;
        break;
      case 'revision':
        if (_rejectedRevision) {
          _rejectedRevision = false;
        }
        _selectedRevision = value;
        _showSnackBarRevision();
        break;
      case 'rechazar':
        if (_selectedRevision) {
          _selectedRevision = false;
        }
        _rejectedRevision = value;
        _showSnackBarRechazar();
        break;
    }
    setState(() {});
  }

  _showSnackBarRechazar() {
    late SnackBar message;
    if (_rejectedRevision) {
      message = const SnackBar(
        content: Text('Se rechazará la inspección'),
      );
    } else {
      message = const SnackBar(
        content: Text('CONTINUARÁ con flujo normal'),
      );
    }
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(message);
  }

  _showSnackBarRevision() {
    late SnackBar message;
    if (_selectedRevision) {
      message = const SnackBar(
        content: Text('Los datos se enviarán a revisión'),
      );
    } else {
      message = const SnackBar(
        content: Text('CONTINUARÁ con flujo normal'),
      );
    }
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(message);
  }

  _onChangedRadios(value, type) {
    switch (type) {
      case 'pintura':
        _selectedPaint = value;
        break;
      case 'lavado-activos':
        _selectedSubmitActivesForm = value;
        break;
    }
    setState(() {});
  }
}
