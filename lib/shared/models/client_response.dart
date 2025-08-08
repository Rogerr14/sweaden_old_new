import 'dart:convert';

DatosCliente datosClienteFromJson(String str) =>
    DatosCliente.fromJson(json.decode(str));

String datosClienteFormToJson(DatosCliente data) => json.encode(data.toJson());

class DatosCliente {
  DatosCliente({required this.persona});

  Persona persona;

  factory DatosCliente.fromJson(Map<String, dynamic> json) => DatosCliente(
        persona: Persona.fromJson(json["persona"]),
      );

  Map<String, dynamic> toJson() => {
        "persona": persona.toJson(),
      };
}

class Persona {
  Persona(
      {required this.nombre,
      required this.email,
      required this.conyuge,
      required this.nombresConyuge,
      required this.rucTrabajo,
      required this.cargoTrabajo,
      required this.empresaTrabajo,
      required this.placaVehiculo,
      required this.marcaVehiculo,
      required this.modeloVehiculo,
      required this.anioVehiculo,
      required this.colorVehiculo,
      required this.claseVehiculo,
      required this.tipoVehiculo,
      required this.motorVehiculo,
      required this.chasisVehiculo,
      required this.apellido1,
      required this.apellido2,
      required this.nombre1,
      required this.nombre2,
      required this.fechaNacimiento,
      required this.fechaIngresoTrabajo,
      required this.cedula,
      required this.genero,
      required this.direcciones,
      required this.telefonos,
      required this.celulares,
      required this.estadoCivil,
      required this.lugarNacimiento,
      required this.codigoLugarNacimiento,
      required this.nacionalidad,
      required this.codigoNacionalidad,
      required this.instruccion,
      required this.codigoInstruccion,
      required this.profesion,
      required this.codigoProfesion,
      required this.condicionCiudadano,
      required this.codigoCondicionCiudadano,
      required this.ubicacionDomicilio,
      required this.codigoUbicacionDomicilio,
      required this.rangoIngresosTrabajo,
      required this.codigoRangoIngresosTrabajo,
      required this.provincia,
      required this.canton,
      required this.parroquia,
      required this.primerNombre,
      required this.segundoNombre,
      required this.primerApellido,
      required this.segundoApellido,
      required this.codigoEstadoCivil,
      required this.direccionTrabajo,
      required this.direccionDomicilio,
      required this.telefonoDomicilio,
      required this.telefonoCelular,
      required this.mensaje,
      required this.patrimonio,
      required this.direccionEmpresa,
      required this.telEmpresa,
      required this.codProvincia,
      required this.codLocalidad,
      required this.codActividad,
      required this.activos,
      required this.pasivos});

  String? nombre;
  String email;
  String? conyuge;
  String? nombresConyuge;
  String? rucTrabajo;
  String? cargoTrabajo;
  String? empresaTrabajo;
  String? placaVehiculo;
  String? marcaVehiculo;
  String? modeloVehiculo;
  String? anioVehiculo;
  String? colorVehiculo;
  String? claseVehiculo;
  String? tipoVehiculo;
  String? motorVehiculo;
  String? chasisVehiculo;
  String? apellido1;
  String? apellido2;
  String nombre1;
  String nombre2;
  String fechaNacimiento;
  String? fechaIngresoTrabajo;
  String? cedula;
  String genero;
  String? direcciones;
  String? telefonos;
  String? celulares;
  String estadoCivil;
  String? lugarNacimiento;
  String? codigoLugarNacimiento;
  String? nacionalidad;
  String? codigoNacionalidad;
  String? instruccion;
  String? codigoInstruccion;
  String? profesion;
  String? codigoProfesion;
  String? condicionCiudadano;
  String? codigoCondicionCiudadano;
  String? ubicacionDomicilio;
  String? codigoUbicacionDomicilio;
  String? rangoIngresosTrabajo;
  String? codigoRangoIngresosTrabajo;
  String? provincia;
  String? canton;
  String? parroquia;
  String? primerNombre;
  String? segundoNombre;
  String? primerApellido;
  String? segundoApellido;
  String? codigoEstadoCivil;
  String? direccionTrabajo;
  String? direccionDomicilio;
  String? telefonoDomicilio;
  String? telefonoCelular;
  String? mensaje;
  String? patrimonio;
  String? direccionEmpresa;
  String? telEmpresa;
  String? codProvincia;
  String? codLocalidad;
  String? codActividad;
  int? activos;
  int? pasivos;

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        nombre: json["nombre"],
        email: json["email"],
        conyuge: json["conyuge"],
        nombresConyuge: json["nombres_conyuge"],
        rucTrabajo: json["ruc_trabajo"],
        cargoTrabajo: json["cargo_trabajo"],
        empresaTrabajo: json["empresa_trabajo"],
        placaVehiculo: json["placa_vehiculo"],
        marcaVehiculo: json["marca_vehiculo"],
        modeloVehiculo: json["modelo_vehiculo"],
        anioVehiculo: json["anio_vehiculo"],
        colorVehiculo: json["color_vehiculo"],
        claseVehiculo: json["clase_vehiculo"],
        tipoVehiculo: json["tipo_vehiculo"],
        motorVehiculo: json["motor_vehiculo"],
        chasisVehiculo: json["chasis_vehiculo"],
        apellido1: json["apellido1"],
        apellido2: json["apellido2"],
        nombre1: json["nombre1"],
        nombre2: json["nombre2"],
        fechaNacimiento: json["fecha_nacimiento"],
        fechaIngresoTrabajo: json["fecha_ingreso_trabajo"],
        cedula: json["cedula"],
        genero: json["genero"],
        direcciones: json["direcciones"],
        telefonos: json["telefonos"],
        celulares: json["celulares"],
        estadoCivil: json["estado_civil"],
        lugarNacimiento: json["lugar_nacimiento"],
        codigoLugarNacimiento: json["codigo_lugar_nacimiento"],
        nacionalidad: json["nacionalidad"],
        codigoNacionalidad: json["codigo_nacionalidad"],
        instruccion: json["instruccion"],
        codigoInstruccion: json["codigo_instruccion"],
        profesion: json["profesion"],
        codigoProfesion: json["codigo_profesion"],
        condicionCiudadano: json["condicion_ciudadano"],
        codigoCondicionCiudadano: json["codigo_condicion_ciudadano"],
        ubicacionDomicilio: json["ubicacion_domicilio"],
        codigoUbicacionDomicilio: json["codigo_ubicacion_domicilio"],
        rangoIngresosTrabajo: json["rango_ingresos_trabajo"],
        codigoRangoIngresosTrabajo: json["codigo_rango_ingresos_trabajo"],
        provincia: json["provincia"],
        canton: json["canton"],
        parroquia: json["parroquia"],
        primerNombre: json["primer_nombre"],
        segundoNombre: json["segundo_nombre"],
        primerApellido: json["primer_apellido"],
        segundoApellido: json["segundo_apellido"],
        codigoEstadoCivil: json["codigo_estado_civil"],
        direccionTrabajo: json["direccion_trabajo"],
        direccionDomicilio: json["direccion_domicilio"],
        telefonoDomicilio: json["telefono_domicilio"] ?? '',
        telefonoCelular: json["telefono_celular"],
        mensaje: json["mensaje"],
        patrimonio: json["patrimonio"],
        direccionEmpresa: json["direccion_empresa"],
        telEmpresa: json["tel_empresa"],
        codActividad: json["codActividad"],
        codLocalidad: json["codLocalidad"],
        codProvincia: json["codProvincia"],
        pasivos: json["pasivos"],
        activos: json["activos"]
      );

  Map<String, dynamic> toJson() => {
        "nombre": nombre,
        "email": email,
        "conyuge": conyuge,
        "nombres_conyuge": nombresConyuge,
        "ruc_trabajo": rucTrabajo,
        "cargo_trabajo": cargoTrabajo,
        "empresa_trabajo": empresaTrabajo,
        "placa_vehiculo": placaVehiculo,
        "marca_vehiculo": marcaVehiculo,
        "modelo_vehiculo": modeloVehiculo,
        "anio_vehiculo": anioVehiculo,
        "color_vehiculo": colorVehiculo,
        "clase_vehiculo": claseVehiculo,
        "tipo_vehiculo": tipoVehiculo,
        "motor_vehiculo": motorVehiculo,
        "chasis_vehiculo": chasisVehiculo,
        "apellido1": apellido1,
        "apellido2": apellido2,
        "nombre1": nombre1,
        "nombre2": nombre2,
        "fecha_nacimiento": fechaNacimiento,
        "fecha_ingreso_trabajo": fechaIngresoTrabajo,
        "cedula": cedula,
        "genero": genero,
        "direcciones": direcciones,
        "telefonos": telefonos,
        "celulares": celulares,
        "estado_civil": estadoCivil,
        "lugar_nacimiento": lugarNacimiento,
        "codigo_lugar_nacimiento": codigoLugarNacimiento,
        "nacionalidad": nacionalidad,
        "codigo_nacionalidad": codigoNacionalidad,
        "instruccion": instruccion,
        "codigo_instruccion": codigoInstruccion,
        "profesion": profesion,
        "codigo_profesion": codigoProfesion,
        "condicion_ciudadano": condicionCiudadano,
        "codigo_condicion_ciudadano": codigoCondicionCiudadano,
        "ubicacion_domicilio": ubicacionDomicilio,
        "codigo_ubicacion_domicilio": codigoUbicacionDomicilio,
        "rango_ingresos_trabajo": rangoIngresosTrabajo,
        "codigo_rango_ingresos_trabajo": codigoRangoIngresosTrabajo,
        "provincia": provincia,
        "canton": canton,
        "parroquia": parroquia,
        "primer_nombre": primerNombre,
        "segundo_nombre": segundoNombre,
        "primer_apellido": primerApellido,
        "segundo_apellido": segundoApellido,
        "codigo_estado_civil": codigoEstadoCivil,
        "direccion_trabajo": direccionTrabajo,
        "direccion_domicilio": direccionDomicilio,
        "telefono_domicilio": telefonoDomicilio,
        "telefono_celular": telefonoCelular,
        "mensaje": mensaje,
        "patrimonio": patrimonio,
        "direccion_empresa": direccionEmpresa,
        "tel_empresa": telEmpresa,
        "codActividad": codActividad,
        "codLocalidad":codLocalidad,
        "codProvincia" : codProvincia,
        "pasivos" : pasivos,
        "activos" : activos
      };
}
