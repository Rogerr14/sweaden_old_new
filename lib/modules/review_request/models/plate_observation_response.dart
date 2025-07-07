// To parse this JSON data, do
//
//     final plateObservationsResponse = plateObservationsResponseFromJson(jsonString);

import 'dart:convert';

List<PlateObservationsResponse> plateObservationsResponseFromJson(String str) => List<PlateObservationsResponse>.from(json.decode(str).map((x) => PlateObservationsResponse.fromJson(x)));

String plateObservationsResponseToJson(List<PlateObservationsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlateObservationsResponse {
    final String observaciones;
    final String observacionEmision;
    final DateTime fechaInspeccionReal;
    final String nombre;
    final String agenciaInspeccion;

    PlateObservationsResponse({
        required this.observaciones,
        required this.observacionEmision,
        required this.fechaInspeccionReal,
        required this.nombre,
        required this.agenciaInspeccion,
    });

    factory PlateObservationsResponse.fromJson(Map<String, dynamic> json) => PlateObservationsResponse(
        observaciones: json["observaciones"] ?? '',
        observacionEmision: json["observacionEmision"] ?? '',
        nombre: json["nombre"] ?? '',
        agenciaInspeccion: json["agenciaInspeccion"] ?? '',
        fechaInspeccionReal: DateTime.parse(json["fechaInspeccionReal"]),
    );

    Map<String, dynamic> toJson() => {
        "observaciones": observaciones,
        "observacionEmision": observacionEmision,
        "fechaInspeccionReal": fechaInspeccionReal.toIso8601String(),
        "agenciaInspeccion" : agenciaInspeccion,
        "nombre": nombre
    };
}
