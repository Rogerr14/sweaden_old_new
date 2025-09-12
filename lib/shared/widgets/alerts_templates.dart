part of 'shared_widgets.dart';

class AlertLoseProcess extends StatelessWidget {
  const AlertLoseProcess({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Image(
              image: ResizeImage(
                  AssetImage(AppConfig.appThemeConfig.processAlertImagePath),
                  height: 300),
              height: 100,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              '¿ Estas seguro ?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              'El proceso en curso no se guardará',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor: AppConfig.appThemeConfig.primaryColor),
                    onPressed: () async {
                      final fp = Provider.of<FunctionalProvider>(context,
                          listen: false);
                      fp.dismissAlert();
                    },
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        backgroundColor:
                            AppConfig.appThemeConfig.secondaryColor),
                    onPressed: () {
                      final fp = Provider.of<FunctionalProvider>(context,
                          listen: false);
                      RequestDataStorage().removeRequestData();
                      fp.dismissAlert();
                      // fp.setIdInspection(null);
                      UserDataStorage().removeIdInspection();
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: const HomePage(),
                              type: PageTransitionType.leftToRightWithFade));
                    },
                    child: const Text("SALIR"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AlertLoading extends StatelessWidget {
  const AlertLoading({super.key, this.title = 'Cargando...'});

  final String? title;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          height: 180,
          width: 240,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image(
                      image:
                          AssetImage(AppConfig.appThemeConfig.loadingGifPath),
                      fit: BoxFit.fill)),
              Positioned(
                  bottom: 0,
                  child: Text(title ?? 'Cargando...',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )))
            ],
          ),
        ),
      ),
    );
  }
}

class AlertOutdatedApplication extends StatelessWidget {
  // final String? title;
  final String message;
  final String urlAndroid;
  final String urliOS;
  const AlertOutdatedApplication(
      {super.key,
      // required this.title,
      required this.message,
      required this.urlAndroid,
      required this.urliOS});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Image(
                  image: AssetImage(AppConfig.appThemeConfig.warningPath)),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "ERROR DE VERSION",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                onPressed: () async {
                  final Uri _urlAndroid = Uri.parse(urlAndroid);
                  final Uri _urliOS = Uri.parse(urliOS);
                  if (Platform.isAndroid) {
                    await launchUrl(_urlAndroid);
                  }
                  if (Platform.isAndroid) {
                    await launchUrl(_urliOS);
                  }
                },
                child: const Text("Descargar versión actual"))
          ],
        ),
      ),
    );
  }
}

class AlertIncompleteFields extends StatelessWidget {
  const AlertIncompleteFields({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: Image(
                  image: AssetImage(AppConfig.appThemeConfig.warningPath)),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Campos Incompletos'.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Por favor llena todos los campos para iniciar sesión.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                onPressed: () async {
                  fp.dismissAlert();
                },
                child: const Text("Entendido"))
          ],
        ),
      ),
    );
  }
}

class AlertGenericError extends StatelessWidget {
  final String message;
  final String? messageButton;
  final void Function()? onPress;
  const AlertGenericError(
      {super.key, required this.message, this.messageButton, this.onPress});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image(
                      image: AssetImage(AppConfig.appThemeConfig.warningPath)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor:
                            AppConfig.appThemeConfig.secondaryColor),
                    onPressed: (onPress != null)
                        ? onPress
                        : () async {
                            fp.dismissAlert();
                          },
                    child: Text(messageButton ?? 'volver a intentar'))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AlertLogOut extends StatelessWidget {
  const AlertLogOut({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        height: 135,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Text(
              '¿ Desea cerrar sesión ?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppConfig.appThemeConfig.primaryColor),
                        onPressed: () async {
                          // fp.dismissAlert();
                          // Future.delayed(const Duration(milliseconds: 800),
                          // () async {
                          // if(HomePage.serviceStatusStream != null){
                          //   HomePage.serviceStatusStream!.cancel();
                          //   HomePage.serviceStatusStream = null;
                          // }

                          if (HomePage.positionStream != null) {
                            debugPrint('Cancelando stream');
                            HomePage.positionStream!.cancel();
                            //HomePage.positionStream!.pause();
                            HomePage.positionStream = null;
                          }
                          fp.dismissAlert();
                          fp.setSession(false);
                          //HomePage.timer.cancel();
                          //fp.setLoggedIn(false);
                          Helper.stopBackgroundService();
                          UserDataStorage().removeUserData();
                          UserDataStorage().activeBackgroundService(true);
                          Navigator.pushReplacement(
                              context,
                              Helper.navigationFadeIn(
                                  context, const LoginPage(), 1500));
                          // });
                        },
                        child: const Text(
                          'SI',
                          style: TextStyle(fontSize: 18),
                        ))),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey),
                        onPressed: () {
                          fp.dismissAlert();
                        },
                        child: const Text(
                          'NO',
                          style: TextStyle(fontSize: 18),
                        ))),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AlertNoLocationSelectec extends StatelessWidget {
  const AlertNoLocationSelectec({super.key});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
        type: MaterialType.transparency,
        child: Container(
          height: 310,
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              SizedBox(
                height: 80,
                child: Image(
                    image: AssetImage(AppConfig.appThemeConfig.locationPath)),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'No ha seleccionado ninguna ubicación',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'no podrá CONTINUAR el proceso si no selecciona una ubicación.',
                textAlign: TextAlign.justify,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppConfig.appThemeConfig.primaryColor),
                          onPressed: () async {
                            fp.dismissAlert(summoner: 'google-map');
                          },
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(fontSize: 18),
                          ))),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          onPressed: () {
                            fp.dismissAlert(summoner: 'google-map');
                            fp.buttonMapEnable = true;
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Salir',
                            style: TextStyle(fontSize: 18),
                          ))),
                ],
              )
            ],
          ),
        ));
  }
}

class AlertSuccess extends StatelessWidget {
  final String message;
  final String? messageButton;
  final void Function()? onPress;
  const AlertSuccess(
      {super.key, required this.message, this.messageButton, this.onPress});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: BounceInDown(
                    child: Image(
                        image: ResizeImage(
                            AssetImage(AppConfig.appThemeConfig.successPath),
                            height: 240,
                            width: 240)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (messageButton != null)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          backgroundColor:
                              AppConfig.appThemeConfig.secondaryColor),
                      onPressed: (onPress != null)
                          ? onPress
                          : () async {
                              fp.dismissAlert();
                            },
                      child: Text(messageButton ?? 'listo!'))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AlertCoverages extends StatelessWidget {
  final List<DataRow> coverages;
  const AlertCoverages({super.key, required this.coverages});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),
        height: 300,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(
              height: 15,
            ),
            Text(
              'LISTA DE COBERTURAS',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[700]),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 3,
                horizontalMargin: 10,
                checkboxHorizontalMargin: 0,
                // headingRowHeight: 0,
                showBottomBorder: true,
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.grey.shade300),
                columns: [
                  DataColumn(
                    label: SizedBox(
                        child: Text('ACCESORIOS',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                  ),
                  DataColumn(
                    label: SizedBox(
                        width: 40,
                        child: Text('INC.',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                  ),
                  DataColumn(
                    label: SizedBox(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('SUMA',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        Text('ASEGURADA',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ],
                    )),
                  ),
                  DataColumn(
                    label: SizedBox(
                        width: 40,
                        child: Text('TASA',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)),
                  ),
                  DataColumn(
                    label: SizedBox(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PRIMA',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        Text('NETA',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center)
                      ],
                    )),
                  ),
                ],
                rows: coverages,
              ),
            )),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.appThemeConfig.primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    fp.dismissAlert();
                  },
                  child: const Text('CERRAR')),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}

class AlertResendMedia extends StatefulWidget {
  final int idRequest;
  final String identification;
  final List<MediaStorage> mediaData;
  const AlertResendMedia(
      {super.key,
      required this.mediaData,
      required this.idRequest,
      required this.identification});

  @override
  State<AlertResendMedia> createState() => _AlertResendMediaState();
}

class _AlertResendMediaState extends State<AlertResendMedia> {
  String messageError = '';

  void updateInspectionStatus(int idArchiveType, String newStatus) {
    final index = Helper.mediaStatus
        .indexWhere((item) => item.idArchiveType == idArchiveType);

    if (index != -1) {
      setState(() {
        final updatedList = Helper.mediaStatus.toList();
        updatedList[index].status = newStatus.toString();
        Helper.mediaStatus = updatedList;
      });
    }
  }

  Widget getIcon(List<MediaResponse> mediaStatus, int idArchiveType) {
    final index =
        mediaStatus.indexWhere((item) => item.idArchiveType == idArchiveType);
    if (mediaStatus[index].status == 'cargando') {
      return const RotatingIcon(icon: Icon(Icons.sync, color: Colors.white));
    } else if (mediaStatus[index].status == 'error') {
      return const Icon(Icons.close_rounded, color: Colors.white);
    } else if (mediaStatus[index].status == 'exito') {
      return const Icon(Icons.check, color: Colors.white);
    } else if (mediaStatus[index].status == 'upload') {
      return const Icon(Icons.upload, color: Colors.white);
    } else {
      return const Icon(Icons.abc, color: Colors.white);
    }
  }

  Color getColor(List<MediaResponse> mediaResponse, int idArchiveType) {
    {
      final index = mediaResponse
          .indexWhere((item) => item.idArchiveType == idArchiveType);
      if (index != -1) {
        if (mediaResponse[index].status == 'cargando') {
          return AppConfig.appThemeConfig.secondaryColor;
        } else if (mediaResponse[index].status == 'error') {
          return Colors.red;
        } else if (mediaResponse[index].status == 'exito') {
          return Colors.green;
        } else if (Helper.mediaStatus[index].status == 'upload') {
          return AppConfig.appThemeConfig.secondaryColor;
        } else {
          return Colors.blue;
        }
      } else {
        return Colors.white;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Helper.logger.w('multimedia: ${jsonEncode(widget.mediaData)}');
    final size = MediaQuery.of(context).size;
    //List<bool> uploaded = [];

    final fp = Provider.of<FunctionalProvider>(context, listen: false);

    bool loadingInspection =
        context.watch<FunctionalProvider>().loadingInspection;

    Helper.logger.w('mediaStatus: ${jsonEncode(Helper.mediaStatus)}');

    return Material(
      type: MaterialType.transparency,
      child: Container(
        alignment: Alignment.center,
        height: size.height * .6,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Container(
              height: 40,
              alignment: Alignment.center,
              child: Text("Archivos faltantes:",
                  style: TextStyle(
                      color: AppConfig.appThemeConfig.secondaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
            ),
            const Divider(),
            Expanded(
                child: ListView.builder(
              itemCount: widget.mediaData.length,
              itemBuilder: (context, index) {
                final item = widget.mediaData[index];
                return ListTile(
                  leading: Icon((item.type == 'image')
                      ? Icons.photo
                      : Icons.video_file_rounded),
                  title: Text(widget.mediaData[index].description),
                  trailing: Material(
                    shape: const CircleBorder(),
                    color: (Helper.mediaStatus
                            .map((e) => e.idArchiveType)
                            .contains(item.idArchiveType)
                        ? getColor(Helper.mediaStatus, item.idArchiveType)
                        : AppConfig.appThemeConfig.secondaryColor),
                    child: IconButton(
                      splashRadius: 23,
                      onPressed: !loadingInspection
                          ?
                          //!mediaStatus.any((media) => media.idArchiveType == item.idArchiveType && media.status == 'cargando')  ?
                          () async {
                              fp.setLoadingInspection(true);
                              Helper.mediaStatus.any((media) =>
                                      media.idArchiveType == item.idArchiveType)
                                  ? updateInspectionStatus(
                                      item.idArchiveType, 'cargando')
                                  : Helper.mediaStatus.add(MediaResponse(
                                      idSolicitud: widget.idRequest,
                                      status: 'cargando',
                                      idArchiveType: item.idArchiveType));
                              setState(() {});
                              OfflineStorage()
                                  .setMediaStatus(Helper.mediaStatus);
                              // await Future.delayed(const Duration(seconds: 5),() {
                              //       //updateInspectionStatus(item.idArchiveType, 'upload');
                              //       //controll.reset();
                              //   });
                              try {
                                var image = Uint8List(0);
                                if (widget.mediaData[index].type == 'image') {
                                  image = Uint8List.fromList(
                                      await File(widget.mediaData[index].path!).readAsBytes());
                                }
                                MediaType mediaType =
                                    (widget.mediaData[index].type == 'image')
                                        ? MediaType('image', 'jpg')
                                        : MediaType('video', 'mp4');
                                Uint8List? mediaPhoto =
                                    (widget.mediaData[index].type == 'image')
                                        ? image
                                        : null;
                                File? mediaVideo =
                                    (widget.mediaData[index].type == 'video')
                                        ? File(widget.mediaData[index].path!)
                                        : null;

                                final response =
                                    await MediaService().uploadMedia(
                                  context: context,
                                  idRequest: widget.idRequest,
                                  idArchiveType:
                                      widget.mediaData[index].idArchiveType,
                                  identification: widget.identification,
                                  mediaType: mediaType,
                                  mediaPhoto: mediaPhoto,
                                  mediaVideo: mediaVideo,
                                  showAlertError: false,
                                );
                                if (!response.error) {
                                  updateInspectionStatus(
                                      item.idArchiveType, 'exito');
                                  OfflineStorage()
                                      .setMediaStatus(Helper.mediaStatus);
                                  fp.setLoadingInspection(false);
                                  //mediaStatus.any((media) => media.idArchiveType == item.idArchiveType) ?  updateInspectionStatus(item.idArchiveType, 'exito') : mediaStatus.add(MediaResponse(idSolicitud: widget.idRequest, status: 'exito', idArchiveType: item.idArchiveType));
                                  //setState(() {});
                                  //controll.success();
                                  //uploaded.add(true);
                                } else {
                                  updateInspectionStatus(
                                      item.idArchiveType, 'error');
                                  OfflineStorage()
                                      .setMediaStatus(Helper.mediaStatus);
                                  //fp.setLoadingInspection(false);
                                  //mediaStatus.any((media) => media.idArchiveType == item.idArchiveType) ?  updateInspectionStatus(item.idArchiveType, 'error') : mediaStatus.add(MediaResponse(idSolicitud: widget.idRequest, status: 'error', idArchiveType: item.idArchiveType));
                                  //setState(() {});
                                  //controll.error();
                                  //uploaded.add(false);
                                  await Future.delayed(
                                      const Duration(seconds: 1), () {
                                    updateInspectionStatus(
                                        item.idArchiveType, 'upload');
                                    OfflineStorage()
                                        .setMediaStatus(Helper.mediaStatus);
                                    fp.setLoadingInspection(false);
                                    //controll.reset();
                                  });

                                  // if(response.message.length >= 300) {
                                  //   messageError = 'Ocurrio un error, intente de nuevo.';
                                  //   setState(() {});
                                  // }else{
                                  //   messageError = response.message;
                                  //   setState(() {});
                                  // }
                                }
                              } on Exception catch (e, s) {
                                updateInspectionStatus(
                                    item.idArchiveType, 'error');
                                OfflineStorage()
                                    .setMediaStatus(Helper.mediaStatus);
                                fp.setLoadingInspection(false);
                                const snackBar = SnackBar(
                                    content: Text(
                                        'Ocurrio un error al cargar el archivo'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                FirebaseCrashlytics.instance.recordError(e, s,
                                    reason: 'Error en subir archivo',
                                    fatal: true);
                              }
                            }
                          : null,
                      icon: Helper.mediaStatus
                              .map((e) => e.idArchiveType)
                              .contains(item.idArchiveType)
                          ? getIcon(Helper.mediaStatus, item.idArchiveType)
                          : const Icon(Icons.upload_rounded,
                              color: Colors.white),
                    ),
                  ),
                );
              },
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _button(
                    nameButton: 'Cerrar',
                    colorButton: AppConfig.appThemeConfig.primaryColor,
                    onPressed: !loadingInspection
                        ? () async {
                            Helper.logger.w(
                                'widget.mediaData.length: ${widget.mediaData.length}');
                            Helper.logger.w(
                                'json media: ${json.encode(Helper.mediaStatus)}');
                            Helper.logger
                                .w('mediaStatus: ${Helper.mediaStatus.length}');
                            Helper.logger.w(
                                'media cargadas con exito: ${json.encode(Helper.mediaStatus.where((e) => e.status == 'exito').toList().length)}');

                            if ((Helper.mediaStatus
                                    .where((e) => e.status == 'exito')
                                    .toList()
                                    .length) ==
                                widget.mediaData.length) {
                              await MediaDataStorage()
                                  .removeMediaData(widget.idRequest);
                              fp.dismissAlert();
                            } else {
                              fp.dismissAlert();
                            }

                            Navigator.pushReplacement(
                                context,
                                PageTransition(
                                    child: const ReviewRequestPage(),
                                    type: PageTransitionType
                                        .leftToRightWithFade));
                          }
                        : null),
                _button(
                  nameButton: 'Cargar todo',
                  colorButton: AppConfig.appThemeConfig.primaryColor,
                  onPressed: !loadingInspection
                      ? () async {
                          fp.setLoadingInspection(true);
                          List<MediaStorage> listMediaCopy =
                              List.from(widget.mediaData);
                          for (var e in listMediaCopy) {
                            Helper.mediaStatus.any((media) =>
                                    media.idArchiveType == e.idArchiveType)
                                ? updateInspectionStatus(
                                    e.idArchiveType, 'cargando')
                                : Helper.mediaStatus.add(MediaResponse(
                                    idSolicitud: widget.idRequest,
                                    status: 'cargando',
                                    idArchiveType: e.idArchiveType));
                            OfflineStorage().setMediaStatus(Helper.mediaStatus);
                            setState(() {});
                            var image = Uint8List(0);
                            if (e.type == 'image') {
                              image = Uint8List.fromList(
                                  await File(e.path!).readAsBytes());
                            }
                            final response = await MediaService().uploadMedia(
                              context: context,
                              idRequest: widget.idRequest,
                              idArchiveType: e.idArchiveType,
                              identification: widget.identification,
                              mediaType: e.type == 'image'
                                  ? MediaType('image', 'jpg')
                                  : MediaType('video', 'mp4'),
                              mediaPhoto: (e.type == 'image')
                                  // ? Uint8List.fromList(e.data!)
                                  ? image
                                  : null,
                              mediaVideo:
                                  (e.type == 'video') ? File(e.path!) : null,
                              showAlertError: false,
                            );

                            if (!response.error) {
                              fp.setLoadingInspection(false);
                              updateInspectionStatus(e.idArchiveType, 'exito');
                              OfflineStorage()
                                  .setMediaStatus(Helper.mediaStatus);
                            } else {
                              updateInspectionStatus(e.idArchiveType, 'error');
                              OfflineStorage()
                                  .setMediaStatus(Helper.mediaStatus);
                              await Future.delayed(const Duration(seconds: 1),
                                  () {
                                fp.setLoadingInspection(false);
                                updateInspectionStatus(
                                    e.idArchiveType, 'upload');
                                OfflineStorage()
                                    .setMediaStatus(Helper.mediaStatus);
                              });
                            }

                            if ((Helper.mediaStatus
                                    .where((e) => e.status == 'exito')
                                    .toList()
                                    .length) ==
                                widget.mediaData.length) {
                              Helper.mediaStatus.clear();
                              OfflineStorage()
                                  .setMediaStatus(Helper.mediaStatus);
                              await MediaDataStorage()
                                  .removeMediaData(widget.idRequest);
                              fp.dismissAlert();

                              Navigator.pushReplacement(
                                  context,
                                  PageTransition(
                                      child: const ReviewRequestPage(),
                                      type: PageTransitionType
                                          .leftToRightWithFade));
                            }
                          }
                        }
                      : null,
                )
              ],
            ),
            const SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  Expanded _button(
      {required String nameButton,
      required Color colorButton,
      required void Function()? onPressed}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              backgroundColor: colorButton),
          onPressed: onPressed,
          child: Text(nameButton),
        ),
      ),
    );
  }
}

class AlertShowImage extends StatelessWidget {
  final String imagePath;
  const AlertShowImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          margin: const EdgeInsets.symmetric(vertical: 20),
          height: 470,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Image.file(
                File(imagePath),
                height: 380,
              ),
              IconButton(
                onPressed: () {
                  fp.dismissAlert();
                },
                icon: const Icon(Icons.highlight_remove_outlined),
                color: AppConfig.appThemeConfig.secondaryColor,
                iconSize: 35,
              )
            ],
          )),
    );
  }
}

class AlertShowVideo extends StatefulWidget {
  final String videoPath;
  const AlertShowVideo({super.key, required this.videoPath});

  @override
  State<AlertShowVideo> createState() => _AlertShowVideoState();
}

class _AlertShowVideoState extends State<AlertShowVideo> {
  VideoPlayerController? vpController;
  bool isReady = false;
  @override
  void initState() {
    _initializeVideo();
    super.initState();
  }

  _initializeVideo() async {
    vpController = VideoPlayerController.file(File(widget.videoPath));
    await vpController?.initialize();
    isReady = true;
    setState(() {});
  }

  @override
  void dispose() {
    vpController!.dispose();
    vpController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Material(
      type: MaterialType.transparency,
      child: Container(
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          margin: const EdgeInsets.symmetric(vertical: 20),
          // height: 470,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (isReady) _videoScreen(),
              IconButton(
                onPressed: () {
                  fp.dismissAlert();
                },
                icon: const Icon(Icons.highlight_remove_outlined),
                color: AppConfig.appThemeConfig.secondaryColor,
                iconSize: 35,
              )
            ],
          )),
    );
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
}

class AlertConfirm extends StatelessWidget {
  final String message;
  //final String? messageButton;

  final void Function()? confirm;
  final void Function()? cancel;

  const AlertConfirm(
      {super.key,
      required this.message,
      //this.messageButton,
      this.confirm,
      this.cancel});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Image(
                      image: AssetImage(AppConfig.appThemeConfig.warningPath)),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor:
                                AppConfig.appThemeConfig.secondaryColor),
                        onPressed: (cancel != null)
                            ? cancel
                            : () async {
                                fp.dismissAlert();
                              },
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor:
                                AppConfig.appThemeConfig.primaryColor),
                        onPressed: confirm,
                        // onPressed: formCompleted
                        //     ? () {
                        //         if (!selectedOption && observacion.isEmpty) {
                        //           debugPrint("Porfavor indique la observación");
                        //         } else {
                        //           Helper.dismissKeyboard(context);
                        //           fp.dismissAlert();
                        //           //Helper.logger.e('Anio vehiculo: ${widget.anioVehiculo}');
                        //      // Helper.logger.e('Anio permitido: ${widget.anioPermitido}');
                        //           widget.onConfirmFlag(EmitPolize(
                        //               emit: selectedOption,
                        //               observacion: observacion));
                        //         }
                        //       }
                        //     : null,
                        child: const Text("Confirmar"),
                      ),
                    ),
                  ],
                ),
                // ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //         shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(12)),
                //         primary: AppConfig.appThemeConfig.secondaryColor),
                //     onPressed: (onPress != null)
                //         ? onPress
                //         : () async {
                //             fp.dismissAlert();
                //           },
                //     child: Text(messageButton ?? 'volver a intentar'))
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AlertSignature extends StatelessWidget {
  final String message;
  final String? messageButton;
  final void Function()? onPress;
  final SignatureController signatureController;

  const AlertSignature(
      {super.key,
      required this.message,
      this.messageButton,
      this.onPress,
      required this.signatureController});

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            // height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w400, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                        style: ButtonStyle(
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                            backgroundColor: WidgetStateProperty.all<Color>(
                                AppConfig.appThemeConfig.primaryColor)),
                        onPressed: () {
                          signatureController.clear();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Limpiar'))),
                //Align(alignment:Alignment.centerRight,child: IconButton(onPressed: (){signatureController.clear();}, icon: Icon(Icons.clear))),
                const SizedBox(height: 10),
                SizedBox(
                  child: Signature(
                      //dynamicPressureSupported: true,
                      //width: 100,
                      height: 250,
                      controller: signatureController),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor:
                                AppConfig.appThemeConfig.secondaryColor),
                        onPressed: () async {
                          signatureController.clear();
                          fp.dismissAlert();
                        },
                        child: Text(messageButton ?? 'Cancelar')),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            backgroundColor:
                                AppConfig.appThemeConfig.secondaryColor),
                        onPressed: onPress,
                        // : () async {
                        //     fp.dismissAlert();
                        //   },
                        child: Text(messageButton ?? 'Finalizar')),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
