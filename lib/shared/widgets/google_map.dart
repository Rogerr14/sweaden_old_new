part of 'shared_widgets.dart';

class GoogleMapPage extends StatefulWidget {
  final LatLng coords;
  const GoogleMapPage({
    super.key,
    required this.coords,
  });

  @override
  State<GoogleMapPage> createState() => _GoogleMapPageState();
}

GoogleMapController? mapController;
Set<Marker> _markerSet = <Marker>{};

class _GoogleMapPageState extends State<GoogleMapPage> {
  late CameraPosition _initialPosition;
  late LatLng currentCoord;
  @override
  void initState() {
    BackButtonInterceptor.add(_myInterceptormap, name: 'map', context: context);
    currentCoord = widget.coords;
    _initialPosition = CameraPosition(
      target: widget.coords,
      zoom: 16,
    );
    super.initState();
  }

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('map');
    super.dispose();
  }

  Future<bool> _myInterceptormap(bool stopDefaultButtonEvent, RouteInfo info) async{
    
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    if (fp.selectedCoords != null) {
      
      // SchedulerBinding.instance.addPostFrameCallback((_) {
        fp.buttonMapEnable = true;
        Future.delayed(const Duration(milliseconds: 300), (){
          Navigator.pop(context);
        });
      // });
    } else {
      fp.showAlert(
          content: const AlertNoLocationSelectec(), summoner: 'google-map');
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Scaffold(
          body: SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                GoogleMapWiget(
                    initialPosition: _initialPosition,
                    markers: _markerSet,
                    onCameraMove: (position) {
                      currentCoord = position.target;
                    }),
                BounceInDown(child: const PinLocation()),
                const SearchBar(),
                _actionButtons()
              ],
            ),
          ),
        ),
        const AlertModal(
          summoner: 'google-map',
        )
      ],
    );
  }

  _actionButtons() {
    return Positioned(
        bottom: 0,
        right: 0,
        left: 0,
        child: FadeInUp(
          child: Container(
            height: 100,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)), backgroundColor: AppConfig.appThemeConfig.primaryColor),
                        onPressed: () async {
                          final fp = Provider.of<FunctionalProvider>(context,
                              listen: false);
                          fp.selectedCoords = currentCoord;
                          fp.buttonMapEnable = true;
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("SELECCIONAR UBICACIÓN"),
                            SizedBox(
                              width: 10,
                            ),
                            Icon(Icons.location_on_rounded),
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () async {
                    final myLocation = await Geolocator.getCurrentPosition();
                    // await mapController!.animateCamera(
                    await mapController!.moveCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                            target: LatLng(
                                myLocation.latitude, myLocation.longitude),
                            zoom: 16.16)));
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor
                        .withOpacity(  0.87),
                    child: const Icon(
                      Icons.my_location_outlined,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    return Positioned(
      top: 15,
      right: 0,
      left: 0,
      child: SafeArea(
        child: FadeInDown(
          delay: const Duration(milliseconds: 800),
          child: Container(
            // color: Colors.red,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    if (fp.selectedCoords != null) {
                      fp.buttonMapEnable = true;
                      Navigator.pop(context);
                    } else {
                      fp.showAlert(
                          content: const AlertNoLocationSelectec(),
                          summoner: 'google-map');
                    }
                  },
                  child: CircleAvatar(
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor,
                    radius: 24,
                    child: Icon(
                      Icons.arrow_back,
                      color: AppConfig.appThemeConfig.primaryColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final myLocation = await Geolocator.getCurrentPosition();
                      final coords = g_places.LatLng(
                          lat: myLocation.latitude, lng: myLocation.longitude);
                      final result = await showSearch(
                          context: context, delegate: SearchPlaces(coords));
                      if (result != null) {
                        // await mapController!.animateCamera(
                        await mapController!.moveCamera(
                            CameraUpdate.newCameraPosition(
                                CameraPosition(target: result, zoom: 16.16)));
                      }
                    },
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: AppConfig.appThemeConfig.primaryColor,
                                spreadRadius: 2.5)
                          ],
                          border: Border.all(
                              width: 1.5,
                              color: AppConfig.appThemeConfig.secondaryColor),
                          borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Buscar",
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.primaryColor,
                                fontWeight: FontWeight.w900),
                          ),
                          Icon(
                            Icons.search_rounded,
                            color: AppConfig.appThemeConfig.secondaryColor,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinLocation extends StatelessWidget {
  const PinLocation({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -16),
          child: Icon(
            Icons.location_pin,
            size: 42,
            color: AppConfig.appThemeConfig.primaryColor,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -14.5),
          child: Icon(
            Icons.location_pin,
            size: 38,
            color: AppConfig.appThemeConfig.secondaryColor,
          ),
        )
      ],
    );
  }
}

class GoogleMapWiget extends StatelessWidget {
  final CameraPosition initialPosition;
  final void Function(CameraPosition)? onCameraMove;
  final Set<Marker> markers;
  final bool? scrollEnable;
  const GoogleMapWiget(
      {super.key,
      required this.initialPosition,
      this.onCameraMove,
      required this.markers,
      this.scrollEnable = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: GoogleMap(
        zoomControlsEnabled: false,
        markers: markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        scrollGesturesEnabled: scrollEnable!,
        zoomGesturesEnabled: true,
        initialCameraPosition: initialPosition,
        minMaxZoomPreference: const MinMaxZoomPreference(0,16),
        onMapCreated: (controller) => mapController = controller,
        onCameraMove:
            // (position) {
            //   currentCoord = position.target;
            // }
            onCameraMove,
      ),
    );
  }
}
