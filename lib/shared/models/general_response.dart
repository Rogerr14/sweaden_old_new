import 'dart:convert';

GeneralResponse generalResponseFromJson(String str) =>
    GeneralResponse.fromJson(json.decode(str));

String generalResponseToJson(GeneralResponse data) =>
    json.encode(data.toJson());

class GeneralResponse<T> {
  GeneralResponse({
    this.data,
    this.existData,
    required this.message,
    required this.error,
  });

  T? data;
  bool? existData;
  String message;
  bool error;

  factory GeneralResponse.fromJson(Map<String, dynamic> json) =>
      GeneralResponse(
          data: json["data"],
          message: json["message"],
          error: json["error"] ?? false,
          existData: json["hayData"] ?? true);

  Map<String, dynamic> toJson() => {
        "data": data,
        "message": message,
      };
}