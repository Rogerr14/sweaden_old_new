import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/models/catalogue_offline_general_response.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/text_rich_widget.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class OfflineConfigurationPage extends StatefulWidget {
  const OfflineConfigurationPage({super.key});

  @override
  State<OfflineConfigurationPage> createState() =>
      _OfflineConfigurationPageState();
}

class _OfflineConfigurationPageState extends State<OfflineConfigurationPage> {
  final RequestReviewService _requestReviewService = RequestReviewService();

  final OfflineStorage _offlineStorage = OfflineStorage();

  String dateCatalogueVehicle = '';
  String dateAccesories = '';
  String dateMedia = '';
  String dateFormClient = '';
  String dateModels = '';
  String dateCatalogueRegisterRequest = '';
  String dateCatalogueExecutives = '';

  late List<Future<void> Function()> offlineService;

  bool? catalogueVehicle;
  bool? catalogueAccessories;
  bool? catalogueMediaInfo;
  bool? catalogueCliente;
  bool? catalogueModels;

  late FunctionalProvider fp;
  final RoundedLoadingButtonController controllerAccessories =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerMediaInfo =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerCliente =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerVehicle =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerModels =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerCatalogueRegisterRequest =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController controllerGetExecutives =
      RoundedLoadingButtonController();

  //List<CatalogueOfflineResponse> catalogue = [];

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    offlineService = [
      getAccesoriesVehicle,
      getMediaInfo,
      getDataClientForm,
      getVehicleDataInspection,
      getModelsVehicle,
      getDataRegisterRequest,
      getExecutives
    ];

    _getAccesoriesVehicleDate();
    _getMediaInfoDate();
    _getCatalogueVehicleStorage();
    _getDataClientFormDate();
    _getCatalogueModelsDate();
    _getCatalogueRegisterRequest();
    _getCatalogueExecutives();

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'offline-configuration', context: context);
    });
  }

  _getCatalogueVehicleStorage() async {
    final response = await _offlineStorage.getCatalogueVehicleData();
    if (response != null) {
      dateCatalogueVehicle = response.date!;
      setState(() {});
    }
  }

  _getCatalogueExecutives() async {
    final response = await _offlineStorage.getCatalogueExecutives();
    if (response != null) {
      dateCatalogueExecutives = response.dateCreation;
      setState(() {});
    }
  }

  _getAccesoriesVehicleDate() async {
    final response = await _offlineStorage.getCatalogueVehicleAccessories();
    if (response != null) {
      dateAccesories = response.dateCreation;
      setState(() {});
    }
  }

  _getMediaInfoDate() async {
    final response = await _offlineStorage.getCatalogueFileType();
    if (response != null) {
      dateMedia = response.dateCreation;
      setState(() {});
    }
  }

  _getDataClientFormDate() async {
    final response = await _offlineStorage.getCataloguePersonalInformation();
    if (response != null) {
      dateFormClient = response.dateCreation!;
      setState(() {});
    }
  }

  _getCatalogueRegisterRequest() async {
    final response = await _offlineStorage.getCatalogueRegisterRequest();
    if (response != null) {
      dateCatalogueRegisterRequest = response.dateCreation!;
      setState(() {});
    }
  }

  _getCatalogueModelsDate() async {
    final response = await _offlineStorage.getCatalogueVehiceModels();
    if (response != null) {
      dateModels = response.dateCreation;
      setState(() {});
    }
  }

  Future<void> getVehicleDataInspection() async {
    final response =
        await _requestReviewService.getVehicleDataInspection(context);
    if (!response.error) {
      controllerVehicle.success();
      response.data!.date = Helper.getCurrentDateAndTime();
      _offlineStorage.saveCatalogueVehicleData(response.data!);
      setState(() {
        dateCatalogueVehicle = Helper.getCurrentDateAndTime();
        catalogueVehicle = false;
      });
    } else {
      controllerVehicle.error();
      Future.delayed(
          const Duration(seconds: 2), () => controllerVehicle.reset());
      setState(() {
        catalogueVehicle = true;
      });
    }
  }

  _desactivateBackgroundService() {}

  Future<void> getModelsVehicle() async {
    final response = await _requestReviewService.getVehicleModels(context, '*');
    if (!response.error) {
      controllerModels.success();
      _offlineStorage.saveCatalogueVehiceModels(CatalogueOfflineGeneralResponse(
          dateCreation: Helper.getCurrentDateAndTime(), data: response.data!));
      setState(() {
        dateModels = Helper.getCurrentDateAndTime();
        catalogueModels = false;
      });
    } else {
      controllerModels.error();
      Future.delayed(
          const Duration(seconds: 3), () => controllerModels.reset());
      setState(() {
        catalogueModels = true;
      });
    }
  }

  Future<void> getAccesoriesVehicle() async {
    final response =
        await _requestReviewService.getAccesoriesVehicle(context, '04');
    if (!response.error) {
      controllerAccessories.success();
      _offlineStorage.saveCatalogueVehicleAccessories(
          CatalogueOfflineGeneralResponse(
              dateCreation: Helper.getCurrentDateAndTime(),
              data: response.data!));
      if (mounted) {
        setState(() {
          dateAccesories = Helper.getCurrentDateAndTime();
          catalogueAccessories = false;
        });
      }
    } else {
      controllerAccessories.error();
      Future.delayed(
          const Duration(seconds: 3), () => controllerAccessories.reset());
      setState(() {
        catalogueAccessories = true;
      });
    }
  }

  Future<void> getMediaInfo() async {
    final response = await _requestReviewService.getMediaInfo(context);
    if (!response.error) {
      controllerMediaInfo.success();
      _offlineStorage.saveCatalogueFileType(CatalogueOfflineGeneralResponse(
          dateCreation: Helper.getCurrentDateAndTime(), data: response.data!));
      setState(() {
        dateMedia = Helper.getCurrentDateAndTime();
        catalogueMediaInfo = false;
      });
    } else {
      controllerMediaInfo.error();
      Future.delayed(
          const Duration(seconds: 3), () => controllerMediaInfo.reset());
      setState(() {
        catalogueMediaInfo = true;
      });
    }
  }

  Future<void> getDataClientForm() async {
    final response = await _requestReviewService.getDataClientForm(context, '');
    if (!response.error) {
      controllerCliente.success();
      response.data!.dateCreation = Helper.getCurrentDateAndTime();
      _offlineStorage.saveCataloguePersonalInformation(response.data!);
      setState(() {
        dateFormClient = Helper.getCurrentDateAndTime();
        catalogueCliente = false;
      });
    } else {
      controllerCliente.error();
      Future.delayed(
          const Duration(seconds: 3), () => controllerCliente.reset());
      setState(() {
        catalogueCliente = true;
      });
    }
  }

  Future<void> getDataRegisterRequest() async {
    final response = await NewRequestService().getInspectionData(context);
    if (!response.error) {
      controllerCatalogueRegisterRequest.success();
      response.data!.dateCreation = Helper.getCurrentDateAndTime();
      _offlineStorage.saveCatalogueRegisterRequest(response.data!);
      setState(() {
        dateCatalogueRegisterRequest = Helper.getCurrentDateAndTime();
      });
    } else {
      controllerCatalogueRegisterRequest.error();
      Future.delayed(const Duration(seconds: 3),
          () => controllerCatalogueRegisterRequest.reset());
    }
  }

  Future<void> getExecutives() async {
    final response = await NewRequestService().getExecutives(context, '*', '*');
    if (!response.error) {
      controllerGetExecutives.success();
      _offlineStorage.saveCatalogueExecutives(CatalogueOfflineGeneralResponse(
          dateCreation: Helper.getCurrentDateAndTime(), data: response.data!));
      setState(() {
        dateCatalogueExecutives = Helper.getCurrentDateAndTime();
      });
    } else {
      controllerGetExecutives.error();
      Future.delayed(
          const Duration(seconds: 3), () => controllerGetExecutives.reset());
    }
  }

  // bool verifyCatalogueList({required String nameCatalogueOffline}){
  //   final response = catalogue.any((e) => e.nameCatalogo == nameCatalogueOffline);
  //   return response;
  // }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('offline-configuration');
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: const HomePage(),
              type: PageTransitionType.leftToRightWithFade));
    }
    return true;
  }

  _activeBackground(bool activate) async {
    UserDataStorage().activeBackgroundService(activate);
    fp.setActiveBackground(activate);
    if (activate) {
     await Helper.startBackgroundService();
    } else {
    await   Helper.stopBackgroundService();
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //Helper.logger.w('lista de catalogo locales: ${jsonEncode(catalogue)}');

    // catalogue.isNotEmpty == true ?  _offlineStorage.saveVerifyListCatalogueOffline(catalogue) : null;

    return Stack(
      children: [
        BackGround(size: size),
        Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _appBarHome(context),
            body: Column(
              children: [
                Container(
                  height: 5,
                  color: AppConfig.appThemeConfig.primaryColor,
                ),
                Expanded(
                  child: Container(
                    width: size.width,
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Wrap(
                                    spacing: 3,
                                    runAlignment: WrapAlignment.end,
                                    crossAxisAlignment: WrapCrossAlignment.end,
                                    alignment: WrapAlignment.start,
                                    children: [
                                      Text('Proceso en segundo plano:',
                                          style: TextStyle(
                                              color: AppConfig.appThemeConfig
                                                  .secondaryColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400)),
                                      Text(fp.activeBackground ? 'Activado' : 'Descativado',
                                          style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Switch(
                                      activeColor:
                                          AppConfig.appThemeConfig.primaryColor,
                                      value: fp.activeBackground,
                                      onChanged: (value) {
                                        _activeBackground(value);
                                      }),
                                ),
                              ],
                            ),
                          ),
                          SynchronizationWidget(
                              controller: controllerAccessories,
                              error: catalogueAccessories,
                              title: 'accesorios',
                              date: dateAccesories,
                              onPressed: () async {
                                getAccesoriesVehicle();
                              }),
                          SynchronizationWidget(
                              controller: controllerMediaInfo,
                              error: catalogueMediaInfo,
                              title: 'archivos',
                              date: dateMedia,
                              onPressed: () {
                                getMediaInfo();
                              }),
                          //const SizedBox(height: 5),
                          SynchronizationWidget(
                              controller: controllerCliente,
                              error: catalogueCliente,
                              title: 'cliente',
                              date: dateFormClient,
                              onPressed: () {
                                getDataClientForm();
                              }),
                          SynchronizationWidget(
                            controller: controllerVehicle,
                            error: catalogueVehicle,
                            title: 'vehiculo',
                            date: dateCatalogueVehicle,
                            onPressed: () {
                              getVehicleDataInspection();
                            },
                          ),
                          SynchronizationWidget(
                            controller: controllerModels,
                            error: catalogueModels,
                            title: 'Modelos',
                            date: dateModels,
                            onPressed: () {
                              getModelsVehicle();
                            },
                          ),
                          SynchronizationWidget(
                            controller: controllerCatalogueRegisterRequest,
                            //error: catalogueModels,
                            title: 'Registrar Solicitud',
                            date: dateCatalogueRegisterRequest,
                            onPressed: () {
                              getDataRegisterRequest();
                            },
                          ),
                          SynchronizationWidget(
                            controller: controllerGetExecutives,
                            //error: catalogueModels,
                            title: 'Ejecutivos',
                            date: dateCatalogueExecutives,
                            onPressed: () {
                              getExecutives();
                            },
                          ),
                          //const SizedBox(height: 5),
                          //const SizedBox(height: 100),
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: WidgetStateProperty.all(
                                      AppConfig.appThemeConfig.secondaryColor)),
                              onPressed: () async {
                                if (!fp.offline) {
                                  for (var item in offlineService) {
                                    await item();
                                    await Future.delayed(
                                        const Duration(milliseconds: 200));
                                  }
                                } else {
                                  Helper.snackBar(
                                      context: context,
                                      message:
                                          'No tienes conexión a internet, porque estas en modo offline.',
                                      colorSnackBar: Colors.red);
                                }
                              },
                              child: const Text('Sincronizar todo'))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            bottomNavigationBar: const BottomInfo()),
        const AlertModal(),
      ],
    );
  }

  AppBar _appBarHome(BuildContext context) {
    return AppBar(
      backgroundColor: AppConfig.appThemeConfig.secondaryColor,
      title: const Text.rich(TextSpan(children: [
        TextSpan(
            text: 'Configuración offline',
            style: TextStyle(fontWeight: FontWeight.w300))
      ])),
      leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context,
                PageTransition(
                    child: const HomePage(),
                    type: PageTransitionType.leftToRightWithFade));
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
      // shadowColor: AppConfig.appThemeConfig.primaryColor,
    );
  }
}

class SynchronizationWidget extends StatelessWidget {
  const SynchronizationWidget({
    Key? key,
    required this.date,
    required this.title,
    this.onPressed,
    this.error,
    required this.controller,
  }) : super(key: key);

  final String date;
  final String title;
  final Function()? onPressed;
  final bool? error;
  final RoundedLoadingButtonController controller;

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: ListTile(
          autofocus: true,
          //contentPadding: EdgeInsets.zero,
          title: Text(
            'Catalogo de $title',
            style: TextStyle(
              color: AppConfig.appThemeConfig.primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: date != ''
              ? Wrap(
                  spacing: 3,
                  runAlignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  alignment: WrapAlignment.start,
                  children: [
                    Text('Se sincronizó por última vez:',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    Text('$date ',
                        style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                )
              : const Text('Aun no se ha sincronizado'),
          trailing: SizedBox(
            width: 50,
            child: RoundedLoadingButton(
              key: key,
              child: const Icon(Icons.download),
              color: AppConfig.appThemeConfig.secondaryColor,
              successColor: Colors.green,
              loaderSize: 15,
              borderRadius: 80,
              height: 29,
              controller: controller,
              onPressed: onPressed,
            ),
          )
          //trailing: IconButtonRefreshWidget(error: error, onPressed: onPressed),
          ),
    );

    // Row(
    //   children: [
    //  RichText(
    //     text: TextSpan(
    //       style: const TextStyle(height: 1.3),
    //       children: [
    //         TextSpan(
    //           text: 'Catalogo de $title             ',
    //           style: TextStyle(
    //             color: AppConfig.appThemeConfig.primaryColor,
    //             fontSize: 16,
    //             fontWeight: FontWeight.w500,
    //           ),
    //         ),
    //         date != ''?
    //         TextSpan(
    //           children: [
    //                TextSpan(
    //                 text: '\nSe sincronizó por última vez: ',
    //                 style: TextStyle(
    //                   color: AppConfig.appThemeConfig.primaryColor,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w300,
    //                 ),
    //               ),
    //               TextSpan(
    //                 text: date != '' ? date : '',
    //                 style: const TextStyle(
    //                   color: Colors.black54,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //           ]
    //         ):
    //         TextSpan(
    //          children: [
    //            TextSpan(
    //                 text: '\nAun no se ha sincronizado',
    //                 style: TextStyle(
    //                   color: AppConfig.appThemeConfig.primaryColor,
    //                   fontSize: 12,
    //                   fontWeight: FontWeight.w300,
    //                 ),
    //               ),
    //          ]
    //         ),
    //       ],
    //     ),
    //   ),
    //     const SizedBox(width: 10),
    //     IconButtonRefreshWidget(
    //       error: error,
    //       onPressed: onPressed
    //     )
    //   ],
    // );
  }
}
