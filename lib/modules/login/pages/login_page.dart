import 'package:animate_do/animate_do.dart';
// import 'package:awesome_select/awesome_select.dart';
import 'package:flutter_awesome_select_clone/flutter_awesome_select.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/login/services/login_services.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackGround(size: size),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SizedBox(
            height: size.height,
            width: size.width,
            child: const LoginForm(),
          ),
        ),
        const AlertModal()
      ],
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

List<S2Choice<String>> profiles = [];

class _LoginFormState extends State<LoginForm> {
  TextEditingController userTextFieldController = TextEditingController();
  TextEditingController passwordTextFieldController = TextEditingController();
//? SELECT DE TIPO DE USUARIO
  String selectedUserType = 'Seleccione tipo de usuario';
  String selectedUserTypeValue = '';
  String selectedUserTypeAbbreviation = '';
  bool _obscureText = true;
  @override
  void initState() {
    // userTextFieldController.text = 'cparedes';
    // passwordTextFieldController.text = 'Prueba123';
    // selectedUserType = 'INSPECTOR';
    // selectedUserTypeValue = "3";
    // selectedUserTypeAbbreviation = "IN";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (profiles.isEmpty) {
        _loadProfiles();
      }
    });
    super.initState();
  }


  @override
  void dispose() {
    userTextFieldController.dispose();
    passwordTextFieldController.dispose();
    super.dispose();
  }

  _loadProfiles() async {
    final response = await LoginServices().getProfiles(context);
    if (!response.error) {
      profiles = response.data!
          .map((p) => S2Choice(
              value: p.idTipoUsuario.toString(),
              title: p.descripcion,
              meta: p.abreviatura))
          .toList();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(
                height: size.height * .1,
              ),
              Hero(
                  tag: 'logo-business',
                  child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(31),
                          boxShadow: const [
                            BoxShadow(
                                offset: Offset(0, 5),
                                color: Colors.grey,
                                spreadRadius: 0.5,
                                blurRadius: 6)
                          ]),
                      child: Image(
                          image: AssetImage(
                              AppConfig.appThemeConfig.logoImagePath)))),
              const SizedBox(
                height: 40,
              ),
              Text(AppConfig.appEnv.environmentLabel, style: TextStyle(color: AppConfig.appThemeConfig.primaryColor, fontWeight: FontWeight.w700),),
              const SizedBox(
                height: 40,
              ),
              TextFieldWidget(
                  controller: userTextFieldController,
                  label: 'Usuario',
                  onChanged: (value) {}),
              const SizedBox(
                height: 10,
              ),
              TextFieldWidget(
                  controller: passwordTextFieldController,
                  label: 'Contraseña',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                      onPressed: () {
                        _obscureText = !_obscureText;
                        setState(() {});
                      },
                      icon: Icon(
                        (!_obscureText)
                            ? Icons.visibility_off
                            : Icons.remove_red_eye,
                        color: AppConfig.appThemeConfig.secondaryColor,
                      )),
                  onChanged: (value) {}),
              const SizedBox(
                height: 10,
              ),
              if (profiles.isNotEmpty)
                FadeInLeft(
                  child: SelectWidget(
                      title: 'tipo de Usuario',
                      options: profiles,
                      optionSelected: (v) {
                        selectedUserType = v!.title!;
                        selectedUserTypeValue = v.value!;
                        selectedUserTypeAbbreviation = v.meta! as String;
                        setState(() {});
                      },
                      textShow: selectedUserType,
                      value: selectedUserTypeValue),
                ),
              const SizedBox(
                height: 50,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                    onPressed: () {
                      Helper.dismissKeyboard(context);
                      final isComplete = _verifyFields();
                      if (isComplete) {
                        _tryLogin();
                      } else {
                        fp.showAlert(content: const AlertIncompleteFields());
                      }
                      setState(() {
                        
                      });
                    },
                    child: const Text("INICIAR SESIÓN")),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _verifyFields() {
    if (userTextFieldController.text.isNotEmpty &&
        passwordTextFieldController.text.isNotEmpty &&
        selectedUserTypeValue != '') {
      return true;
    }
    return false;
  }

  _tryLogin() async {
    final firebaseToken = await FirebaseMessaging.instance.getToken();
    // print('FB: $firebaseToken');
    final data = {
      "username": userTextFieldController.text.trim(),
      "password": passwordTextFieldController.text.trim(),
      "tipoUsuario": {
        "id_tipo_usuario": int.parse(selectedUserTypeValue),
        "descripcion": selectedUserType,
        "abreviatura": selectedUserTypeAbbreviation.toString()
      },
      "tokenFirebase": firebaseToken
    };
    await LoginServices().login(context, data);
  }
}
