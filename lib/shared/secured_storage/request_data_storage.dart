import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweaden_old_new_version/shared/models/request_model.dart';

class RequestDataStorage {
  final storage = const FlutterSecureStorage();

  void setRequestData(Request request) async {
    final dataStringify = requestToJson(request);
    await storage.write(key: 'request', value: dataStringify);
  }

  Future<Request> getRequestData() async {
    final dataStringify = await storage.read(key: 'request');
    if (dataStringify != null) {
      Request request = requestFromJson(dataStringify);
      return request;
    }
    return Request(opcion: 'I', dataSolicitud: null);
  }

  void removeRequestData() async {
    await storage.delete(key: 'request');
  }
}
