import 'dart:convert';

LocationResponse locationResponseFromJson(String str) =>
    LocationResponse.fromJson(json.decode(str));

String locationResponseToJson(LocationResponse data) =>
    json.encode(data.toJson());

class LocationResponse {
  String longitud;
  String latitud;
  String? idSolicitud;

  LocationResponse({
    required this.longitud,
    required this.latitud,
     this.idSolicitud
  });

  factory LocationResponse.fromJson(Map<String, dynamic> json) =>
      LocationResponse(
        longitud: json["longitud"],
        latitud: json["latitud"],
        idSolicitud: json["idSolicitud"] ?? ''
      );

  Map<String, dynamic> toJson() => {
        "longitud": longitud,
        "latitud": latitud,
        "idSolicitud": idSolicitud
      };
}
