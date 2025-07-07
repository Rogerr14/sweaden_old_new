import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';

class NewRequestProvider extends ChangeNotifier {
  String informativeTitle = AppConfig.appThemeConfig.customerDataTitle;

  changeTitle(int page) {
    switch (page) {
      case 0:
        informativeTitle = AppConfig.appThemeConfig.customerDataTitle;
        break;
      case 1:
        informativeTitle = AppConfig.appThemeConfig.requestDataTitle;
        break;
      default:
        informativeTitle = AppConfig.appThemeConfig.customerDataTitle;
        break;
    }
    notifyListeners();
  }
}
