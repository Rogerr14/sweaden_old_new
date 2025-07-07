import 'package:sweaden_old_new_version/envs/business/business.dart';
import 'package:sweaden_old_new_version/envs/generic/app_theme_config.dart'
    as generic_theme;

import 'package:sweaden_old_new_version/envs/generic/app_env.dart'
    as generic_env;

class AppConfig {
  static String appConfig = "sweaden";

  static generic_theme.AppThemeConfig appThemeConfig = generic_theme.AppThemeConfig();
  static generic_env.AppEnv appEnv = generic_env.AppEnv();

  AppConfig() {
    switch (appConfig) {
      case 'sweaden':
        appEnv = AppEnvSweaden();
        appThemeConfig = AppThemeConfigSweaden();
        break;
      case 'sweaden-test':
        appEnv = AppEnvQASweaden();
        appThemeConfig = AppThemeConfigSweadenQA();
        break;  
      case 'sweaden-dev':
        appEnv = AppEnvDEVSweaden();
        appThemeConfig = AppThemeConfigSweadenDEV();
        break;  
    }
  }
}
