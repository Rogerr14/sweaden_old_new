part of 'review_request_widgets.dart';

class FacialRecognitionForm extends StatefulWidget {
  final int idRequest;
  final void Function() onSetFlag;
  final ValueChanged<bool> onBackFlag;
  const FacialRecognitionForm(
      {Key? key, required this.idRequest, required this.onSetFlag, required this.onBackFlag})
      : super(key: key);

  @override
  State<FacialRecognitionForm> createState() => _FacialRecognitionFormState();
}

class _FacialRecognitionFormState extends State<FacialRecognitionForm> {
  ContinueInspection inspectionData = ContinueInspection();
  bool faceValid = false;
  XFile? facePhoto;
  String? base64Image;

  @override
  void initState() {
    super.initState();
    _getDataStorage();
  }

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(builder: (context, constraint){
      return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraint.maxHeight),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Reconocimiento facial",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppConfig.appThemeConfig.secondaryColor)),
              _space(10),
              Text(
                  "Por favor, mire a la cámara y ubique su rostro dentro del espacio señalado",
                  style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor)),
              _space(16),
              const Expanded(child: SizedBox()),
              Container(
                // height: 150,
                width: double.infinity,
                color: Colors.white,
                child: Image(
                  image: AssetImage(AppConfig.appThemeConfig.facialRecognitionPath),
                  color: (!faceValid)
                      ? AppConfig.appThemeConfig.secondaryColor
                      : Colors.green,
                ),
              ),
              const Expanded(child: SizedBox()),
              SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 13),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor:
                                  AppConfig.appThemeConfig.secondaryColor),
                          onPressed: () async {
                            //? SE CAMBIO A CAMARA NATIVA y se AGREGO BAKEORIENTATION PARA IOS
                             final fp = Provider.of<FunctionalProvider>(context,listen:false);
                            //  final ImagePicker _picker = ImagePicker();
                             await _verifyCache();
                            //?   <<<<Metodo en produccion>>>>
                            //?  XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                            //  XFile? photo = await _picker.pickImage(source: ImageSource.gallery);
                             XFile? photo = await _openCameraWidgetPhoto('Rostros detectados: ');
                             if(photo!=null){
                               fp.showAlert(content: const AlertLoading());
                              //?   <<<<Metodo en produccion>>>>
                              //?  final success = await _verifyFace(photo);
                              //? if (success) {
                              
                              facePhoto = photo;
                              
                              base64Image =
                                  base64Encode(await facePhoto!.readAsBytes());
                                fp.dismissAlert(); 
                              faceValid = true;
          
                              setState(() {});
                              //? }
                             }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.camera,
                                  color: AppConfig.appThemeConfig.primaryColor),
                              const Text(
                                'TOMAR FOTO',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (!faceValid) const Expanded(child: SizedBox()),
                    if (faceValid)
                      Expanded(
                        child: FadeInRight(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 16),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  backgroundColor:
                                      AppConfig.appThemeConfig.primaryColor),
                              onPressed: () {
                                // _saveDataStorage();
                                _openOtp();
                              },
                              child: const Text(
                                'CONTINUAR',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
    });
  }

  Future<XFile?> _openCameraWidgetPhoto(
    /*int idArchiveType,*/
     String description)async{
    final cameraDescription = await availableCameras();

    XFile? choosenImage = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraWidget(
                cameras: cameraDescription,
                // id: 2,
                // uniqueKey: key,
                // idRequest: widget.idRequest,
                description: description,
                // idArchiveType: idArchiveType,
                type:'face'
          )));
       return choosenImage;                       
  }

  SizedBox _space(double height) {
    return SizedBox(height: height);
  }

  Future<void> _verifyCache()async {
    if(facePhoto != null){
      var exist = await File(facePhoto!.path).exists();
        if(exist){
          await File(facePhoto!.path).delete();
        }
    }
  }
  // ? COMENTAMOS POR SI SE USA EN UN FUTURO
  // Future<bool> _verifyFace(XFile photo)async{
  //   final fp = Provider.of<FunctionalProvider>(context,listen:false);
  //    if (Platform.isIOS) {
  //       await Future.delayed(const Duration(milliseconds: 1000));
  //     }
  //   List<gmlkit.Face> faces =await processPickedFile( photo);
    
  //   if(faces.isNotEmpty){
  //      return true;
  //   }else{
  //    fp.showAlert(content: const AlertGenericError(message: "No se detectaron rostros en la imagen"));
  //     return false;
  //   }
  // }

  Future<List<gmlkit.Face>> processPickedFile(XFile pickedFile) async {
    // final path = pickedFile.path;
    final faceDetector =
        gmlkit.FaceDetector(options: gmlkit.FaceDetectorOptions());
    gmlkit.InputImage inputImage;
    if (Platform.isIOS) {
      final File iosImageProcessed =
          await bakeImageOrientation(pickedFile);
      inputImage = gmlkit.InputImage.fromFilePath(iosImageProcessed.path);
    } else {
      final File androidImageProcessed =
          await bakeImageOrientation(pickedFile);
      inputImage = gmlkit.InputImage.fromFilePath(androidImageProcessed.path);
    }
    debugPrint(
        'INPUT IMAGE PROCESSED: ${inputImage.filePath} - ${inputImage.type}');
        List<gmlkit.Face> faces = await faceDetector.processImage(inputImage);
    debugPrint('Found ${faces.length} faces for picked file');
    return faces;
  }

  bakeImageOrientation(XFile pickedFile) async {
    // if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final filename = DateTime.now().millisecondsSinceEpoch.toString();

      final imglib.Image? capturedImage =
          imglib.decodeImage(await File(pickedFile.path).readAsBytes());

      final imglib.Image orientedImage = imglib.bakeOrientation(capturedImage!);

      final imageToBeProcessed = await File('$path/$filename')
          .writeAsBytes(imglib.encodeJpg(orientedImage));

      return imageToBeProcessed;
    // }
    // return null;
  }

  _openOtp() {
    _saveDataStorage();
    _connectionInternet();
  }

  _connectionInternet() async {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    //final internet = await Helper.checkConnection();
    if(!fp.offline){
      fp.showAlert(
          content: OtpModal(
        celular: inspectionData.celular ?? '',
        email: inspectionData.email ?? '',
        idSolicitud: widget.idRequest.toString(),
        onConfirmFlag: _validOtp,
      ));
    }else{
      widget.onSetFlag();
    }
    
  }

  _validOtp(v) {
    widget.onSetFlag();
  }

  _getDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.idRequest.toString());
    if (continueInspection != null) {
      inspectionData = continueInspection;
    }
  }

  _saveDataStorage() async {
    ContinueInspection? continueInspection = await InspectionStorage()
        .getDataInspection(widget.idRequest.toString());

    if (continueInspection != null) {
      log('EXISTE DATA STORAGE: ${continueInspection.toJson()}');
      inspectionData = continueInspection;
    }
    inspectionData.base64Image = base64Image;
    InspectionStorage().setDataInspection(inspectionData, widget.idRequest.toString());
  }
}
