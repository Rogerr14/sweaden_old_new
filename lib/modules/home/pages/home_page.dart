import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/home/models/location_response.dart';
import 'package:sweaden_old_new_version/modules/home/service/user_location_service.dart';
import 'package:sweaden_old_new_version/modules/home/widgets/home_widgets.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/new_request.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/auth_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/button_opacity_widget.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static StreamSubscription<Position>? positionStream;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? myName;
  DateTime? date;

  AuthResponse? usuario;
  late FunctionalProvider fp;
  Position? position;

  //late StreamSubscription<ServiceStatus> serviceStatusStream;

  //late  StreamSubscription<Position> positionStream;

  //int? timeUpdateLocation; // segundos

  @override
  void initState() {
    _getListInspectionOfflineFinished();
    _getListCreatingRequests();
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    //_processBackground();
    _getMyName();
    _getUserStorage();
    // streamStatusPendingMedia();
    // if(fp.activeBackground){
       Helper.startBackgroundService();
    // }

    // log(ReviewRequestPage.listInspectionFinishedOffline.length.toString());

    super.initState();
  }

  _getListCreatingRequests() async {
    final response = await OfflineStorage().getCreatingRequests();

    // log(jsonEncode({'requests_offline': (response)}));

    if (response.isNotEmpty) {
      NewRequestPage.listCreatingrequests = response;
      //listInspection();
      setState(() {});
    }
  }

  _getListInspectionOfflineFinished() async {
    List<ListInspectionDataResponse>? inspectionOfflineFinished =
        await OfflineStorage().getInspectionFinishedOffline();

    if (inspectionOfflineFinished != null &&
        ReviewRequestPage.listInspectionFinishedOffline.isEmpty) {
      ReviewRequestPage.listInspectionFinishedOffline.addAll(
        inspectionOfflineFinished.first.lista,
      );
      setState(() {});
    }
  }

  // Future<void> streamStatusPendingMedia() async {
  //   //declaro un timer que verifique si existe datos en el storage
  //   //si existe, lo añado a la lista de helper, si no no hace nada
  //   //si el estatus es cargando, mando el fpsetloadingtrue.
  //   //si no hay nada, entonces limpio la lista del storage.

  //   Timer.periodic(const Duration(minutes: 1), (timer) async {
  //     final listMedia = await OfflineStorage().getMediaStatus();
  //     if (listMedia.isNotEmpty) {
  //       Helper.mediaStatus = listMedia;
  //       fp.setLoadingInspection(true);
  //       // setState(() {});
  //     } else {
  //       fp.setLoadingInspection(false);
  //     }
  //   });
  // }

  // Future<Position> _position() async{
  //   Position position = await Geolocator.getCurrentPosition();
  //   Helper.logger.w('posicion actual del usuario: longitude: ${position.longitude} altitude: ${position.altitude}');
  //   return position;
  // }

  // _processBackground() async {
  //   HomePage.timer = Timer.periodic(Duration(seconds: Helper.timeUpdateLocation), (Timer t){
  //     if(!fp.offline){
  //       _position();
  //       locationUser();
  //     }else{
  //       _position();
  //     }
  //   });
  // }

  _getUserStorage() async {
    usuario = await UserDataStorage().getUserData();
    setState(() {});
  }

  _getMyName() async {
    final userData = await UserDataStorage().getUserData();
    myName = userData!.informacion.nombre;
    date = userData.expiraToken;
    setState(() {});
  }

  //  Future<int>_getTimeLocation() async {
  //   final userData = await UserDataStorage().getUserData();
  //   return userData!.tiempoActualizarUbicacion;
  //   //setState(() {});
  // }

  // @override
  // void dispose() {
  //   _connectivityService.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    bool offline = context.watch<FunctionalProvider>().offline;
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    // Helper.logger.w('positionStreamn: ${positionStream}');

    final size = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          BackGround(size: size),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _appBarHome(context, fp),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ButtonOpacityWidget(
                  child: Text(
                    "${Helper.calculateTimeRemaining(date: date ?? DateTime.now())} d",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    "Te quedan ${Helper.calculateTimeRemaining(date: date ?? DateTime.now())} dias para que tu sesión expire.",
                    style: TextStyle(
                      fontSize: 15.0,
                      color: AppConfig.appThemeConfig.secondaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.all<Color>(
                          !offline ? Colors.green : Colors.red,
                        ),
                      ),
                      onPressed: () async {
                        //Helper.logger.e(!offline ? 'Offline': 'Online');
                        if (offline) {
                          fp.showAlert(
                            content: const AlertLoading(
                              title: 'Verificando conexión a internet...',
                            ),
                          );
                          bool hasConnectionInternet =
                              await Helper.checkConnection();
                          if (hasConnectionInternet) {
                            fp.setOffline(false);
                            fp.dismissAlert();
                            Helper.snackBar(
                              context: context,
                              message: 'Vuelves a tener conexión a internet.',
                              colorSnackBar: Colors.green,
                            );
                          } else {
                            fp.setOffline(true);
                            fp.dismissAlert();
                            Helper.snackBar(
                              context: context,
                              message: 'No tienes conexión a internet.',
                              colorSnackBar: Colors.red,
                            );
                          }
                          //fp.setConnection(!offline);
                        } else {
                          fp.setOffline(true);
                        }
                      },
                      icon:
                          offline
                              ? const Icon(Icons.wifi_off)
                              : const Icon(Icons.wifi),
                      label: Text(offline ? 'Offline' : 'Online'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  color: AppConfig.appThemeConfig.primaryColor,
                ),
                // const SizedBox(height: 20),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Container(
                //     alignment: AlignmentGeometry.lerp(Alignment.center, Alignment.centerRight, 0.5),
                //     height: 80,
                //     decoration: BoxDecoration(
                //         border: Border.all(color: Colors.red, width:1),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Text(
                //         '$myName ${Helper.calculateTimeRemaining(date: usuario!.expiraToken.toString())} para que tu sesión expire.',
                //         style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  margin: const EdgeInsets.only(top: 40),
                  child: const Text(
                    'Por favor, selecciona una de las tareas que deseas realizar hoy.',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                // GridView.count(crossAxisCount: 2)
                const SizedBox(height: 20),
                if (usuario != null) TaskGrid(usuario: usuario!),
              ],
            ),
            bottomNavigationBar: const BottomInfo(),
          ),
          const AlertModal(),
          const NotificationModal(),
        ],
      ),
    );
  }

  AppBar _appBarHome(BuildContext context, FunctionalProvider fp) {
    return AppBar(
      backgroundColor: AppConfig.appThemeConfig.secondaryColor,
      title: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: 'Hola ',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
            TextSpan(
              text: myName ?? 'Usuario',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      // shadowColor: AppConfig.appThemeConfig.primaryColor,
      actions: [
        IconButton(
          onPressed: () {
            fp.showAlert(content: const AlertLogOut());
            // log('entra');
          },
          icon: const Icon(Icons.logout_sharp),
        ),
      ],
    );
  }
}
