import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/main.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/loading/services/loading_service.dart';
import 'package:sweaden_old_new_version/modules/loading/widgets/loading_widgets.dart';
import 'package:sweaden_old_new_version/modules/login/pages/login_page.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({Key? key}) : super(key: key);

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late FunctionalProvider fp;

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    //_verifyProtocol();
    _verifyPermissionLocation();
    _activeBackground();
    //  _verifyStatusLocation();
    super.initState();
  }

  // _verifyStatusLocation() async{
  //   // bool serviceLocationEnabled = await Geolocator.isLocationServiceEnabled();
  //   // Helper.logger.w("serviceLocationEnabled: $serviceLocationEnabled");
  //   // if(serviceLocationEnabled){
  //   //   _verifyPermissionLocation();
  //   // }else{
  //   //   _showAlertStatusLocation();
  //   // }
  // }

  _activeBackground() async {
    bool isActive = await UserDataStorage().getActiveBackground();
    fp.setActiveBackground(isActive);
  }

  _verifyPermissionLocation() async {
    bool serviceLocationEnabled = await Geolocator.isLocationServiceEnabled();
    // Helper.logger.w("serviceLocationEnabled: $serviceLocationEnabled");
    final status = await Geolocator.checkPermission();
    // Helper.logger.e('permiso de ubicacion: $status');

    if (status == LocationPermission.always) {
      if (serviceLocationEnabled) {
        _getServerResponse();
      } else {
        _showAlertStatusLocation();
      }
    } else if (status == LocationPermission.whileInUse) {
      // if(serviceLocationEnabled){
      // _getServerResponse();

      // }else{

      _showAlertNotifyPermissionLocation();
      // }
    } else {
      // debugPrint('holalsjfjfjfjf');
      _showAlertPermissionLocation();
    }
  }

  // _verifyProtocol() async {
  //   await Geolocator.requestPermission();
  //   _getServerResponse();
  // }

  Future<void> _showAlertNotifyPermissionLocation() async {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              title: const Text(
                  'Para que se puedan gestionar de mejor manera la asignación de inspecciones, es necesario activar siempre la ubicación.'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[Image.asset('assets/location.gif')],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          AppConfig.appThemeConfig.secondaryColor)),
                  child: const Text('Aceptar'),
                  onPressed: () async {
                    _activateUbication(context);
                    // LocationPermission status =
                    //     await Geolocator.requestPermission();
                    // try {

                    // // await Geolocator.openAppSettings();
                    // await openAppSettings();
                    // } catch (e) {
                    //   Helper.logger.w('setting: $e');
                    // }

                    // if (status == LocationPermission.always ||
                    //     status == LocationPermission.whileInUse) {
                    //   bool serviceLocationEnabled =
                    //       await Geolocator.isLocationServiceEnabled();
                    //   Helper.logger
                    //       .e('serviceLocationEnabled: $serviceLocationEnabled');

                    //   if (serviceLocationEnabled) {
                    //     Navigator.of(context).pop();
                    //     _getServerResponse();
                    //   } else {
                    //     Navigator.of(context).pop();
                    //     _showAlertStatusLocation();
                    //   }
                    // } else if (status == LocationPermission.denied) {
                    //   await Geolocator.requestPermission();
                    // }
                  },
                ),
                ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                          Colors.white,
                        ),
                        side: WidgetStateProperty.all(
                          BorderSide(
                              color: AppConfig.appThemeConfig.tertiaryColor),
                        )),
                    child: Text(
                      'Después',
                      style: TextStyle(
                          color: AppConfig.appThemeConfig.primaryColor),
                    ),
                    onPressed: () async {
                      // LocationPermission status =
                      //     await Geolocator.requestPermission();
                      // Helper.logger.e('status: $status');
                      // await Geolocator.openAppSettings();
                      // LocationPermission status =
                      //     await Geolocator.requestPermission();
                      // if (status == LocationPermission.deniedForever) {
                      //   Geolocator.openAppSettings();
                      // } else
                      // if(status == LocationPermission.always){
                      //   bool serviceLocationEnabled =
                      //       await Geolocator.isLocationServiceEnabled();
                      //   Helper.logger
                      //       .e('serviceLocationEnabled: $serviceLocationEnabled');

                      // if (serviceLocationEnabled) {
                      Navigator.of(context).pop();
                      _getServerResponse();
                      // } else {
                      //   Navigator.of(context).pop();
                      //   _showAlertStatusLocation();
                      // }
                    }
                    // if (status == LocationPermission.always ||
                    //     status == LocationPermission.whileInUse) {
                    //   bool serviceLocationEnabled =
                    //       await Geolocator.isLocationServiceEnabled();
                    //   Helper.logger
                    //       .e('serviceLocationEnabled: $serviceLocationEnabled');

                    //   if (serviceLocationEnabled) {
                    //     Navigator.of(context).pop();
                    //     _getServerResponse();
                    //   } else {
                    //     Navigator.of(context).pop();
                    //     _showAlertStatusLocation();
                    //   }
                    // } else if (status == LocationPermission.denied) {
                    //   await Geolocator.requestPermission();

                    ),
              ],
            ),
          );
        });
  }

  _activateUbication(BuildContext context) async {
    // final status = await Permission.location;
    // if (status == LocationPermission.deniedForever) {
    // Helper.logger.e('status: $status');
    //   Geolocator.openAppSettings();
    // } else
    if (await Permission.locationAlways.isGranted) {
      bool serviceLocationEnabled = await Geolocator.isLocationServiceEnabled();
      Helper.logger.e('serviceLocationEnabled: $serviceLocationEnabled');

      if (serviceLocationEnabled) {
        Navigator.of(context).pop();
        _getServerResponse();
      } else {
        Navigator.of(context).pop();
        _showAlertStatusLocation();
      }
    } else {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_application_details_settings',
        data: 'package:com.example.sweaden_old_new_version',
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }

  Future<void> _showAlertPermissionLocation() async {
    return showDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            actionsAlignment: MainAxisAlignment.center,
            title: const Text(
                'Para continuar es necesario acceder a la ubicacion actual del dispositivo.'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Image.asset('assets/location.gif')],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                        AppConfig.appThemeConfig.secondaryColor)),
                child: const Text('Permitir'),
                onPressed: () async {
                  LocationPermission status =
                      await Geolocator.requestPermission();
                  Helper.logger.e('status: $status');

                  if (status == LocationPermission.deniedForever) {
                    Geolocator.openAppSettings();
                  } else if (status == LocationPermission.always ||
                      status == LocationPermission.whileInUse) {
                    bool serviceLocationEnabled =
                        await Geolocator.isLocationServiceEnabled();
                    Helper.logger
                        .e('serviceLocationEnabled: $serviceLocationEnabled');

                    if (serviceLocationEnabled) {
                      Navigator.of(context).pop();
                      _getServerResponse();
                    } else {
                      Navigator.of(context).pop();
                      _showAlertStatusLocation();
                    }
                  } else if (status == LocationPermission.denied) {
                    await Geolocator.requestPermission();
                  }
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAlertStatusLocation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
                'Para continuar tienes que tener habilibitado la ubicación del dispositivo.'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Listo!'),
                onPressed: () async {
                  bool serviceLocationEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (serviceLocationEnabled) {
                    Navigator.of(context).pop();
                    _getServerResponse();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getServerResponse() async {
    // bool connectivityService = await Helper.checkConnection();
    // // Helper.logger.e("connectivityService: $connectivityService");
    // if (connectivityService) {
    final response = await LoadingService().getServerResponse();
    if (response) {
      _sesionVerify();
    } else {
      await _showAlert();
      fp.setOffline(true);
      _sesionVerify();
    }
    // } else {
    // }
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lo sentimos'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'En este momento no se pueden conectar con los servidores.'),
                Text('Por favor, intentalo de nuevo en unos minutos.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Listo!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _sesionVerify() async {
    final tokenVerify = await UserDataStorage().verifyToken();

    if (tokenVerify) {
      // Helper.timeUpdateLocation = userData!.tiempoActualizarUbicacion;
      final userData = await UserDataStorage().getUserData();
      if (userData != null) {
        Logger().i('userData: ${userData.toJson()}');
        // Helper.kmDistance = userData.kmRecorrido;
        // Helper.timeUpdateDistance = userData.tiempoActualizarDistancia;
        UserDataStorage().setTKmDistance(userData.kmRecorrido);
        UserDataStorage().setTimeUpDistance(userData.tiempoActualizarDistancia);
        // Logger().w(userData.tiempoActualizarUbicacion);
        fp.setSession(true);

        _navigateTo(const HomePage());
      } else {
        _navigateTo(const LoginPage());
      }
    } else {
      _navigateTo(const LoginPage());
    }
  }

  _navigateTo(Widget page) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      Navigator.pushReplacement(
          context, Helper.navigationFadeIn(context, page, 1700));
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Center(
          child: LoadingAnimation(
              animation: AppConfig.appThemeConfig.loadingAnimation,
              child: Hero(
                  tag: 'logo-business',
                  child: SizedBox(
                      height: 170,
                      child: Image(
                          image: AssetImage(
                              AppConfig.appThemeConfig.logoImagePath))))),
        ),
      ),
    );
  }
}
