import 'package:flutter/material.dart';

class AppThemeConfig {
  //* 1. COLOR
  Color primaryColor = Colors.yellow;
  Color secondaryColor = Colors.blue;
  Color tertiaryColor = Colors.red;

  //* 2. ANIMATIONS
  String loadingAnimation = 'NONE';
  Duration durationLoadingAnimation = const Duration();

  //*3. TEXTFIELDS
  double circularBorderTextField = 0.0;

  //*4. ASSETS
  String logoImagePath = '';
  String backGroundImagePath = '';
  String processAlertImagePath = '';
  String loadingGifPath = '';
  String warningPath = '';
  String locationPath = '';
  String successPath = '';
  String cameraPath = '';
  String videoPath = '';
  String photoPath = '';
  String takePicPath = '';
  String uploadVideoPath = '';
  String recordVideoPath = '';
  String tapToPlayPath = '';
  String facialRecognitionPath = '';

  //*5. MESSAGES
  //? Page: New Request
  String customerDataTitle = '';
  String requestDataTitle = '';
}
