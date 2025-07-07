// To parse this JSON data, do
//
//     final policy = policyFromJson(jsonString);

import 'dart:convert';

List<Policy> policyFromJson(String str) =>
    List<Policy>.from(json.decode(str).map((x) => Policy.fromJson(x)));

String policyToJson(List<Policy> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Policy {
  Policy({
    required this.codBroker,
    required this.ramo,
    required this.poliza,
    required this.descripcion,
  });

  String codBroker;
  String ramo;
  String poliza;
  String descripcion;

  factory Policy.fromJson(Map<String, dynamic> json) => Policy(
        codBroker: json["cod_broker"],
        ramo: json["ramo"],
        poliza: json["poliza"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "cod_broker": codBroker,
        "ramo": ramo,
        "poliza": poliza,
        "descripcion": descripcion,
      };
}
