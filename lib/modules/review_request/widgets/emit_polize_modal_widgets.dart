part of 'review_request_widgets.dart';

class EmitPolizeModal extends StatefulWidget {
  final bool rejectRevision;
  final ValueChanged<EmitPolize> onConfirmFlag;
  final String observationForm;
  // final int? anioVehiculo;
  final bool anioPermitidoBoolean;
  final void Function(int) continueProcess;

  const EmitPolizeModal({Key? key, required this.onConfirmFlag, required this.rejectRevision, required this.observationForm, required this.anioPermitidoBoolean, required this.continueProcess})
      : super(key: key);

  @override
  State<EmitPolizeModal> createState() => _EmitPolizeModalState();
}

class _EmitPolizeModalState extends State<EmitPolizeModal> {
  String observacion = '';
  bool selectedOption = true;
  bool formCompleted = false;
  bool observationValid = false;

  TextEditingController obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    observacion = widget.observationForm;
    obsController.text = widget.observationForm;
    if (observacion.isNotEmpty) {
      observationValid = true;
    } else {
      observationValid = false;
    }
    setState(() {});
    if(widget.rejectRevision){
      selectedOption = false;
    }
    _checkFormCompleted();
    setState(() {});
  }

  _checkFormCompleted() {
    if (selectedOption) {
      formCompleted = true;
      observacion = '';
    } else {
      /*if (observacion != '') {
        formCompleted = false;
        //formCompleted = true;
      } else {
        formCompleted = true;
        //formCompleted = false;
      }*/
      formCompleted = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                if(widget.rejectRevision)
                Text(
                  '¿Porque se rechaza la inspección?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppConfig.appThemeConfig.primaryColor),
                ),
                if(!widget.rejectRevision)
                Text(
                  '¿Se emitirá la Póliza?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppConfig.appThemeConfig.primaryColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                if(!widget.rejectRevision)
                _radioButtonsField(),
                if (!selectedOption)
                  TextFieldWidget(
                    controller: obsController,
                    isValid: observationValid,
                    label: 'Observaciones',
                    textInputType: TextInputType.text,
                    maxLines: 5,
                    onChanged: (e) {
                      Helper.logger.e('Observacion: $e');
                      observacion = e;
                      // widget.observationController.text = e;
                      if (observacion.isNotEmpty) {
                        observationValid = true;
                      } else {
                        observationValid = false;
                      }
                      setState(() {});
                    },
                    inputFormatter: [
                      LengthLimitingTextInputFormatter(5000),
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.,\sñÑáéíóúÁÉÍÓÚüÜ\-]+'))
                    ],
                  ),
                if (!selectedOption)
                  const Text("Por favor indique una observación!.",
                      style: TextStyle(color: Colors.red)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                        onPressed: () async {
                          fp.dismissAlert();
                        },
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                        onPressed: formCompleted
                            ? () {
                                if (!selectedOption && observacion.isEmpty) {
                                  debugPrint("Porfavor indique la observación");
                                } else {
                                  Helper.dismissKeyboard(context);
                                  fp.dismissAlert();
                                  //Helper.logger.e('Anio vehiculo: ${widget.anioVehiculo}');
                             // Helper.logger.e('Anio permitido: ${widget.anioPermitido}');

                                  if (widget.anioPermitidoBoolean) {
                                      widget.onConfirmFlag(EmitPolize(
                                          emit: selectedOption,
                                          observacion: observacion));
                                    }else{
                                        widget.continueProcess(9);
                                    }
                                }
                              }
                            : null,
                        child: const Text("Confirmar"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _radioButtonsField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _optionRadioField(true, selectedOption, 'Si'),
                _optionRadioField(false, selectedOption, 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _optionRadioField(value, groupValue, title) {
    return Expanded(
      child: InkWell(
        splashColor: AppConfig.appThemeConfig.secondaryColor,
        onTap: () {
          _onChangedRadios(value);
        },
        child: Row(
          children: [
            Radio(
                value: value,
                groupValue: groupValue,
                activeColor: AppConfig.appThemeConfig.secondaryColor,
                onChanged: (dynamic value) {
                  _onChangedRadios(value);
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

  _onChangedRadios(bool value) {
    selectedOption = value;
    setState(() {});
    _checkFormCompleted();
  }
}
