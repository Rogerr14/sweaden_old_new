part of '../review_request_widgets.dart';

class MediaFormWidget extends StatefulWidget {
  final int idRequest;
  final int durationVideo;
  final List<MediaInfo> mediaInfo;
  final ValueChanged<bool> onNextFlag;
  final ValueChanged<bool> onBackFlag;
  const MediaFormWidget({
    Key? key,
    required this.durationVideo,
    required this.mediaInfo,
    required this.idRequest,
    required this.onNextFlag,
    required this.onBackFlag,
  }) : super(key: key);

  @override
  State<MediaFormWidget> createState() => _MediaFormWidgetState();
}

class _MediaFormWidgetState extends State<MediaFormWidget>
    with AutomaticKeepAliveClientMixin {
  bool imageFormat = false;
  bool videoFormat = false;
  // List<MediaStorage> mediaStorage = [];
  List<MediaInfo> images = [];
  List<MediaInfo> videos = [];
  //? TABS
  UniqueKey tabPics = UniqueKey();
  UniqueKey tabVideo = UniqueKey();
  late UniqueKey tabSelected;

  //? PAGEVIEW CONTROLLER - TYPE MEDIA (FOTO|VIDEO)
  PageController mediaTypeController = PageController(initialPage: 0);

  @override
  void initState() {
    tabSelected = tabVideo;
    //tabSelected = tabPics; //ORIGINAL
    _sortMediaData();
    _createStorageForMedia();

    super.initState();
  }

  @override
  void dispose() {
    mediaTypeController.dispose();
    super.dispose();
  }

  _createStorageForMedia() async {
    //?Verificamos si ya existe una lista de media
    final mediaData = await MediaDataStorage().getMediaData(widget.idRequest);
    if (mediaData == null) {
      List<MediaStorage> mediaStorage = widget.mediaInfo
          .map((e) => MediaStorage(
              type: e.tipoArchivo,
              idArchiveType: e.idTipoArchivo,
              description: e.detalle,
              isRequired: e.obligatorio,
              path: null,
              status: 'NO_MEDIA'))
          .toList();
      MediaDataStorage().setMediaData(widget.idRequest, mediaStorage);
    }
  }

  _sortMediaData() {
    for (var mediaItem in widget.mediaInfo) {
      // print("LLEGA DATA");
      switch (mediaItem.tipoArchivo) {
        case 'video':
          if (!videoFormat) {
            videoFormat = true;
          }
          videos.add(mediaItem);
          break;
        case 'image':
          if (!imageFormat) {
            imageFormat = true;
          }
          images.add(mediaItem);
          break;
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final size = MediaQuery.of(context).size;

    return ChangeNotifierProvider(
      create: (context) => MediaFormProvider(),
      builder: (newContext, child) {
        final formCompleted =
            newContext.select((MediaFormProvider mfp) => mfp.formCompleted);
        return Material(
          type: MaterialType.transparency,
          child: Container(
            key: tabVideo,
            //key: tabPics, //ORIGINAL
            height: size.height,
            width: size.width,
            color: Colors.white,
            // child: SingleChildScrollView(
            child: Column(
              children: [
                //? FOTOS O VIDEO
                _mediaTypes(),
                const SizedBox(
                  height: 8,
                ),
                //! TOMAR FOTO O VIDEO
                Expanded(
                  child: PageView(
                    controller: mediaTypeController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (imageFormat)
                        VideosTab(durationVideo: widget.durationVideo, idRequest: widget.idRequest, videos: videos),
                      if (videoFormat)
                        PicsTab(durationVideo: widget.durationVideo, idRequest: widget.idRequest, images: images),
                        //ORIGINAL
                      // if (imageFormat)
                      //   PicsTab(idRequest: widget.idRequest, images: images),
                      // if (videoFormat)
                      //   VideosTab(idRequest: widget.idRequest, videos: videos),
                    ],
                  ),
                ),
                //? BOTONES NAVEGACION
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(4),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor:
                                  AppConfig.appThemeConfig.secondaryColor),
                          onPressed: () {
                            widget.onBackFlag(true);
                          },
                          child: Row(
                            children: const [
                              Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              Text(
                                'REGRESAR',
                                style: TextStyle(color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                      if (formCompleted)
                        FadeInRight(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 18),
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
                    ],
                  ),
                )
              ],
            ),
            // ),
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  _saveDataStorage() async {
    bool incompletes = false;
    String idIncompletes = '';
    final mediaStoraged =
        await MediaDataStorage().getMediaData(widget.idRequest);
    for (var i in mediaStoraged!) {
      if (i.status != 'UPLOADED' && i.status != 'NO_MEDIA') {
        // print("HAY UN INCOMPLETO");
        // print('${i.idArchiveType} - ${i.type} - ${i.status}');
        incompletes = true;
        if (idIncompletes.isEmpty) {
          idIncompletes = '${i.idArchiveType}';
        } else {
          idIncompletes = '$idIncompletes,${i.idArchiveType}';
        }
      }
    }
    if (!incompletes) {
      idIncompletes = '0';
    }

    final dataInspection = await InspectionStorage()
        .getDataInspection(widget.idRequest.toString());

    dataInspection!.cantidadArchivosTratadoEnviar = idIncompletes;

    InspectionStorage()
        .setDataInspection(dataInspection, widget.idRequest.toString());
  }

  Widget _mediaTypes() {
    return SizedBox(
      height: 35,
      child: Row(
        children: [
          if (imageFormat)
           Expanded(
                child: InkWell(
              onTap: () {
                _navigateToPage(0);
                setState(() {
                  tabSelected = tabVideo;
                });
              },
              child: Container(
                key: tabVideo,
                alignment: Alignment.center,
                height: double.infinity,
                child: Text(
                  'Video',
                  style: TextStyle(
                      color: (tabSelected == tabVideo)
                          ? Colors.white
                          : AppConfig.appThemeConfig.secondaryColor,
                      fontWeight: FontWeight.w700),
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppConfig.appThemeConfig.secondaryColor),
                    color: (tabSelected == tabVideo)
                        ? AppConfig.appThemeConfig.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5)),
              ),
            )),
            // Expanded(
            //     child: InkWell(
            //   onTap: () {
            //     _navigateToPage(0);
            //     tabSelected = tabPics;

            //     setState(() {});
            //   },
            //   child: Container(
            //     key: tabPics,
            //     alignment: Alignment.center,
            //     height: double.infinity,
            //     child: Text(
            //       'Fotos',
            //       style: TextStyle(
            //           color: (tabSelected == tabPics)
            //               ? Colors.white
            //               : AppConfig.appThemeConfig.secondaryColor,
            //           fontWeight: FontWeight.w700),
            //     ),
            //     decoration: BoxDecoration(
            //         border: Border.all(
            //             color: AppConfig.appThemeConfig.secondaryColor),
            //         color: (tabSelected == tabPics)
            //             ? AppConfig.appThemeConfig.secondaryColor
            //             : Colors.white,
            //         borderRadius: BorderRadius.circular(5)),
            //   ),
            // )),
          if (videoFormat)
            const SizedBox(
              width: 1,
            ),
          if (videoFormat)
           Expanded(
                child: InkWell(
              onTap: () {
                _navigateToPage(1);
                tabSelected = tabPics;

                setState(() {});
              },
              child: Container(
                key: tabPics,
                alignment: Alignment.center,
                height: double.infinity,
                child: Text(
                  'Fotos',
                  style: TextStyle(
                      color: (tabSelected == tabPics)
                          ? Colors.white
                          : AppConfig.appThemeConfig.secondaryColor,
                      fontWeight: FontWeight.w700),
                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppConfig.appThemeConfig.secondaryColor),
                    color: (tabSelected == tabPics)
                        ? AppConfig.appThemeConfig.secondaryColor
                        : Colors.white,
                    borderRadius: BorderRadius.circular(5)),
              ),
            )),
            // Expanded(
            //     child: InkWell(
            //   onTap: () {
            //     _navigateToPage(1);
            //     setState(() {
            //       tabSelected = tabVideo;
            //     });
            //   },
            //   child: Container(
            //     key: tabVideo,
            //     alignment: Alignment.center,
            //     height: double.infinity,
            //     child: Text(
            //       'Video',
            //       style: TextStyle(
            //           color: (tabSelected == tabVideo)
            //               ? Colors.white
            //               : AppConfig.appThemeConfig.secondaryColor,
            //           fontWeight: FontWeight.w700),
            //     ),
            //     decoration: BoxDecoration(
            //         border: Border.all(
            //             color: AppConfig.appThemeConfig.secondaryColor),
            //         color: (tabSelected == tabVideo)
            //             ? AppConfig.appThemeConfig.secondaryColor
            //             : Colors.white,
            //         borderRadius: BorderRadius.circular(5)),
            //   ),
            // ))
        ],
      ),
    );
  }

  _navigateToPage(int page) {
    mediaTypeController.animateToPage(page,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
  }
}

class VideosTab extends StatefulWidget {
  final int durationVideo;
  final int idRequest;
  final List<MediaInfo> videos;
  const VideosTab({Key? key, required this.durationVideo, required this.videos, required this.idRequest})
      : super(key: key);

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
          height: double.infinity,
          width: double.infinity,
          child:
              // SingleChildScrollView(
              //   child:
              Column(
            children: [
              (widget.videos.length > 1)
                  ?
                  const SizedBox()
                  : _buildTitle(),
              Expanded(
                child: SizedBox(
                  // alignment: Alignment.center,
                  child: TakePicVideo(
                      durationVideo: widget.durationVideo,
                      idRequest: widget.idRequest,
                      idArchiveType: widget.videos[0].idTipoArchivo,
                      typeMedia: 'video',
                      description: widget.videos[0].detalle),
                ),
              )
            ],
          )
          // ),
          ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Container _buildTitle() {
    return Container(
      alignment: Alignment.center,
      height: 50,
      child: Text(
        widget.videos[0].detalle,
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
      ),
      decoration: BoxDecoration(
          color: AppConfig.appThemeConfig.secondaryColor,
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20))),
    );
  }
}

class PicsTab extends StatefulWidget {
  final int idRequest;
  final List<MediaInfo> images;
  final int durationVideo;
  const PicsTab({Key? key, required this.durationVideo, required this.images, required this.idRequest})
      : super(key: key);

  @override
  State<PicsTab> createState() => _PicsTabState();
}

class _PicsTabState extends State<PicsTab>
// with AutomaticKeepAliveClientMixin
{
  late UniqueKey seletedPicTab;
  late List<UniqueKey> tabKeys;
  late int itemSelected;
  PageController imagePagesController = PageController(initialPage: 0);
  @override
  void initState() {
    tabKeys = widget.images.map((e) => UniqueKey()).toList();
    seletedPicTab = tabKeys[0];
    itemSelected = 0;
    super.initState();
  }

  @override
  void dispose() {
    imagePagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    var duration = 300;
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child:
            // SingleChildScrollView(
            //   child:
            Column(
          children: [
            //? son los tabs de las fotos
            SizedBox(
              height: 90,
              child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int item) {
                    final uniqueKeyTab = tabKeys[item];
                    duration = duration + 200;
                    return InkWell(
                      onTap: () {
                        seletedPicTab = uniqueKeyTab;
                        itemSelected = item;
                        imagePagesController.animateToPage(itemSelected,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeIn);
                        setState(() {});
                      },
                      child: FadeInRight(
                        duration: Duration(milliseconds: duration),
                        child: Container(
                          key: uniqueKeyTab,
                          alignment: Alignment.center,
                          height: double.infinity,
                          width: 50,
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          decoration: BoxDecoration(
                              color: (seletedPicTab == uniqueKeyTab)
                                  ? Colors.white
                                  : AppConfig.appThemeConfig.secondaryColor,
                              borderRadius: (item + 1 == itemSelected)
                                  ? const BorderRadius.only(
                                      bottomRight: Radius.circular(25))
                                  : (item - 1 == itemSelected)
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(25))
                                      : null),
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              widget.images[item].detalle,
                              style: TextStyle(
                                  color: (seletedPicTab == uniqueKeyTab)
                                      ? AppConfig.appThemeConfig.secondaryColor
                                      : Colors.white,
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, i) {
                    return const SizedBox(
                      width: 1,
                    );
                  },
                  itemCount: widget.images.length),
            ),

            Expanded(
                child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: PageView.builder(
                controller: imagePagesController,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (photoPageContext, page) {
                  return TakePicVideo(
                    durationVideo: widget.durationVideo,
                    idRequest: widget.idRequest,
                    idArchiveType: widget.images[page].idTipoArchivo,
                    description: widget.images[page].detalle,
                    typeMedia: 'photo',
                  );
                },
                itemCount: widget.images.length,
              ),
            ))
          ],
        ),
        // ),
      ),
    );
  }

  // @override
  // bool get wantKeepAlive => true;
}
