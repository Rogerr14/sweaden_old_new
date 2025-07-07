import 'dart:convert';

DataClientForm dataClientFromJson(String str) =>
    DataClientForm.fromJson(json.decode(str));

String dataClientFormToJson(DataClientForm data) => json.encode(data.toJson());

class DataClientForm {
  DataClientForm({
    this.dateCreation,
    required this.listaGenero,
    required this.listaPais,
    required this.listaEstadoCivil,
    required this.listaProvincia,
    required this.listaActividadEconomica,
    required this.listaProducto,
    required this.listaRamo,
    required this.listaFPagos,
  });
  String? dateCreation;
  List<ListaGeneral> listaGenero;
  List<ListaGeneral> listaPais;
  List<ListaEstadoCivil> listaEstadoCivil;
  List<ListaProvincia> listaProvincia;
  List<ListaGeneral> listaActividadEconomica;
  List<ListaProducto> listaProducto;
  List<ListaRamo>? listaRamo;
  List<ListaGeneral> listaFPagos;

  factory DataClientForm.fromJson(Map<String, dynamic> json) => DataClientForm(
    dateCreation: json["dateCreation"] ?? '',
        listaGenero: List<ListaGeneral>.from(
            json["listaGenero"].map((x) => ListaGeneral.fromJson(x))),
        listaPais: List<ListaGeneral>.from(
            json["listaPais"].map((x) => ListaGeneral.fromJson(x))),
        listaEstadoCivil: List<ListaEstadoCivil>.from(
            json["listaEstadoCivil"].map((x) => ListaEstadoCivil.fromJson(x))),
        listaProvincia: List<ListaProvincia>.from(
            json["listaProvincia"].map((x) => ListaProvincia.fromJson(x))),
        listaActividadEconomica: List<ListaGeneral>.from(
            json["listaActividadEconomica"]
                .map((x) => ListaGeneral.fromJson(x))),
        listaProducto: List<ListaProducto>.from(
            json["listaProducto"].map((x) => ListaProducto.fromJson(x))),
        listaRamo: json["listaRamo"] != null
            ? List<ListaRamo>.from(
                json["listaRamo"].map((x) => ListaRamo.fromJson(x)))
            : null,
        listaFPagos: List<ListaGeneral>.from(
            json["listaFPagos"].map((x) => ListaGeneral.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "dateCreation": dateCreation,
        "listaGenero": List<dynamic>.from(listaGenero.map((x) => x.toJson())),
        "listaPais": List<dynamic>.from(listaPais.map((x) => x.toJson())),
        "listaEstadoCivil":
            List<dynamic>.from(listaEstadoCivil.map((x) => x.toJson())),
        "listaProvincia":
            List<dynamic>.from(listaProvincia.map((x) => x.toJson())),
        "listaActividadEconomica":
            List<dynamic>.from(listaActividadEconomica.map((x) => x.toJson())),
        "listaProducto":
            List<dynamic>.from(listaProducto.map((x) => x.toJson())),
        "listaRamo": listaRamo != null
            ? List<dynamic>.from(listaRamo!.map((x) => x.toJson()))
            : null,
        "listaFPagos": List<dynamic>.from(listaFPagos.map((x) => x.toJson())),
      };
}

class ListaGeneral {
  ListaGeneral({
    required this.codigo,
    required this.descripcion,
  });

  String codigo;
  String descripcion;

  factory ListaGeneral.fromJson(Map<String, dynamic> json) => ListaGeneral(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListaEstadoCivil {
  ListaEstadoCivil({
    required this.codigo,
    required this.descripcion,
  });

  int codigo;
  String descripcion;

  factory ListaEstadoCivil.fromJson(Map<String, dynamic> json) =>
      ListaEstadoCivil(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListaProducto {
  ListaProducto({
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
  double tasa;
  dynamic tipoProducto;
  int primaMinima;
  String esProdCotizador;
  bool varEdad;
  bool varAgencia;
  bool varDeducible;
  List<Cobertura> coberturas;

  factory ListaProducto.fromJson(Map<String, dynamic> json) => ListaProducto(
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
        tasa: double.tryParse(json["tasa"].toString()) ?? 0.0,
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
    required this.tasaPrima,
    this.cobertura,
    this.asignaSumasegCasco,
    this.asignaValxocupant,
    this.valorOcupant,
    required this.descComercial,
    required this.orden,
    required this.cubre,
    this.esExterna,
    required this.codGasto,
    this.numAnalitico,
    this.valorPagProv,
  });

  String accesorio;
  String descripcionCobertura;
  String? marIncl;
  int? capAseg;
  dynamic primBas;
  String? detalle;
  double? tasaPrima;
  String? cobertura;
  String? asignaSumasegCasco;
  String? asignaValxocupant;
  int? valorOcupant;
  String descComercial;
  int orden;
  String? cubre;
  bool? esExterna;
  int codGasto;
  dynamic numAnalitico;
  dynamic valorPagProv;

  factory Cobertura.fromJson(Map<String, dynamic> json) => Cobertura(
        accesorio: json["accesorio"],
        descripcionCobertura: json["descripcion_cobertura"],
        marIncl: json["mar_incl"],
        capAseg: json["cap_aseg"],
        primBas: json["prim_bas"],
        detalle: json["detalle"],
        tasaPrima: json["tasa_prima"] != null
            ? double.parse(json["tasa_prima"].toString())
            : null,
        cobertura: json["cobertura"],
        asignaSumasegCasco: json["asigna_sumaseg_casco"],
        asignaValxocupant: json["asigna_valxocupant"],
        valorOcupant: json["valor_ocupant"],
        descComercial: json["desc_comercial"],
        orden: json["orden"],
        cubre: json["cubre"],
        esExterna: json["es_externa"],
        codGasto: json["cod_gasto"],
        numAnalitico: json["num_analitico"],
        valorPagProv: json["valor_pag_prov"],
      );

  Map<String, dynamic> toJson() => {
        "accesorio": accesorio,
        "descripcion_cobertura": descripcionCobertura,
        "mar_incl": marIncl,
        "cap_aseg": capAseg,
        "prim_bas": primBas,
        "detalle": detalle,
        "tasa_prima": tasaPrima,
        "cobertura": cobertura,
        "asigna_sumaseg_casco": asignaSumasegCasco,
        "asigna_valxocupant": asignaValxocupant,
        "valor_ocupant": valorOcupant,
        "desc_comercial": descComercial,
        "orden": orden,
        "cubre": cubre,
        "es_externa": esExterna,
        "cod_gasto": codGasto,
        "num_analitico": numAnalitico,
        "valor_pag_prov": valorPagProv,
      };
}

class ListaProvincia {
  ListaProvincia({
    required this.codigo,
    required this.descripcion,
    required this.idPais,
    required this.listaLocalidad,
  });

  String codigo;
  String descripcion;
  String idPais;
  List<ListaLocalidad> listaLocalidad;

  factory ListaProvincia.fromJson(Map<String, dynamic> json) => ListaProvincia(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        idPais: json["idPais"],
        listaLocalidad: List<ListaLocalidad>.from(
            json["listaLocalidad"].map((x) => ListaLocalidad.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "idPais": idPais,
        "listaLocalidad":
            List<dynamic>.from(listaLocalidad.map((x) => x.toJson())),
      };
}

class ListaLocalidad {
  ListaLocalidad({
    required this.codigo,
    required this.descripcion,
    required this.idProvincia,
  });

  String codigo;
  String descripcion;
  String idProvincia;

  factory ListaLocalidad.fromJson(Map<String, dynamic> json) => ListaLocalidad(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        idProvincia: json["idProvincia"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "idProvincia": idProvincia,
      };
}

class ListaRamo {
  ListaRamo({
    required this.codigo,
    required this.descripcion,
    this.estado,
    this.anioAntiguedad
  });

  String codigo;
  String descripcion;
  dynamic estado;
  int? anioAntiguedad;

  factory ListaRamo.fromJson(Map<String, dynamic> json) => ListaRamo(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
        estado: json["estado"],
        anioAntiguedad: json["anio_antiguedad"] ?? ''
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
        "estado": estado,
        "anio_antiguedad": anioAntiguedad
      };
}
