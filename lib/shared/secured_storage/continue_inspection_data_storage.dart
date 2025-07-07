import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sweaden_old_new_version/shared/models/continue_inspection.dart';

class InspectionStorage {
  final storage = const FlutterSecureStorage();

  Future<ContinueInspection?> getDataInspection(String idSoliciutd) async {
    final data = await storage.read(key: idSoliciutd);
    if (data != null) {
      ContinueInspection response = continueInspectionFromJson(data);
      return response;
    }
    return null;
  }

  void setDataInspection(ContinueInspection inspectionData, String idSoliciutd) async {
    debugPrint("ME EJECUTO......");
    inspect(inspectionData);
    debugPrint(idSoliciutd);
    final data = jsonEncode(inspectionData);
    await storage.write(key: idSoliciutd, value: data);
  }

  removeDataInspection(String idSoliciutd) async {
    await storage.delete(key: idSoliciutd);
  }
}
