// import 'dart:math';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:sweaden_old_new_version/shared/helpers/helper.dart';

// class LocalNotificationPush{
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initNotification() async {
//     const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     //const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();

//     const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   static Future<void> viewNotification({required String title, required String body}) async{
//    try {
//       const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'your_channel_id', 
//       'your_channel_name', 
//        'fff',
//       importance: Importance.max, 
//       priority: Priority.high,
//       // largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
//       //styleInformation: BigTextStyleInformation('', htmlFormatBigText: true, htmlFormatContentTitle: true, htmlFormatSummaryText: true, htmlFormatContent: true, htmlFormatTitle: true),
//       );
        
//         const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      
//         await flutterLocalNotificationsPlugin.show(Random().nextInt(100), title, body, platformChannelSpecifics);
//     } on Exception catch (e) {
//       Helper.logger.e('error al mostrar notificacion local: $e');
//     }

//   }
// }