
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';

class FirebaseService {
  static Future<bool> inicialize() async {
    try {
      if (Platform.isAndroid) {
        await Firebase.initializeApp(
            options: AppConfig.appEnv.firebaseOptionsAndroid);
      } else if (Platform.isIOS) {
        await Firebase.initializeApp(
            options: AppConfig.appEnv.firebaseOptionsIos);
      }
      FirebaseService.config();

      return true;
    } catch (e) {
      log('Error al inicializar $e');
      return false;
    }
  }

  static Future<bool> config({
    bool alert = true,
    bool badge = true,
    bool sound = true,
  }) async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: alert,
        badge: badge,
        sound: sound,
      );
      // FirebaseMessaging.onMessageOpenedApp.listen(onOpenNotification);
      // FirebaseMessaging.onMessage.listen(onOpenNotification);
      FirebaseMessaging.instance.requestPermission(criticalAlert: true);
      return true;
    } on Exception catch (e) {
      debugPrint('$e');
      return false;
    }
  }
}
