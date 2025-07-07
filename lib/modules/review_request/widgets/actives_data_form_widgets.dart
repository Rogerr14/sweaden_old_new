part of 'review_request_widgets.dart';

class ActivesDataFormWidget extends StatefulWidget {
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  final Lista inspection;

  const ActivesDataFormWidget({
    Key? key,
    required this.onNextFlag,
    required this.onBackFlag,
    required this.inspection,
  }) : super(key: key);

  @override
  ActivesDataFormState createState() => ActivesDataFormState();
}

class ActivesDataFormState extends State<ActivesDataFormWidget>
    with AutomaticKeepAliveClientMixin 
    {
  ContinueInspection inspectionData = ContinueInspection();
  TextEditingController calendarController = TextEditingController();
  TextEditingController incomeController = TextEditingController(text: '0');
  TextEditingController secondaryIncomeController =
      TextEditingController(text: '0');
  TextEditingController activesController = TextEditingController(text: '0');
  TextEditingController pasivesController = TextEditingController(text: '0');
  bool formCompleted = true;

  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: 'en').currencySymbol;

  bool isValidIncomes = true;
  bool isValidSecondaryIncomes = true;
  bool isValidActives = true;
  bool isValidPasives = true;

  @override
  void initState() {
    super.initState();
    _getDataStorage();
  }

  @override
  void dispose() {
    calendarController.dispose();
    incomeController.dispose();
    secondaryIncomeController.dispose();
    activesController.dispose();
    pasivesController.dispose();
    super.dispose();
  }

  _getDataStorage() async {
    ContinueInspection? inspectionData = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (inspectionData != null) {
      _setDataStorageInForm(inspectionData);
    }
  }

  _setDataStorageInForm(ContinueInspection continueInspection) {
    inspectionData = continueInspection;
    incomeController.text = inspectionData.incomes ?? '0';
    inspectionData.incomes != null ? isValidIncomes = true : null;
    secondaryIncomeController.text = inspectionData.secondaryIncomes ?? '0';
    inspectionData.secondaryIncomes != null
        ? isValidSecondaryIncomes = true
        : null;
    activesController.text = inspectionData.actives ?? '0';
    inspectionData.actives != null ? isValidActives = true : null;
    pasivesController.text = inspectionData.pasives ?? '0';
    inspectionData.pasives != null ? isValidPasives = true : null;
    setState(() {});
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.inspection.idSolicitud.toString());

    if (continueInspection != null) {
      inspectionData = continueInspection;
    }

    inspectionData.incomes = incomeController.text;
    inspectionData.secondaryIncomes = secondaryIncomeController.text;
    inspectionData.actives = activesController.text;
    inspectionData.pasives = pasivesController.text;
    InspectionStorage().setDataInspection(
        inspectionData, widget.inspection.idSolicitud.toString());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(
          "INFORMACIÓN DE LAVADOS DE ACTIVOS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
          textAlign: TextAlign.left,
        ),
        const Divider(),
        _incomeField(),
        _incomeSecondaryField(),
        _activesField(),
        _pasivesField(),
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

  _checkIfFieldsAreComplete() {
    if (incomeController.text.isNotEmpty &&
        isValidIncomes &&
        secondaryIncomeController.text.isNotEmpty &&
        isValidSecondaryIncomes &&
        activesController.text.isNotEmpty &&
        isValidActives &&
        pasivesController.text.isNotEmpty &&
        isValidPasives) {
      formCompleted = true;
    } else {
      formCompleted = false;
    }
    setState(() {});
  }

  _incomeField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Ingresos mensuales',
            controller: incomeController,
            hinText: '0.00',
            textInputType: TextInputType.number,
            isValid: isValidIncomes,
            prefixText: _currency,
            onChanged: (value) {
              isValidIncomes = Helper().moneyValidator(value);
              setState(() {});
              _checkIfFieldsAreComplete();
              incomeController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _incomeSecondaryField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Ingresos secundarios mensuales',
            controller: secondaryIncomeController,
            hinText: '0.00',
            prefixText: _currency,
            isValid: isValidSecondaryIncomes,
            textInputType: TextInputType.number,
            onChanged: (value) {
              isValidSecondaryIncomes = Helper().moneyValidator(value);
              setState(() {});
              _checkIfFieldsAreComplete();
              secondaryIncomeController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _activesField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Activos',
            controller: activesController,
            prefixText: _currency,
            hinText: '0.00',
            isValid: isValidActives,
            textInputType: TextInputType.number,
            onChanged: (value) {
              isValidActives = Helper().moneyValidator(value);
              setState(() {});
              _checkIfFieldsAreComplete();
              activesController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  _pasivesField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Pasivos',
            controller: pasivesController,
            prefixText: _currency,
            hinText: '0.00',
            isValid: isValidPasives,
            textInputType: TextInputType.number,
            onChanged: (value) {
              isValidPasives = Helper().moneyValidator(value);
              setState(() {});
              _checkIfFieldsAreComplete();
              pasivesController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
