// To parse this JSON data, do
//
//     final mediaStorage = mediaStorageFromJson(jsonString);

import 'dart:convert';

List<MediaStorage> mediaStorageFromJson(String str) => List<MediaStorage>.from(
    json.decode(str).map((x) => MediaStorage.fromJson(x)));

String mediaStorageToJson(List<MediaStorage> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MediaStorage {
  MediaStorage({
    required this.idArchiveType,
    this.data,
    required this.isRequired,
    required this.description,
    required this.type,
    this.path,
    this.status,
  });

  int idArchiveType;
  List<int>? data;
  String description;
  String isRequired;
  String type;
  String? path;
  // String? status = 'NO_MEDIA';
  String? status;

  factory MediaStorage.fromJson(Map<String, dynamic> json) => MediaStorage(
        idArchiveType: json["idArchiveType"],
        data: (json["data"] != null)
            ? List<int>.from(json["data"].map((x) => x))
            : null,
        description: json['description'],
        isRequired: json["isRequired"],
        type: json["type"],
        path: json["path"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "idArchiveType": idArchiveType,
        "data": (data != null) ? List<dynamic>.from(data!.map((x) => x)) : data,
        "description": description,
        "isRequired": isRequired,
        "type": type,
        "path": path,
        "status": status,
      };
}
