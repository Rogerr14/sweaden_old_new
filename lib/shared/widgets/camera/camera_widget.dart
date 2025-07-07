part of '../shared_widgets.dart';

class CameraWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  // final int id;
  // final int? idArchiveType;
  //? PARA MOSTRAR EL TITULO DE LA DESCRIPCION
  final String description;
  //?PARA SABER SI ES FOTO/VIDEO
  final String? type;
  // final int idRequest;
  final bool? saveStorage;

  const CameraWidget({
    super.key,
    required this.cameras,
    // required this.id,
    required this.description,
    // this.idArchiveType,
    this.type = 'photo',
    // required this.idRequest,
    this.saveStorage = true,
  });

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  late CameraController cameraController;
  VideoPlayerController? vpController;
  XFile? pictureFile;
  XFile? videoFile;
  String indicatorCount = '00:00';
  Timer? timer;
  int count = 0;

  @override
  void initState() {
    super.initState();
    debugPrint("PREFERENCES");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BackButtonInterceptor.add(myInterceptor,
          name: 'camera', context: context);
    });
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);

    cameraController =
        CameraController(widget.cameras[0], ResolutionPreset.high);

    _inizializeCamera();
  }

  _inizializeCamera() async {
    cameraController.initialize().then((value) async {
      if (!mounted) {
        return;
      } else {
        await cameraController.setFlashMode(FlashMode.off);
        // await cameraController.setFocusMode(FocusMode.locked);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    if (widget.type == 'video') {
      timer?.cancel();
      if (vpController != null) {
        vpController!.dispose();
      }
    }
    BackButtonInterceptor.removeByName('camera');
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    _dismiss();

    return true;
  }

  _dismiss() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) {
      return const SizedBox(
          child: Center(
        child: CircularProgressIndicator(),
      ));
    }
    final size = MediaQuery.of(context).size;
    return ChangeNotifierProvider(
      create: (context) => CameraProvider(),
      builder: (newContext, child) {
        final isRecording =
            newContext.select((CameraProvider cp) => cp.isRecording);

        return SafeArea(
          child: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: SizedBox(
                      width: size.width,
                      child: Stack(
                        children: [
                          Positioned(
                              top: 0,
                              right: 0,
                              left: 0,
                              child: CameraPreview(cameraController)),
                          if (isRecording) _recordingIndicator(),
                        ],
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  height: size.height * .15,
                  color: Colors.white,
                  child: GestureDetector(
                      // controller: sweadenServices.btnCameraController,
                      onTap: () async {
                        // await cameraController.lockCaptureOrientation();
                        switch (widget.type) {
                          case 'photo':
                            _takePicture();
                            break;
                          case 'video':
                            _recordVideo(newContext);
                            break;
                          case 'face':
                            _takePictureFace();
                            break;
                          default:
                            _takePicture();
                        }

                        setState(() {});
                      },
                      child: _typeButton()),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  _recordingIndicator() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 10,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ZoomIn(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(30)),
            child: Text(
              indicatorCount,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  _typeButton() {
    switch (widget.type) {
      case 'photo':
        return const PhotoButton();
      case 'video':
        return const VideoButton();
      case 'face':
        return const PhotoButton();
      default:
        return const PhotoButton();
    }
  }

  _takePicture() async {
    pictureFile = await cameraController.takePicture();

    bool setPhoto = await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => Material(
              type: MaterialType.transparency,
              child: SizedBox(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      color: Colors.white,
                      child: Text(widget.description,
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Image.file(File(pictureFile!.path)),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              icon: const Icon(
                                Icons.highlight_remove_outlined,
                                size: 40,
                              ),
                              onPressed: () {
                                Navigator.pop(context, false);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: IconButton(
                              icon: const Icon(
                                Icons.check_circle_outline_outlined,
                                size: 40,
                              ),
                              onPressed: () async {
                                // widget.saveStorage!
                                // ? _updateMediaDataStorage(pictureFile!.path)
                                // :
                                //  null;
                                Navigator.pop(context, true);
                              },
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
    if (setPhoto) {
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pop(context, pictureFile);
      });
    }
  }

  _takePictureFace() async {
    pictureFile = await cameraController.takePicture();
    final faceDetector =
        gmlkit.FaceDetector(options: gmlkit.FaceDetectorOptions());
    final inputImage = gmlkit.InputImage.fromFilePath(pictureFile!.path);
    final List<gmlkit.Face> faces = await faceDetector.processImage(inputImage);

    bool setPhoto = await showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => Material(
              type: MaterialType.transparency,
              child: SizedBox(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: double.infinity,
                      color: Colors.white,
                      child: Text('${widget.description} ${faces.length}',
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 18)),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Image.file(File(pictureFile!.path)),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                              height: 80,
                              width: 80,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.highlight_remove_outlined,
                                  size: 40,
                                ),
                                onPressed: () {
                                  Navigator.pop(context, false);
                                },
                              )),
                          if (faces.isNotEmpty)
                            SizedBox(
                              height: 80,
                              width: 80,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.check_circle_outline_outlined,
                                  size: 40,
                                ),
                                onPressed: () async {
                                  // _updateMediaDataStorage(pictureFile!.path);
                                  Navigator.pop(context, true);
                                },
                              ),
                            )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
    if (setPhoto) {
      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.pop(context, pictureFile);
      });
    }
  }

  // _updateMediaDataStorage(String? path) async {
  //   final mediaStoraged =
  //       await MediaDataStorage().getMediaData(widget.idRequest);
  //   final mediaData = mediaStoraged!
  //       .firstWhere((m) => m.idArchiveType == widget.idArchiveType);
  //   mediaData.path = path;
  //   mediaData.status = 'RECORDED';
  //   MediaDataStorage().setMediaData(widget.idRequest, mediaStoraged);
  // }

  //?CAMERA PACKAGE
  _recordVideo(BuildContext newContext) async {
    final cp = newContext.read<CameraProvider>();
    cp.isRecording = !cp.isRecording;
    if (cp.isRecording) {
      await cameraController.prepareForVideoRecording();
      _initCount(newContext);

      await cameraController.startVideoRecording();

      // await cameraController.startVideoRecording();
    } else {
      _stopCount(newContext);
    }
  }

  //?CAMERA PACKAGE
  _stopCount(BuildContext newContext) async {
    final cp = newContext.read<CameraProvider>();
    cp.isRecording = false;
    timer?.cancel();
    indicatorCount = '00:00';
    count = 0;
    videoFile = await cameraController.stopVideoRecording();

    vpController = VideoPlayerController.file(File(videoFile!.path))
      ..initialize().then((value) async {
        bool setVideo = await showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => Material(
                  type: MaterialType.transparency,
                  child: SizedBox(
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 50,
                          width: double.infinity,
                          color: Colors.white,
                          child: Text(widget.description,
                              style: TextStyle(
                                  color:
                                      AppConfig.appThemeConfig.secondaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18)),
                        ),
                        Expanded(
                          child: SizedBox(
                            child: (vpController!.value.isInitialized)
                                ? _videoScreen()
                                : Container(
                                    height: 10,
                                    width: 10,
                                    color: Colors.red,
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.highlight_remove_outlined,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    if (vpController!.value.isPlaying) {
                                      vpController!.pause();
                                    }
                                    cameraController = CameraController(
                                        widget.cameras[0],
                                        ResolutionPreset.high);
                                    await cameraController.initialize();
                                    setState(() {});
                                    Navigator.pop(context, false);
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 80,
                                width: 80,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.check_circle_outline_outlined,
                                    size: 40,
                                  ),
                                  onPressed: () async {
                                    // _updateMediaDataStorage(videoFile!.path);
                                    // widget.saveStorage!
                                    //     ? _updateMediaDataStorage(
                                    //         videoFile!.path)
                                    //     : null;
                                    Navigator.pop(context, true);
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ));
        if (setVideo) {
          Future.delayed(const Duration(milliseconds: 800), () {
            Navigator.pop(context, videoFile);
          });
        }
      });
    // }).catchError((onError) async {
    //   print("Error STOPVIDEO++++++");
    //   inspect(onError);

    //   setState(() {});
    // });

    setState(() {});
  }

  //?CAMERA PACKAGE
  _videoScreen() {
    return AspectRatio(
      aspectRatio: vpController!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(vpController!),
          InkWell(
            onTap: () {
              if (vpController!.value.isPlaying) {
                vpController!.pause();
              } else {
                vpController!.play();
              }
              setState(() {});
            },
            child: FadeOut(
              animate: true,
              delay: const Duration(milliseconds: 800),
              child: Container(
                  color: Colors.black54,
                  height: double.infinity,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image:
                            AssetImage(AppConfig.appThemeConfig.tapToPlayPath),
                        height: 60,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text("Tap to play",
                          style: TextStyle(color: Colors.white, fontSize: 20))
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }

  //?CAMERA PACKAGE
  _initCount(BuildContext newContext) {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      count++;
      if (count < 10) {
        indicatorCount = '00:0$count';
      } else if (count > 9 && count < 60) {
        indicatorCount = '00:$count';
      }
      var seconds = 0;
      if (count > 60) {
        seconds = count - 60;
        if (seconds < 10) {
          indicatorCount = '01:0$seconds';
        } else {
          indicatorCount = '01:$seconds';
          if (count == 120) {
            _stopCount(newContext);
          }
        }
      }

      setState(() {});
    });
  }
}

class PhotoButton extends StatelessWidget {
  const PhotoButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppConfig.appThemeConfig.secondaryColor,
          borderRadius: BorderRadius.circular(150)),
      child: Container(
        height: 73,
        width: 73,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(150)),
        child: Container(
            height: 67,
            width: 67,
            decoration: BoxDecoration(
                color: AppConfig.appThemeConfig.primaryColor,
                borderRadius: BorderRadius.circular(150))),
      ),
    );
  }
}

class VideoButton extends StatelessWidget {
  const VideoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isRecording = context.select((CameraProvider cp) => cp.isRecording);
    return Container(
      height: 80,
      width: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: AppConfig.appThemeConfig.secondaryColor,
          borderRadius: BorderRadius.circular(150)),
      child: Container(
        height: 73,
        width: 73,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(150)),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: (isRecording) ? 40 : 67,
            width: (isRecording) ? 40 : 67,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular((isRecording) ? 3 : 150))),
      ),
    );
  }
}
