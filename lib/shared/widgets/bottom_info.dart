part of 'shared_widgets.dart';

class BottomInfo extends StatefulWidget {
  const BottomInfo({super.key});

  @override
  State<BottomInfo> createState() => _BottomInfoState();
}

String? versionName;
class _BottomInfoState extends State<BottomInfo> {
  @override
  void initState() {
    if(versionName==null){
      _getInfoVersion();
    }
    super.initState();
  }
  
  _getInfoVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  setState((){
    versionName = packageInfo.version;
  });
  }

  @override
  Widget build(BuildContext context) {
    
    //?PROD
    return SizedBox(height: 79, child: _infoBottom(versionName??'0.0.0'));
    //!DEV
    // return SizedBox(height: 65, child: _infoBottomStackVrs(context));
    
  }

  // ignore: unused_element
  _infoBottomStackVrs(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        InkWell(
          splashColor: AppConfig.appThemeConfig.secondaryColor,
          onTap: () async {
            // debugPrint("======= TRAYENDO MEDIA DATA! =======");
            // final data = await MediaDataStorage().getMediaData(600);
            //! BORRAR DATOS
            // await InspectionStorage().removeDataInspection('793');
            // print("BORRADO!");
            //* CONSULTAR DATOS
            // final dataInsp = await InspectionStorage().getDataInspection('793');
            // inspect(dataInsp);
            // inspect(dataInsp);
            // await MediaDataStorage().removeAll();
            // try {
            //   final List<int> list = <int>[];
            //   print(list[100]);
            // } catch (e, s) {
            //   await FirebaseCrashlytics.instance.recordError(e, s,
            //       reason: 'as an example of fatal error LIST!1', fatal: true);
            // }
            // Helper().setNull();
          },
          child: Ink(
              padding: const EdgeInsets.only(right: 15),
              height: double.infinity,
              width: double.infinity,
              color: AppConfig.appThemeConfig.primaryColor,
              child: const Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 45,
                ),
              )),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: Colors.white,
            height: 61.5,
            width: size.width * .81,
            child: Row(
              children: [
                Hero(
                  tag: 'logo-business',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    width: 80,
                    child: Image(
                        image:
                            AssetImage(AppConfig.appThemeConfig.logoImagePath)),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sanchez de Avila N37-35 y Naciones Unidas',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'QUITO - ECUADOR',
                          style: TextStyle(
                              color: AppConfig.appThemeConfig.secondaryColor,
                              fontWeight: FontWeight.w900),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  _infoBottom(String versionName){
    
    return Column(
      children: [
        Container(
          height: 3.5,
          color: AppConfig.appThemeConfig.primaryColor,
        ),
        Row(
          children: [
            Expanded(
                child: Container(
              color: Colors.white,
              height: 75.5,
              child: Row(
                children: [
                  Hero(
                    tag: 'logo-business',
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      width: 80,
                      child: Image(
                          image: ResizeImage(AssetImage(
                              AppConfig.appThemeConfig.logoImagePath), height: 240,width:240)),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${AppConfig.appEnv.environmentLabel} $versionName',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.primaryColor,
                                fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Sánchez de Ávila N37-35 y Naciones Unidas',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'QUITO - ECUADOR',
                            style: TextStyle(
                                color: AppConfig.appThemeConfig.secondaryColor,
                                fontWeight: FontWeight.w900),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )),
            InkWell(
              splashColor: AppConfig.appThemeConfig.secondaryColor,
              onTap: () async {
                await _makePhoneCall('02-500-800');
              },
              child: Ink(
                height: 75.5,
                width: 95,
                color: AppConfig.appThemeConfig.primaryColor,
                child: const Icon(
                  Icons.call,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
