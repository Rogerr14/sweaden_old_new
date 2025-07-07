part of 'review_request_widgets.dart';

class FacturaForm extends StatefulWidget {
  final int idRequest;
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  const FacturaForm(
      {Key? key,
      required this.idRequest,
      required this.onNextFlag,
      required this.onBackFlag})
      : super(key: key);

  @override
  State<FacturaForm> createState() => _FacturaFormState();
}

class _FacturaFormState extends State<FacturaForm> 
with AutomaticKeepAliveClientMixin {
  ContinueInspection inspectionData = ContinueInspection();
  bool photo = false;
  XFile? factura;
  String? base64Image;

  @override
  void initState() {
    super.initState();
    _getDataStorage();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Factura",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppConfig.appThemeConfig.secondaryColor)),
        _space(10),
        Text("Por favor, tome foto de la factura para CONTINUAR el proceso",
            style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor)),
        _space(16),
        Expanded(
            child: InkWell(
          onTap: () {
            _showPhotoOptions();
          },
          child: photo
              ? Container(
                  height: 150,
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(
                    File(factura!.path),
                  ),
                )
              : Container(
                  // height: 150,
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage(AppConfig.appThemeConfig.cameraPath),
                        width: 130,
                        color: AppConfig.appThemeConfig.secondaryColor,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'TOMAR FOTO',
                        style: TextStyle(
                            color: AppConfig.appThemeConfig.secondaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      )
                    ],
                  ),
                ),
        )),
        SizedBox(
          height: 50,
          child: Row(
            children: [
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
                              AppConfig.appThemeConfig.secondaryColor),
                      onPressed: () {
                        widget.onBackFlag(true);
                      },
                      child: const Text(
                        'REGRESAR',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              if (!photo) const Expanded(child: SizedBox()),
              if (photo)
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
                          _saveDataStorage();
                          widget.onNextFlag(true);
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
    );
  }
  @override
  bool get wantKeepAlive => true;

  SizedBox _space(double height) {
    return SizedBox(height: height);
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
      inspectionData = continueInspection;
    }

    inspectionData.factura = base64Image;

    InspectionStorage()
        .setDataInspection(inspectionData, widget.idRequest.toString());
    photo = true;
    setState(() {});
  }

//? Opciones para fotos: tomar foto o subir de galeria
  _showPhotoOptions() {
    return showMaterialModalBottomSheet(
      context: context,
      elevation: 10,
      builder: (photocontext) => SizedBox(
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              child: InkWell(
                onTap: () async {
                  final ImagePicker _picker = ImagePicker();
                  Navigator.pop(context);
                  // final cameraDescription = await availableCameras();
                  XFile? choosenImage = await _picker.pickImage(source: ImageSource.camera);
                  // = await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => CameraWidget(
                  //               cameras: cameraDescription,
                  //               id: 2,
                  //               idRequest: widget.idRequest,
                  //               description: 'Factura',
                  //               saveStorage: false,
                  //             )));
                  if (choosenImage != null) {
                    factura = choosenImage;
                    base64Image = base64Encode(await factura!.readAsBytes());
                    setState(() {});
                    _saveDataStorage();
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
                          image:
                              AssetImage(AppConfig.appThemeConfig.takePicPath),
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
                      )
                    ],
                  ),
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
                    factura = image;
                    base64Image = base64Encode(await factura!.readAsBytes());
                    setState(() {});
                    _saveDataStorage();
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
}
