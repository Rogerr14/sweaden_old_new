import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus { online, offline }

class ConnectivityService {
  StreamController<NetworkStatus> controller = StreamController.broadcast();

  final customInstance = InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 3), // Custom check timeout
    checkInterval: const Duration(seconds: 3), // Custom check interval
    addresses: [
      AddressCheckOption(uri: Uri.parse('http://8.8.4.4'), timeout: const Duration(seconds: 3) )
      // AddressCheckOption(
      //     InternetAddress('8.8.4.4', type: InternetAddressType.IPv4),
      //     timeout: const Duration(seconds: 3)),
    ],
  );

  ConnectivityService() {
    Connectivity().onConnectivityChanged.listen((result) async {controller.add(await _networkStatus());
    });
  }

  Future<NetworkStatus> _networkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if(connectivityResult.contains(ConnectivityResult.none) ){
      bool isConnected = await pingToGoogle();
      if(isConnected){
        Helper.logger.w('tienes red y acceso a internet');
        return NetworkStatus.online;
      }else{
        Helper.logger.w('tienes red, pero no accceso a internet');
        return NetworkStatus.offline;
      }
    }else{
      Helper.logger.w('no tienes red');
      return NetworkStatus.offline;
    }
    // var connectivityResult = await Connectivity().checkConnectivity();
    // if (connectivityResult == ConnectivityResult.none) {
    //   return NetworkStatus.offline;
    // } else {
    //   bool isConnected = await pingToGoogle();
    //   Helper.logger.e('isConnected: $isConnected');
    //   if (isConnected) {
    //     return NetworkStatus.online;
    //   } else {
    //     return NetworkStatus.offline;
    //   }
    // }
  }

  void dispose() {
    controller.close();
  }

  Future<bool> checkInternetConection() async {
    bool result = await InternetConnectionChecker.I.hasConnection;
    return result;
  }

  Future<bool> pingToGoogle() async {
    try {
      final hasInternet = await checkInternetConection();
      if (hasInternet) {
        final response = await http.get(Uri.parse('https://google.com'));
        return response.statusCode == 200;
      }
      return false;
    } on Exception catch (e) {
      Helper.logger.e('Error en pingToGoogle: $e');
      return false;
    }
  }
}
