import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/routes.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/services/firebase_service.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  //Timer.periodic(const Duration(seconds: 5), (Timer t) => _SWAPPState().executeMethod());

  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig();
    await firebaseInit();
    await initializeService();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}

Future firebaseInit() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await LocalNotificationPush.initNotification();
  await FirebaseService.inicialize();
}

const notificationChannelId = 'my_foreground';

const notificationId = 888;

// Future<void> _requestNotificationPermission() async {
//   if (await Permission.notification.request().isGranted) {
//     // Permiso concedido
//     print("Permiso de notificación concedido");
//   } else {
//     // Permiso denegado
//     print("Permiso de notificación denegado");
//   }
// }

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  Helper.logger.w("enta aqui");
  final rquest = await Permission.notification.request().isGranted;

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId,
    'Sweaden Segundo Plano',
    importance: Importance.low,
  );

  // AndroidInitializationSettings initializationSettingsAndroid =
  //      AndroidInitializationSettings(AppThemeConfig().logoImagePath);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<
  //         AndroidFlutterLocalNotificationsPlugin>()
  //     ?.initialize(initializationSettingsAndroid);

  Helper.logger.w("enta aqui $rquest");

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: false,
      onStart: onStart,
      isForegroundMode: true,
      autoStartOnBoot: true,
      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'Sweaden procesos en segundo plano',
      initialNotificationContent: 'Iniciando',
      foregroundServiceNotificationId: notificationId,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  AppConfig();
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // WidgetsFlutterBinding.ensureInitialized();
  AppConfig();
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  service.on("stop").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  service.on("start").listen((event) {});
  Helper().initsubscriptionLocation();
  Helper().initSubscriptionPendingMediaInspection();
  // Helper().initUploadInspecctionOffline();

  // Timer.periodic(const Duration(seconds: 1200 ), (timer) async {
  //   if (isConnected) {
  //     _downloadOrders();
  //   } else {
  //     return;
  //   }
  // });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // late BuildContext fpContext;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FunctionalProvider()),
        //  Provider<ConnectivityService>(
        //   create: (_) => ConnectivityService(),
        //   dispose: (_, service) => service.controller.close(),
        // ),
        //StreamProvider(create: (_) => ConnectivityService().controller.stream, initialData: NetworkStatus.online),
      ],
      child: const SWAPP(),
    );
  }
}

class SWAPP extends StatefulWidget {
  const SWAPP({
    Key? key,
  }) : super(key: key);

  @override
  State<SWAPP> createState() => _SWAPPState();
}

class _SWAPPState extends State<SWAPP> {
  // late Timer timer;
  // late FunctionalProvider fp;

  @override
  void initState() {
    //fp = Provider.of<FunctionalProvider>(context, listen: false);
    //_startTimer();
    FirebaseMessaging.onMessage.listen(onOpenNotification);
    super.initState();
  }

  // HttpClient createHttpClient() {
  //   final HttpClient httpClient = HttpClient()
  //     ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  //   return httpClient;
  // }

  // IOClient createIOClient() {
  //   return IOClient(createHttpClient());
  // }

  // void _startTimer(){
  //   timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
  //       if(!fp.offline && fp.loggedIn){
  //         _executeMethod(context);
  //       }else{
  //        // timer.cancel();
  //         debugPrint('aqui no hay internet o no esta logueado');
  //       }
  //     }
  //   );
  // }

  // void _executeMethod(BuildContext context) async {
  //   try {
  //     String url = AppConfig.appEnv.protocol + AppConfig.appEnv.serviceUrl + "status";
  //     debugPrint("U R L $url");
  //     Uri uri = Uri.parse(url);

  //     final client = createIOClient();
  //     final responseHTTPS = await client.get(uri);
  //     if (responseHTTPS.statusCode == 200) {
  //       debugPrint('Método ejecutado a las: ${DateTime.now()} con status: ${responseHTTPS.statusCode}');
  //     } else {
  //       debugPrint('Error...: ${responseHTTPS.statusCode}');
  //     }
  //   } on Exception catch (e) {
  //     debugPrint('Error........: $e');
  //   }
  // }

  // @override
  // void dispose() {
  //   timer.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Helper.navigatorKey,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'EC')],
      debugShowCheckedModeBanner: false,
      title: AppConfig.appEnv.appName,
      //* PROD
      initialRoute: 'loading',
      //?TEST
      // initialRoute: 'test-camera',
      routes: customRoutes,
    );
  }

  onOpenNotification(RemoteMessage message) async {
    inspect(message);
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    // FunctionalProvider().showAlert(content: SizedBox());
    fp.showNotification();
    await Future.delayed(const Duration(milliseconds: 4000));
    fp.dismissNotification();
  }
}
