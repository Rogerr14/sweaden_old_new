import 'dart:io';
import 'package:http/http.dart'as http;

class CheckConnectionService {

  Future<bool> hasInternetConnection() async {
    try {
      final response = await http.get(Uri.parse('https://www.google.com')).timeout(const Duration(seconds: 5),onTimeout: () { return http.Response('Timeout', 408);},);
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } on SocketException {
      return false;
    } catch (e) {
      return false;
    }
  }
}