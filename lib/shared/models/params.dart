
class ParamsLoadMedia {
  final int idRequestReal;
  final int idSolicitudTemp;

  ParamsLoadMedia({required this.idRequestReal, required this.idSolicitudTemp});
}

class ParamsLoadRequest {
  final bool? errorMediaLoad;
  final bool? showLoading;
  final int idRequestReal;
  final int idSolicitudTemp;
  final ParamsRequest paramsRequest;

  ParamsLoadRequest({this.showLoading = true, required this.idRequestReal, required this.idSolicitudTemp, required this.paramsRequest, this.errorMediaLoad = false});
}

class ParamsRequest {
    final int idSolicitud;
    final String idBroker;
    final String idAgencia;
    final String idProceso;
    final String codEjecutivo;
    final String idTipoFlujo;
    final String? polizaMadre;

    ParamsRequest({
        required this.idSolicitud,
        required this.idBroker,
        required this.idAgencia,
        required this.idProceso,
        required this.codEjecutivo,
        required this.idTipoFlujo,
        this.polizaMadre,
    });

}












//CODIGO PARA SERIALIZAR PARAMETROS...
// import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
// import 'dart:convert';

// class ParamsLoadMedia {
//   final int idRequest;

//   ParamsLoadMedia({required this.idRequest});

//   // Método para convertir el objeto en un mapa
//   Map<String, dynamic> toJson() => {
//     'idRequest': idRequest,
//   };

//   // Método para crear un objeto desde un mapa
//   factory ParamsLoadMedia.fromJson(Map<String, dynamic> json) {
//     return ParamsLoadMedia(
//       idRequest: json['idRequest'],
//     );
//   }
// }