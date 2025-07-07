// To parse this JSON data, do
//
//     final mediaResponse = mediaResponseFromJson(jsonString);

import 'dart:convert';

MediaResponse mediaResponseFromJson(String str) => MediaResponse.fromJson(json.decode(str));

String mediaResponseToJson(MediaResponse data) => json.encode(data.toJson());

class MediaResponse {
    int idSolicitud;
    int idArchiveType;
    String status;

    MediaResponse({
        required this.idSolicitud,
        required this.idArchiveType,
        required this.status,
    });

    factory MediaResponse.fromJson(Map<String, dynamic> json) => MediaResponse(
        idSolicitud: json["idSolicitud"],
        idArchiveType: json["idArchiveType"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "idSolicitud": idSolicitud,
        "idArchiveType": idArchiveType,
        "status": status,
    };
}
