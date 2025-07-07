// To parse this JSON data, do
//
//     final deductible = deductibleFromJson(jsonString);

import 'dart:convert';

List<Deductible> deductibleFromJson(String str) =>
    List<Deductible>.from(json.decode(str).map((x) => Deductible.fromJson(x)));

String deductibleToJson(List<Deductible> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Deductible {
  Deductible({
    required this.sumaasegRangoIn,
    required this.sumaasegRangoFin,
    required this.valDeducible,
    required this.descuento,
  });

  int sumaasegRangoIn;
  int sumaasegRangoFin;
  int valDeducible;
  double descuento;

  factory Deductible.fromJson(Map<String, dynamic> json) => Deductible(
        sumaasegRangoIn: json["sumaaseg_rango_in"],
        sumaasegRangoFin: json["sumaaseg_rango_fin"],
        valDeducible: json["val_deducible"],
        descuento: json["descuento"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "sumaaseg_rango_in": sumaasegRangoIn,
        "sumaaseg_rango_fin": sumaasegRangoFin,
        "val_deducible": valDeducible,
        "descuento": descuento,
      };
}
