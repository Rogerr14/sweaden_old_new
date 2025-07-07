import 'dart:convert';


CatalogueOfflineGeneralResponse catalogueOfflineGeneralResponseFromJson(String str) => CatalogueOfflineGeneralResponse.fromJson(json.decode(str));

String catalogueOfflineGeneralResponseToJson(CatalogueOfflineGeneralResponse data) => json.encode(data.toJson());

class CatalogueOfflineGeneralResponse<T> {
    String dateCreation;
    List<T> data;

    CatalogueOfflineGeneralResponse({
        required this.dateCreation,
        required this.data,
    });

    factory CatalogueOfflineGeneralResponse.fromJson(Map<String, dynamic> json) => CatalogueOfflineGeneralResponse(
        dateCreation: json["date_creation"],
        data: json["data"]
    );

    Map<String, dynamic> toJson() => {
        "date_creation": dateCreation,
        "data": data
    };
}
