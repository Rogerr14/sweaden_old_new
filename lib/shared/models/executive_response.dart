// To parse this JSON data, do
//
//     final executive = executiveFromJson(jsonString);

import 'dart:convert';

List<Executive> executiveFromJson(String str) =>
    List<Executive>.from(json.decode(str).map((x) => Executive.fromJson(x)));

String executiveToJson(List<Executive> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Executive {
  Executive({
    required this.codEjecutivo,
    required this.usuario,
    required this.nombre,
    required this.mail,
  });

  int codEjecutivo;
  String usuario;
  String nombre;
  String mail;

  factory Executive.fromJson(Map<String, dynamic> json) => Executive(
        codEjecutivo: json["cod_ejecutivo"],
        usuario: json["usuario"],
        nombre: json["nombre"],
        mail: json["mail"],
      );

  Map<String, dynamic> toJson() => {
        "cod_ejecutivo": codEjecutivo,
        "usuario": usuario,
        "nombre": nombre,
        "mail": mail,
      };
}
