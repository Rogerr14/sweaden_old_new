

part of 'shared_widgets.dart';

class NotificationExpirationCatalogue extends StatelessWidget {
  const NotificationExpirationCatalogue({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    final size = MediaQuery.of(context).size;
    final fp = Provider.of<FunctionalProvider>(context);
    return  SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: FadeInDownBig(
              controller:(controller)=>fp.notificationControllerCatalogue=controller,
              animate: false,
              child: InkWell(
                onTap: (){
                 //fp.notificationControllerCatalogue!.status == AnimationStatus.completed;
                  Navigator.pushReplacement(
                        context,
                        PageTransition(
                          child:  OfflineConfigurationPage(
                            key: navigatorKey
                          ),
                          type: PageTransitionType.leftToRightWithFade,
                        ),
                      );
              },
                child: Container(
                  height: size.height * 0.185,
                  width: size.width, 
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const[BoxShadow(color: Colors.grey, spreadRadius: 2, blurRadius: 8)],
                  color: Colors.white,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
                  child: Column(
                    children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      WidgetAnimation(child: Icon(Icons.warning, size: 40, color: AppConfig.appThemeConfig.primaryColor)),
                      //const SizedBox(width: 10,),
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.center,
                          "Algunos catálogos no se han actualizado en 7 días, se recomienda actualizar para evitar problemas en modo offline.", 
                          style: TextStyle(
                            fontSize: 18,
                            color: AppConfig.appThemeConfig.secondaryColor, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      ],),
                      const SizedBox(height: 20),
                      Text("Si desea actualizar presione aqui...", style: TextStyle(fontSize: 18, color: AppConfig.appThemeConfig.primaryColor, fontWeight: FontWeight.bold),),
                      //const SizedBox(height: 20),
                      ],
                  ),
                  ),
              ),
            ),
          ),
        );
  }
}