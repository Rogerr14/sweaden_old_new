// import 'dart:convert';
// import 'dart:developer';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:sweaden_old_new_version/envs/app_config.dart';
// import 'package:sweaden_old_new_version/shared/models/general_response.dart';
// import 'package:sweaden_old_new_version/shared/services/http.dart';
// import 'package:http_parser/http_parser.dart';
// import 'package:http/http.dart' as http;
// import 'package:video_compress/video_compress.dart' as video_compress;

// import '../../../../../shared/models/media_info_response.dart';

// class MediaService {
//   InterceptorHttp interceptorHttp = InterceptorHttp();

//   Future<GeneralResponse> uploadMedia(
//       {required BuildContext context,
//       required int idRequest,
//       required int idArchiveType,
//       required String identification,
//       Uint8List? mediaPhoto,
//       File? mediaVideo,
//       required MediaType mediaType,
//       Function(int, int)? onProgressLoad}) async {
//     try {
//       late http.MultipartFile file;
//       if (mediaType.subtype == 'jpg') {
//         file = http.MultipartFile.fromBytes('archivos[]', mediaPhoto!,
//             // filename: '$idRequest-$idArchiveType', contentType: mediaType);
//             filename: 'jpg',
//             contentType: mediaType);
//       } else {
//         debugPrint("VIDEO MP4");
//         //comprimir el video antes de subirlo
//         String compressedVideoPath = await compressVideo(mediaVideo!);
//         file = await http.MultipartFile.fromPath(
//             'archivos[]', compressedVideoPath,
//             filename: 'mp4', contentType: mediaType);
//       }

//       final data = [
//         {
//           "idSolicitud": idRequest,
//           "idTipoArchivo": idArchiveType,
//           "identificacion": identification
//         }
//       ];

//       log(jsonEncode(data.toString()));
//       final fields = {'informacion': jsonEncode(data)};
//       GeneralResponse response = await interceptorHttp.request(context, 'POST',
//           '${AppConfig.appEnv.serviceUrlMedia}seguros/archivos/subir', null,
//           showLoading: false,
//           multipartFiles: [file],
//           multipartFields: fields,
//           requestType: 'FORM',
//           onProgressLoad: onProgressLoad);

//       debugPrint(response.error.toString());
//       debugPrint(response.message.toString());
//       return GeneralResponse(message: response.message, error: response.error);
//     } catch (e, s) {
//       FirebaseCrashlytics.instance.recordError(e, s,
//           reason: 'Se produjo un error al subir los archivos', fatal: true);
//       debugPrint("Error subiendo media $e");
//       inspect(e);
//       return GeneralResponse(error: true, message: 'Error');
//     }
//   }

//   Future<String> compressVideo(File videoFile) async {
//     video_compress.MediaInfo? mediaInfo =
//         await video_compress.VideoCompress.compressVideo(videoFile.path,
//             quality: video_compress.VideoQuality.Res640x480Quality,
//             frameRate: 15);

//     String compressedVideoPath = mediaInfo!.path!;
//     return compressedVideoPath;
//   }
// }


import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/shared/services/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;


class MediaService {
  InterceptorHttp interceptorHttp = InterceptorHttp();

  Future<GeneralResponse> uploadMedia({
    required BuildContext? context,
    required int idRequest,
    required int idArchiveType,
    required String identification,
    Uint8List? mediaPhoto,
    File? mediaVideo,
    required MediaType mediaType,
    Function(int, int)? onProgressLoad,
    bool showAlertError = true,
    bool showLoading = false,
  }) async {

    //return GeneralResponse(message: 'error al enviar, intente nuevamente.', error: true);
    try {
      late http.MultipartFile file;
      if (mediaType.subtype == 'jpg') {
        file = http.MultipartFile.fromBytes(
          'archivos[]',
          mediaPhoto!,
          filename: 'jpg',
          contentType: mediaType,
        );
      } else {
        //debugPrint("VIDEO MP4");

        // No se realiza la compresión de video
        file = await http.MultipartFile.fromPath(
          'archivos[]',
          mediaVideo!.path,
          filename: 'mp4',
          contentType: mediaType,
        );
      }

      final data = [
        {"idSolicitud": idRequest, "idTipoArchivo": idArchiveType, "identificacion": identification}
      ];

      log(jsonEncode(data.toString()));
      final fields = {'informacion': jsonEncode(data)};
      GeneralResponse response = await interceptorHttp.request(
        context,
        'POST',
        '${AppConfig.appEnv.serviceUrlMedia}seguros/archivos/subir',
        null,
        showLoading: showLoading,
        showAlertError : showAlertError,
        multipartFiles: [file],
        multipartFields: fields,
        requestType: 'FORM',
        onProgressLoad: onProgressLoad,
      );

      // debugPrint(response.error.toString());
      // debugPrint(response.message.toString());
      return GeneralResponse(message: response.message, error: response.error);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'Se produjo un error al subir los archivos', fatal: true);
      //debugPrint("Error subiendo media $e");
      inspect(e);
      return GeneralResponse(error: true, message: 'Error');
    }
  }
}
