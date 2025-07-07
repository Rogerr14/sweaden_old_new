part of 'review_request_widgets.dart';

class ButtonsInspectionWidget extends StatefulWidget {
  final int stateInspection;
  final ValueChanged<bool> onEditFlag;
  final Function() onPress;
  final ValueChanged<bool>? onAcceptFlag;
  final ValueChanged<bool> onRejectFlag;
  final ValueChanged<bool> onContinueFlag;
  final ValueChanged<bool> onRescheduleFlag;

  const ButtonsInspectionWidget(
      {Key? key,
      required this.stateInspection,
      required this.onEditFlag,
      required this.onContinueFlag,
      this.onAcceptFlag,
      required this.onRejectFlag,
      required this.onRescheduleFlag,
      required this.onPress})
      : super(key: key);

  @override
  ButtonsInspectionState createState() => ButtonsInspectionState();
}

class ButtonsInspectionState extends State<ButtonsInspectionWidget> {
  @override
  Widget build(BuildContext context) {
    final stateInspection = widget.stateInspection;
    return Container(
        height: (stateInspection != 2) ? 120 : 150,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
            ),
            if (stateInspection == 1)
              Expanded(
                child: SizedBox(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppConfig.appThemeConfig.primaryColor),
                    onPressed: () {
                      widget.onEditFlag(true);
                    },
                    child: const Text(
                      'Editar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            const SizedBox(
              width: 5,
            ),
            if (stateInspection == 1 && widget.onAcceptFlag != null)
              Expanded(
                child: SizedBox(
                  // margin: const EdgeInsets.all(4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor:
                            AppConfig.appThemeConfig.secondaryColor),
                    onPressed: () {
                      widget.onAcceptFlag!(true);
                      widget.onPress();
                    },
                    child: const Text('ACEPTAR',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            if (stateInspection == 2)
              Container(
                  margin: const EdgeInsets.all(1),
                  child: Column(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 18),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            backgroundColor:
                                AppConfig.appThemeConfig.secondaryColor),
                        onPressed: () {
                          widget.onContinueFlag(true);
                          widget.onPress();
                        },
                        child: const Text('CONTINUAR INSPECCIÓN',
                            style: TextStyle(color: Colors.white)),
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              backgroundColor:
                                  AppConfig.appThemeConfig.primaryColor),
                          onPressed: () {
                            widget.onRescheduleFlag(true);
                          },
                          child: const Text('REAGENDAR INSPECCIÓN',
                              style: TextStyle(color: Colors.white))),
                      SizedBox(
                        //  height: 45,
                        // margin: const EdgeInsets.all(4),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 18),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 72),
                              backgroundColor:
                                  AppConfig.appThemeConfig.primaryColor),
                          onPressed: () {
                            widget.onRejectFlag(true);
                          },
                          child: const Text('RECHAZAR',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )),
            const SizedBox(
              width: 5,
            ),
            if (stateInspection == 1)
              Expanded(
                child: SizedBox(
                  // height: 45,
                  // margin: const EdgeInsets.all(4),
                  child: TextButton(
                    style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: AppConfig.appThemeConfig.primaryColor),
                    onPressed: () {
                      widget.onRejectFlag(true);
                    },
                    child: const Text('RECHAZAR',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            const SizedBox(
              width: 16,
            ),
          ],
        ));
  }
}

class ButtonsInspectionConfirmWidget extends StatefulWidget {
  final ValueChanged<bool> onConfirmFlag;
  final bool saveActivateFlag;

  const ButtonsInspectionConfirmWidget(
      {Key? key, required this.onConfirmFlag, required this.saveActivateFlag})
      : super(key: key);

  @override
  ButtonsInspectionConfirmState createState() =>
      ButtonsInspectionConfirmState();
}

class ButtonsInspectionConfirmState
    extends State<ButtonsInspectionConfirmWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.all(4),
              child: TextButton(
                style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 18),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: AppConfig.appThemeConfig.secondaryColor),
                onPressed: () {
                  widget.onConfirmFlag(false);
                },
                child: const Text('CANCELAR',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              margin: const EdgeInsets.all(4),
              child: TextButton(
                style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 18),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    backgroundColor: widget.saveActivateFlag
                        ? AppConfig.appThemeConfig.primaryColor
                        : Colors.grey),
                onPressed: widget.saveActivateFlag
                    ? () {
                        widget.onConfirmFlag(true);
                      }
                    : null,
                child: const Text(
                  'GUARDAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ));
  }
}
