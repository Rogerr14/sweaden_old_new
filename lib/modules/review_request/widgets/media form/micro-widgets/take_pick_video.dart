import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:camera/camera.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sweaden_old_new_version/envs/app_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/providers/media_form_provider.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/continue_inspection_data_storage.dart';
import 'package:sweaden_old_new_version/shared/secured_storage/media_data_storage.dart';
import 'package:sweaden_old_new_version/shared/widgets/shared_widgets.dart';
import 'package:logger/logger.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:video_compress/video_compress.dart' as vc;
import 'package:http_parser/http_parser.dart';
import 'package:sweaden_old_new_version/envs/generic/app_env.dart' as generic;
import 'package:sweaden_old_new_version/shared/models/general_response.dart';
import 'package:sweaden_old_new_version/modules/review_request/widgets/media%20form/services/media_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';

import '../../../../../shared/helpers/helper.dart';
import '../../../../../shared/models/continue_inspection.dart';

class TakePicVideo extends StatefulWidget {
  final int idRequest;
  final int durationVideo;
  final int idArchiveType;
  final String description;
  final String typeMedia;
  const TakePicVideo({
    Key? key,
    required this.idArchiveType,
    required this.durationVideo,
    required this.typeMedia,
    required this.description,
    required this.idRequest,
  }) : super(key: key);

  @override
  State<TakePicVideo> createState() => _TakePicVideoState();
}

class _TakePicVideoState extends State<TakePicVideo>
    with AutomaticKeepAliveClientMixin {
  XFile? choosenImageVideo;
  ContinueInspection inspectionData = ContinueInspection();

  //? CUANDO ESTAMOS SUBIENDO UNA FOTO/VIDEO
  bool processUploading = false;
  bool mediaUploading = false;
  bool mediaCompressing = false;
  bool uploadingFailed = false;
  bool isCompress = true;
  int cantBytes = 0;
  int cantTotalBytes = 0;

  // //? Proceso de compresion
  late vc.Subscription _subscription;
  String compressionProcess = '0.00';

  @override
  void initState() {
    // if(Platform.isAndroid){
    _getMediaStorage();
    // }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getMediaStorage() async {
    try {
      final mediaData = await MediaDataStorage().getMediaData(widget.idRequest);
      if (mediaData != null) {
        final mediaFile = mediaData
            .firstWhere((e) => e.idArchiveType == widget.idArchiveType);
        debugPrint('tipo de archivo: ${mediaFile.type}');

        // if (mediaFile.status != 'UPLOADED' && mediaFile.status != 'NO_MEDIA') {
        //   processUploading = true;
        //   uploadingFailed = true;
        // }

        if (mediaFile.path != null) {
          final exist = await File(mediaFile.path!).exists();
          if (exist) {
            switch (mediaFile.type) {
              case 'image':
                if (mediaFile.status != 'UPLOADED' &&
                    mediaFile.status != 'NO_MEDIA') {
                  processUploading = true;
                  uploadingFailed = true;
                }
                choosenImageVideo = XFile(mediaFile.path!);
                break;
              case 'video':
                if (mediaFile.status != 'UPLOADED') {
                  processUploading = true;
                  uploadingFailed = true;
                  if (mediaFile.status == 'RECORDED') {
                    debugPrint('video no comprimido');
                    // uploadingFailed = false;
                    processUploading = false;
                    isCompress = false;
                  } else {
                    debugPrint('video comprimido pero no subido');
                  }
                }
                // mediaCompressing = false;
                choosenImageVideo = XFile(mediaFile.path!);
                // vpController =
                //     VideoPlayerController.file(File(choosenImageVideo!.path))
                //       ..initialize();
                break;
            }
          }
          _checkIfFormIsComplete();
          setState(() {});
        }
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _getMediaStorage', fatal: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        const SizedBox(
          height: double.infinity,
          width: double.infinity,
        ),
        InkWell(
            onTap: () {
              _showOptionsModal(
                  widget.typeMedia, widget.idArchiveType, widget.description);
            },
            child: (choosenImageVideo != null)
                //? MUESTRA LA IMAGEN O VIDEO SELECCIONADO
                ? _showImageOrVideo()
                //? MUESTRA EL DE ACCION (TOMAR FOTO/GRABAR VIDEO)
                : _showTemplateInfo()),
        if (processUploading) _processUploading(),
        if (!isCompress) _retryCompressWidget(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  //? Muestra la plantilla para tomar foto o grabar video
  _showTemplateInfo() {
    try {
      return SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: ResizeImage(
                AssetImage(_showImage()),
                width: 390,
              ),
              width: 130,
              color: AppConfig.appThemeConfig.secondaryColor,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              _showTitle(),
              style: TextStyle(
                  color: AppConfig.appThemeConfig.secondaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            )
          ],
        ),
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _showTemplateInfo', fatal: true);
    }
  }

  //? Muestra la image para el template segun corresponda
  _showImage() {
    switch (widget.typeMedia) {
      case 'photo':
        return AppConfig.appThemeConfig.cameraPath;
      case 'video':
        return AppConfig.appThemeConfig.videoPath;
    }
  }

  Future<String?> _getIdentification() async {
    final dataInspection = await InspectionStorage()
        .getDataInspection(widget.idRequest.toString());
    if (dataInspection != null) {
      return dataInspection.identificacion;
    }
    return null;
  }

  //? Capa que se muestra encima del archivo que se esta (comprimiendo/subiendo)
  _processUploading() {
    try {
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: (!uploadingFailed)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image:
                          AssetImage(AppConfig.appThemeConfig.loadingGifPath),
                      height: 150,
                    ),
                    if (mediaCompressing)
                      Container(
                        constraints:
                            const BoxConstraints(maxWidth: 120, maxHeight: 40),
                        child: const Text(
                          'Comprimiendo..',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    if (widget.typeMedia == 'video' &&
                        mediaCompressing &&
                        Platform.isAndroid)
                      Container(
                        constraints:
                            const BoxConstraints(maxWidth: 120, maxHeight: 40),
                        child: Text(
                          '$compressionProcess % ',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    if (widget.typeMedia == 'video')
                      const Text(
                        'Esto podría tardar un poco según la duración del video',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                        ),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (mediaUploading)
                      const Text(
                        'Subiendo..',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    if (mediaUploading)
                      Text(
                        '${(cantBytes / cantTotalBytes * 100).toStringAsFixed(0)}/100',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                  ],
                )
              // : (isCompress)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage((widget.typeMedia == 'photo')
                          ? AppConfig.appThemeConfig.photoPath
                          : AppConfig.appThemeConfig.uploadVideoPath),
                      height: 120,
                    ),
                    const Text(
                      'No se pudo subir',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    if (widget.typeMedia == 'video')
                      Column(
                        children: const [
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            'Se hizo un respaldo del video en tu Galería, puedes intentar subirlo ahora o cuando tengas una mejor conexión',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        side: const BorderSide(width: 1.0, color: Colors.white),
                      ),
                      onPressed: (widget.typeMedia == 'photo')
                          ? _retryPhoto()
                          : _retryVideo(),
                      child: const Text("Reintentar"),
                    ),
                  ],
                ),
        ),
      );
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _processUploading', fatal: true);
    }
  }

  _retryCompressWidget() {
    try {
      return Container(
          height: double.infinity,
          width: double.infinity,
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image(
                image: AssetImage((widget.typeMedia == 'photo')
                    ? AppConfig.appThemeConfig.photoPath
                    : AppConfig.appThemeConfig.uploadVideoPath),
                height: 120,
              ),
              const Text(
                'No se pudo comprimir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              if (widget.typeMedia == 'video')
                Column(
                  children: const [
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Se realizará la compresión del video',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  side: const BorderSide(width: 1.0, color: Colors.white),
                ),
                onPressed: (widget.typeMedia == 'photo')
                    // ? _retryPhoto()
                    ? () {
                        debugPrint('comprime foto');
                      }
                    : _retryCompress(),
                // : _retryVideo(),
                child: const Text("Reintentar"),
              ),
            ]),
          ));
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _retryCompress', fatal: true);
    }
  }

  //? Reintentar subir Foto
  void Function()? _retryPhoto() {
    return () async {
      try {
        uploadingFailed = false;
        final mediaDataStorage =
            await MediaDataStorage().getMediaData(widget.idRequest);
        final mediaData = mediaDataStorage!
            .firstWhere((m) => m.idArchiveType == widget.idArchiveType);
        final mediaCompressed = mediaData.data;
        final mediaInbytes = Uint8List.fromList(mediaCompressed!);
        mediaUploading = true;
        final identification = await _getIdentification();
        final response = await _uploadMedia(
            idRequest: widget.idRequest,
            idArchiveType: widget.idArchiveType,
            identification: identification!,
            imageCompressed: mediaInbytes);
        if (response.error) {
          uploadingFailed = true;
        } else {
          _updateStatusMedia('UPLOADED', null);
          _successUploadingProcess();
        }
        setState(() {});
      } catch (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace,
            reason: 'Error en _retryPhoto', fatal: false);
        setState(() {
          uploadingFailed = true;
        });
      }
    };
  }

  //? reintentar comprimir video
  void Function()? _retryCompress() {
    return () async {
      try {
        uploadingFailed = false;
        processUploading = true;
        isCompress = true;
        final mediaDataStorage =
            await MediaDataStorage().getMediaData(widget.idRequest);
        final mediaData = mediaDataStorage!
            .firstWhere((m) => m.idArchiveType == widget.idArchiveType);
        final path = mediaData.path;
        mediaCompressing = true;
        // debugPrint('path: $path');
        final videoCompressed = await _compressVideo(XFile(path!));
        if (videoCompressed != null) {
          debugPrint('video comprsse path :  ${videoCompressed.path}');
          // choosenImageVideo!.path = videoCompressed.path;
          choosenImageVideo = XFile(videoCompressed.path);
          _updateStatusMedia('COMPRESSED', null, path: videoCompressed.path);
          mediaCompressing = false;
          mediaUploading = true;
          //? 2 SUBIMOS MEDIA
          final identification = await _getIdentification();
          final response = await _uploadMedia(
              idRequest: widget.idRequest,
              idArchiveType: widget.idArchiveType,
              identification: identification!,
              videoCompressed: videoCompressed);
          // await _checkIfFormIsComplete();
          if (response.error) {
            _updateStatusMedia('UPLOADED_FAILED', null);
            uploadingFailed = true;
            mediaUploading = false;
            cantBytes = 0;
            cantTotalBytes = 0;
          } else {
            debugPrint('exito');
            // _checkIfFormIsComplete();
            _successUploadingProcess();
            _updateStatusMedia('UPLOADED', null);
          }
          _checkIfFormIsComplete();
        } else {
          _updateStatusMedia("COMPRESS_FAILED", null);
          // choosenImageVideo = null;
        }

        setState(() {});
      } catch (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace,
            reason: 'Error en _retryVideo', fatal: false);
        setState(() {});
      }
    };
  }

  // //? Reintentar subir Video
  void Function()? _retryVideo() {
    return () async {
      try {
        uploadingFailed = false;
        final mediaDataStorage =
            await MediaDataStorage().getMediaData(widget.idRequest);

        final mediaData = mediaDataStorage!
            .firstWhere((m) => m.idArchiveType == widget.idArchiveType);

        final path = mediaData.path;
        debugPrint('path sin conexion: $path');
        mediaUploading = true;
        final identification = await _getIdentification();
        final response = await _uploadMedia(
            idRequest: widget.idRequest,
            idArchiveType: widget.idArchiveType,
            identification: identification!,
            videoCompressed: File(path!));
        if (response.error) {
          uploadingFailed = true;
        } else {
          _successUploadingProcess();
          _updateStatusMedia('UPLOADED', null);
        }
        setState(() {});
      } catch (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(error, stackTrace,
            reason: 'Error en _retryVideo', fatal: false);
        setState(() {});
      }
    };
  }

  //? Muestra la Imagen o video que se tomó
  _showImageOrVideo() {
    try {
      switch (widget.typeMedia) {
        case 'photo':
          return Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(AppConfig.appThemeConfig.photoPath),
                  color: Colors.green,
                  height: 180,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("CARGADO CORRECTAMENTE"),
              ],
            ),
          );
        case 'video':
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            alignment: Alignment.center,
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: AssetImage(AppConfig.appThemeConfig.videoPath),
                  color: Colors.green,
                  height: 180,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("CARGADO CORRECTAMENTE"),
              ],
            ),
          );
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _showImageOrVideo', fatal: false);
    }
  }

  //? Muestra el titulo informativo de la accion (Tomar foto/Video)
  _showTitle() {
    switch (widget.typeMedia) {
      case 'photo':
        return 'TOMAR FOTO';
      case 'video':
        return 'GRABAR VIDEO';
    }
  }

  //? Muestra un bottom modal con las respectivas opciones
  _showOptionsModal(String type, int idArchiveType, String description) {
    switch (type) {
      case 'photo':
        _showPhotoOptions(idArchiveType, description);
        break;
      case 'video':
        _showVideoOptions(idArchiveType, description);
        break;
      default:
        _showPhotoOptions(idArchiveType, description);
    }
  }

  //? Opciones para fotos: tomar foto o subir de galeria
  _showPhotoOptions(int idArchiveType, String description) {
    return showMaterialModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (photocontext) => SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              child:
                  //? TOMAFR FOTOS
                  InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  await _verifyCache(idArchiveType, 'photo');
                  // debugPrint('verify: $');
                  // XFile? choosenImage;
                  // choosenImage = await _openNativeCameraPhoto();
                  _takePhoto(idArchiveType, description, generic.Camera.widget);
                  
                },
                splashColor:
                    AppConfig.appThemeConfig.primaryColor.withOpacity(  0.5),
                child: Ink(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Image(
                          image: ResizeImage(
                              AssetImage(AppConfig.appThemeConfig.takePicPath),
                              height: 240,
                              width: 240),
                          color: AppConfig.appThemeConfig.secondaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Tomar una foto',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (choosenImageVideo != null)
              InkWell(
                onTap: () async {
                  final fp =
                      Provider.of<FunctionalProvider>(context, listen: false);
                  Navigator.pop(context);
                  final path = choosenImageVideo!.path;
                  debugPrint(path);
                  fp.showAlert(content: AlertShowImage(imagePath: path));
                },
                splashColor:
                    AppConfig.appThemeConfig.primaryColor.withOpacity( 0.5),
                child: Ink(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Image(
                          image: ResizeImage(
                              AssetImage(AppConfig.appThemeConfig.photoPath),
                              height: 240,
                              width: 240),
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Ver imagen cargada',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
            if (AppConfig.appEnv.gallerysImageEnabled)
              InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  Navigator.pop(context);
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    choosenImageVideo = image;
                    setState(() {});
                  }
                },
                splashColor:
                    AppConfig.appThemeConfig.primaryColor.withOpacity( 0.5),
                child: Ink(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Image(
                          image: AssetImage(AppConfig.appThemeConfig.photoPath),
                          color: AppConfig.appThemeConfig.secondaryColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Seleccionar una foto',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  _takePhoto(
      int idArchiveType, String description, generic.Camera typeCamera) async {
    XFile? choosenImage;
    choosenImage = await _openNativeCameraPhoto();
    if (choosenImage != null) {
      _imageGeneralProcess(choosenImage, idArchiveType);
    }
  }

  _imageGeneralProcess(XFile choosenImage, int idArchiveType) async {
    processUploading = true;
    setState(() {});
    choosenImageVideo = choosenImage;
    //? 1. COMPRIMIMOS MEDIA - IMAGE
    Logger().w('Imagen path_' + choosenImage.path);
    
    mediaCompressing = true;
    final imageCompressed = await _compressImage(choosenImageVideo!);
    if (imageCompressed != null) {
      _updateStatusMedia('COMPRESSED', imageCompressed,
          path: choosenImageVideo!.path);
      mediaCompressing = false;
      mediaUploading = true;
      //? 2 SUBIMOS MEDIA
      final identification = await _getIdentification();
      final response = await _uploadMedia(
          idRequest: widget.idRequest,
          idArchiveType: idArchiveType,
          identification: identification!,
          imageCompressed: imageCompressed);
      // print(response);

      if (response.error) {
        _updateStatusMedia('UPLOADED_FAILED', null);
        uploadingFailed = true;
        mediaUploading = false;
        cantBytes = 0;
        cantTotalBytes = 0;
      } else {
        _updateStatusMedia('UPLOADED', null);
        _successUploadingProcess();
      }
      _checkIfFormIsComplete();
    } else {
      _updateStatusMedia("COMPRESS_FAILED", null);
    }
    setState(() {});
  }
  // );

  // Future<XFile?> _openCameraWidgetPhoto(int idArchiveType, String description)async{
  //   final cameraDescription = await availableCameras();

  //                XFile? choosenImage = await Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => CameraWidget(
  //                               cameras: cameraDescription,
  //                               id: 2,
  //                               // uniqueKey: key,
  //                               idRequest: widget.idRequest,
  //                               description: description,
  //                               idArchiveType: idArchiveType,
  //                             )));
  //      return choosenImage;
  // }

  Future<XFile?> _openNativeCameraPhoto() async {
    final ImagePicker _picker = ImagePicker();
    XFile? choosenImage = await _picker.pickImage(source: ImageSource.camera);
    return choosenImage;
  }

  //verifica si hay un video y lo elimina.
  Future<void> _verifyCache(int idArchiveType, String typeMedia) async {
    final mediaStoraged =
        await MediaDataStorage().getMediaData(widget.idRequest);
      if(mediaStoraged != null){

    final mediaData = mediaStoraged
        .firstWhere((m) => m.idArchiveType == widget.idArchiveType);
    debugPrint('arcihvo: ${mediaData.status} - ${mediaData.isRequired}');
    if (mediaData.path != null) {
      var exist = await File(mediaData.path!).exists();
      if (exist) {
        await File(mediaData.path!).delete();
      }
      mediaData.path = null;
      mediaData.status = 'NO_MEDIA';
      choosenImageVideo = null;
      await _updateStatusMedia(
        'NO_MEDIA',
        null,
      );
      debugPrint('cambio el estatus');
      setState(() {});
      _checkIfFormIsComplete();
    }
      }
  }

  //? Muestra las opciones de video (grabar o seleccionar)
  _showVideoOptions(int idArchiveType, String description) {
    final mfp = Provider.of<FunctionalProvider>(context, listen: false);
    return showMaterialModalBottomSheet(
      context: context,
      isDismissible: true,
      elevation: 10,
      builder: (context) => SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            //? GRABAR VIDEO
            InkWell(
              onTap: () async {
                // mfp.formCompleted = false;

                // Helper.navigationFadeIn(context, Prueba(), 200);
                await _verifyCache(idArchiveType, 'video');
                Navigator.pop(context);
                mfp.setReverse = true;

                _recordVideo(idArchiveType, description, generic.Camera.widget);
              },
              child: Ink(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Image(
                        image: ResizeImage(
                            AssetImage(
                                AppConfig.appThemeConfig.recordVideoPath),
                            height: 240,
                            width: 240),
                        color: AppConfig.appThemeConfig.secondaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Grabar video',
                      style: TextStyle(
                          color: AppConfig.appThemeConfig.secondaryColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            if (choosenImageVideo != null)
              InkWell(
                onTap: () {
                  final fp =
                      Provider.of<FunctionalProvider>(context, listen: false);
                  Navigator.pop(context);
                  Helper.logger
                      .w('este es el path: ${choosenImageVideo!.path}');
                  final path = choosenImageVideo!.path;
                  // print(path);

                  (choosenImageVideo != null)
                      ? fp.showAlert(content: AlertShowVideo(videoPath: path))
                      : const CircularProgressIndicator();
                },
                child: Ink(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        child: Image(
                          image: ResizeImage(
                              AssetImage(
                                  AppConfig.appThemeConfig.uploadVideoPath),
                              height: 240,
                              width: 240),
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Ver video cargado',
                        style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ),
              ),
            //! CUANDO SE NECESITE QUE LOS VIDEOS SE PUEDAN SELECCIONAR DESDE GALERIA
            // if (AppConfig.appEnv.gallerysVideoEnabled)
            //   InkWell(
            //     onTap: () async {
            //       Navigator.pop(context);
            //       final ImagePicker _picker = ImagePicker();
            //       final XFile? video =
            //           await _picker.pickVideo(source: ImageSource.gallery);
            //       if (video != null) {
            //         choosenImageVideo = video;
            //         vpController = VideoPlayerController.file(
            //             File(choosenImageVideo!.path))
            //           ..initialize();
            //       }
            //       setState(() {});
            //     },
            //     child: Ink(
            //       child: Column(
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           SizedBox(
            //             width: 80,
            //             child: Image(
            //               image: AssetImage(
            //                   AppConfig.appThemeConfig.uploadVideoPath),
            //               color: AppConfig.appThemeConfig.secondaryColor,
            //             ),
            //           ),
            //           const SizedBox(
            //             height: 10,
            //           ),
            //           Text(
            //             'Seleccionar un video',
            //             style: TextStyle(
            //                 color: AppConfig.appThemeConfig.secondaryColor,
            //                 fontWeight: FontWeight.w400),
            //           )
            //         ],
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  _recordVideo(
      int idArchiveType, String description, generic.Camera typeCamera) async {
    // recordVideo({required int idArchiveType, XFile? choosenVideo}) async {
    // XFile? choosenVideo;
    // final choosenVideo = await _openNativeCameraVideo();
    final choosenVideo = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (contexto) => CameraPage(
            durationVideo: widget.durationVideo,
            idTypeArchive: idArchiveType,
          ),
        ));

    if (choosenVideo != null) {
      await _videoGeneralProcess(XFile(choosenVideo), idArchiveType);
    }
    setState(() {});
  }
  Future _videoGeneralProcess(XFile choosenVideo, int idArchiveType) async {
    //AQUI SE GUARDA EL VIDEO SUPUESTAMENTE

    choosenImageVideo = choosenVideo;
    await _updateStatusMedia('RECORDED', null, path: choosenVideo.path);
    isCompress = true;
    processUploading = true;
    Logger().w('video general path: ${choosenVideo.path}');
    setState(() {});
    // vpController = VideoPlayerController.file(File(choosenImageVideo!.path))
    //   ..initialize();
    setState(() {});
    //? 1. COMPRIMIMOS MEDIA - VIDEO
    mediaCompressing = true;
    // await Future.delayed(const Duration(milliseconds: 1000));

    final videoCompressed = await _compressVideo(choosenImageVideo!);
    if (videoCompressed != null) {
      Helper.logger.e('entra en compresion');
      mediaCompressing = false;
      choosenImageVideo = XFile(videoCompressed.path);
      await _updateStatusMedia('COMPRESSED', null, path: videoCompressed.path);
      await _checkIfFormIsComplete();
      mediaUploading = true;
      //? 2 SUBIMOS MEDIA
      final identification = await _getIdentification();
      final response = await _uploadMedia(
          idRequest: widget.idRequest,
          idArchiveType: idArchiveType,
          identification: identification!,
          videoCompressed: videoCompressed);
      if (response.error) {
        _updateStatusMedia('UPLOADED_FAILED', null);
        uploadingFailed = true;
        mediaUploading = false;
        cantBytes = 0;
        cantTotalBytes = 0;
      } else {
        debugPrint('exito');
        // _checkIfFormIsComplete();
        _successUploadingProcess();
        _updateStatusMedia('UPLOADED', null);
      }
      // _checkIfFormIsComplete();
    } else {
      _updateStatusMedia("COMPRESS_FAILED", null);
      // choosenImageVideo = null;
    }

    setState(() {});
  }

  //? SUBIR MEDIA
  Future<GeneralResponse<dynamic>> _uploadMedia({
    required int idRequest,
    required int idArchiveType,
    required String identification,
    Uint8List? imageCompressed,
    File? videoCompressed,
  }) async {
    try {
      final fp = Provider.of<FunctionalProvider>(context, listen: false);
      if(!fp.offline){
         MediaType mediaType = (widget.typeMedia == 'photo')
          ? MediaType('image', 'jpg')
          : MediaType('video', 'mp4');

        final response = await MediaService().uploadMedia(
          context: context,
          idRequest: widget.idRequest,
          idArchiveType: idArchiveType,
          identification: identification,
          mediaPhoto: imageCompressed,
          mediaVideo: videoCompressed,
          mediaType: mediaType,
          showAlertError: false,
          onProgressLoad: ((p0, p1) {
            setState(() {
              cantBytes = p0;
              cantTotalBytes = p1;
            });
          }),
        );

        log(jsonEncode(response));

        return response;
      }else{
        //Helper.snackBar(context: context, colorSnackBar: Colors.red, message: 'No tienes conexión a internet, porque estas en modo offline.');
        return GeneralResponse(message: 'no cuentas con conexión a internet.', error: true);
      }
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace,
          reason: 'Error en _uploadMedia', fatal: false);
      return GeneralResponse<dynamic>(
        error: true,
        message:
            'Error al subir el archivo. Por favor, inténtalo nuevamente más tarde.',
        data: null,
      );
    }
  }

  //? Limpia la pantalla cuando el proceso tiene exito
  _successUploadingProcess() {
    processUploading = false;
    mediaUploading = false;
    mediaCompressing = false;
    uploadingFailed = false;
    cantBytes = 0;
    cantTotalBytes = 0;
  }

  //? Actualiza el status de la media en cuestion
  _updateStatusMedia(String status, Uint8List? mediaCompressed,
      {String? path}) async {
    final mediaStoraged =
        await MediaDataStorage().getMediaData(widget.idRequest);
    final mediaData = mediaStoraged!
        .firstWhere((m) => m.idArchiveType == widget.idArchiveType);
    switch (status) {
      case 'COMPRESS_FAILED':
        mediaData.status = 'COMPRESS_FAILED';
        break;
      case 'COMPRESSED':
        if (widget.typeMedia == 'photo') {
          mediaData.data = mediaCompressed;
          mediaData.path = path;

          // _checkIfFormIsComplete();
        } else {
          Helper.logger.w('compresion: $path');
          mediaData.path = path;
          // _checkIfFormIsComplete();
        }
        mediaData.status = 'COMPRESSED';
        break;
      case 'NO_MEDIA':
        debugPrint('entra en no media');
        mediaData.status = 'NO_MEDIA';
        break;
      case 'UPLOADED_FAILED':
        mediaData.status = 'UPLOADED_FAILED';
        break;
      case 'UPLOADED':
      //  File(mediaData.path!).delete();
        // mediaData.data = null;
        mediaData.status = 'UPLOADED';

        break;
      
      case 'VERIFY':
        break;
      case 'RECORDED':
        //? ESTO SOLO SE HACE CUANDO EL DISPOSITIVO ANDROID ES version 8.1...
        mediaData.path = path;
        mediaData.status = 'RECORDED';
        break;
    }
    if (status != 'VERIFY') {
      MediaDataStorage().setMediaData(widget.idRequest, mediaStoraged);
    }
    //AQUI DEBERIA QUITARLO TAL VEZ
    // _checkIfFormIsComplete();
  }

  //?Verificamos
  _checkIfFormIsComplete() async {
    BuildContext contexSend = context;
    final mediaStoraged =
        await MediaDataStorage().getMediaData(widget.idRequest);
    var mediaIncomplete = false;
    for (var media in mediaStoraged!) {
      debugPrint('verify form ${media.type}:${media.isRequired} - ${media.status}');
      if (media.status == 'RECORDED') {
        mediaIncomplete = true;
      }
      if (media.isRequired == 'true' && media.status == 'NO_MEDIA') {
        //NO puedo CONTINUAR
        mediaIncomplete = true;
        debugPrint('Incompleto');
      }
    }
    final mfp = Provider.of<MediaFormProvider>(contexSend, listen: false);
    if (!mediaIncomplete) {
      debugPrint('media completa');
      mfp.formCompleted = true;
    } else {
      debugPrint('media incompleta');
      mfp.formCompleted = false;
    }
    setState(() {
      
    });
  }

  //? Compresion de imagenes
  Future<Uint8List>? _compressImage(XFile file) async {

    final tempDir = await getExternalStorageDirectory();
    // var path = tempDir.path;
    //  var lastSeparator = file.path.lastIndexOf(Platform.pathSeparator);

    //  var newPath = path.substring(0, lastSeparator + 1) +
    //             '${widget.idRequest}_${widget.idArchiveType}.jpg';
  //  File file = await File('${tempDir?.path}/${widget.idRequest}_${widget.idArchiveType}.jpg').create();
  //   file.absolute.createSync(recursive: true);
    Logger().w(tempDir?.path ?? '');
    var result = await FlutterImageCompress.compressWithFile(file.path,
        quality: 40, rotate: 0,);
    if(tempDir != null){
     final file = File(tempDir.path+'/${widget.idRequest}_${widget.idArchiveType}.jpg');
     file.writeAsBytesSync(result?.buffer.asInt8List() ?? []);
      final result1 = List<int>.from(result!);
     file.writeAsBytesSync(result1);
    Logger().w(file.path);
    choosenImageVideo = XFile(file.path);
    }
    return result!;
  }


Future<File?> _compressVideo(XFile file) async {
  if (!Platform.isAndroid) return null;

  try {
    // Validar archivo de entrada
    final originalFile = File(file.path);
    // if (!await originalFile.exists() || file.path.isEmpty) {
    //   Logger().e('Archivo de entrada inválido o no existe: ${file.path}');
    //   _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
    //   return null;
    // }

    // Verificar tamaño del archivo para prevenir OutOfMemoryError
    // final fileSize = await originalFile.length();
    // Logger().w('Tamaño del video: $fileSize bytes');
    // const maxFileSize = 500 * 1024 * 1024; // 500 MB
    // if (fileSize > maxFileSize) {
    //   Logger().e('Archivo demasiado grande: $fileSize bytes');
    //   _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
    //   return null;
    // }

    // Configurar suscripción para progreso
    final subscription = vc.VideoCompress.compressProgress$.subscribe((progress) {
      setState(() {
        compressionProcess = progress.toStringAsFixed(2);
      });
    });

    try {
      // Comprimir video
      final result = await vc.VideoCompress.compressVideo(
        file.path,
        frameRate: 15,
      );

      // Limpiar suscripción
      subscription.unsubscribe();

      // Validar resultado
      if (result == null || result.path == null || result.path!.isEmpty) {
        Logger().e('Compresión fallida: resultado nulo o ruta vacía');
        _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
        return null;
      }

      final compressedFile = File(result.path!);
      // if (!await compressedFile.exists()) {
      //   Logger().e('Archivo comprimido no existe: ${result.path}');
      //   _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
      //   return null;
      // }

      // Verificar tamaño del archivo comprimido
      final compressedSize = await compressedFile.length();
      if (compressedSize == 0) {
        Logger().e('Archivo comprimido tiene 0 bytes: ${result.path}');
        _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
        await compressedFile.delete();
        return null;
      }

      // Renombrar archivo
      final lastSeparator = result.path!.lastIndexOf(Platform.pathSeparator);
      if (lastSeparator == -1) {
        Logger().e('Ruta inválida para renombrar: ${result.path}');
        _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
        await compressedFile.delete();
        return null;
      }
      final newPath =
          '${result.path!.substring(0, lastSeparator + 1)}${widget.idRequest}_${widget.idArchiveType}.mp4';
      final newFile = await compressedFile.rename(newPath);

      // Eliminar archivo original
      try {
        await originalFile.delete();
        Logger().w('Archivo original eliminado: ${originalFile.path}');
        Logger().w('Nuevo archivo: ${newFile.path}');
      } catch (e) {
        Logger().w('No se pudo eliminar el archivo original: $e');
      }

      // Restablecer estado
      setState(() {
        compressionProcess = '0.00';
      });

      return newFile;
    } finally {
      // Asegurar que la suscripción se limpie incluso si hay un error
      subscription.unsubscribe();
    }
  } catch (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(
      error,
      stackTrace,
      reason: 'Error en _compressVideo: $error',
      fatal: false,
    );
    _updateStatusMedia('COMPRESS_FAILED', null, path: file.path);
    setState(() {
      compressionProcess = '0.00';
    });
    return null;
  }
}

  // Future<File?> _compressVideo(XFile file) async {
  //   try {
  //     if (Platform.isAndroid) {
  //       final originalFile = File(file.path);
  //       Helper.logger
  //           .w('archivo original ${originalFile.path}');
  //       _subscription = vc.VideoCompress.compressProgress$.subscribe((event) {
  //         compressionProcess = event.toStringAsFixed(2);
  //         setState(() {});
  //         String tmpPorcent = compressionProcess;
  //         String tmpPorcentResult =
  //             tmpPorcent.replaceAll(RegExp('[^0-9.]'), '');
  //         int? porcentInt = int.tryParse(tmpPorcentResult);
  //         if ((porcentInt ?? 0) >= 100 || tmpPorcent.contains("100.0")) {
  //           _subscription.unsubscribe();
  //           compressionProcess = '0.00';
  //         }
  //       });
  //       // debugPrint('video compress process path: ${originalFile.path}');
  //       final result = await vc.VideoCompress.compressVideo(
  //         file.path,
  //         frameRate: 15,
  //         // quality: vc.VideoQuality.Res640x480Quality
  //         // startTime: 1,
  //         // duration: 1,
  //       );

  //       _subscription.unsubscribe();
  //   Logger().w('resultado: ${result?.file?.path}');
  //       final compressedFile = File(result?.path ?? '');
  //       Logger().w('comprresed file:  ${compressedFile.path}');
  //       //con esto comprobamos si el archivo tiene 0 bytes. aun quedan cosas por considerar
  //       // if(compressedFile.existsSync() && compressedFile.lengthSync()!= 0){
  //       if (compressedFile.existsSync()) {
  //         var path = result?.path;
  //         var lastSeparator = path?.lastIndexOf(Platform.pathSeparator) ?? -1;
  //         if (lastSeparator != -1) {
  //           var newPath = path!.substring(0, lastSeparator + 1) +
  //               '${widget.idRequest}_${widget.idArchiveType}.mp4';

  //           final newFile = await File(result?.path ?? '').rename(newPath);

  //           await originalFile.delete();
  //           Logger().w('Archivo original eliminado: ${originalFile.path}');
  //           Logger().w('nuevo archivo:  ${newFile.path}');

  //           return newFile;
  //         }
  //         //  else {

  //         // _subscription.unsubscribe();
  //         //   _updateStatusMedia('CCOMPRESS_FAILED', null, path: originalFile.path);}
  //       }
  //     }
  //   } catch (error, stackTrace) {
  //     FirebaseCrashlytics.instance.recordError(error, stackTrace,
  //         reason: 'Error en _compressVideo', fatal: false);
  //   }
  //   return null;
  // }

  // Future<File> _compressVideo(XFile file) async {
  //   try {
  //     if (Platform.isAndroid) {
  //       final originalFile = File(file.path);

  //       _subscription = vc.VideoCompress.compressProgress$.subscribe((event) {
  //         compressionProcess = event.toStringAsFixed(2);
  //         setState(() {});
  //         String tmpPorcent = compressionProcess;
  //         String tmpPorcentResult =
  //             tmpPorcent.replaceAll(RegExp('[^0-9.]'), '');
  //         int? porcentInt = int.tryParse(tmpPorcentResult);
  //         if ((porcentInt ?? 0) >= 100 || tmpPorcent.contains("100.0")) {
  //           _subscription.unsubscribe();
  //           compressionProcess = '0.00';
  //         }
  //       });

  //       final result = await vc.VideoCompress.compressVideo(
  //         file.path,
  //         quality: vc.VideoQuality.Res640x480Quality,
  //         frameRate: 15,
  //       );

  //       _subscription.unsubscribe();

  //       if (result != null && result.path != null && result.path!.isNotEmpty) {
  //         final compressedFile = File(result.path!);

  //         if (compressedFile.existsSync()) {
  //           var path = result.path;
  //           var lastSeparator = path!.lastIndexOf(Platform.pathSeparator);

  //           if (lastSeparator != -1) {
  //             var newPath = path.substring(0, lastSeparator + 1) +
  //                 '${widget.idRequest}_${widget.idArchiveType}.mp4';

  //             final newFile = await compressedFile.rename(newPath);

  //             await originalFile.delete();
  //             print('Archivo original eliminado: ${originalFile.path}');

  //             return newFile;
  //           }
  //         }
  //       }
  //     }
  //   } catch (error, stackTrace) {
  //     FirebaseCrashlytics.instance.recordError(
  //       error,
  //       stackTrace,
  //       reason: 'Error en _compressVideo',
  //       fatal: false,
  //     );
  //   }
  //   return File(file.path);
  // }

}

class CameraPage extends StatefulWidget {
  final int idTypeArchive;
  final int durationVideo;
  const CameraPage({super.key, required this.durationVideo, required this.idTypeArchive});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  static const int _totalTime = 0; // Total time in seconds (2 minutes)
  int _remainingTime = _totalTime;
  Timer? _timer;

  bool _isLoading = true;
  bool _isRecording = false;
  bool _flashActive = false;
  late CameraController _cameraController;

  @override
  void initState() {
    // Navigator.pop(context);
    _initCamera();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'camera', context: context);
    });
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime <= widget.durationVideo - 1) {
          _remainingTime++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  String get timerText {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    if(mounted){

    BackButtonInterceptor.removeByName('camera');
    _cameraController.dispose();
    _timer?.cancel();
    }
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back);
    _cameraController = CameraController(
      back,
      ResolutionPreset.medium,
    );
    await _cameraController.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo() async {
    if (_isRecording) {
    if(_remainingTime == 0){
      return;
    }
      _timer!.cancel();
      _remainingTime = 0;
      final file = await _cameraController.stopVideoRecording();
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(
          filePath: file.path,
        ),
      );
      Navigator.push(context, route);
    } else {
      //TODO: arreglar esto
      await _cameraController.prepareForVideoRecording();
      startTimer();
      setState(() => _isRecording = true);
      await _cameraController.startVideoRecording();
      await Future.delayed(Duration(seconds: widget.durationVideo));
      Helper.logger.w('hace esto');
      if(mounted){

      final file = await _cameraController.stopVideoRecording();
      _timer!.cancel();
      _remainingTime = 0;
      setState(() => _isRecording = false);
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoPage(
          filePath: file.path,
        ),
      );
      Navigator.push(context, route);
      }

      // Future.delayed(
      //   const Duration(minutes: 2),
      //   () async {
      //     final file = await _cameraController.stopVideoRecording();
      //     setState(() => _isRecording = false);
      //     final route = MaterialPageRoute(
      //       fullscreenDialog: true,
      //       builder: (_) => VideoPage(filePath: file.path),
      //     );
      //    Navigator.push(context, route);

      //   },
      // );
    }
  }

  bool myInterceptor(bool stopreturn, RouteInfo info) {
    // Navigator.pop(context);
    Navigator.pop(context);
    debugPrint(
        'holllllll---------------------------------------------------------');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return Center(
        child: Stack(children: [
          CameraPreview(_cameraController),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(width: 2, color: Colors.white)),
                    child: Text(
                      timerText,
                      style: const TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
               Padding(
                  padding: const EdgeInsets.all(25),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FloatingActionButton(
                        heroTag: 'detener video',
                        backgroundColor: Colors.red,
                        child: Icon(_isRecording ? Icons.stop : Icons.circle),
                        onPressed: () => _recordVideo(),
                      ),
                      FloatingActionButton(
                        heroTag: 'flash',
                        backgroundColor: Colors.blue,
                        child: Icon(_flashActive
                            ? Icons.flash_on_sharp
                            : Icons.flash_off_sharp),
                        onPressed: () {
                          if (!_flashActive) {
                            _cameraController.setFlashMode(FlashMode.torch);
                            _flashActive = true;
                          } else {
                            _cameraController.setFlashMode(FlashMode.off);
                            _flashActive = false;
                          }
                          setState(() {
                            
                          });
                        },
                      ),
                    ],
                  ),
                ),              ],
            ),
          )
        ]),
      );
    }
  }
}

class VideoPage extends StatefulWidget {
  final String filePath;
  const VideoPage({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.filePath));
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true);
    await _videoPlayerController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview'),
        elevation: 0,
        backgroundColor: Colors.black26,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, widget.filePath);
              // widget.onPressed(
              //     idTypeArchive: 1, filepath: XFile(widget.filePath));
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: (context, state) {
          if (state.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return VideoPlayer(_videoPlayerController);
          }
        },
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  static const int _totalTime = 0; // Total time in seconds (2 minutes)
  int _remainingTime = _totalTime;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime <= 119) {
          _remainingTime++;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get timerText {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(width: 2, color: Colors.white)),
        child: Text(
          timerText,
          style: const TextStyle(
              fontSize: 30, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
