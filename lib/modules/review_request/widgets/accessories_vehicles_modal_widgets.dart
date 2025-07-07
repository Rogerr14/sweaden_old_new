part of 'review_request_widgets.dart';

class AccessoriesModal extends StatefulWidget {
  final AccesoriesVehicle accessoryVehicle;
  final String type;
  final ValueChanged<AccesoriesVehicle> add;

  const AccessoriesModal(
      {Key? key,
      required this.accessoryVehicle,
      required this.type,
      required this.add})
      : super(key: key);

  @override
  State<AccessoriesModal> createState() => _AccessoriesModalState();
}

class _AccessoriesModalState extends State<AccessoriesModal> {
  TextEditingController priceController = TextEditingController(text: '0');
  TextEditingController markController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController cantController = TextEditingController(text: '1');
  String get _currency =>
      NumberFormat.compactSimpleCurrency(locale: 'en').currencySymbol;
  bool isValidPrice = false;
  bool isValidCant = true;
  bool formCompleted = false;

  @override
  void initState() {
    super.initState();
    formCompleted = widget.type == 'O' ? true : false;
    cantController.text = widget.accessoryVehicle.cantidad ?? '1';
    modelController.text = widget.accessoryVehicle.modelo ?? '';
    markController.text = widget.accessoryVehicle.marca ?? '';
    priceController.text = widget.accessoryVehicle.valUnit ?? '0';
    setState(() {});
  }

  @override
  void dispose() {
    priceController.dispose();
    markController.dispose();
    modelController.dispose();
    cantController.dispose();
    super.dispose();
  }

  _checkFormCompleted() {
    if (widget.type == 'E') {
      if (isValidPrice &&
          isValidCant &&
          cantController.text.isNotEmpty &&
          cantController.text != '' &&
          priceController.text.isNotEmpty &&
          priceController.text != '') {
        formCompleted = true;
      } else {
        formCompleted = false;
      }
    } else {
      if (isValidCant &&
          cantController.text.isNotEmpty &&
          cantController.text != '') {
        formCompleted = true;
      } else {
        formCompleted = false;
      }
    }
    setState(() {});
  }

  _markField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Marca',
            controller: markController,
            textInputType: TextInputType.text,
            inputFormatter:[
              LengthLimitingTextInputFormatter(150),
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-_.() ]'))
            ],
            onChanged: (value) {
              _checkFormCompleted();
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _modelField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Modelo',
            controller: modelController,
            textInputType: TextInputType.text,
            inputFormatter:[
              LengthLimitingTextInputFormatter(255),
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-_.() ]'))
            ],
            onChanged: (value) {
              _checkFormCompleted();
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _cantField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Cantidad',
            controller: cantController,
            textInputType: TextInputType.number,
            isValid: isValidCant,
            inputFormatter: [
              LengthLimitingTextInputFormatter(5),
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
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
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _priceField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Valor Unitario',
            controller: priceController,
            prefixText: _currency,
            hinText: '0.00',
            isValid: isValidPrice,
            textInputType: TextInputType.phone,
            inputFormatter: [
                LengthLimitingTextInputFormatter(15),
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
              ],
            onChanged: (value) {
              isValidPrice = Helper().moneyValidator(value);
              setState(() {});
              _checkFormCompleted();
              priceController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  _updatedAccessoryData() {
    widget.accessoryVehicle.cantidad = cantController.text;
    widget.accessoryVehicle.marca = markController.text;
    widget.accessoryVehicle.modelo = modelController.text;
    widget.accessoryVehicle.valUnit = priceController.text;
    widget.accessoryVehicle.tipo = widget.type;
    if(widget.type == 'O'){widget.accessoryVehicle.valUnit=null;}
    setState(() {});
    widget.add(widget.accessoryVehicle);
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(child: Column(
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
                  Text(
                    widget.accessoryVehicle.descripcion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppConfig.appThemeConfig.primaryColor),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Cuenta con una nueva soliciutd de inspección para este momento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppConfig.appThemeConfig.secondaryColor),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  _cantField(),
                  _markField(),
                  _modelField(),
                  widget.type == 'E' ? _priceField() : Container(),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
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
                              ? () async {
                                  Helper.dismissKeyboard(context);
                                  _updatedAccessoryData();
                                  fp.dismissAlert();
                                }
                              : null,
                          child: const Text("Añadir"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
    )),
      ),
    );
  }
}
