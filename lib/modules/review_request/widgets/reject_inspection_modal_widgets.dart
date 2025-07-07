part of 'review_request_widgets.dart';

class AlertRejectInspection extends StatelessWidget {
  final int idSolicitud;
  final ValueChanged<bool> onRejectFlag;
  const AlertRejectInspection(
      {Key? key, required this.idSolicitud, required this.onRejectFlag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    String observacion = '';
    return Column(
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
                  'Ingrese el motivo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppConfig.appThemeConfig.primaryColor),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldWidget(
                  textInputType: TextInputType.text,
                  maxLines: 5,
                  onChanged: (e) {
                    //Helper.logger.e('observacion: $e');
                    observacion = e;
                  },
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(5000),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9.,\sñÑáéíóúÁÉÍÓÚüÜ\-]+'))
                  ],
                ),
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
                      width: 20,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                        onPressed: () async {
                          fp.dismissAlert();
                          final response = await RequestReviewService().updateStateInspection(context, idSolicitud, 3, observacion);

                          if(!response.error){
                            bool exists = ReviewRequestPage.listInspectionCoordinated.any((e) => e.idSolicitud == idSolicitud);

                            if(exists){
                              ReviewRequestPage.listInspectionCoordinated.removeWhere((e) => e.idSolicitud == idSolicitud);
                              await OfflineStorage().setListInspectionOffline(ReviewRequestPage.listInspectionCoordinated);
                              Helper.logger.w('existe inspeccion en storage? : $exists');
                            }else{
                              Helper.logger.w('existe inspeccion en storage? : $exists');
                            }

                            fp.showAlert(
                              content: AlertSuccess(
                                message: response.message,
                                messageButton: 'Aceptar',
                                onPress: () {
                                onRejectFlag(true);
                                },
                              )
                            );
                          }else{
                             fp.showAlert(content: AlertGenericError(
                              message: response.message,
                              messageButton: 'Cerrar',));
                          }
                          //var message = await _rejectInspection(context, idSolicitud, observacion);
                        },
                        child: const Text("CONTINUAR"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Future<String> _rejectInspection(BuildContext context, int idSolicitud, String observacion) async {
//   debugPrint('---- rechazando inspección ----');
//   final response = await RequestReviewService().updateStateInspection(context, idSolicitud, 3, observacion);
//   return response.message;
// }
