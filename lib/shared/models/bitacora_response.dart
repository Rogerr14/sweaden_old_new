// To parse this JSON data, do
//
//     final listBitacoraResponse = listBitacoraResponseFromJson(jsonString);

import 'dart:convert';

List<ListBitacoraResponse> listBitacoraResponseFromJson(String str) =>
    List<ListBitacoraResponse>.from(
        json.decode(str).map((x) => ListBitacoraResponse.fromJson(x)));

String listBitacoraResponseToJson(List<ListBitacoraResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListBitacoraResponse {
  final int idBitacora;
  final int idSolicitud;
  final int idUsuario;
  final String detalle;
  final DateTime fecha;
  final String nombre;

  ListBitacoraResponse({
    required this.idBitacora,
    required this.idSolicitud,
    required this.idUsuario,
    required this.detalle,
    required this.fecha,
    required this.nombre,
  });

  factory ListBitacoraResponse.fromJson(Map<String, dynamic> json) =>
      ListBitacoraResponse(
        idBitacora: json["id_bitacora"],
        idSolicitud: json["id_solicitud"],
        idUsuario: json["id_usuario"],
        detalle: json["detalle"],
        fecha: DateTime.parse(json["fecha"]),
        nombre: json["nombre"],
      );

  Map<String, dynamic> toJson() => {
        "id_bitacora": idBitacora,
        "id_solicitud": idSolicitud,
        "id_usuario": idUsuario,
        "detalle": detalle,
        "fecha": fecha.toIso8601String(),
        "nombre": nombre,
      };
}
