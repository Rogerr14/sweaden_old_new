part of 'review_request_widgets.dart';

class OtpModal extends StatefulWidget {
  final ValueChanged<bool> onConfirmFlag;
  final String idSolicitud;
  final String celular;
  final String email;
  const OtpModal(
      {Key? key,
      required this.idSolicitud,
      required this.celular,
      required this.email,
      required this.onConfirmFlag})
      : super(key: key);

  @override
  State<OtpModal> createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController phoneThirdController = TextEditingController();
  OtpFieldController otpController = OtpFieldController();
  String otpValue = '';
  bool selectedOption = false;
  bool formCompleted = false;
  bool isValidPhone = false;
  bool isValidEmail = false;
  bool isValidPhoneThird = false;
  bool optFlag = false;
  bool optCompleted = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.email;
    phoneController.text = widget.celular;
    isValidEmail = Helper().emailValidator(widget.email);
    isValidPhone = widget.celular.length == 10 ? true : false;
    setState(() {});
    _checkFormCompleted();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    phoneThirdController.dispose();
    super.dispose();
  }

  _getOPt() async {
    debugPrint("--- cargando obtener otp ---");
    String phone =  selectedOption ? phoneThirdController.text : phoneController.text;
    final response = await RequestReviewService().getOpt(context, widget.idSolicitud, emailController.text, phone);
    Helper.logger.w('response otp: ${json.encode(response)}');
    if (!response.error) {
      optFlag = true;
      loading = false;
      if(mounted){

      setState(() {});
      }
    }
  }

  _validOPt() async {
    debugPrint("--- cargando validar otp ---");
    final fp = Provider.of<FunctionalProvider>(context,listen:false);    
    final response = await RequestReviewService().validOtp(context, widget.idSolicitud, otpValue);
    if (!response.error ) {
      //? Mostramos un Loading hasta que empieze la otra peticion de 
      fp.showAlert(content: const AlertLoading());
      ContinueInspection? continueInspection = await InspectionStorage().getDataInspection(widget.idSolicitud);
      continueInspection?.tokenFirma = otpValue;
      continueInspection?.base64SignatureClientImage = '';
      log('continueInspection: ${json.encode(continueInspection)}');
      InspectionStorage()
          .setDataInspection(continueInspection!, widget.idSolicitud);

      widget.onConfirmFlag(true);
    }else{
      fp.showAlert(content: AlertGenericError(message: response.message));
    }
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
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Código de seguridad',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppConfig.appThemeConfig.primaryColor),
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10,
                  ),
                  _emailField(),
                  _phoneCelField(),
                  _thirdCheckField(),
                  if (selectedOption) _phoneCelThirdField(),
                  const Divider(),
                  if (optFlag)
                    const Text(
                      'Por favor, ingrese el código de seguridad enviado por SMS a su número celular registrado.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  if (optFlag)
                    const SizedBox(
                      height: 20,
                    ),
                  if (optFlag) _optField(),
                  if (optFlag)
                    const SizedBox(
                      height: 10,
                    ),
                  if (optFlag)
                    TextButton(
                        onPressed: formCompleted
                            ? () {
                              Helper.dismissKeyboard(context);
                                _getOPt();
                              }
                            : null,
                        child: Text('No recibí el SMS, reenviar.',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: AppConfig.appThemeConfig.secondaryColor,
                            ))),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                          onPressed: () {
                            fp.dismissAlert();
                          },
                          child: const Text("Cerrar"),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (!optFlag)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                            onPressed: formCompleted && !loading
                                ? () {
                                    Helper.dismissKeyboard(context);
                                    loading = true;
                                    setState(() {});
                                    _getOPt();
                                  }
                                : null,
                            child: loading
                                ? const Text("Cargando...")
                                : const Text("Generar"),
                          ),
                        ),
                      if (optFlag)
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                            onPressed: optCompleted
                                ? () {
                                    fp.dismissAlert();
                                    _validOPt();
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
    ),),
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
            controller: phoneController,
            maxLength: 10,
            isValid: isValidPhone,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            onChanged: (value) {
              if (value.length == 10) {
                isValidPhone = true;
              } else {
                isValidPhone = false;
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

  _phoneCelThirdField() {
    return FadeInRight(
      duration: const Duration(milliseconds: 600),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          TextFieldWidget(
            label: 'Celular de Tercero',
            controller: phoneThirdController,
            maxLength: 10,
            isValid: isValidPhoneThird,
            textInputType: TextInputType.phone,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp('[0-9]'))
            ],
            onChanged: (value) {
              if (value.length == 10) {
                isValidPhoneThird = true;
              } else {
                isValidPhoneThird = false;
              }
              setState(() {});
              _checkFormCompleted();
            },
          ),
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
            inputFormatter:[
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9-_.@]'))
            ],
            isValid: isValidEmail,
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

  _thirdCheckField() {
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
                    selectedOption, 'Inspección realizada a tercero'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _optField() {
    return OTPTextField(
        controller: otpController,
        length: 6,
        width: MediaQuery.of(context).size.width,
        textFieldAlignment: MainAxisAlignment.spaceAround,
        fieldWidth: 45,
        fieldStyle: FieldStyle.box,
        outlineBorderRadius: 15,
        style: const TextStyle(fontSize: 17),
        onChanged: (pin) {},
        onCompleted: (pin) {
          otpValue = pin;
          optCompleted = true;
          setState(() {});
        });
  }

  Expanded _optionCheckField(value, title) {
    return Expanded(
      child: InkWell(
        splashColor: AppConfig.appThemeConfig.secondaryColor,
        onTap: () {
          selectedOption = !selectedOption;
          setState(() {});
          _checkFormCompleted();
        },
        child: Row(
          children: [
            Checkbox(
                value: value,
                activeColor: AppConfig.appThemeConfig.secondaryColor,
                onChanged: (bool? newValue) {
                  selectedOption = !selectedOption;
                  setState(() {});
                  _checkFormCompleted();
                }),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 14),
              ),
            )
          ],
        ),
      ),
      flex: 1,
    );
  }

  _checkFormCompleted() {
    if (emailController.text != '' &&
        emailController.text.isNotEmpty &&
        isValidEmail) {
      if (selectedOption) {
        if (phoneThirdController.text != '' &&
            phoneThirdController.text.isNotEmpty &&
            isValidPhoneThird) {
          formCompleted = true;
        } else {
          formCompleted = false;
        }
      } else {
        if (phoneController.text != '' &&
            phoneController.text.isNotEmpty &&
            isValidPhone) {
          formCompleted = true;
        } else {
          formCompleted = false;
        }
      }
    } else {
      formCompleted = false;
    }
    setState(() {});
  }
}
