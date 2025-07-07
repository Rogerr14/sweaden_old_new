// To parse this JSON data, do
//
//     final mediaInfo = mediaInfoFromJson(jsonString);

import 'dart:convert';

List<MediaInfo> mediaInfoFromJson(String str) =>
    List<MediaInfo>.from(json.decode(str).map((x) => MediaInfo.fromJson(x)));

String mediaInfoToJson(List<MediaInfo> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MediaInfo {
  MediaInfo({
    required this.idTipoArchivo,
    required this.tipoArchivo,
    required this.detalle,
    required this.formato,
    required this.obligatorio,
  });

  int idTipoArchivo;
  String tipoArchivo;
  String detalle;
  String formato;
  String obligatorio;

  factory MediaInfo.fromJson(Map<String, dynamic> json) => MediaInfo(
        idTipoArchivo: json["idTipoArchivo"],
        tipoArchivo: json["tipoArchivo"],
        detalle: json["detalle"],
        formato: json["formato"],
        obligatorio: json["obligatorio"],
      );

  Map<String, dynamic> toJson() => {
        "idTipoArchivo": idTipoArchivo,
        "tipoArchivo": tipoArchivo,
        "detalle": detalle,
        "formato": formato,
        "obligatorio": obligatorio,
      };
}
