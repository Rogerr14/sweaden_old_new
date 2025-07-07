// To parse this JSON data, do
//
//     final product = productFromJson(jsonString);

import 'dart:convert';

List<Product> productFromJson(String str) =>
    List<Product>.from(json.decode(str).map((x) => Product.fromJson(x)));

String productToJson(List<Product> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Product {
  Product({
    required this.codRamo,
    required this.ramo,
    required this.codAgencia,
    required this.agencia,
    required this.codProducto,
    required this.descripcion,
    required this.ejecCuenta,
    this.codTextoFrente,
    this.codTextoCondpart,
    this.cobertura,
    required this.tasa,
    this.tipoProducto,
    required this.primaMinima,
    required this.esProdCotizador,
    required this.varEdad,
    required this.varAgencia,
    required this.varDeducible,
    required this.coberturas,
  });

  String codRamo;
  String ramo;
  String codAgencia;
  String agencia;
  String codProducto;
  String descripcion;
  int ejecCuenta;
  dynamic codTextoFrente;
  dynamic codTextoCondpart;
  dynamic cobertura;
  int tasa;
  dynamic tipoProducto;
  int primaMinima;
  String esProdCotizador;
  bool varEdad;
  bool varAgencia;
  bool varDeducible;
  List<Cobertura> coberturas;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        codRamo: json["cod_ramo"],
        ramo: json["ramo"],
        codAgencia: json["cod_agencia"],
        agencia: json["agencia"],
        codProducto: json["cod_producto"],
        descripcion: json["descripcion"],
        ejecCuenta: json["ejec_cuenta"],
        codTextoFrente: json["cod_texto_frente"],
        codTextoCondpart: json["cod_texto_condpart"],
        cobertura: json["cobertura"],
        tasa: json["tasa"],
        tipoProducto: json["tipo_producto"],
        primaMinima: json["prima_minima"],
        esProdCotizador: json["es_prod_cotizador"],
        varEdad: json["var_edad"],
        varAgencia: json["var_agencia"],
        varDeducible: json["var_deducible"],
        coberturas: List<Cobertura>.from(
            json["coberturas"].map((x) => Cobertura.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cod_ramo": codRamo,
        "ramo": ramo,
        "cod_agencia": codAgencia,
        "agencia": agencia,
        "cod_producto": codProducto,
        "descripcion": descripcion,
        "ejec_cuenta": ejecCuenta,
        "cod_texto_frente": codTextoFrente,
        "cod_texto_condpart": codTextoCondpart,
        "cobertura": cobertura,
        "tasa": tasa,
        "tipo_producto": tipoProducto,
        "prima_minima": primaMinima,
        "es_prod_cotizador": esProdCotizador,
        "var_edad": varEdad,
        "var_agencia": varAgencia,
        "var_deducible": varDeducible,
        "coberturas": List<dynamic>.from(coberturas.map((x) => x.toJson())),
      };
}

class Cobertura {
  Cobertura({
    required this.accesorio,
    required this.descripcionCobertura,
    this.marIncl,
    this.capAseg,
    this.primBas,
    this.detalle,
    this.tasaPrima,
    this.cobertura,
    this.asignaSumasegCasco,
    this.asignaValxocupant,
    this.valorOcupant,
    required this.descComercial,
    required this.orden,
    required this.cubre,
    required this.esExterna,
    required this.codGasto,
    this.numAnalitico,
    this.valorPagProv,
  });

  String accesorio;
  String descripcionCobertura;
  MarIncl? marIncl;
  int? capAseg;
  dynamic primBas;
  String? detalle;
  double? tasaPrima;
  Cubre? cobertura;
  Asigna? asignaSumasegCasco;
  Asigna? asignaValxocupant;
  int? valorOcupant;
  String descComercial;
  int orden;
  Cubre cubre;
  bool esExterna;
  int codGasto;
  dynamic numAnalitico;
  dynamic valorPagProv;

  factory Cobertura.fromJson(Map<String, dynamic> json) => Cobertura(
        accesorio: json["accesorio"],
        descripcionCobertura: json["descripcion_cobertura"],
        marIncl: json["mar_incl"] == null
            ? null
            : marInclValues.map[json["mar_incl"]],
        capAseg: json["cap_aseg"],
        primBas: json["prim_bas"],
        detalle: json["detalle"],
        tasaPrima: json["tasa_prima"] = json["tasa_prima"]?.toDouble(),
        cobertura: json["cobertura"] == null
            ? null
            : cubreValues.map[json["cobertura"]],
        asignaSumasegCasco: json["asigna_sumaseg_casco"] == null
            ? null
            : asignaValues.map[json["asigna_sumaseg_casco"]],
        asignaValxocupant: json["asigna_valxocupant"] == null
            ? null
            : asignaValues.map[json["asigna_valxocupant"]],
        valorOcupant: json["valor_ocupant"],
        descComercial: json["desc_comercial"],
        orden: json["orden"],
        cubre: cubreValues.map[json["cubre"]]!,
        esExterna: json["es_externa"],
        codGasto: json["cod_gasto"],
        numAnalitico: json["num_analitico"],
        valorPagProv: json["valor_pag_prov"],
      );

  Map<String, dynamic> toJson() => {
        "accesorio": accesorio,
        "descripcion_cobertura": descripcionCobertura,
        "mar_incl": marIncl == null ? null : marInclValues.reverse[marIncl],
        "cap_aseg": capAseg,
        "prim_bas": primBas,
        "detalle": detalle,
        "tasa_prima": tasaPrima,
        "cobertura": cobertura == null ? null : cubreValues.reverse[cobertura],
        "asigna_sumaseg_casco": asignaSumasegCasco == null
            ? null
            : asignaValues.reverse[asignaSumasegCasco],
        "asigna_valxocupant": asignaValxocupant == null
            ? null
            : asignaValues.reverse[asignaValxocupant],
        "valor_ocupant": valorOcupant,
        "desc_comercial": descComercial,
        "orden": orden,
        "cubre": cubreValues.reverse[cubre],
        "es_externa": esExterna,
        "cod_gasto": codGasto,
        "num_analitico": numAnalitico,
        "valor_pag_prov": valorPagProv,
      };
}

enum Asigna { S }

final asignaValues = EnumValues({"S": Asigna.S});

enum Cubre { C }

final cubreValues = EnumValues({"C": Cubre.C});

enum MarIncl { X }

final marInclValues = EnumValues({"X": MarIncl.X});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    (reverseMap == null)
        ? reverseMap = map.map((k, v) => MapEntry(v, k))
        : reverseMap;

    // reverseMap?.map((v, k) => MapEntry(v, k));
    return reverseMap!;
  }
}
