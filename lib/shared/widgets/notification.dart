


part of 'shared_widgets.dart';

class NotificationModal extends StatelessWidget {
  const NotificationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fp = Provider.of<FunctionalProvider>(context);
    return  SafeArea(
          child: Material(
            type: MaterialType.transparency,
            child: FadeInDownBig(
              controller:(controller)=>fp.notificationController=controller,
              animate: false,
              child: InkWell(
                onTap: (){
                Navigator.pushReplacement(
                          context,
                          PageTransition(
                              child: const ReviewRequestPage(),
                              type: PageTransitionType.leftToRightWithFade));
              },
                child: Container(
                  height: 70,
                  width: size.width, 
                  decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const[BoxShadow(color: Colors.grey, spreadRadius: 5, blurRadius: 8)],
                  color: Colors.white,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Text("Nueva solicitud de inspección".toUpperCase(), style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor, fontWeight: FontWeight.bold),),
                      const SizedBox(width: 10,),
                      const Icon(Icons.circle, color: Colors.red, size: 15,)
                      ],),
                      const SizedBox(height: 10,),
                      Text("Te asignaron una nueva solicitud.", style: TextStyle(color: AppConfig.appThemeConfig.secondaryColor, fontWeight: FontWeight.w400),),
                      ],
                  ),
                  ),
              ),
            ),
          ),
        );
  }
}