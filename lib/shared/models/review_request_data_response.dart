import 'dart:convert';

List<ListInspectionDataResponse> listInspectionDataResponseFromJson(
        String str) =>
    List<ListInspectionDataResponse>.from(
        json.decode(str).map((x) => ListInspectionDataResponse.fromJson(x)));

String listInspectionDataResponseToJson(
        List<ListInspectionDataResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListInspectionDataResponse {
  ListInspectionDataResponse({
    required this.idEstadoInspeccion,
    required this.estadoInspeccion,
    required this.lista,
  });

  int idEstadoInspeccion;
  String estadoInspeccion;
  List<Lista> lista;

  factory ListInspectionDataResponse.fromJson(Map<String, dynamic> json) =>
      ListInspectionDataResponse(
        idEstadoInspeccion: json["idEstadoInspeccion"],
        estadoInspeccion: json["estadoInspeccion"],
        lista: List<Lista>.from(json["lista"].map((x) => Lista.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "idEstadoInspeccion": idEstadoInspeccion,
        "estadoInspeccion": estadoInspeccion,
        "lista": List<dynamic>.from(lista.map((x) => x.toJson())),
      };
}

class Lista {
  Lista({
    required this.idSolicitud,
    required this.idTipoSolicitud,
    required this.tipoSolicitud,
    required this.idBroker,
    required this.nombreBroker,
    required this.idRamo,
    required this.ramo,
    required this.duracionVideo,
    required this.idAgencia,
    required this.agencia,
    required this.valorAsegurado,
    required this.idTipoIdentificacion,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    required this.razonSocial,
    required this.fechaInspeccionCompleta,
    required this.fechaInspeccion,
    required this.horaInspeccion,
    required this.telefono,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.idUsuarioCreacion,
    required this.usuarioCreacion,
    required this.idEstadoInspeccion,
    required this.idTipoFlujo,
    required this.tipoFlujo,
    required this.idProducto,
    this.polizaMadre,
    this.reasignado,
    this.numPoliza,
    required this.pdfAdjunto,
    required this.idProceso,
    required this.proceso,
    required this.codEjecutivo,
    required this.nombreEjecutivo,
    required this.datosVehiculo,
    required this.ejecutivo,
    required this.hayBitacoras,
    required this.mostrarBotonRegistrarBitacora,
    required this.creacionOffline,
    required this.idSolicitudReal,
    required this.haveAdvertObservation
    //this.viewDownloadInspection = true,
  });

  int idSolicitud;
  int idTipoSolicitud;
  String tipoSolicitud;
  String idBroker;
  String nombreBroker;
  String idRamo;
  String ramo;
  int duracionVideo;
  String idAgencia;
  String agencia;
  String valorAsegurado;
  int idTipoIdentificacion;
  String identificacion;
  String nombres;
  String apellidos;
  String razonSocial;
  DateTime? fechaInspeccionCompleta;
  DateTime? fechaInspeccion;
  String? horaInspeccion;
  String telefono;
  String direccion;
  String latitud;
  String longitud;
  int idUsuarioCreacion;
  String usuarioCreacion;
  int idEstadoInspeccion;
  int idTipoFlujo;
  String tipoFlujo;
  String idProducto;
  String? polizaMadre;
  dynamic reasignado;
  dynamic numPoliza;
  String pdfAdjunto;
  int idProceso;
  String proceso;
  String codEjecutivo;
  String nombreEjecutivo;
  DatosVehiculo datosVehiculo;
  Ejecutivo ejecutivo;
  int hayBitacoras;
  int mostrarBotonRegistrarBitacora;
  bool creacionOffline;
  int idSolicitudReal;
  int haveAdvertObservation;
  //bool? viewDownloadInspection;

  factory Lista.fromJson(Map<String, dynamic> json) => Lista(
        idSolicitud: json["idSolicitud"],
        idTipoSolicitud: json["id_tipo_solicitud"],
        tipoSolicitud: json["tipoSolicitud"],
        idBroker: json["idBroker"],
        nombreBroker: json["nombreBroker"],
        idRamo: json["idRamo"],
        ramo: json["ramo"],
        duracionVideo: json["duracionVideo"] ?? 120,
        idAgencia: json["idAgencia"],
        agencia: json["agencia"],
        valorAsegurado: json["valorAsegurado"],
        idTipoIdentificacion: json["idTipoIdentificacion"],
        identificacion: json["identificacion"],
        nombres: json["nombres"]??"",
        apellidos: json["apellidos"]??"",
        razonSocial: json["razonSocial"],
        fechaInspeccionCompleta:(json["fechaInspeccionCompleta"]!=null)?
            DateTime.parse(json["fechaInspeccionCompleta"]):null,
        fechaInspeccion:(json["fechaInspeccion"]!=null)? DateTime.parse(json["fechaInspeccion"]):null,
        horaInspeccion: json["horaInspeccion"],
        telefono: json["telefono"],
        direccion: json["direccion"],
        latitud: json["latitud"],
        longitud: json["longitud"],
        idUsuarioCreacion: json["idUsuarioCreacion"],
        usuarioCreacion: json["usuarioCreacion"],
        idEstadoInspeccion: json["idEstadoInspeccion"],
        idTipoFlujo: json["idTipoFlujo"],
        tipoFlujo: json["tipoFlujo"],
        idProducto: json["idProducto"],
        polizaMadre: (json["polizaMadre"] == null) ? null : json["polizaMadre"],
        reasignado: (json["reasignado"] == null) ? null : json["reasignado"],
        numPoliza: (json["num_poliza"] == null) ? null : json["num_poliza"],
        pdfAdjunto: json["pdfAdjunto"],
        idProceso: json["idProceso"],
        proceso: json["proceso"],
        codEjecutivo: json["cod_ejecutivo"],
        nombreEjecutivo: json["nombreEjecutivo"],
        datosVehiculo: DatosVehiculo.fromJson(json["datosVehiculo"]),
        ejecutivo: Ejecutivo.fromJson(json["ejecutivo"]),
        hayBitacoras: json["hayBitacoras"],
        mostrarBotonRegistrarBitacora: json["mostrarBotonRegistrarBitacora"],
        creacionOffline: json["creacionOffline"] ?? false,
        idSolicitudReal: json["idSolicitudReal"] ?? 0,
        haveAdvertObservation : json["haveAdvertObservation"]
        //viewDownloadInspection : json["viewDownloadInspection"] ?? true,
      );

  Map<String, dynamic> toJson() => {
        "idSolicitud": idSolicitud,
        "id_tipo_solicitud": idTipoSolicitud,
        "tipoSolicitud": tipoSolicitud,
        "idBroker": idBroker,
        "nombreBroker": nombreBroker,
        "idRamo": idRamo,
        "ramo": ramo,
        "duracionVideo" : duracionVideo,
        "idAgencia": idAgencia,
        "agencia": agencia,
        "valorAsegurado": valorAsegurado,
        "idTipoIdentificacion": idTipoIdentificacion,
        "identificacion": identificacion,
        "nombres": nombres,
        "apellidos": apellidos,
        "razonSocial": razonSocial,
        "fechaInspeccionCompleta": fechaInspeccionCompleta?.toIso8601String(),
        "fechaInspeccion":(fechaInspeccion!=null)
            ?"${fechaInspeccion!.year.toString().padLeft(4, '0')}-${fechaInspeccion!.month.toString().padLeft(2, '0')}-${fechaInspeccion!.day.toString().padLeft(2, '0')}"
            :null,
        "horaInspeccion": horaInspeccion,
        "telefono": telefono,
        "direccion": direccion,
        "latitud": latitud,
        "longitud": longitud,
        "idUsuarioCreacion": idUsuarioCreacion,
        "usuarioCreacion": usuarioCreacion,
        "idEstadoInspeccion": idEstadoInspeccion,
        "idTipoFlujo": idTipoFlujo,
        "tipoFlujo": tipoFlujo,
        "idProducto": idProducto,
        "polizaMadre": (polizaMadre == null) ? null : polizaMadre,
        "reasignado": (reasignado == null) ? null : reasignado,
        "num_poliza": (numPoliza == null) ? null : numPoliza,
        "pdfAdjunto": pdfAdjunto,
        "idProceso": idProceso,
        "proceso": proceso,
        "cod_ejecutivo": codEjecutivo,
        "nombreEjecutivo": nombreEjecutivo,
        "datosVehiculo": datosVehiculo.toJson(),
        "ejecutivo": ejecutivo.toJson(),
        "hayBitacoras": hayBitacoras,
        "mostrarBotonRegistrarBitacora": mostrarBotonRegistrarBitacora,
        "creacionOffline": creacionOffline,
        "idSolicitudReal":idSolicitudReal,
        "haveAdvertObservation": haveAdvertObservation
        //"viewDownloadInspection": viewDownloadInspection
      };

  void then(Set<void> Function(dynamic value) param0) {}
}

class DatosVehiculo {
  DatosVehiculo({
    required this.id,
    required this.anio,
    required this.placa,
    required this.deducible,
    required this.sumaAsegurada,
  });

  int id;
  String anio;
  String placa;
  String deducible;
  String sumaAsegurada;

  factory DatosVehiculo.fromJson(Map<String, dynamic> json) => DatosVehiculo(
        id: json["id"],
        anio: json["anio"],
        placa: json["placa"],
        deducible: json["deducible"] ?? '0',
        sumaAsegurada: json["sumaAsegurada"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "anio": anio,
        "placa": placa,
        "deducible": deducible,
        "sumaAsegurada": sumaAsegurada,
      };
}

class Ejecutivo {
  Ejecutivo({
    this.mail,
    required this.nombre,
    this.usuario,
    required this.codEjecutivo,
  });

  String? mail;
  String nombre;
  String? usuario;
  String codEjecutivo;

  factory Ejecutivo.fromJson(Map<String, dynamic> json) => Ejecutivo(
        mail: (json["mail"] == null) ? null : json["mail"],
        nombre: json["nombre"],
        usuario: (json["usuario"] == null) ? null : json["usuario"],
        codEjecutivo: json["cod_ejecutivo"],
      );

  Map<String, dynamic> toJson() => {
        "mail": (mail == null) ? null : mail,
        "nombre": nombre,
        "usuario": (usuario == null) ? null : usuario,
        "cod_ejecutivo": codEjecutivo,
      };
}
