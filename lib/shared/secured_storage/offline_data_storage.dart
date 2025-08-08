import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweaden_old_new_version/modules/offline_configuration/models/catalogue_offline_general_response.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/models/media_response.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/data_client_form_response.dart';
import 'package:sweaden_old_new_version/shared/models/inspection_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';
import 'package:sweaden_old_new_version/shared/models/review_request_data_response.dart';
import 'package:sweaden_old_new_version/shared/models/vehicles_data_inspection.dart';

class OfflineStorage {
  final storage = const FlutterSecureStorage();

  void saveCatalogueExecutives(
      CatalogueOfflineGeneralResponse executives) async {
    final data = jsonEncode(executives);
    await storage.write(
        key: InspectionCatalogue.catalogueExecutives.toString(), value: data);
  }

  Future<CatalogueOfflineGeneralResponse?> getCatalogueExecutives() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueExecutives.toString());
    if (data != null) {
      CatalogueOfflineGeneralResponse response =
          catalogueOfflineGeneralResponseFromJson(data);
      return response;
    }
    return null;
  }

  void saveCatalogueRegisterRequest(
      InspectionDataResponse inspectionDataResponse) async {
    final data = jsonEncode(inspectionDataResponse);
    await storage.write(
        key: InspectionCatalogue.catalogueRegisterRequest.toString(),
        value: data);
  }

  Future<InspectionDataResponse?> getCatalogueRegisterRequest() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueRegisterRequest.toString());
    if (data != null) {
      InspectionDataResponse response = inspectionDataResponseFromJson(data);
      return response;
    }
    return null;
  }

  void saveCataloguePersonalInformation(DataClientForm dataClientForm) async {
    final data = jsonEncode(dataClientForm);
    await storage.write(
        key: InspectionCatalogue.cataloguePersonalInformation.toString(),
        value: data);
  }

  Future<DataClientForm?> getCataloguePersonalInformation() async {
    final data = await storage.read(
        key: InspectionCatalogue.cataloguePersonalInformation.toString());
    if (data != null) {
      DataClientForm response = dataClientFromJson(data);
      return response;
    }
    return null;
  }

  void saveCatalogueVehicleData(
      VehicleDataInspection catalogueDataVehicles) async {
    final data = jsonEncode(catalogueDataVehicles);
    await storage.write(
        key: InspectionCatalogue.catalogueVehicleData.toString(), value: data);
  }

  Future<VehicleDataInspection?> getCatalogueVehicleData() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueVehicleData.toString());
    if (data != null) {
      VehicleDataInspection response = vehicleDataInspectionFromJson(data);
      return response;
    }
    return null;
  }

  void saveCatalogueVehiceModels(
      CatalogueOfflineGeneralResponse information) async {
    final data = jsonEncode(information);
    await storage.write(
        key: InspectionCatalogue.catalogueVehicleModels.toString(),
        value: data);
  }

  Future<CatalogueOfflineGeneralResponse?> getCatalogueVehiceModels() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueVehicleModels.toString());
    if (data != null) {
      CatalogueOfflineGeneralResponse response =
          catalogueOfflineGeneralResponseFromJson(data);
      return response;
    }
    return null;
  }

  void saveCatalogueVehicleAccessories(
      CatalogueOfflineGeneralResponse information) async {
    final data = jsonEncode(information);
    await storage.write(
        key: InspectionCatalogue.catalogueVehicleAccesories.toString(),
        value: data);
  }

  Future<CatalogueOfflineGeneralResponse?>
      getCatalogueVehicleAccessories() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueVehicleAccesories.toString());
    if (data != null) {
      CatalogueOfflineGeneralResponse response =
          catalogueOfflineGeneralResponseFromJson(data);
      // List<AccesoriesVehicle> listAccesories = response.data.map((item) => AccesoriesVehicle.fromJson(item)).toList();
      // return listAccesories;
      return response;
    }
    return null;
  }

  void saveCatalogueFileType(CatalogueOfflineGeneralResponse mediaInfo) async {
    final data = jsonEncode(mediaInfo);
    await storage.write(
        key: InspectionCatalogue.catalogueFileType.toString(), value: data);
  }

  Future<CatalogueOfflineGeneralResponse?> getCatalogueFileType() async {
    final data = await storage.read(
        key: InspectionCatalogue.catalogueFileType.toString());
    if (data != null) {
      CatalogueOfflineGeneralResponse response =
          catalogueOfflineGeneralResponseFromJson(data);
      return response;
    }
    return null;
  }

  // saveCatalogueDate({required InspectionCatalogueDate key, required String date}) async{
  //   await storage.write(key: key.toString(), value: date);
  // }

  // Future<String?> getCatalogueDate({required InspectionCatalogueDate key}) async {
  //   final date = await storage.read(key: key.toString());
  //   if(date != null){
  //     return date;
  //   }
  //   return '';
  // }

  //METODOS PARA LEER Y GUARDAR LAS INSPECCIONES OFFLINE
  Future<void> setListInspectionOffline(List<Lista> value) async {
    List<ListInspectionDataResponse> listInspectionDataResponses = [
      ListInspectionDataResponse(
        idEstadoInspeccion: 2,
        estadoInspeccion: 'Coordinada',
        lista: value,
      )
    ];
    final data =
        jsonEncode(listInspectionDataResponses.map((e) => e.toJson()).toList());
    await storage.write(key: 'listInspectionOfflines', value: data);
  }

  Future<List<ListInspectionDataResponse>?> getListInspectionOffline() async {
    final data = await storage.read(key: 'listInspectionOfflines');
    if (data != null) {
      List<dynamic> jsonData = jsonDecode(data);
      List<ListInspectionDataResponse> response = jsonData
          .map((item) => ListInspectionDataResponse.fromJson(item))
          .toList();
      return response;
    }
    return null;
  }

// removeIspectionOfflineCoordinated() async{
//   await storage.delete(key: 'listInspectionOfflines');
// }

  //guardar id de ispeccion para validar el boton de mostrar de descarga
  setDownloadButtonInspecction({required int idSolicitud}) async {
    await storage.write(
        key: 'downloadButtonInspecction_${idSolicitud.toString()}',
        value: true.toString());
  }

  Future<bool> getDownloadButtonInspecction({required int idSolicitud}) async {
    final value = await storage.read(
        key: 'downloadButtonInspecction_${idSolicitud.toString()}');
    if (value != null) {
      return false;
    } else {
      return true;
    }
  }

  removeDownloadButtonInspecction({required int idSolicitud}) async {
    await storage.delete(
        key: 'downloadButtonInspecction_${idSolicitud.toString()}');
  }

  //METODOS PARA GUARDAR INSPECCIONES QUE ESTEN PENDIENTE A ENVIAR AL SERVICIO:
  Future<void> saveInspectionFinishedOffline(List<Lista> value) async {
    List<ListInspectionDataResponse> listInspectionDataResponses = [
      ListInspectionDataResponse(
        idEstadoInspeccion: 12,
        estadoInspeccion: 'Finalizada offline',
        lista: value,
      )
    ];
    final data =
        jsonEncode(listInspectionDataResponses.map((e) => e.toJson()).toList());
    await storage.write(key: 'finished-offline', value: data);
  }

  Future<List<ListInspectionDataResponse>?>
      getInspectionFinishedOffline() async {
    final data = await storage.read(key: 'finished-offline');
    if (data != null) {
      List<dynamic> jsonData = jsonDecode(data);
      List<ListInspectionDataResponse> response = jsonData
          .map((item) => ListInspectionDataResponse.fromJson(item))
          .toList();
      return response;
    }
    return null;
  }

  // removeListInspectionOfflineFinished() async {
  //   await storage.delete(key: 'finished-offline');
  // }

  //REGISTRO DE CREACION DE SOLICITUDES EN MODO OFFLINE

  Future<bool> saveCreatingRequests({required List<Request> value}) async {
    try {
      final data = jsonEncode(value);
      await storage.write(key: 'creatingRequests', value: data);
      return false;
    } catch (e) {
      return true;
    }
  }

  Future<List<Request>> getCreatingRequests() async {
    // storage.delete(key: 'creatingRequests');
    // return[];
    final data = await storage.read(key: 'creatingRequests');
    if (data != null) {
      List<dynamic> jsonData = jsonDecode(data);
      List<Request> response =
          jsonData.map((item) => Request.fromJson(item)).toList();

      return response;
    } else {
      return [];
    }
  }

  void setMediaStatus(List<MediaResponse> lista) async {
    final data = jsonEncode(lista);
    await storage.write(key: 'MediaStatus', value: data);
  }

  Future<List<MediaResponse>> getMediaStatus() async {
    List<MediaResponse> listStatusMedia = [];
    try {
      final response = await storage.read(key: 'MediaStatus');
      if (response != null && response.isNotEmpty) {
        // Decodificar el JSON y asegurarnos de que sea una lista
        final decoded = jsonDecode(response);
        if (decoded is List<dynamic>) {
          listStatusMedia = decoded
              .map((item) =>
                  MediaResponse.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          // Si no es una lista, loguear el problema y devolver lista vacía
          Helper.logger
              .w("Error: 'MediaStatus' no contiene una lista válida: $decoded");
        }
      } else {
        Helper.logger
            .w("No hay datos en 'MediaStatus' o response es null/vacío");
      }
    } catch (e, stacktrace) {
      // Capturar errores de decodificación o mapeo
      Helper.logger.w("Error al obtener MediaStatus: $e");
      // debugPrint("Stacktrace: $stacktrace");
    }
    return listStatusMedia;
  }

  Future<bool?> loadingInspection() async {
    final value = await storage.read(key: 'loadingInspection');
    if (value != null) {
      if (value == 'true') {
        return true;
      } else {
        return false;
      }
    } else {
      return null;
    }
  }
}
