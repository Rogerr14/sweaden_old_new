// To parse this JSON data, do
//
//     final authResponse = authResponseFromJson(jsonString);

import 'dart:convert';

AuthResponse authResponseFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

String authResponseToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  AuthResponse({
    required this.token,
    required this.informacion,
     this.anticipacionExpiraToken,
     this.expiraToken,
    required this.tiempoUbicacion,
    required this.vigenciaDiasCatalogo,
    required this.tiempoActualizarUbicacion,
    required this.kmRecorrido,
    required this.tiempoActualizarDistancia,
  });

  String token;
  Informacion informacion;
  int? anticipacionExpiraToken;
  DateTime? expiraToken;
  String tiempoUbicacion;
  int vigenciaDiasCatalogo;
  int tiempoActualizarUbicacion;
  int kmRecorrido;
  int tiempoActualizarDistancia;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json["token"],
        informacion: Informacion.fromJson(json["informacion"]),
        anticipacionExpiraToken: json["anticipacionExpiraToken"],
        expiraToken: (json["expiraToken"]!=null)?DateTime.parse(json["expiraToken"]):json["expiraToken"],
        tiempoUbicacion: json["tiempoUbicacion"],
        vigenciaDiasCatalogo: json["vigenciaDiasCatalogo"],
        tiempoActualizarUbicacion: json["tiempoActualizarUbicacion"],
        kmRecorrido: json["kmRecorrido"],
        tiempoActualizarDistancia: json["tiempoActualizarDistancia"],

      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "informacion": informacion.toJson(),
        "anticipacionExpiraToken": anticipacionExpiraToken,
        "expiraToken": (expiraToken!=null)?expiraToken!.toIso8601String():null,
        "tiempoUbicacion": tiempoUbicacion,
        "vigenciaDiasCatalogo": vigenciaDiasCatalogo,
        "tiempoActualizarUbicacion": tiempoActualizarUbicacion,
        "kmRecorrido": kmRecorrido,
        "tiempoActualizarDistancia": tiempoActualizarDistancia,
      };
}

class Informacion {
  Informacion({
    required this.codigo,
    required this.idUsuario,
    required this.idTipoUsuario,
    required this.tipoUsuario,
    required this.nombre,
    this.idBroker,
    required this.permiteInspeccion,
    this.tipoEmi,
    this.agencia,
    required this.usuario
  });

  String codigo;
  int idUsuario;
  int idTipoUsuario;
  String tipoUsuario;
  String nombre;
  String? idBroker;
  bool permiteInspeccion;
  String? tipoEmi;
  String? agencia;
  String usuario;

  factory Informacion.fromJson(Map<String, dynamic> json) => Informacion(
        codigo: json["codigo"],
        idUsuario: json["id_usuario"],
        idTipoUsuario: json["id_tipo_usuario"],
        tipoUsuario: json["tipo_usuario"],
        nombre: json["nombre"],
        idBroker: json["id_broker"],
        permiteInspeccion: json["permite_inspeccion"],
        tipoEmi: json["tipo_emi"],
        agencia: json["agencia"],
        usuario: json["usuario"]
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "id_usuario": idUsuario,
        "id_tipo_usuario": idTipoUsuario,
        "tipo_usuario": tipoUsuario,
        "nombre": nombre,
        "id_broker": idBroker,
        "permite_inspeccion": permiteInspeccion,
        "tipo_emi": tipoEmi,
        "agencia": agencia,
        "usuario": usuario
      };
}
