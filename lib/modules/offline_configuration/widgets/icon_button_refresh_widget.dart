import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';

class IconButtonRefreshWidget extends StatelessWidget {
  final void Function()? onPressed;
  //final IconData? icon;
  final bool? error;
  const IconButtonRefreshWidget({super.key, this.onPressed, this.error});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: error == null ? AppConfig.appThemeConfig.secondaryColor : (error == true ? Colors.red : Colors.green),
      splashColor: AppConfig.appThemeConfig.primaryColor,
      onPressed: onPressed,
      icon: Icon(error == null ? Icons.refresh_outlined : (error == true ?  Icons.close : Icons.check)),
    );
  }
}
