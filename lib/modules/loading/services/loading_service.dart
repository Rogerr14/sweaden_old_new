

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:http/http.dart' as http;

class LoadingService{

  Future<bool> getServerResponse() async {
    
    try {
      //AppConfig.appEnv.protocol = "http";
      final resp = await _queryMethoth();
      // if(!resp){
      //   AppConfig.appEnv.protocol = "http";
      //   final resps = await _queryMethoth();
      //   return resps;
      // }
      return resp;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al obtener la respuesta del servidor', fatal: true);
      return false;
    }
    
  }

  Future<bool> _queryMethoth()async{
    try {
    String url = AppConfig.appEnv.protocol + AppConfig.appEnv.serviceUrl + "status";
    debugPrint("U R L $url");
    Uri uri = Uri.parse(url);
    final responseHTTPS = await http.get(uri).timeout(const Duration(seconds: 10));
    if(responseHTTPS.statusCode == 200){
      return true;
    }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al realizar la consulta al servidor', fatal: true);
      return false;
    }
    return false;
  }
}