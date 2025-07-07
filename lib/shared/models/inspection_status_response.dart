import 'dart:convert';


InspectionStatusResponse inspectionStatusResponseFromJson(String str) => InspectionStatusResponse.fromJson(json.decode(str));

String inspectionStatusResponseToJson(InspectionStatusResponse data) => json.encode(data.toJson());

class InspectionStatusResponse {
    int idSolicitud;
    String status;

    InspectionStatusResponse({
        required this.idSolicitud,
        required this.status,
    });

    factory InspectionStatusResponse.fromJson(Map<String, dynamic> json) => InspectionStatusResponse(
        idSolicitud: json["idSolicitud"],
        status: json["status"],
    );

    Map<String, dynamic> toJson() => {
        "idSolicitud": idSolicitud,
        "status": status,
    };
}
