import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sweaden_old_new_version/modules/new_request/services/new_request_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/inspection_continue_form.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/inspection_edit.dart';
import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
import 'package:sweaden_old_new_version/modules/review_request/services/request_review_services.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/review_request_widgets.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/user_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InspectionDetailPage extends StatefulWidget {
  final Lista inspection;
  const InspectionDetailPage({Key? key, required this.inspection})
      : super(key: key);

  @override
  State<InspectionDetailPage> createState() => _InspectionDetailPageState();
}

class _InspectionDetailPageState extends State<InspectionDetailPage>
    with AutomaticKeepAliveClientMixin {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'inspection-detail', context: context);
    });
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('inspection-detail');
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    // return true;
    if (!info.ifRouteChanged(context)) {
      // print("INSPECTION DETAIL INTERCEPTOR");
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: const ReviewRequestPage(),
              type: PageTransitionType.leftToRightWithFade));
      // final fp = Provider.of<FunctionalProvider>(context, listen: false);
      // fp.showAlert(content: const AlertLoseProcess());
    }
    return true;
  }

  _updatedEditFlag(bool value) async {
    debugPrint('---- cargando datos de inspección ----');
    final response = await NewRequestService().getInspectionData(context);
    await Future.delayed(const Duration(milliseconds: 100), () {});
    if (response.data != null) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: InspectionEditPage(
                  inspection: widget.inspection,
                  catInspectionData: response.data!),
              type: PageTransitionType.leftToRightWithFade));
    }
  }

  _acceptInspection(bool value) async {
    if (value) {
      debugPrint('---- aceptando inspección ----....');
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      final response = await RequestReviewService().updateStateInspection(
          context, widget.inspection.idSolicitud, 2, null);
      if (!response.error) {
        fp.showAlert(
            content: AlertSuccess(
          message: response.message,
          messageButton: 'Aceptar',
          onPress: () => {_continueInspection(true)},
        ));
      } else {
        fp.showAlert(
            content: AlertGenericError(
          message: response.message,
          messageButton: 'Aceptar',
          //onPress: () => {_continueInspection(true)},
        ));
      }
    }
  }

  _redirectListInspection(bool value) {
    if (value) {
      Navigator.pushReplacement(
          context,
          PageTransition(
              child: const ReviewRequestPage(),
              type: PageTransitionType.leftToRightWithFade));
    }
  }

  _openModalReject(bool value) {
    if (value) {
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if (fp.offline) {
        Helper.snackBar(
            context: context,
            message:
                'No tienes conexión a internet, porque estas en modo offline.',
            colorSnackBar: Colors.red);
      } else {
        fp.showAlert(
            content: AlertRejectInspection(
                onRejectFlag: _redirectListInspection,
                idSolicitud: widget.inspection.idSolicitud));
      }
    }
  }

  _continueInspection(bool value) async {
    Helper.dismissKeyboard(context);
    //bool connection = await Helper.checkConnection();
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    bool offline = fp.getOffline();
    if (offline) {
      debugPrint('no tiene internet');
      final response = await OfflineStorage().getCataloguePersonalInformation();
      if (response != null) {
        navigationContinueInspection(
            dataClientForm: response, inspection: widget.inspection);
      }
    } else {
      debugPrint('tiene internet');
      debugPrint('---- Cargando datos cliente formulario ---');
      final response = await RequestReviewService()
          .getDataClientForm(context, widget.inspection.idBroker);
      // inspect(response.data);
      if (response.data != null) {
        navigationContinueInspection(
            dataClientForm: response.data!, inspection: widget.inspection);
      }
    }
  }

  navigationContinueInspection(
      {required DataClientForm dataClientForm, required Lista inspection}) {
    return Navigator.pushReplacement(
        context,
        PageTransition(
            child: InspectionContinueFormPage(
                inspection: inspection, dataClientForm: dataClientForm),
            type: PageTransitionType.leftToRightWithFade));
  }

  _rescheduleInspection(bool value) async {
    debugPrint('----Reaendando Inspección-----');
    final fp = Provider.of<FunctionalProvider>(context, listen: false);

    if (!fp.offline) {
      // final response = GeneralResponse(error: false, message: 'error');
      // Helper.logger.e('response: ${jsonEncode(response)}');
      final response = await RequestReviewService()
          .getRescheduleConfirmation(context, widget.inspection.idSolicitud);

      if (response.error) {
        fp.showAlert(
            content: AlertGenericError(
          message: response.message,
          messageButton: 'Cerrar',
        ));
      } else {
        bool exists = ReviewRequestPage.listInspectionCoordinated
            .any((e) => e.idSolicitud == widget.inspection.idSolicitud);

        if (exists) {
          ReviewRequestPage.listInspectionCoordinated.removeWhere(
              (e) => e.idSolicitud == widget.inspection.idSolicitud);
          await OfflineStorage().setListInspectionOffline(
              ReviewRequestPage.listInspectionCoordinated);
          Helper.logger.w('existe inspeccion en storage? : $exists');
        } else {
          Helper.logger.w('existe inspeccion en storage? : $exists');
        }

        fp.showAlert(
            content: AlertSuccess(
                message: response.message,
                messageButton: 'Aceptar',
                onPress: () => _redirectListInspection(true)));
      }
    } else {
      Helper.snackBar(
          context: context,
          message:
              'No tienes conexión a internet, porque estas en modo offline.',
          colorSnackBar: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;
    final inspection = widget.inspection;
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
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  color: Colors.white,
                  width: double.infinity,
                  child: Text(
                      inspection.nombres != ''
                          ? inspection.nombres + ' ' + inspection.apellidos
                          : inspection.razonSocial,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppConfig.appThemeConfig.secondaryColor,
                          fontWeight: FontWeight.bold)),
                ),
                _detailInspection(inspection),
                ButtonsInspectionWidget(
                  stateInspection: inspection.idEstadoInspeccion,
                  onEditFlag: _updatedEditFlag,
                  onContinueFlag: _continueInspection,
                  onAcceptFlag: _acceptInspection,
                  onRejectFlag: _openModalReject,
                  onRescheduleFlag: _rescheduleInspection,
                  onPress: () {
                    final fp =
                        Provider.of<FunctionalProvider>(context, listen: false);
                    if (!fp.offline) {
                      UserDataStorage()
                          .setIdInspection(inspection.idSolicitud.toString());
                    }
                    // fp.setIdInspection(inspection.idSolicitud.toString());
                    // Helper.logger.w(Helper.idInspection);
                    // Helper.logger.w(Helper.getIdInspection);
                  },
                )
              ],
            ),
            bottomNavigationBar: const BottomInfo()),
        const AlertModal(),
        const NotificationModal()
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  Flexible _detailInspection(Lista inspection) {
    // final CameraPosition _currentPosition = CameraPosition(
    //   target: LatLng(
    //       double.parse(inspection.latitud), double.parse(inspection.longitud)),
    //   zoom: 15,
    // );

    final marker = Marker(
      markerId: const MarkerId('place_name'),
      position: LatLng(
          double.parse(inspection.latitud), double.parse(inspection.longitud)),
    );

    markers[MarkerId(inspection.direccion)] = marker;

    return Flexible(
        child: ListView(
      shrinkWrap: true,
      children: <Widget>[
        DetailInspectionWidget(
          inspection: inspection,
        ),
        //? GOOGLE MAPS
        // FadeInRight(
        //     duration: const Duration(milliseconds: 600),
        //     child: SizedBox(
        //       height: 300,
        //       child: GoogleMapWiget(
        //         initialPosition: _currentPosition,
        //         markers: markers.values.toSet(),
        //       ),
        //     ))
      ],
    ));
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
            Navigator.pushReplacement(
                context,
                PageTransition(
                    child: const ReviewRequestPage(),
                    type: PageTransitionType.leftToRightWithFade));
          },
          icon: const Icon(Icons.arrow_back_ios_new)),
    );
  }
}
