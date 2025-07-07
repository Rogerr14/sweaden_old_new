import 'dart:convert';

import 'package:sweaden_old_new_version/shared/models/vehicles_data_inspection.dart';

ContinueInspection continueInspectionFromJson(String str) =>
    ContinueInspection.fromJson(json.decode(str));

String continueInspectionToJson(ContinueInspection data) =>
    json.encode(data.toJson());

class ContinueInspection {
  ContinueInspection({
    this.identificacion,
    this.identificationType,
    this.nombres,
    this.apellidos,
    this.fechaNacimiento,
    this.genero,
    this.generoValue,
    this.estadoCivil,
    this.estadoCivilValue,
    this.email,
    this.direccion,
    this.pais,
    this.paisValue,
    this.provincia,
    this.provinciaValue,
    this.localidad,
    this.localidadValue,
    this.actividadEconomica,
    this.actividadEconomicaValue,
    this.personaPublica,
    this.personaPublicaValue,
    this.telefono,
    this.celular,
    this.incomes,
    this.secondaryIncomes,
    this.actives,
    this.pasives,
    this.placa,
    this.codMarca,
    this.nombreMarca,
    this.codModelo,
    this.nombreModelo,
    this.codPaisO,
    this.paisO,
    this.chasis,
    this.motor,
    this.codCarroceria,
    this.carroceria,
    this.codUso,
    this.uso,
    this.anio,
    this.color,
    this.codColor,
    this.km,
    this.capacidadPasajeros,
    this.valorSumaAsegurada,
    this.fechaInicioVigencia,
    this.fechaFinVigencia,
    this.isCompletedVehiculesForm,
    this.accessoriesVehicles,
    this.entregaForm,
    this.emitPolize,
    this.observacion,
    this.enRevision,
    this.rechazado,
    this.pintura,
    this.retapizado,
    this.forros,
    this.vidrios,
    this.observacionEmision,
    this.razonSocial,
    this.valorSugerido,
    this.tipoIdentificacion,
    this.tokenFirma,
    this.base64Image,
    this.cantidadArchivosTratadoEnviar,
    this.deducible,
    this.codRamo,
    this.codProducto,
    this.producto,
    this.codFormaPago,
    this.cuotas,
    this.idMedioCobro,
    this.factura,
    this.fechaInspeccionReal,
    this.base64SignatureClientImage,
    this.finishedInpectionOffline = false,
    //this.idTransaccion
  });

  String? identificacion;
  bool? identificationType; //TRUE PARA NOMBRES Y APELLIDOS, FALSE RAZON SOCIAL ;
  String? nombres;
  String? apellidos;
  String? fechaNacimiento;
  String? genero;
  String? generoValue;
  String? estadoCivil;
  String? estadoCivilValue;
  String? email;
  String? direccion;
  String? pais;
  String? paisValue;
  String? provincia;
  String? provinciaValue;
  String? localidad;
  String? localidadValue;
  String? actividadEconomica;
  String? actividadEconomicaValue;
  String? personaPublica;
  String? personaPublicaValue;
  String? telefono;
  String? celular;
  String? incomes;
  String? secondaryIncomes;
  String? actives;
  String? pasives;

  String? placa;
  String? codMarca;
  String? nombreMarca;
  String? codModelo;
  String? nombreModelo;
  String? codPaisO;
  String? paisO;
  String? chasis;
  String? motor;
  String? codCarroceria;
  String? carroceria;
  String? codUso;
  String? uso;
  String? anio;
  String? color;
  String? codColor;
  String? km;
  String? capacidadPasajeros;
  String? valorSumaAsegurada;
  String? fechaInicioVigencia;
  String? fechaFinVigencia;
  bool? isCompletedVehiculesForm;
  List<AccesoriesVehicle>? accessoriesVehicles;

  bool? entregaForm;
  String? observacion;
  bool? enRevision;
  bool? rechazado;
  String? pintura;
  bool? retapizado;
  bool? forros;
  bool? vidrios;
  bool? emitPolize;
  bool? mediaCompressing;
  String? observacionEmision;
  String? razonSocial;
  String? valorSugerido;
  String? tipoIdentificacion;
  String? tokenFirma;
  String? cantidadArchivosTratadoEnviar;
  String? base64Image;
  String? base64SignatureClientImage;
  bool? finishedInpectionOffline;

  String? deducible;
  String? codRamo;
  String? codProducto;
  String? producto;
  String? codFormaPago;
  String? cuotas;
  String? idMedioCobro;
  String? factura;

  String? fechaInspeccionReal;

  //String? idTransaccion;

  factory ContinueInspection.fromJson(Map<String, dynamic> json) =>
      ContinueInspection(
          identificacion: json["identificacion"],
          identificationType: json["identification_type"],
          nombres: json["nombres"],
          apellidos: json["apellidos"],
          fechaNacimiento: json["fecha_nacimiento"],
          genero: json["genero"],
          generoValue: json["genero_value"],
          estadoCivil: json["estado_civil"].toString().trim(),
          estadoCivilValue: json["estado_civil_value"],
          email: json["email"],
          direccion: json["direccion"],
          pais: json["pais"],
          paisValue: json["pais_value"],
          provincia: json["provincia"],
          provinciaValue: json["provincia_value"],
          localidad: json["localidad"],
          localidadValue: json["localidad_value"],
          actividadEconomica: json["actividad_economica"],
          actividadEconomicaValue: json["actividad_economica_value"],
          personaPublica: json["persona_publica"],
          personaPublicaValue: json["persona_publica_value"],
          telefono: json["telefono"].toString().trim(),
          celular: json["celular"],
          incomes: json["incomes"],
          secondaryIncomes: json["secondary_incomes"],
          actives: json["actives"],
          pasives: json["pasives"],
          placa: json['placa'],
          codMarca: json['codMarca'],
          nombreMarca: json['nombreMarca'],
          codModelo: json['codModelo'],
          nombreModelo: json['nombreModelo'],
          codPaisO: json['codPaisO'],
          paisO: json['paisO'],
          chasis: json['chasis'],
          motor: json['motor'],
          codCarroceria: json['codCarroceria'],
          carroceria: json['carroceria'],
          codUso: json['codUso'],
          uso: json['uso'],
          anio: json['anio'],
          color: json['color'],
          codColor: json['codColor'],
          km: json['km'],
          capacidadPasajeros: json['capacidadPasajeros'],
          valorSumaAsegurada: json['valorSumaAsegurada'],
          fechaInicioVigencia: json['fechaInicioVigencia'],
          fechaFinVigencia: json['fechaFinVigencia'],
          isCompletedVehiculesForm: json['isCompletedVehiculesForm'],
          accessoriesVehicles: json["accessoriesVehicles"] != null
              ? List<AccesoriesVehicle>.from(json["accessoriesVehicles"]
                  .map((x) => AccesoriesVehicle.fromJson(x)))
              : null,
          entregaForm: json['entregaForm'],
          observacion: json['observacion'],
          enRevision: json['enRevision'],
          rechazado: json['rechazado'],
          pintura: json['pintura'],
          retapizado: json['retapizado'],
          forros: json['forros'],
          vidrios: json['vidrios'],
          emitPolize: json['emitPolize'],
          observacionEmision: json['observacionEmision'],
          razonSocial: json['razonSocial'],
          valorSugerido: json['valorSugerido'],
          tipoIdentificacion: json['tipoIdentificacion'],
          tokenFirma: json['tokenFirma'],
          base64Image: json['base64Image'],
          deducible: json['deducible'],
          codRamo: json['codRamo'],
          codProducto: json['codProducto'],
          producto: json['producto'],
          codFormaPago: json['codFormaPago'],
          cuotas: json['cuotas'],
          idMedioCobro: json['idMedioCobro'],
          base64SignatureClientImage : json['base64SignatureClientImage'],
          finishedInpectionOffline: json['finishedInpectionOffline'] ?? false,
          //idTransaccion: json['idTransaccion'],
          factura: json['factura'],
          cantidadArchivosTratadoEnviar:
              (json['cantidadArchivosTratadoEnviar'] != null)
                  ? json['cantidadArchivosTratadoEnviar']
                  : null,
          fechaInspeccionReal:json['fechaInspeccionReal'] 
                  );

  Map<String, dynamic> toJson() => {
        "identificacion": identificacion,
        "identification_type": identificationType,
        "nombres": nombres,
        "apellidos": apellidos,
        "fecha_nacimiento": fechaNacimiento,
        "genero": genero,
        "genero_value": generoValue,
        "estado_civil": estadoCivil,
        "estado_civil_value": estadoCivilValue,
        "email": email,
        "direccion": direccion,
        "pais": pais,
        "pais_value": paisValue,
        "provincia": provincia,
        "provincia_value": provinciaValue,
        "localidad": localidad,
        "localidad_value": localidadValue,
        "actividad_economica": actividadEconomica,
        "actividad_economica_value": actividadEconomicaValue,
        "persona_publica": personaPublica,
        "persona_publica_value": personaPublicaValue,
        "telefono": telefono,
        "celular": celular,
        "incomes": incomes,
        "secondary_incomes": secondaryIncomes,
        "actives": actives,
        "pasives": pasives,
        "placa": placa,
        "codMarca": codMarca,
        "nombreMarca": nombreMarca,
        "codModelo": codModelo,
        "nombreModelo": nombreModelo,
        "codPaisO": codPaisO,
        "paisO": paisO,
        "chasis": chasis,
        "motor": motor,
        "codCarroceria": codCarroceria,
        "carroceria": carroceria,
        "codUso": codUso,
        "uso": uso,
        "anio": anio,
        "color": color,
        "codColor": codColor,
        "km": km,
        "capacidadPasajeros": capacidadPasajeros,
        "valorSumaAsegurada": valorSumaAsegurada,
        "fechaInicioVigencia": fechaInicioVigencia,
        "fechaFinVigencia": fechaFinVigencia,
        "isCompletedVehiculesForm": isCompletedVehiculesForm,
        "accessoriesVehicles": accessoriesVehicles != null
            ? List<dynamic>.from(accessoriesVehicles!.map((x) => x.toJson()))
            : null,
        "entregaForm": entregaForm,
        "observacion": observacion,
        "enRevision": enRevision,
        "rechazado": rechazado,
        "pintura": pintura,
        "retapizado": retapizado,
        "forros": forros,
        "vidrios": vidrios,
        "emitPolize": emitPolize,
        "observacionEmision": observacionEmision,
        "razonSocial": razonSocial,
        "valorSugerido": valorSugerido,
        "tipoIdentificacion": tipoIdentificacion,
        "tokenFirma": tokenFirma,
        "base64Image": base64Image,
        "deducible": deducible,
        "codRamo": codRamo,
        "codProducto": codProducto,
        "producto": producto,
        "codFormaPago": codFormaPago,
        "cuotas": cuotas,
        "idMedioCobro": idMedioCobro,
        "factura": factura,
        "base64SignatureClientImage": base64SignatureClientImage,
        //"idTransaccion": idTransaccion,
        "finishedInpectionOffline" : finishedInpectionOffline,
        "cantidadArchivosTratadoEnviar": (cantidadArchivosTratadoEnviar != null)
            ? cantidadArchivosTratadoEnviar
            : null,
        "fechaInspeccionReal":fechaInspeccionReal    
      };
}

SaveInspection saveInspectionFromJson(String str) =>
    SaveInspection.fromJson(json.decode(str));

String saveInspectionToJson(SaveInspection data) => json.encode(data.toJson());

class SaveInspection {
  SaveInspection({
    required this.tokenFirma,
    required this.deducible,
    required this.tipoFlujo,
    required this.idSolicitud,
    required this.idProceso,
    required this.identificacion,
    required this.tipoIdentificacion,
    required this.apellidos,
    required this.nombres,
    required this.razonSocial,
    required this.tratamiento,
    required this.codProvincia,
    required this.codLocalidad,
    required this.domicilio,
    required this.fechaNacimiento,
    required this.idEstadoCivil,
    required this.idSector,
    required this.codPais,
    required this.codBroker,
    required this.email,
    required this.codActividadEconomica,
    required this.codOcupacion,
    required this.idPpe,
    required this.usuario,
    required this.telefono,
    required this.celular,
    required this.valorIngresos,
    required this.valorIngresosSecundarios,
    required this.valorActivos,
    required this.valorPasivos,
    required this.codRamo,
    required this.codEjecutivoCuenta,
    required this.codAgencia,
    required this.fechaInicioVigencia,
    required this.fechaFinVigencia,
    required this.valorSumaAsegurada,
    required this.placa,
    required this.codMarca,
    required this.nombreMarca,
    required this.codModelo,
    required this.nombreModelo,
    required this.codPaisO,
    required this.anio,
    required this.chasis,
    required this.motor,
    required this.codCarroceria,
    required this.color,
    required this.codUso,
    required this.codProducto,
    required this.producto,
    required this.capacidadPasajeros,
    required this.codFormaPago,
    required this.cuotas,
    required this.idMedioCobro,
    required this.emitirPoliza,
    required this.observacionEmision,
    required this.enRevision,
    required this.rechazarRevision,
    required this.codInspector,
    required this.numPoliza,
    required this.cobAdicionales,
    required this.cantidadArchivosTratadoEnviar,
    required this.cobOriginales,
    required this.hobby,
    required this.mascotaPreferida,
    required this.equipoFavorito,
    required this.tapiceria,
    required this.entregaForm,
    required this.km,
    required this.observacion,
    required this.valorSugerido,
    required this.factura,
    required this.base64ReconocimientoF,
    required this.fechaInspeccionReal,
    required this.idArchiveType,
    required this.typeMedia,
    required this.idRequest,
    required this.base64SignatureClientImage,
    required this.finishedInpectionOffline,
    //required this.idTransaccion
  });

  String tokenFirma;
  String deducible;
  String tipoFlujo;
  String idSolicitud;
  String idProceso;
  String idRequest;
  String typeMedia;
  String idArchiveType;
  String identificacion;
  String tipoIdentificacion;
  String apellidos;
  String nombres;
  String razonSocial;
  String tratamiento;
  String codProvincia;
  String codLocalidad;
  String domicilio;
  String fechaNacimiento;
  String idEstadoCivil;
  String idSector;
  String codPais;
  String codBroker;
  String email;
  String codActividadEconomica;
  String codOcupacion;
  String idPpe;
  String usuario;
  String telefono;
  String celular;
  String valorIngresos;
  String valorIngresosSecundarios;
  String valorActivos;
  String valorPasivos;
  String codRamo;
  String codEjecutivoCuenta;
  String codAgencia;
  String fechaInicioVigencia;
  String fechaFinVigencia;
  String valorSumaAsegurada;
  String placa;
  String codMarca;
  String nombreMarca;
  String codModelo;
  String nombreModelo;
  String codPaisO;
  String anio;
  String chasis;
  String motor;
  String codCarroceria;
  String color;
  String codUso;
  String codProducto;
  String producto;
  String capacidadPasajeros;
  String codFormaPago;
  String cuotas;
  String idMedioCobro;
  bool emitirPoliza;
  String observacionEmision;
  bool enRevision;
  bool rechazarRevision;
  String codInspector;
  String numPoliza;
  List<CobOriginale> cobAdicionales;
  String cantidadArchivosTratadoEnviar;
  List<CobOriginale> cobOriginales;
  String hobby;
  String mascotaPreferida;
  String equipoFavorito;
  List<Tapiceria> tapiceria;
  bool entregaForm;
  String km;
  String observacion;
  String valorSugerido;
  String factura;
  String base64ReconocimientoF;
  String fechaInspeccionReal;
  String base64SignatureClientImage;
  bool finishedInpectionOffline;
  //String idTransaccion;

  factory SaveInspection.fromJson(Map<String, dynamic> json) => SaveInspection(
        tokenFirma: json["tokenFirma"],
        deducible: json["deducible"],
        tipoFlujo: json["tipo_flujo"],
        idSolicitud: json["idSolicitud"],
        idProceso: json["idProceso"],
        identificacion: json["identificacion"],
        tipoIdentificacion: json["tipoIdentificacion"],
        apellidos: json["apellidos"],
        nombres: json["nombres"],
        razonSocial: json["razonSocial"],
        tratamiento: json["tratamiento"],
        codProvincia: json["codProvincia"],
        codLocalidad: json["codLocalidad"],
        domicilio: json["domicilio"],
        fechaNacimiento: json["fechaNacimiento"],
        idEstadoCivil: json["idEstadoCivil"],
        idSector: json["idSector"],
        codPais: json["codPais"],
        codBroker: json["codBroker"],
        email: json["email"],
        codActividadEconomica: json["codActividadEconomica"],
        codOcupacion: json["codOcupacion"],
        idPpe: json["idPpe"],
        usuario: json["usuario"],
        telefono: json["telefono"],
        celular: json["celular"],
        valorIngresos: json["valorIngresos"],
        valorIngresosSecundarios: json["valorIngresosSecundarios"],
        valorActivos: json["valorActivos"],
        valorPasivos: json["valorPasivos"],
        codRamo: json["codRamo"],
        codEjecutivoCuenta: json["codEjecutivoCuenta"],
        codAgencia: json["codAgencia"],
        fechaInicioVigencia: json["fechaInicioVigencia"],
        fechaFinVigencia: json["fechaFinVigencia"],
        valorSumaAsegurada: json["valorSumaAsegurada"],
        placa: json["placa"],
        codMarca: json["codMarca"],
        nombreMarca: json["nombreMarca"],
        codModelo: json["codModelo"],
        nombreModelo: json["nombreModelo"],
        codPaisO: json["codPaisO"],
        anio: json["anio"],
        chasis: json["chasis"],
        motor: json["motor"],
        codCarroceria: json["codCarroceria"],
        color: json["color"],
        codUso: json["codUso"],
        codProducto: json["codProducto"],
        producto: json["producto"],
        capacidadPasajeros: json["capacidadPasajeros"],
        codFormaPago: json["codFormaPago"],
        cuotas: json["cuotas"],
        idMedioCobro: json["idMedioCobro"],
        emitirPoliza: json["emitirPoliza"],
        observacionEmision: json["observacionEmision"],
        enRevision: json["enRevision"],
        rechazarRevision: json["rechazarRevision"],
        codInspector: json["codInspector"],
        numPoliza: json["numPoliza"],
        cobAdicionales:
            List<CobOriginale>.from(json["cobAdicionales"].map((x) => x)),
        cantidadArchivosTratadoEnviar: json["cantidadArchivosTratadoEnviar"],
        cobOriginales: List<CobOriginale>.from(
            json["cobOriginales"].map((x) => CobOriginale.fromJson(x))),
        hobby: json["hobby"],
        mascotaPreferida: json["mascotaPreferida"],
        equipoFavorito: json["equipoFavorito"],
        tapiceria: List<Tapiceria>.from(
            json["tapiceria"].map((x) => Tapiceria.fromJson(x))),
        entregaForm: json["entregaForm"],
        km: json["km"],
        observacion: json["observacion"],
        valorSugerido: json["valorSugerido"],
        factura: json["factura"],
        base64ReconocimientoF: json["base64_ReconocimientoF"],
        fechaInspeccionReal:json['fechaInspeccionReal'], idArchiveType: '', idRequest: '', typeMedia: '',
        base64SignatureClientImage: json['base64SignatureClientImage'],
        finishedInpectionOffline: json['finishedInpectionOffline'],
        //idTransaccion: json['idTransaccion']
      );

  Map<String, dynamic> toJson() => {
        "tokenFirma": tokenFirma,
        "deducible": deducible,
        "tipo_flujo": tipoFlujo,
        "idSolicitud": idSolicitud,
        "idProceso": idProceso,
        "identificacion": identificacion,
        "tipoIdentificacion": tipoIdentificacion,
        "apellidos": apellidos,
        "nombres": nombres,
        "razonSocial": razonSocial,
        "tratamiento": tratamiento,
        "codProvincia": codProvincia,
        "codLocalidad": codLocalidad,
        "domicilio": domicilio,
        "fechaNacimiento": fechaNacimiento,
        "idEstadoCivil": idEstadoCivil,
        "idSector": idSector,
        "codPais": codPais,
        "codBroker": codBroker,
        "email": email,
        "codActividadEconomica": codActividadEconomica,
        "codOcupacion": codOcupacion,
        "idPpe": idPpe,
        "usuario": usuario,
        "telefono": telefono,
        "celular": celular,
        "valorIngresos": valorIngresos,
        "valorIngresosSecundarios": valorIngresosSecundarios,
        "valorActivos": valorActivos,
        "valorPasivos": valorPasivos,
        "codRamo": codRamo,
        "codEjecutivoCuenta": codEjecutivoCuenta,
        "codAgencia": codAgencia,
        "fechaInicioVigencia": fechaInicioVigencia,
        "fechaFinVigencia": fechaFinVigencia,
        "valorSumaAsegurada": valorSumaAsegurada,
        "placa": placa,
        "codMarca": codMarca,
        "nombreMarca": nombreMarca,
        "codModelo": codModelo,
        "nombreModelo": nombreModelo,
        "codPaisO": codPaisO,
        "anio": anio,
        "chasis": chasis,
        "motor": motor,
        "codCarroceria": codCarroceria,
        "color": color,
        "codUso": codUso,
        "codProducto": codProducto,
        "producto": producto,
        "capacidadPasajeros": capacidadPasajeros,
        "codFormaPago": codFormaPago,
        "cuotas": cuotas,
        "idMedioCobro": idMedioCobro,
        "emitirPoliza": emitirPoliza,
        "observacionEmision": observacionEmision,
        "enRevision": enRevision,
        "rechazarRevision": rechazarRevision,
        "codInspector": codInspector,
        "numPoliza": numPoliza,
        "cobAdicionales": List<dynamic>.from(cobAdicionales.map((x) => x)),
        "cantidadArchivosTratadoEnviar": cantidadArchivosTratadoEnviar,
        "cobOriginales":
            List<dynamic>.from(cobOriginales.map((x) => x.toJson())),
        "hobby": hobby,
        "mascotaPreferida": mascotaPreferida,
        "equipoFavorito": equipoFavorito,
        "tapiceria": List<dynamic>.from(tapiceria.map((x) => x.toJson())),
        "entregaForm": entregaForm,
        "km": km,
        "observacion": observacion,
        "valorSugerido": valorSugerido,
        "factura": factura,
        "base64_ReconocimientoF": base64ReconocimientoF,
        "fechaInspeccionReal":fechaInspeccionReal,
        "base64SignatureClientImage": base64SignatureClientImage,
        "finishedInpectionOffline" : finishedInpectionOffline,
        //"idTransaccion":idTransaccion
      };
}

class CobOriginale {
  CobOriginale({
    required this.descripcion,
    required this.accesorio,
    required this.marIncl,
    required this.cobertura,
    required this.cantidad,
    required this.capAseg,
    required this.bueno,
    required this.medio,
    required this.regular,
    required this.marca,
    required this.modelo,
  });

  String descripcion;
  String accesorio;
  String marIncl;
  String cobertura;
  String cantidad;
  String capAseg;
  bool bueno;
  bool medio;
  bool regular;
  String marca;
  String modelo;

  factory CobOriginale.fromJson(Map<String, dynamic> json) => CobOriginale(
        descripcion: json["descripcion"],
        accesorio: json["accesorio"],
        marIncl: json["mar_incl"],
        cobertura: json["cobertura"],
        cantidad: json["cantidad"],
        capAseg: json["cap_aseg"],
        bueno: json["bueno"],
        medio: json["medio"],
        regular: json["regular"],
        marca: json["marca"],
        modelo: json["modelo"],
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "accesorio": accesorio,
        "mar_incl": marIncl,
        "cobertura": cobertura,
        "cantidad": cantidad,
        "cap_aseg": capAseg,
        "bueno": bueno,
        "medio": medio,
        "regular": regular,
        "marca": marca,
        "modelo": modelo,
      };
}

class Tapiceria {
  Tapiceria({
    required this.descripcion,
    required this.marcado,
  });

  String descripcion;
  bool marcado;

  factory Tapiceria.fromJson(Map<String, dynamic> json) => Tapiceria(
        descripcion: json["descripcion"],
        marcado: json["marcado"],
      );

  Map<String, dynamic> toJson() => {
        "descripcion": descripcion,
        "marcado": marcado,
      };
}

class EmitPolize {
  bool emit;
  String observacion;

  EmitPolize({
    required this.emit,
    required this.observacion,
  });
}
