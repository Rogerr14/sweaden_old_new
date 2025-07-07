// To parse this JSON data, do
//
//     final inspectionDataResponse = inspectionDataResponseFromJson(jsonString);

import 'dart:convert';

InspectionDataResponse inspectionDataResponseFromJson(String str) =>
    InspectionDataResponse.fromJson(json.decode(str));

String inspectionDataResponseToJson(InspectionDataResponse data) =>
    json.encode(data.toJson());

class InspectionDataResponse {
  InspectionDataResponse({
    this.dateCreation,
    required this.listaIdentif,
    required this.listabroker,
    required this.listaramos,
    required this.listaagencias,
    required this.listasolicitud,
    required this.listaproceso,
    required this.configuracionInicial,
  });

  String? dateCreation;
  List<ListaIdentifElement> listaIdentif;
  List<ListabrokerElement> listabroker;
  List<ListaRamoElement> listaramos;
  List<Listaagencia> listaagencias;
  List<ListaIdentifElement> listasolicitud;
  List<ListaIdentifElement> listaproceso;
  ConfiguracionInicial configuracionInicial;

  factory InspectionDataResponse.fromJson(Map<String, dynamic> json) =>
      InspectionDataResponse(
        dateCreation: json["dateCreation"] ?? '',
        listaIdentif: List<ListaIdentifElement>.from(
            json["listaIdentif"].map((x) => ListaIdentifElement.fromJson(x))),
        listabroker: List<ListabrokerElement>.from(
            json["listabroker"].map((x) => ListabrokerElement.fromJson(x))),
        listaramos: List<ListaRamoElement>.from(
            json["listaramos"].map((x) => ListaRamoElement.fromJson(x))),
        listaagencias: List<Listaagencia>.from(
            json["listaagencias"].map((x) => Listaagencia.fromJson(x))),
        listasolicitud: List<ListaIdentifElement>.from(
            json["listasolicitud"].map((x) => ListaIdentifElement.fromJson(x))),
        listaproceso: List<ListaIdentifElement>.from(
            json["listaproceso"].map((x) => ListaIdentifElement.fromJson(x))),
        configuracionInicial:
            ConfiguracionInicial.fromJson(json["configuracionInicial"]),
      );

  Map<String, dynamic> toJson() => {
    "dateCreation": dateCreation,
        "listaIdentif": List<dynamic>.from(listaIdentif.map((x) => x.toJson())),
        "listabroker": List<dynamic>.from(listabroker.map((x) => x.toJson())),
        "listaramos": List<dynamic>.from(listaramos.map((x) => x.toJson())),
        "listaagencias":
            List<dynamic>.from(listaagencias.map((x) => x.toJson())),
        "listasolicitud":
            List<dynamic>.from(listasolicitud.map((x) => x.toJson())),
        "listaproceso": List<dynamic>.from(listaproceso.map((x) => x.toJson())),
        "configuracionInicial": configuracionInicial.toJson(),
      };
}

class ConfiguracionInicial {
  ConfiguracionInicial({
    required this.antiguedadPermitida,
    required this.futuroVhPermitido,
    required this.descriptivoVehiculo,
    required this.anioActual,
  });

  String antiguedadPermitida;
  int  futuroVhPermitido;
  String descriptivoVehiculo;
  String anioActual;

  factory ConfiguracionInicial.fromJson(Map<String, dynamic> json) =>
      ConfiguracionInicial(
        antiguedadPermitida: json["antiguedadPermitida"],
        futuroVhPermitido: json["futuroVhPermitido"],
        descriptivoVehiculo: json["descriptivoVehiculo"],
        anioActual: json["anioActual"],
      );

  Map<String, dynamic> toJson() => {
        "antiguedadPermitida": antiguedadPermitida,
        "futuroVhPermitido": futuroVhPermitido,
        "descriptivoVehiculo": descriptivoVehiculo,
        "anioActual": anioActual,
      };
}

class ListaIdentifElement {
  ListaIdentifElement({
    required this.codigo,
    this.idEstadoSweaden,
    required this.descripcion,
  });

  int codigo;
  int? idEstadoSweaden;
  String descripcion;

  factory ListaIdentifElement.fromJson(Map<String, dynamic> json) =>
      ListaIdentifElement(
        codigo: json["codigo"],
        idEstadoSweaden: json["idEstadoSweaden"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "idEstadoSweaden": idEstadoSweaden,
        "descripcion": descripcion,
      };
}

class Listaagencia {
  Listaagencia({
    required this.codigo,
    required this.descripcion,
  });

  String codigo;
  String descripcion;

  factory Listaagencia.fromJson(Map<String, dynamic> json) => Listaagencia(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListabrokerElement {
  ListabrokerElement({
    required this.codigo,
    this.descripcion,
    this.estado,
  });

  String codigo;
  String? descripcion;
  dynamic estado;

  factory ListabrokerElement.fromJson(Map<String, dynamic> json) =>
      ListabrokerElement(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        estado: json["estado"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "estado": estado,
      };
}

class ListaRamoElement {
  ListaRamoElement({
    required this.codigo,
    this.descripcion,
    this.anioAntiguedad,
    this.estado,
    this.duracionVideo
  });

  String codigo;
  String? descripcion;
  int? anioAntiguedad;
  dynamic estado;
  int? duracionVideo;

  factory ListaRamoElement.fromJson(Map<String, dynamic> json) =>
      ListaRamoElement(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        anioAntiguedad : json["anio_antiguedad"] ?? 0,
        estado: json["estado"],
        duracionVideo : json["duracion_video"] ?? 120
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "anio_antiguedad":anioAntiguedad ,
        "estado": estado,
        "duracion_video": duracionVideo
      };
}

