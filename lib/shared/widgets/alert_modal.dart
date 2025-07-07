part of 'shared_widgets.dart';

// class AlertModal extends StatefulWidget {
//   final String? summoner;
//   const AlertModal({Key? key, this.summoner}) : super(key: key);

//   @override
//   State<AlertModal> createState() => _AlertModalState();
// }

// class _AlertModalState extends State<AlertModal> {
//   late String summoner;
//   @override
//   void initState() {
//     super.initState();
//     summoner = widget.summoner ?? 'normal';
//   }

 

//   @override
//   Widget build(BuildContext context) {
//     final alertContent =
//         context.select((FunctionalProvider fp) => fp.alertContent);
//     final size = MediaQuery.of(context).size;
//     return ZoomIn(
//       controller: (animationController) {
//         _typeAnimation('zoom-in', animationController);
//       },
//       animate: false,
//       duration: const Duration(milliseconds: 200),
//       child: Container(
//         height: size.height,
//         width: size.width,
//         color: Colors.black54,
//         alignment: Alignment.center,
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: FadeInUpBig(
//           animate: false,
//           controller: (animetionControllerContent) {
//             _typeAnimation('fade-in-up-big', animetionControllerContent);
//           },
//           duration: const Duration(milliseconds: 500),
//           child: alertContent,
//         ),
//       ),
//     );
//   }

//   _typeAnimation(String name, AnimationController animationController) {
//     final fp = Provider.of<FunctionalProvider>(context, listen: true);
//     switch (summoner) {
//       case 'google-map':
//         if (name == 'zoom-in') {
//           fp.alertControllerGMap = animationController;
//         }
//         if (name == 'fade-in-up-big') {
//           fp.alertControllerContentGmap = animationController;
//         }
//         break;
//       case 'normal':
//         if (name == 'zoom-in') {
//           fp.alertController = animationController;
//         }
//         if (name == 'fade-in-up-big') {
//           fp.alertControllerContent = animationController;
//         }
//         break;
//     }
//   }


// }

class AlertModal extends StatelessWidget {
  final String? summoner;
  const AlertModal({Key? key, this.summoner}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fp = Provider.of<FunctionalProvider>(context);
    final alertContent = fp.alertContent;
    final size = MediaQuery.of(context).size;

    return AnimatedOpacity(
      opacity: alertContent is SizedBox ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: alertContent is SizedBox
          ? const SizedBox()
          : Container(
              height: size.height,
              width: size.width,
              color: Colors.black54,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                transform: alertContent is SizedBox
                    ? Matrix4.translationValues(0, 50, 0)
                    : Matrix4.translationValues(0, 0, 0),
                child: alertContent,
              ),
            ),
    );
  }
}