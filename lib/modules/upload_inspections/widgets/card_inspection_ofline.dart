import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/helper/request_offline.dart';
import 'package:sweaden_old_new_version/modules/upload_inspections/widgets/text_rich_widget.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_status_response.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/widgets/rotating_icon_widget.dart';
import 'package:provider/provider.dart';

class CardTitleInspectionOffline extends StatefulWidget {

  final Lista information;
  final void Function()? onPressed;
  final List<InspectionStatusResponse> inspecctionStatus;
  // final bool isloading;
  // final Color? colorLoading;
  // final List<bool> error;
  const CardTitleInspectionOffline({super.key, required this.information, required this.onPressed, required this.inspecctionStatus, 
  //this.isloading = false, this.colorLoading, required this.error
  });

  @override
  State<CardTitleInspectionOffline> createState() => _CardTitleInspectionOfflineState();
}
class _CardTitleInspectionOfflineState extends State<CardTitleInspectionOffline> {

  @override
  Widget build(BuildContext context) {

    //Helper.logger.w("lista de inspecciones a cargar: ${jsonEncode(widget.inspecctionStatus)}");

     bool loadingInspection  = context.watch<FunctionalProvider>().loadingInspection;
     //log(jsonEncode(widget.information));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppConfig.appThemeConfig.primaryColor),
      ),
      child: ListTile(
        title: (widget.information.nombres.isNotEmpty || widget.information.apellidos.isNotEmpty) 
              ? Text('${widget.information.nombres.toUpperCase()} ${widget.information.apellidos.toUpperCase()}', style: TextStyle( color: AppConfig.appThemeConfig.secondaryColor, fontWeight: FontWeight.bold))
              : Text(widget.information.razonSocial.toUpperCase(), style: TextStyle( color: AppConfig.appThemeConfig.secondaryColor, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextRichWidget(title: 'Placa', subtitle: widget.information.datosVehiculo.placa, colorSubtitle: Colors.red),
            const TextRichWidget(title: 'Proceso', subtitle: 'Proc sin Emisión'),
            TextRichWidget(title: 'Dirección', subtitle: widget.information.direccion),
            TextRichWidget(title: 'N° Teléfono', subtitle: widget.information.telefono)
          ],
        ),
        trailing: Material(
          shape: const CircleBorder(),
          color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
          //child: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white)
         child: IconButton(
            disabledColor: Colors.white,
            splashRadius: 23,
            icon: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white),
           // color: Colors.white,
            onPressed: !loadingInspection ? widget.onPressed : null,
          ),
        ),
        // trailing: Material(
        //   color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
        //   shape: const CircleBorder(),
        //   child: InkWell(
        //   borderRadius: BorderRadius.circular(20),
        //   onTap: !loadingInspection ? widget.onPressed : null,
        //     child: Container(
        //       width: 50, 
        //       height: 45, 
        //       decoration: BoxDecoration(
        //         //color: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getColor(widget.inspecctionStatus) : AppConfig.appThemeConfig.secondaryColor,
        //         shape: BoxShape.circle
        //       ),
        //       child: widget.inspecctionStatus.map((e) => e.idSolicitud).contains(widget.information.idSolicitud) ? getIcon(widget.inspecctionStatus) : const Icon(Icons.upload_rounded, color: Colors.white),
        //       ),
        //   ),
        // ),
      ) 
    );
}
  Color getColor(List<InspectionStatusResponse> inspecctionStatus) {
    final index = inspecctionStatus.indexWhere((item) => item.idSolicitud == widget.information.idSolicitud);
    if (index != -1) {
      if(widget.inspecctionStatus[index].status == InspectionStatus.loading.toString()){
        return AppConfig.appThemeConfig.secondaryColor;
      }else if(widget.inspecctionStatus[index].status == InspectionStatus.error.toString()){
        return Colors.red;
      }else{
        return Colors.blue;
      }
    }else{
      return Colors.white;
    }
  }
  Widget getIcon(List<InspectionStatusResponse> inspecctionStatus){
     final index = inspecctionStatus.indexWhere((item) => item.idSolicitud == widget.information.idSolicitud);
     if(widget.inspecctionStatus[index].status == InspectionStatus.loading.toString()){
      return const RotatingIcon(icon: Icon(Icons.sync, color: Colors.white));
     }else if(widget.inspecctionStatus[index].status == InspectionStatus.error.toString()){
        return const Icon(Icons.close_rounded, color: Colors.white);
     }
     else{
      return const Icon(Icons.abc, color: Colors.white);
     }
  }
}