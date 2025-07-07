// To parse this JSON data, do
//
//     final invoiceResponse = invoiceResponseFromJson(jsonString);

import 'dart:convert';

InvoiceResponse invoiceResponseFromJson(String str) =>
    InvoiceResponse.fromJson(json.decode(str));

String invoiceResponseToJson(InvoiceResponse data) =>
    json.encode(data.toJson());

class InvoiceResponse {
  InvoiceResponse({
    required this.estado,
    this.mensajeError,
    required this.sumaAseg,
    required this.primaNeta,
    required this.impSuper,
    required this.impScc,
    required this.demision,
    required this.cargoSujetoIva,
    required this.iva,
    required this.cargoNosujetoIva,
    required this.primaTotal,
    this.coberturas,
  });

  bool estado;
  String? mensajeError;
  double sumaAseg;
  double primaNeta;
  double impSuper;
  double impScc;
  double demision;
  double cargoSujetoIva;
  double iva;
  double cargoNosujetoIva;
  double primaTotal;
  List<Cobertura>? coberturas;

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) =>
      InvoiceResponse(
        estado: json["estado"],
        mensajeError:
            (json["mensajeError"] != null) ? json["mensajeError"] : null,
        sumaAseg: json["suma_aseg"].toDouble(),
        primaNeta: json["prima_neta"].toDouble(),
        impSuper: json["imp_super"].toDouble(),
        impScc: json["imp_scc"].toDouble(),
        demision: json["demision"].toDouble(),
        cargoSujetoIva: json["cargo_sujeto_iva"].toDouble(),
        iva: json["iva"].toDouble(),
        cargoNosujetoIva: json["cargo_nosujeto_iva"].toDouble(),
        primaTotal: json["prima_total"].toDouble(),
        coberturas: (json["coberturas"] != null)
            ? List<Cobertura>.from(
                json["coberturas"].map((x) => Cobertura.fromJson(x)))
            : json["coberturas"],
      );

  Map<String, dynamic> toJson() => {
        "estado": estado,
        "mensajeError": mensajeError,
        "suma_aseg": sumaAseg,
        "prima_neta": primaNeta,
        "imp_super": impSuper,
        "imp_scc": impScc,
        "demision": demision,
        "cargo_sujeto_iva": cargoSujetoIva,
        "iva": iva,
        "cargo_nosujeto_iva": cargoNosujetoIva,
        "prima_total": primaTotal,
        "coberturas": (coberturas != null)
            ? List<dynamic>.from(coberturas!.map((x) => x.toJson()))
            : coberturas,
      };
}

class Cobertura {
  Cobertura({
    required this.cobertura,
    this.marIncl,
    this.capAseg,
    this.tasaPrima,
    this.primBas,
     this.codCobertura,
    this.valOcupant,
     this.descComercial,
     this.cubre,
     this.orden,
  });

  String cobertura;
  String? marIncl;
  double? capAseg;
  double? tasaPrima;
  double? primBas;
  String? codCobertura;
  int? valOcupant;
  String? descComercial;
  String? cubre;
  int? orden;

  factory Cobertura.fromJson(Map<String, dynamic> json) => Cobertura(
        cobertura: json["cobertura"],
        marIncl: (json["mar_incl"] != null) ? json["mar_incl"] : null,
        capAseg: (json["cap_aseg"] != null) ? json["cap_aseg"].toDouble() : null,
        tasaPrima:
            (json["tasa_prima"] != null) ? json["tasa_prima"].toDouble() : null,
        primBas:
            (json["prim_bas"] != null) ? json["prim_bas"].toDouble() : null,
        codCobertura: (json["cod_cobertura"]!=null)?json["cod_cobertura"]:null,
        valOcupant: (json["val_ocupant"] != null) ? json["val_ocupant"] : null,
        descComercial: (json["desc_comercial"]!=null)?json["desc_comercial"]:null,
        cubre: (json["cubre"]!=null)?json["cubre"]:null,
        orden: (json["orden"]!=null)?json["orden"]:null,
      );

  Map<String, dynamic> toJson() => {
        "cobertura": cobertura,
        "mar_incl": (marIncl == null) ? null : marIncl,
        "cap_aseg": (capAseg == null) ? null : capAseg,
        "tasa_prima": (tasaPrima == null) ? null : tasaPrima,
        "prim_bas": (primBas == null) ? null : primBas,
        "cod_cobertura": (codCobertura==null)?null:codCobertura,
        "val_ocupant": (valOcupant == null) ? null : valOcupant,
        "desc_comercial": (descComercial==null)?null:descComercial,
        "cubre": (cubre==null)?null:cubre,
        "orden": (orden==null)?null:orden,
      };
}
