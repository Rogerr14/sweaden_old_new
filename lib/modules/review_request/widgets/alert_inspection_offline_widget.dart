// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:sweaden_old_new_version/envs/app_config.dart';
// import 'package:sweaden_old_new_version/modules/review_request/pages/request_review.dart';
// import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/services/media_service.dart';
// import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
// import 'package:sweaden_old_new_version/modules/upload_inspections/helper/request_offline.dart';
// import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';
// import 'package:sweaden_old_new_version/shared/models/inspection_status_response.dart';
// import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
// import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
// import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
// import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
// import 'package:sweaden_old_new_version/shared/secured_storage/offline_data_storage.dart';
// import 'package:sweaden_old_new_version/shared/widgets/rotating_icon_widget.dart';
// import 'package:provider/provider.dart';
// import '../../../envs/generic/app_theme_config.dart';
// import 'package:http_parser/http_parser.dart';

// class AlertInspectionOfflineWidget extends StatefulWidget {
//   final List<Lista> inspectionOffline;
//   final void Function() uploadInspections;

//   const AlertInspectionOfflineWidget({super.key, required this.inspectionOffline, required this.uploadInspections});

//   @override
//   State<AlertInspectionOfflineWidget> createState() => _AlertInspectionOfflineWidgetState();
// }

// class _AlertInspectionOfflineWidgetState extends State<AlertInspectionOfflineWidget> {

//   List<InspectionStatusResponse> inspecctionStatus = [];
 
//   // List<Widget> listInspectionOffline() {
//   //   return widget.inspectionOffline
//   //   .where((valid) => valid.creacionOffline == false)
//   //   .map((elemento) {
//   //     return Visibility(
//   //       //visible: !elemento.creacionOffline,
//   //       child: Padding(
//   //         padding: const EdgeInsets.only(bottom: 5, left: 8, right: 8),
//   //         child: CardTitleInspectionOffline(
//   //           inspecctionStatus: inspecctionStatus,
//   //           information: elemento,
//   //           onPressed: () async {
//   //             int pendingCount = widget.inspectionOffline.where((e) => e.creacionOffline == false).length;
//   //             final fp = Provider.of<FunctionalProvider>(context, listen: false);
           
//   //             inspecctionStatus.any((solicitud) => solicitud.idSolicitud == elemento.idSolicitud) ?  updateInspectionStatus(elemento.idSolicitud, InspectionStatus.loading) : inspecctionStatus.add(InspectionStatusResponse(idSolicitud: elemento.idSolicitud, status: InspectionStatus.loading.toString()));
//   //             final continueInspection = await InspectionStorage().getDataInspection(elemento.idSolicitud.toString());
        
//   //             if(continueInspection != null){
//   //               final SaveInspection saveInspection = await Helper.getDataSave(continueInspection: continueInspection, inspection: elemento);
//   //               final response = await Helper.finishedInspecction(requiredRemoveDataInspection: false, saveInspection: saveInspection, continueInspection: continueInspection, context: context, idRequest: elemento.idSolicitud, showLoading: false, showAlertError: false);
//   //               if(!response.error){
//   //                  bool ok = await loadMediaData(list: elemento, fp: fp);
//   //                   if(ok){
//   //                     await InspectionStorage().removeDataInspection(elemento.idSolicitud.toString());
//   //                      await Future.delayed(const Duration(seconds: 1), () async {
//   //                      ReviewRequestPage.listInspectionFinishedOffline.removeWhere((e) => e.idSolicitud == elemento.idSolicitud);
//   //                      await OfflineStorage().saveInspectionFinishedOffline(ReviewRequestPage.listInspectionFinishedOffline);
//   //                        if (elemento.creacionOffline == false) {
//   //                                   pendingCount--;
//   //                                 }
//   //                       setState(() {});
//   //                     });
//   //                   }
                   
//   //                 //widget.inspectionOffline.isEmpty ? dismissAlertService(fp: fp) : null; //REVISARRR
//   //                 //widget.inspectionOffline.map((e) => e.creacionOffline == false).isEmpty ? dismissAlertService(fp: fp) : null;
//   //                  if (pendingCount <= 0) {
//   //                           dismissAlertService(fp: fp);
//   //                         }
      
//   //               }else{
//   //                 updateInspectionStatus(elemento.idSolicitud, InspectionStatus.error);
//   //               }
//   //             }else{
//   //             }
//   //           },
//   //         ),
//   //       ),
//   //     );
//   //   }).toList();
//   // }

//   Future<bool> loadMediaData({required Lista list, required FunctionalProvider fp}) async {
//     try {
//       fp.setLoadingInspection(true);
//       final dataMedia = await MediaDataStorage().getMediaData(list.idSolicitud);
//       //log(jsonEncode(dataMedia));
//        //final List<MediaResponse> mediaNotUploaded = [];
//        List<bool> uploaded = [];
       
//       //await MediaDataStorage().removeMediaData(widget.idRequest);
//       if(dataMedia != null){
//         for (var item in dataMedia) {
//             if (item.status != 'UPLOADED' && item.status != 'NO_MEDIA') {
//               debugPrint('Archivo a reenviar: ${item.type} - ${item.idArchiveType} - ${item.status}');
//               final response = await MediaService().uploadMedia(context: context, idRequest: list.idSolicitud,
//                                 idArchiveType: item.idArchiveType,
//                                 identification: await HelperRequestOffline.getDataInspectionStorage(idSoliciutd: list.idSolicitud.toString()),
//                                 mediaType: item.type == 'image' ? MediaType('image', 'jpg') : MediaType('video', 'mp4'),
//                                 mediaPhoto: (item.type == 'image') ? Uint8List.fromList(item.data!) : null,
//                                 mediaVideo:  (item.type == 'video') ? File(item.path!) : null,
//                                 showAlertError : false,
//               );

//               if(!response.error){
//                // mediaNotUploaded.add(MediaResponse(idSolicitud: list.idSolicitud, idArchiveType: item.idArchiveType, status: Helper.statusMedia["2"].toString()));
//                 Helper.logger.w('response; ${jsonEncode(response)}');
//                 uploaded.add(true);
//                 //await MediaDataStorage().removeMediaData(list.idSolicitud);
//               }else{
//                 Helper.logger.w('response; ${jsonEncode(response)}');
//               }
              
//             }
//           }
//           fp.setLoadingInspection(false);

//           //DESCOMENTAR
//           if(uploaded.length == dataMedia.where((e) => e.status != 'UPLOADED' && e.status != 'NO_MEDIA').toList().length){
//             await MediaDataStorage().removeMediaData(list.idSolicitud);
//             Helper.logger.e('entroo todo es igual');
//           }
//       }

//       Helper.logger.w('uploaded: ${jsonEncode(uploaded)}');

//       return true;
//     } catch (e) {
//       return true; 
//     }
//   }

//   dismissAlertService({required FunctionalProvider fp}) {
//     fp.dismissAlert();
//     widget.uploadInspections();
//   }

//   @override
//   Widget build(BuildContext context) {
//     //final size = MediaQuery.of(context).size;
//     final fp = Provider.of<FunctionalProvider>(context, listen: false);
//     bool loadingInspection  = context.watch<FunctionalProvider>().loadingInspection;

//     //log(jsonEncode({"inspecciones descargadas: ${widget.inspectionOffline}"}));
//     //log(jsonEncode({'descargadas': (widget.inspectionOffline)}));

//     return Material(
//       type: MaterialType.transparency,
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _title(),
//             subTitle(),
//             const SizedBox(height: 20),
//             // SizedBox(
//             //   height: widget.inspectionOffline.where((element) => element.creacionOffline == false).toList().length > 5
//             //       ? size.height * 0.6
//             //       : size.height * (0.09 + (widget.inspectionOffline.where((element) => element.creacionOffline == false).toList().length / 10)),
//             //   child: SingleChildScrollView(
//             //     child: Column(children: listInspectionOffline()),
//             //   ),
//             // ),
//             Padding(
//               padding: const EdgeInsets.only(left: 15, right: 15, bottom: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                  _button(
//                     nameButton: 'Ahora no',
//                     colorButton: AppConfig.appThemeConfig.secondaryColor,
//                     onPressed: !loadingInspection ? ()  {
//                       dismissAlertService(fp: fp);
//                       // fp.dismissAlert();
//                       // widget.uploadInspections();
//                     } : null
//                   ),
//                   const SizedBox(width: 10),
//                   _button(
//                     nameButton: 'Cargar todo',
//                     colorButton: AppConfig.appThemeConfig.primaryColor,
//                     onPressed: !loadingInspection ?
//                       () async {
                        
//                         List<Lista> listaFilter = ReviewRequestPage.listInspectionFinishedOffline.where((element) =>  element.creacionOffline == false).toList();
//                         List<Lista> listInspectionOfflineCopy = List.from(listaFilter);

//                         int pendingCount = listInspectionOfflineCopy.where((e) => e.creacionOffline == false).length;

                        
//        //idInspectionLoading = listInspectionOfflineCopy.map((e) => e.idSolicitud).toList();
    
//                         //fp.setLoadingInspection(true);
    
//                         for (var e in listInspectionOfflineCopy) {
                          
//                           // log('for: ${jsonEncode(e.creacionOffline)}');
//                           // return;
//                           inspecctionStatus.any((element) => element.idSolicitud == e.idSolicitud) ?  updateInspectionStatus(e.idSolicitud, InspectionStatus.loading) : inspecctionStatus.add(InspectionStatusResponse(idSolicitud: e.idSolicitud, status: InspectionStatus.loading.toString()));
//                           final continueInspection = await InspectionStorage().getDataInspection(e.idSolicitud.toString());
    
//                           if(continueInspection != null){
//                             final SaveInspection saveInspection = await Helper.getDataSave(continueInspection: continueInspection, inspection: e);
    
//                             final response = await Helper.finishedInspecction(requiredRemoveDataInspection: false, saveInspection: saveInspection, continueInspection: continueInspection, context: context, idRequest: e.idSolicitud, showLoading: false, showAlertError: false);
//                             if(!response.error){
//                               //Helper.logger.w("response: ${jsonEncode(response)}");
//                                bool ok = await loadMediaData(list: e, fp: fp);

//                                if(ok){
//                                 await InspectionStorage().removeDataInspection(e.idSolicitud.toString());
//                                 ReviewRequestPage.listInspectionFinishedOffline.removeWhere((data) => data.idSolicitud == e.idSolicitud);
//                                 await OfflineStorage().saveInspectionFinishedOffline(ReviewRequestPage.listInspectionFinishedOffline);
//                                 // idInspectionLoading.removeWhere((id) => id == e.idSolicitud);
//                                 // error.add(false);
//                                 if (e.creacionOffline == false) {
//                                   pendingCount--;
//                                 }
                              
//                                 setState(() {});
//                                }
                              
                              
//                             }else{
//                               updateInspectionStatus(e.idSolicitud, InspectionStatus.error);
//                               Helper.logger.w("error: ${jsonEncode(response)}");
//                             }

//                           }
//                           //dismissAlertService(fp: fp);
//                           //!ReviewRequestPage.listInspectionFinishedOffline.every((e) => e.creacionOffline == false) ? dismissAlertService(fp: fp) : null;
//                           //ReviewRequestPage.listInspectionFinishedOffline.isEmpty ? dismissAlertService(fp: fp) : null;
                          
//                         }

//                         // Verificar si ya no hay más registros pendientes para cerrar la alerta
//                         if (pendingCount <= 0) {
//                           dismissAlertService(fp: fp);
//                         }

//                         //dismissAlertService(fp: fp);
//                       }
//                     : null
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void updateInspectionStatus(int idSolicitud, InspectionStatus newStatus) {
//   final index = inspecctionStatus.indexWhere((item) => item.idSolicitud == idSolicitud);

//   if (index != -1) {
//     setState(() {
//       final updatedList = inspecctionStatus.toList();
//       updatedList[index].status = newStatus.toString();
//       inspecctionStatus = updatedList;
//     });
//   }
// }

//   Expanded _button({required String nameButton, required Color colorButton, required void Function()? onPressed}) {
//     return Expanded(
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//             primary: colorButton),
//         onPressed: onPressed,
//         child: Text(nameButton),
//       ),
//     );
//   }

//   Padding subTitle() {
//     return const Padding(
//       padding: EdgeInsets.only(top: 10, left: 20, right: 20),
//       child: Text(
//         'Estimado usuario usted cuenta con inspecciones finalizadas en modo offline, si desea cargar todas las solicitudes presione Cargar todo, caso contrario presione ahora no',
//         textAlign: TextAlign.center,
//         style: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 15),
//       ),
//     );
//   }

//   Padding _title() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 20, bottom: 5),
//       child: Text(
//         'Inspecciones Finalizadas Offline',
//         style: TextStyle(
//           color: AppThemeConfig().secondaryColor,
//           fontSize: 15,
//         ),
//       ),
//     );
//   }
// }


// // class CardTitleInspectionOffline extends StatefulWidget {

// //   final Lista information;
// //   final void Function()? onPressed;
// //   final List<InspectionStatusResponse> inspecctionStatus;
// //   // final bool isloading;
// //   // final Color? colorLoading;
// //   // final List<bool> error;
// //   const CardTitleInspectionOffline({super.key, required this.information, required this.onPressed, required this.inspecctionStatus, 
// //   //this.isloading = false, this.colorLoading, required this.error
// //   });

// //   @override
// //   State<CardTitleInspectionOffline> createState() => _CardTitleInspectionOfflineState();
// // }
// // class _CardTitleInspectionOfflineState extends State<CardTitleInspectionOffline> {

// //   @override
// //   Widget build(BuildContext context) {

// //     //Helper.logger.w("lista de inspecciones a cargar: ${jsonEncode(widget.inspecctionStatus)}");

// //      bool loadingInspection  = context.watch<FunctionalProvider>().loadingInspection;
// //      log(jsonEncode(widget.information));

// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: AppConfig.appThemeConfig.primaryColor),
// //       ),
// //       child: ListTile(
// //         title: Text("Placa: ${widget.information.datosVehiculo.placa}"),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text("Identificacion: ${widget.information.identificacion}"),
// //             if(widget.information.nombres.isNotEmpty || widget.information.apellidos.isNotEmpty)
// //             Text("Cliente: ${widget.information.nombres} ${widget.information.apellidos}")
// //             else
// //             Text("Cliente: ${widget.information.razonSocial}")
// //           ],
// //         ),
// //         trailing: Material(
// //           shape: const CircleBorder(),
// //           color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
// //           //child: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white)
// //          child: IconButton(
// //             disabledColor: Colors.white,
// //             splashRadius: 23,
// //             icon: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white),
// //            // color: Colors.white,
// //             onPressed: !loadingInspection ? widget.onPressed : null,
// //           ),
// //         ),
// //         // trailing: Material(
// //         //   color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
// //         //   shape: const CircleBorder(),
// //         //   child: InkWell(
// //         //   borderRadius: BorderRadius.circular(20),
// //         //   onTap: !loadingInspection ? widget.onPressed : null,
// //         //     child: Container(
// //         //       width: 50, 
// //         //       height: 45, 
// //         //       decoration: BoxDecoration(
// //         //         //color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
// //         //         shape: BoxShape.circle
// //         //       ),
// //         //       child: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white),
// //         //       ),
// //         //   ),
// //         // ),
// //       ) 
// //     );
// // }
// //   Color getColor(List<InspectionStatusResponse> inspecctionStatus) {
// //     final index = inspecctionStatus.indexWhere((item) => item.idSolicitud == widget.information.idSolicitud);
// //     if (index != -1) {
// //       if(widget.inspecctionStatus[index].status == InspectionStatus.loading.toString()){
// //         return AppConfig.appThemeConfig.secondaryColor;
// //       }else if(widget.inspecctionStatus[index].status == InspectionStatus.error.toString()){
// //         return Colors.red;
// //       }else{
// //         return Colors.blue;
// //       }
// //     }else{
// //       return Colors.white;
// //     }
// //   }
// //   Widget getIcon(List<InspectionStatusResponse> inspecctionStatus){
// //      final index = inspecctionStatus.indexWhere((item) => item.idSolicitud == widget.information.idSolicitud);
// //      if(widget.inspecctionStatus[index].status == InspectionStatus.loading.toString()){
// //       return const RotatingIcon(icon: Icon(Icons.sync, color: Colors.white));
// //      }else if(widget.inspecctionStatus[index].status == InspectionStatus.error.toString()){
// //         return const Icon(Icons.close_rounded, color: Colors.white);
// //      }
// //      else{
// //       return const Icon(Icons.abc, color: Colors.white);
// //      }
// //   }
// // }