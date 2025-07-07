import 'dart:async';
import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/modules/home/pages/home_page.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/alert_inspection_offline_widget.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/review_request_widgets.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class ReviewRequestPage extends StatefulWidget {
  const ReviewRequestPage({Key? key}) : super(key: key);
  static List<Lista> listInspectionCoordinated = [];
  static List<Lista> listInspectionFinishedOffline = [];
  static bool viewAlert = true;

  @override
  State<ReviewRequestPage> createState() => _ReviewRequestPageState();
}

List<ListInspectionDataResponse>? listInspectionData;

class _ReviewRequestPageState extends State<ReviewRequestPage> {
  late ScrollController _controller;
  late FunctionalProvider fp;

  Timer timer = Timer(const Duration(seconds: 0), (){});

  final TextEditingController _controllerSearch = TextEditingController();

  @override
  void initState() {
    fp = Provider.of<FunctionalProvider>(context, listen: false);
    //getListInspectionOfflineFinished();
    getListInspectionOfflineCoordinated();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      BackButtonInterceptor.add(myInterceptor, name: 'request-review', context: context);
      getInternet();
    });
    _controller = ScrollController()..addListener(_scrollListener);
  }

  getInternet() async {
    if(fp.offline){
      _loadInspectionSecureStorage();
    }else{
      await _loadInspectionData();
      //await _verifyListInspectionOffline();

      bool catalogueExpiration = await Helper.verifyCatalogueExpiration();

      if(catalogueExpiration){
        fp.showNotificationCatalogue();
        timer = Timer(const Duration(seconds: 5), () => fp.dismissNotificationCatalogue());
      }
    }
  }

  // _verifyListInspectionOffline() async {
  //   if(ReviewRequestPage.listInspectionFinishedOffline.isNotEmpty){
  //     fp.setLoadingInspection(false);
  //     final exist = ReviewRequestPage.listInspectionFinishedOffline.any((e) => e.creacionOffline == false);

  //     //Helper.logger.e("any: $exist");
      
  //     if(exist){
  //       fp.showAlert(
  //         content: AlertInspectionOfflineWidget(
  //           inspectionOffline: ReviewRequestPage.listInspectionFinishedOffline,
  //           uploadInspections: _uploadInspections,
  //         ),
  //       );
  //     }
  //   }
  // }

  // _uploadInspections() async {
  //   listInspectionData = null;
  //   setState(() {});
  //   _loadInspectionData();
  // }

  getListInspectionOfflineCoordinated() async {
    List<ListInspectionDataResponse>? value = await OfflineStorage().getListInspectionOffline();
    
    if(value != null && ReviewRequestPage.listInspectionCoordinated.isEmpty){
      ReviewRequestPage.listInspectionCoordinated.addAll(value.first.lista);
      setState(() {});
    }
  }

  // getListInspectionOfflineFinished() async {
  //   List<ListInspectionDataResponse>?  inspectionOfflineFinished = await OfflineStorage().getInspectionFinishedOffline();
  //   if(inspectionOfflineFinished != null && ReviewRequestPage.listInspectionFinishedOffline.isEmpty){
  //     ReviewRequestPage.listInspectionFinishedOffline.addAll(inspectionOfflineFinished.first.lista);
  //     setState(() {});
  //   }
  // }
  

  _scrollListener() {
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
    }
  }

  _loadInspectionData() async {
    final response = await RequestReviewService().getListInspect(context);
    if(!response.error){
       listInspectionData = response.data!;
       setState(() {});
    } else {
      fp.showAlert(content: AlertGenericError(message: response.message));
    }
  }

  _loadInspectionSecureStorage() async {
    final response = await OfflineStorage().getListInspectionOffline();
    final inspectionOfflineFinished = await OfflineStorage().getInspectionFinishedOffline();
    if(response != null || inspectionOfflineFinished != null){
        if(ReviewRequestPage.viewAlert){
          fp.showAlert(
          content: AlertConfirm(
            message: 'Actualmente no cuentas con conexion a internet, ¿deseas continuar en modo offline?',
            confirm: () {
              fp.dismissAlert();
              listInspectionData = verifyListInspecctionOffline(response: response!, inspectionOfflineFinished: inspectionOfflineFinished);
              ReviewRequestPage.viewAlert = false;
              setState(() { });
            },
            cancel: (){
              fp.dismissAlert();
              listInspectionData = null;
              Navigator.pushReplacement(
              context,
              PageTransition(
                  child: const HomePage(),
                  type: PageTransitionType.leftToRightWithFade));
            },
          )
        );
      }else{
        listInspectionData = verifyListInspecctionOffline(response: response!, inspectionOfflineFinished: inspectionOfflineFinished);
        setState(() { });
      }
    }
    else {
      fp.showAlert(
        content: AlertGenericError(
          messageButton: 'Cerrar', 
          message: 'No cuentas con inspecciones descargadas para continuar en modo offline',
          onPress: (){
            fp.dismissAlert();
            listInspectionData = null;
            Navigator.pushReplacement(
            context,
            PageTransition(
                child: const HomePage(),
                type: PageTransitionType.leftToRightWithFade));
          },
        )
      );
    }
  }

  List<ListInspectionDataResponse> verifyListInspecctionOffline({required List<ListInspectionDataResponse> response, required List<ListInspectionDataResponse>? inspectionOfflineFinished}){
    final List<ListInspectionDataResponse> listInspectionFinal = [];
    if(response.first.lista.isNotEmpty) {
        listInspectionFinal.addAll(response);
    }

    if((inspectionOfflineFinished != null && inspectionOfflineFinished.isNotEmpty) && (inspectionOfflineFinished.first.lista.isNotEmpty)){
      listInspectionFinal.addAll(inspectionOfflineFinished);
    }

    return listInspectionFinal;
  }

  @override
  void dispose() {
    timer.cancel();
    listInspectionData = null;
    BackButtonInterceptor.removeByName('request-review');
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (!info.ifRouteChanged(context)) {
      if(!fp.loadingInspection){
        listInspectionData = null;
        Navigator.pushReplacement(
            context,
            PageTransition(
                child: const HomePage(),
                type: PageTransitionType.leftToRightWithFade));
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    //bool loadingInspection = context.watch<FunctionalProvider>().loadingInspection;

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          TabBar(
                            labelColor: AppConfig.appThemeConfig.primaryColor,
                            indicatorColor:
                                AppConfig.appThemeConfig.secondaryColor,
                            tabs: const <Widget>[
                              Tab(text: 'PENDIENTES'),
                              Tab(text: 'FINALIZADAS'),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFieldWidget(
                            multiline: false,
                            textInputType: TextInputType.text,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: (){
                                _controllerSearch.clear();
                                setState(() {});
                              },
                            ),
                            label: 'Busqueda',
                            controller: _controllerSearch,
                              onChanged: ((value) {
                                setState(() {});
                              }
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                              child: TabBarView(
                            children: <Widget>[
                              _tabListInspectionWidget(
                                  context, _controller, 'pendientes'),
                              _tabListInspectionWidget(
                                  context, _controller, 'finalizadas'),
                            ],
                          ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
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
            text: 'Bandeja ', style: TextStyle(fontWeight: FontWeight.bold)),
        TextSpan(
            text: 'de entrada', style: TextStyle(fontWeight: FontWeight.w300))
      ])),
      leading: IconButton(
          onPressed: () {
            listInspectionData = null;
            Navigator.pushReplacement(
                context,
                PageTransition(
                    child: const HomePage(),
                    type: PageTransitionType.leftToRightWithFade));
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
    );
  }


  FadeInRight _tabListInspectionWidget( BuildContext context, ScrollController _controller, String state) {
    return FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: SingleChildScrollView(
          controller: _controller,
          child: listInspectionData != null
              ? ListInspectionWidget(
                controllerSearch: _controllerSearch,
                  listInspection: listInspectionData,
                  type: state,
                )
              : Container(),
        ));
  }
}
