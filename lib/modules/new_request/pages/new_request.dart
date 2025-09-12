
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/customer_data_form.dart';
import 'package:sweaden_old_new_version/modules/new_request/pages/request_data_form.dart';
import 'package:sweaden_old_new_version/modules/new_request/providers/new_request_provider.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/new_request/widgets/new_request_widgets.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/pages/offline_configuration_page.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart' as request_offline;
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:provider/provider.dart';

class NewRequestPage extends StatefulWidget {
  static InspectionDataResponse? inspectionData;

  static List<request_offline.Request> listCreatingrequests = [];
  static String idInspector = '';

  
  const NewRequestPage({Key? key}) : super(key: key);

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}



class _NewRequestPageState extends State<NewRequestPage> {
  final OfflineStorage _offlineStorage = OfflineStorage();

  late FunctionalProvider fp;

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    _getUserSession();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor, name: 'new-request', context: context);
      //if (NewRequestPage.inspectionData == null) {
        _loadInspectionData();
      // }else{
      //   _loadDataInspectionStorage();
      //   //debugPrint('entroooooo');
      // }
    });
  }

  _loadInspectionData() async {
    if(!fp.offline){
      if(NewRequestPage.inspectionData == null){
        final response = await NewRequestService().getInspectionData(context);
        // log('response: ${response.data}');
        if(response.data!=null){
          NewRequestPage.inspectionData = response.data;
          setState(() {});
        }
      }
    }else{
      bool existCatalog = await Helper.verifyCatalogueStorage();

      if(!existCatalog){
        fp.showAlert(
          content: AlertGenericError(
            messageButton: 'Ir a los catalogos',
            message: 'Antes de crear solicitudes offline, debe tener descargados todos los catalogos.',
            onPress: () {
              fp.dismissAlert();
              Navigator.pushReplacement(context, Helper.navigationFadeIn(context, const OfflineConfigurationPage(), 500));
            },
          )
        );
      }else{
        //CARGAR CATALOGO DE STORAGE Y ASIGNAR A VARIABLE GLOBAL
        _loadDataInspectionStorage();
        //_getCreatingRequests();
        _getListInspectionOfflineCoordinated();
        
        //Helper.snackBar(context: context, message: 'No tienes conexión a internet, porque estas en modo offline.', colorSnackBar: Colors.red);
      }
    }
  }

  // _getCreatingRequests () async {
  //   final response = await  OfflineStorage().getCreatingRequests();
  //   if(response.isNotEmpty){
  //     NewRequestPage.listCreatingrequests = response;
  //     setState(() {});
  //   }
  // }

  _loadDataInspectionStorage() async {
    if(NewRequestPage.inspectionData == null){
      final response = await _offlineStorage.getCatalogueRegisterRequest();
      if(response != null){
        NewRequestPage.inspectionData = response;
        setState(() {});
      }
    }
  }

  _getListInspectionOfflineCoordinated() async {
    List<ListInspectionDataResponse>? value = await OfflineStorage().getListInspectionOffline();
    // log('1${jsonEncode(value)}');
    if(value != null && ReviewRequestPage.listInspectionCoordinated.isEmpty /*&& value.first.lista.isNotEmpty*/){
     // Helper.logger.w('2');
      ReviewRequestPage.listInspectionCoordinated.addAll(value.first.lista);
      setState(() {});
    }
  }

  _getUserSession() async {
    if(NewRequestPage.idInspector.isEmpty){
      final userData = await UserDataStorage().getUserData();
      NewRequestPage.idInspector = userData!.informacion.codigo;
      setState(() {});
    }
  }


  @override
  void dispose() {
    //  debugPrint('dispose');
    // NewRequestPage.inspectionData = null;
    BackButtonInterceptor.removeByName('new-request');
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      fp.showAlert(content: const AlertLoseProcess());
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (context) => NewRequestProvider(),
      child: Stack(
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const FormHeader(),
                          if (NewRequestPage.inspectionData != null)
                            FormContent(
                              inspectionData: NewRequestPage.inspectionData!,
                            )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: const BottomInfo()),
          const AlertModal(),
        const NotificationModal(),
        const NotificationExpirationCatalogue(),
        ],
      ),
    );
  }

  AppBar _appBarHome(BuildContext context) {
    return AppBar(
      backgroundColor: AppConfig.appThemeConfig.secondaryColor,
      title: const Text.rich(TextSpan(children: [
        TextSpan(
            text: 'Ingreso ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'de solicitud', style: TextStyle(fontWeight: FontWeight.w300))
      ])),
      leading: IconButton(
          onPressed: () {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            fp.showAlert(content: const AlertLoseProcess());
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
      // shadowColor: AppConfig.appThemeConfig.primaryColor,
    );
  }
}

class FormContent extends StatefulWidget {
  final InspectionDataResponse inspectionData;
  const FormContent({
    Key? key,
    required this.inspectionData,
  }) : super(key: key);

  @override
  State<FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<FormContent> {
  late List<ListaIdentifElement> identifList;
  late List<ListabrokerElement> brokerList;
  late List<ListaIdentifElement> processList;
  late ConfiguracionInicial initialConfig;
  late List<ListaRamoElement> branchesList;
  late List<Listaagencia> agenciesList;
  late List<ListaIdentifElement> requestsList;
  late PageController pageViewController;
  late FunctionalProvider fp;
  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
     pageViewController = PageController(initialPage: 0);
    _loadSpecificData();
    super.initState();
  }

  @override
  void dispose() {
    
     pageViewController.dispose();   
    super.dispose();
  }

  _loadSpecificData() {
    //? para Customer data
    identifList = NewRequestPage.inspectionData!.listaIdentif;
    //? para Request data form
    brokerList = NewRequestPage.inspectionData!.listabroker;
    // if(!fp.offline){
    //    debugPrint('online');
    //   processList = NewRequestPage.inspectionData!.listaproceso;
    //   Helper.logger.w(jsonEncode(NewRequestPage.inspectionData!.listaproceso));
    // }else{
    //   debugPrint('offline');
    //   NewRequestPage.inspectionData!.listaproceso.removeWhere((e) => e.codigo == Helper.processEmission);
      processList = NewRequestPage.inspectionData!.listaproceso;
    //}
    initialConfig = NewRequestPage.inspectionData!.configuracionInicial;
    branchesList = NewRequestPage.inspectionData!.listaramos;
    agenciesList = NewRequestPage.inspectionData!.listaagencias;
    requestsList = NewRequestPage.inspectionData!.listasolicitud;
  }

  

 

  navigateToScreen(int page) {
    final nrp = Provider.of<NewRequestProvider>(context,listen: false);
    if (pageViewController.hasClients) {
    nrp.changeTitle(page);
    pageViewController.animateToPage(page,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    }
    
  }

  

  @override
  Widget build(BuildContext context) {
    
    return Expanded(
      child:PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageViewController,
        children: [
          CustomerDataForm(
            identificationList: identifList,
            navigateToPage: navigateToScreen ,
          ),
          RequestDataForm(
            navigateToPage: navigateToScreen,
              brokerList: brokerList,
              processList: processList,
              initialConfig: initialConfig,
              branchesList: branchesList,
              agenciesList: agenciesList,
              requestsList: requestsList)
        ],
      ),
    );
  }
}

class FormHeader extends StatelessWidget {
  const FormHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final informativeTitle =
        context.select((NewRequestProvider nrp) => nrp.informativeTitle);
    return Column(
      children: [
        const SizedBox(
          height: 25,
        ),
        Text(
          "A continuación podrás realizar el registro de la solicitud de inspección de tu cliente.",
          style: TextStyle(
              color: AppConfig.appThemeConfig.secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 15),
        ),
        const SizedBox(
          height: 10,
        ),
        InfoTileWidget(informativeTitle: informativeTitle),
      ],
    );
  }
}
