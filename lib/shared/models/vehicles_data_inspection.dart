import 'dart:convert';

VehicleDataInspection vehicleDataInspectionFromJson(String str) =>
    VehicleDataInspection.fromJson(json.decode(str));

String vehicleDataInspectionToJson(VehicleDataInspection data) =>
    json.encode(data.toJson());

class VehicleDataInspection {
  VehicleDataInspection({
    required this.listaMarca,
    required this.listaPaisOrigen,
    required this.listaUso,
    required this.listaColor,
    required this.listaTipoV,
    this.date
  });

  String? date;
  List<ListaMarca> listaMarca;
  List<ListaPaisO> listaPaisOrigen;
  List<ListaUso> listaUso;
  List<ListaColor> listaColor;
  List<ListaTipoV> listaTipoV;
  

  factory VehicleDataInspection.fromJson(Map<String, dynamic> json) =>
      VehicleDataInspection(
        date: json["date"] ?? '',
        listaMarca: List<ListaMarca>.from(
            json["listaMarca"].map((x) => ListaMarca.fromJson(x))),
        listaPaisOrigen: List<ListaPaisO>.from(
            json["listaPaisOrigen"].map((x) => ListaPaisO.fromJson(x))),
        listaUso: List<ListaUso>.from(
            json["listaUso"].map((x) => ListaUso.fromJson(x))),
        listaColor: List<ListaColor>.from(
            json["listaColor"].map((x) => ListaColor.fromJson(x))),
        listaTipoV: List<ListaTipoV>.from(
            json["listaTipoV"].map((x) => ListaTipoV.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "date": date,
        "listaMarca": List<dynamic>.from(listaMarca.map((x) => x.toJson())),
        "listaPaisOrigen":
            List<dynamic>.from(listaPaisOrigen.map((x) => x.toJson())),
        "listaUso": List<dynamic>.from(listaUso.map((x) => x.toJson())),
        "listaColor": List<dynamic>.from(listaColor.map((x) => x.toJson())),
        "listaTipoV": List<dynamic>.from(listaTipoV.map((x) => x.toJson())),
      };
}

class ListaColor {
  ListaColor({
    required this.codigo,
    required this.descripcion,
  });

  int codigo;
  String descripcion;

  factory ListaColor.fromJson(Map<String, dynamic> json) => ListaColor(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListaMarca {
  ListaMarca({
    required this.codMarca,
    required this.descripcion,
  });

  String codMarca;
  String descripcion;

  factory ListaMarca.fromJson(Map<String, dynamic> json) => ListaMarca(
        codMarca: json["cod_marca"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "cod_marca": codMarca,
        "descripcion": descripcion,
      };
}

class ListaTipoV {
  ListaTipoV({
    required this.codigo,
    required this.descripcion,
  });

  String codigo;
  String descripcion;

  factory ListaTipoV.fromJson(Map<String, dynamic> json) => ListaTipoV(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListaUso {
  ListaUso({
    required this.codigo,
    required this.descripcion,
  });

  String codigo;
  String descripcion;

  factory ListaUso.fromJson(Map<String, dynamic> json) => ListaUso(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

class ListaPaisO {
  ListaPaisO({
    required this.codigo,
    required this.descripcion,
  });

  String codigo;
  String descripcion;

  factory ListaPaisO.fromJson(Map<String, dynamic> json) => ListaPaisO(
        codigo: json["codigo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "descripcion": descripcion,
      };
}

List<VehicleModel> vehicleModelFromJson(String str) => List<VehicleModel>.from(
    json.decode(str).map((x) => VehicleModel.fromJson(x)));

String vehicleModelToJson(List<VehicleModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VehicleModel {
  VehicleModel({
    required this.codMarca,
    required this.codModelo,
    required this.descripcion,
  });

  String codMarca;
  String codModelo;
  String descripcion;

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        codMarca: json["cod_marca"],
        codModelo: json["cod_modelo"],
        descripcion: json["descripcion"],
      );

  Map<String, dynamic> toJson() => {
        "cod_marca": codMarca,
        "cod_modelo": codModelo,
        "descripcion": descripcion,
      };
}

VehicleClientData vehicleClientDataFromJson(String str) =>
    VehicleClientData.fromJson(json.decode(str));

String vehicleClientDataToJson(VehicleClientData data) =>
    json.encode(data.toJson());

class VehicleClientData {
  VehicleClientData({
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.anio,
    this.clase,
    this.subclase,
    required this.tipo,
    required this.motor,
    required this.chasis,
    required this.cedulaPropietario,
    required this.nombrePropietario,
    this.pais,
    this.capacidad,
    required this.cilindraje,
    this.combustible,
    this.estadoExoneracion,
    this.fechaCompra,
    this.fechaCaducidad,
    this.camv,
    required this.cargaUtil,
    this.anioFiscal,
    required this.valorAvaluo,
    this.valorImpuesto,
    this.precioVenta,
    this.cantonMatriculacion,
    this.color,
    this.fechaNacimientoPropietario,
    required this.estadoCivilPropietario,
    required this.generoPropietario,
    required this.mensaje,
  });

  String placa;
  String marca;
  String modelo;
  String anio;
  dynamic clase;
  dynamic subclase;
  String tipo;
  String motor;
  String chasis;
  String cedulaPropietario;
  String nombrePropietario;
  dynamic pais;
  dynamic capacidad;
  String cilindraje;
  dynamic combustible;
  dynamic estadoExoneracion;
  dynamic fechaCompra;
  dynamic fechaCaducidad;
  dynamic camv;
  String cargaUtil;
  dynamic anioFiscal;
  double valorAvaluo;
  dynamic valorImpuesto;
  dynamic precioVenta;
  dynamic cantonMatriculacion;
  dynamic color;
  dynamic fechaNacimientoPropietario;
  String estadoCivilPropietario;
  String generoPropietario;
  String mensaje;

  factory VehicleClientData.fromJson(Map<String, dynamic> json) =>
      VehicleClientData(
        placa: json["placa"],
        marca: json["marca"],
        modelo: json["modelo"],
        anio: json["anio"],
        clase: json["clase"],
        subclase: json["subclase"],
        tipo: json["tipo"],
        motor: json["motor"],
        chasis: json["chasis"],
        cedulaPropietario: json["cedula_propietario"],
        nombrePropietario: json["nombre_propietario"],
        pais: json["pais"],
        capacidad: json["capacidad"],
        cilindraje: json["cilindraje"],
        combustible: json["combustible"],
        estadoExoneracion: json["estado_exoneracion"],
        fechaCompra: json["fecha_compra"],
        fechaCaducidad: json["fecha_caducidad"],
        camv: json["camv"],
        cargaUtil: json["carga_util"],
        anioFiscal: json["anio_fiscal"],
        valorAvaluo: (json["valor_avaluo"]!=null)?json["valor_avaluo"].toDouble():0,
        valorImpuesto: json["valor_impuesto"],
        precioVenta: json["precio_venta"],
        cantonMatriculacion: json["canton_matriculacion"],
        color: json["color"],
        fechaNacimientoPropietario: json["fecha_nacimiento_propietario"],
        estadoCivilPropietario: json["estado_civil_propietario"],
        generoPropietario: json["genero_propietario"],
        mensaje: json["mensaje"],
      );

  Map<String, dynamic> toJson() => {
        "placa": placa,
        "marca": marca,
        "modelo": modelo,
        "anio": anio,
        "clase": clase,
        "subclase": subclase,
        "tipo": tipo,
        "motor": motor,
        "chasis": chasis,
        "cedula_propietario": cedulaPropietario,
        "nombre_propietario": nombrePropietario,
        "pais": pais,
        "capacidad": capacidad,
        "cilindraje": cilindraje,
        "combustible": combustible,
        "estado_exoneracion": estadoExoneracion,
        "fecha_compra": fechaCompra,
        "fecha_caducidad": fechaCaducidad,
        "camv": camv,
        "carga_util": cargaUtil,
        "anio_fiscal": anioFiscal,
        "valor_avaluo": valorAvaluo,
        "valor_impuesto": valorImpuesto,
        "precio_venta": precioVenta,
        "canton_matriculacion": cantonMatriculacion,
        "color": color,
        "fecha_nacimiento_propietario": fechaNacimientoPropietario,
        "estado_civil_propietario": estadoCivilPropietario,
        "genero_propietario": generoPropietario,
        "mensaje": mensaje,
      };
}

List<AccesoriesVehicle> accesoriesVehicleFromJson(String str) =>
    List<AccesoriesVehicle>.from(
        json.decode(str).map((x) => AccesoriesVehicle.fromJson(x)));

String accesoriesVehicleToJson(List<AccesoriesVehicle> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AccesoriesVehicle {
  AccesoriesVehicle({
    required this.descripcion,
    this.accesorio,
    this.marIncl,
    this.cobertura,
    required this.capAseg,
    this.cantidad,
    this.bueno,
    this.medio,
    this.marca,
    this.regular,
    this.modelo,
    this.original,
    this.extra,
    this.valUnit,
    this.tipo,
  });

  String descripcion;
  String? accesorio;
  String? marIncl;
  String? cobertura;
  int capAseg;
  String? valUnit;
  String? cantidad;
  bool? bueno;
  bool? medio;
  bool? regular;
  String? marca;
  String? modelo;
  bool? original;
  bool? extra;
  String? tipo;

  factory AccesoriesVehicle.fromJson(Map<String, dynamic> json) =>
      AccesoriesVehicle(
        descripcion: json["descripcion"],
        accesorio: json["accesorio"],
        marIncl: json["mar_incl"],
        cobertura: json["cobertura"],
        capAseg: json["cap_aseg"],
        valUnit: json["valUnit"],
        extra: json["extra"],
        original: json["original"],
        modelo: json["modelo"],
        marca: json["marca"],
        regular: json["regular"],
        medio: json["medio"],
        bueno: json["bueno"],
        cantidad: json["cantidad"],
        tipo: json["tipo"],
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "accesorio": accesorio,
        "mar_incl": marIncl,
        "cobertura": cobertura,
        "cap_aseg": capAseg,
        "original": original,
        "extra": extra,
        "modelo": modelo,
        "marca": marca,
        "regular": regular,
        "medio": medio,
        "bueno": bueno,
        "cantidad": cantidad,
        "valUnit": valUnit,
        "tipo": tipo,
      };
}
