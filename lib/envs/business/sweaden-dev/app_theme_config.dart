part of '../business.dart';

class AppThemeConfigSweadenDEV implements app_theme.AppThemeConfig {
  //*1. COLORS
  @override
  Color primaryColor = const Color.fromARGB(255, 230, 134, 56);
  @override
  Color secondaryColor = const Color.fromARGB(255, 99, 125, 241);
  @override
  Color tertiaryColor = const Color(0xff292929);
  //*2. ANIMATIONS
  @override
  String loadingAnimation = 'FadeInDownBig';
  @override
  Duration durationLoadingAnimation = const Duration(milliseconds: 800);
  //*3. TEXTFIELDS
  @override
  double circularBorderTextField = 25.0;
  //*4. ASSETS
  @override
  String logoImagePath = 'assets/logo.png';
  @override
  String backGroundImagePath = 'assets/bgsweaden.png';
  @override
  String processAlertImagePath = 'assets/process.png';
  @override
  String loadingGifPath = 'assets/loading.gif';
  @override
  String warningPath = 'assets/warning.gif';
  @override
  String locationPath = 'assets/location.gif';
  @override
  String successPath = 'assets/success.png';
  @override
  String cameraPath = 'assets/camera.png';
  @override
  String videoPath = 'assets/video.png';
  @override
  String photoPath = 'assets/photo.png';
  @override
  String takePicPath = 'assets/take-pick.png';
  @override
  String recordVideoPath = 'assets/record-video.png';
  @override
  String uploadVideoPath = 'assets/upload-video.png';
  @override
  String tapToPlayPath = 'assets/tap.png';
  @override
  String facialRecognitionPath = 'assets/face-id.png';

  //*5. MESSAGES
  //? Page: New Request
  @override
  String customerDataTitle = 'INGRESE LOS DATOS DEL CLIENTE';
  @override
  String requestDataTitle = 'INGRESE LOS DATOS DE LA SOLICITUD';
}