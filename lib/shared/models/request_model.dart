
import 'dart:convert';

Request requestFromJson(String str) => Request.fromJson(json.decode(str));

String requestToJson(Request data) => json.encode(data.toJson());

class Request {
  Request({
    this.idSolicitudTemp,
    required this.opcion,
    this.dataSolicitud,
    this.idSolicitudServicio,
    this.statusSolicitudRegistrada,
    this.statusMultimediaRegistrada,
    this.statusInspeccionRegistrada,
    this.completedOffline,
    this.messageInspectionRegistrada,
    this.mensageErrorSolicitudRegistrar,
    this.mensageErrorMultimedia,
    this.mensageErrorRegistrarInspection,
    this.uuidRequest
    // this.solicitudRegistrada,
    // this.multimediaRegistrada,
    // this.inspeccionRegistrada,
  });

  int? idSolicitudTemp;
  int? idSolicitudServicio;
  String opcion;
  DataSolicitud? dataSolicitud;
  int? statusSolicitudRegistrada;
  int? statusMultimediaRegistrada;
  int? statusInspeccionRegistrada;
  bool? completedOffline;
  String? messageInspectionRegistrada;
  String? mensageErrorSolicitudRegistrar;
  String? mensageErrorMultimedia;
  String? mensageErrorRegistrarInspection;
  String? uuidRequest;
  // bool? solicitudRegistrada;
  // bool? multimediaRegistrada;
  // bool? inspeccionRegistrada;

  factory Request.fromJson(Map<String, dynamic> json) => Request(
        idSolicitudTemp: json["idSolicitudTemp"] ?? 0,
        opcion: json["opcion"],
        dataSolicitud: DataSolicitud?.fromJson(json["dataSolicitud"]),
        idSolicitudServicio: json["idSolicitudServicio"] ?? 0,
        statusSolicitudRegistrada: json["statusSolicitudRegistrada"] ?? 0,
        statusMultimediaRegistrada: json["statusMultimediaRegistrada"] ?? 0,
        statusInspeccionRegistrada: json["statusInspeccionRegistrada"] ?? 0,
        completedOffline: json["completedOffline"] ?? false,
        messageInspectionRegistrada: json["messageInspectionRegistrada"] ?? '',
        uuidRequest: json["uuidRequest"] ?? '',
        mensageErrorSolicitudRegistrar : json["mensageErrorSolicitudRegistrar"] ?? '',
        mensageErrorMultimedia : json["mensageErrorMultimedia"] ?? '',
        mensageErrorRegistrarInspection: json["mensageErrorRegistrarInspection"] ?? ''
        // solicitudRegistrada: json["solicitudRegistrada"] ?? false,
        // multimediaRegistrada: json["multimediaRegistrada"] ?? false,
        // inspeccionRegistrada: json["inspeccionRegistrada"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "idSolicitudTemp":idSolicitudTemp,
        "opcion": opcion,
        "dataSolicitud": dataSolicitud?.toJson(),
        "idSolicitudServicio":idSolicitudServicio,
        "statusSolicitudRegistrada": statusSolicitudRegistrada,
        "statusMultimediaRegistrada": statusMultimediaRegistrada,
        "statusInspeccionRegistrada": statusInspeccionRegistrada,
        "completedOffline": completedOffline,
        "messageInspectionRegistrada": messageInspectionRegistrada,
        "uuidRequest" : uuidRequest,
        "mensageErrorSolicitudRegistrar": mensageErrorSolicitudRegistrar,
        "mensageErrorMultimedia" : mensageErrorMultimedia,
        "mensageErrorRegistrarInspection": mensageErrorRegistrarInspection
        // "solicitudRegistrada": solicitudRegistrada,
        // "multimediaRegistrada": multimediaRegistrada,
        // "inspeccionRegistrada": inspeccionRegistrada,
      };
}

class DataSolicitud {
  DataSolicitud(
      {this.idTipoIdentificacion,
      this.identificacion,
      this.nombres,
      this.apellidos,
      this.razonSocial,
      this.telefono,
      this.direccion,
      this.idBroker,
      this.idRamo,
      this.idAgencia,
      this.idAgenciaInspeccion,
      this.idProducto,
      this.idProceso,
      this.nombreBroker,
      this.ramo,
      this.agencia,
      this.ejecutivo,
      this.producto,
      this.pdfAdjunto, 
      this.idTipoSolicitud,
      this.idTipoFlujo,
      this.datosVehiculo,
      this.latitud,
      this.longitud,
      this.fechaInspeccion,
      this.horaInspeccion,
      this.reasignado,
      this.idEstado,
      this.polizaMadre,
      this.correo1,
      this.correo2,
      this.idEstadoInspeccion,
      this.idInspector
      });

  String? idTipoIdentificacion;
  String? identificacion;
  String? nombres;
  String? apellidos;
  String? razonSocial;
  String? telefono;
  String? direccion;
  String? idBroker;
  String? idRamo;
  String? idAgencia;
  String? idAgenciaInspeccion;
  String? idProducto;
  String? idProceso;
  String? nombreBroker;
  String? ramo;
  String? agencia;
  Ejecutivo? ejecutivo;
  String? producto;
  String? pdfAdjunto;
  String? idTipoSolicitud;
  String? idTipoFlujo;
  DatosVehiculo? datosVehiculo;
  String? latitud;
  String? longitud;
  String? fechaInspeccion;
  String? horaInspeccion;
  String? reasignado;
  int? idEstado;
  String? polizaMadre;
  String? correo1;
  String? correo2;
  int? idEstadoInspeccion; // CAMPO NUEVO OFFLINE
  String? idInspector;

  factory DataSolicitud.fromJson(Map<String, dynamic> json) => DataSolicitud(
      idTipoIdentificacion: json["idTipoIdentificacion"],
      identificacion: json["identificacion"],
      nombres: json["nombres"],
      apellidos: json["apellidos"],
      razonSocial: json["razonSocial"],
      telefono: json["telefono"],
      direccion: json["direccion"],
      idBroker: json["idBroker"],
      idRamo: json["idRamo"],
      idAgencia: json["idAgencia"],
      idAgenciaInspeccion: json["idAgenciaInspeccion"],
      idProducto: json["idProducto"],
      pdfAdjunto: json["pdfAdjunto"],
      idProceso: json["idProceso"],
      nombreBroker: json["nombreBroker"],
      ramo: json["ramo"],
      agencia: json["agencia"],
      ejecutivo: (json["ejecutivo"] != null)
          ? Ejecutivo.fromJson(json["ejecutivo"])
          : null,
      producto: json["producto"],
      idTipoSolicitud: json["idTipoSolicitud"],
      idTipoFlujo: json["idTipoFlujo"],
      datosVehiculo: (json["datosVehiculo"] != null)
          ? DatosVehiculo.fromJson(json["datosVehiculo"])
          : null,
      latitud: json["latitud"],
      longitud: json["longitud"],
      fechaInspeccion: json["fechaInspeccion"],
      horaInspeccion: json["horaInspeccion"],
      reasignado: json["reasignado"],
      idEstado: json["idEstado"],
      polizaMadre: json["polizaMadre"],
      correo1: json["correo1"],
      correo2: json["correo2"],
      idEstadoInspeccion: json["idEstadoInspeccion"] ?? 1 ,// CAMPO NUEVO OFFLINE
      idInspector: json["idInspector"] ?? ''
      );

  Map<String, dynamic> toJson() => {
        "idTipoIdentificacion": idTipoIdentificacion,
        "identificacion": identificacion,
        "nombres": nombres,
        "apellidos": apellidos,
        "razonSocial": razonSocial,
        "telefono": telefono,
        "direccion": direccion,
        "idBroker": idBroker,
        "idRamo": idRamo,
        "idAgencia": idAgencia,
        "idAgenciaInspeccion": idAgenciaInspeccion,
        "idProducto": idProducto,
        "pdfAdjunto": pdfAdjunto,
        "idProceso": idProceso,
        "nombreBroker": nombreBroker,
        "ramo": ramo,
        "agencia": agencia,
        "ejecutivo": ejecutivo?.toJson(),
        "producto": producto,
        "idTipoSolicitud": idTipoSolicitud,
        "idTipoFlujo": idTipoFlujo,
        "datosVehiculo": datosVehiculo?.toJson(),
        "latitud": latitud,
        "longitud": longitud,
        "fechaInspeccion": fechaInspeccion,
        //"${fechaInspeccion?.year.toString().padLeft(4, '0')}-${fechaInspeccion?.month.toString().padLeft(2, '0')}-${fechaInspeccion?.day.toString().padLeft(2, '0')}",
        "horaInspeccion": horaInspeccion,
        "reasignado": reasignado,
        "idEstado": idEstado,
        "polizaMadre": polizaMadre,
        "correo1": correo1,
        "correo2": correo2,
        "idEstadoInspeccion":idEstadoInspeccion, // CAMPO NUEVO OFFLINE
        "idInspector":idInspector
      };
}

class DatosVehiculo {
  DatosVehiculo({
    this.anio,
    this.placa,
    this.deducible,
    this.sumaAsegurada,
  });

  String? anio;
  String? placa;
  String? deducible;
  String? sumaAsegurada;

  factory DatosVehiculo.fromJson(Map<String, dynamic> json) => DatosVehiculo(
        anio: json["anio"],
        placa: json["placa"],
        deducible: json["deducible"],
        sumaAsegurada: json["sumaAsegurada"],
      );

  Map<String, dynamic> toJson() => {
        "anio": anio,
        "placa": placa,
        "deducible": deducible,
        "sumaAsegurada": sumaAsegurada,
      };
}

class Ejecutivo {
  Ejecutivo({
    this.codEjecutivo,
    this.mail,
    this.nombre,
    this.usuario,
  });

  String? codEjecutivo;
  String? mail;
  String? nombre;
  String? usuario;

  factory Ejecutivo.fromJson(Map<String, dynamic> json) => Ejecutivo(
        codEjecutivo: json["cod_ejecutivo"],
        mail: json["mail"],
        nombre: json["nombre"],
        usuario: json["usuario"],
      );

  Map<String, dynamic> toJson() => {
        "cod_ejecutivo": codEjecutivo,
        "mail": mail,
        "nombre": nombre,
        "usuario": usuario,
      };
}
