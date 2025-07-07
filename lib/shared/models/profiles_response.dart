// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

List<Profile> profileFromJson(String str) =>
    List<Profile>.from(json.decode(str).map((x) => Profile.fromJson(x)));

String profileToJson(List<Profile> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Profile {
  Profile({
    required this.idTipoUsuario,
    required this.descripcion,
    required this.abreviatura,
  });

  int idTipoUsuario;
  String descripcion;
  String abreviatura;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        idTipoUsuario: json["id_tipo_usuario"],
        descripcion: json["descripcion"],
        abreviatura: json["abreviatura"],
      );

  Map<String, dynamic> toJson() => {
        "id_tipo_usuario": idTipoUsuario,
        "descripcion": descripcion,
        "abreviatura": abreviatura,
      };
}
