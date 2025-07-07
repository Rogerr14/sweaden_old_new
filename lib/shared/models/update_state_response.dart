import 'dart:convert';

List<UpdateState> updateStateFromJson(String str) => List<UpdateState>.from(
    json.decode(str).map((x) => UpdateState.fromJson(x)));

String updateStateToJson(List<UpdateState> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UpdateState {
  UpdateState({
    required this.filasAfectadas,
    required this.idSolicitud,
  });

  int filasAfectadas;
  int idSolicitud;

  factory UpdateState.fromJson(Map<String, dynamic> json) => UpdateState(
        filasAfectadas: json["filasAfectadas"],
        idSolicitud: json["idSolicitud"],
      );

  Map<String, dynamic> toJson() => {
        "filasAfectadas": filasAfectadas,
        "idSolicitud": idSolicitud,
      };
}
