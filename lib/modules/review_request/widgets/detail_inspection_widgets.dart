part of 'review_request_widgets.dart';

class DetailInspectionWidget extends StatelessWidget {
  final Lista? inspection;
  const DetailInspectionWidget({Key? key, required this.inspection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double width = double.infinity;
    final size = MediaQuery.of(context).size;

    return Container(
      height:size.height * 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child:
                  _InfoDateTimeInspectionAttributeData(inspection: inspection),
            ),
            const SizedBox(
              height: 10,
            ),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              child: _InfoBrokerInspection(inspection: inspection),
            ),
            const SizedBox(
              height: 10,
            ),
            _InfoCardInspectionAttributeData(
              text: inspection!.direccion,
              width: width,
            ),
            _InfoCardInspectionAttributeData(
              text: inspection!.tipoSolicitud,
              width: width,
            ),
            _InfoCardInspectionAttributeData(
              text: inspection!.ramo,
              width: width,
            ),
            _InfoCardInspectionAttributeData(
              text: inspection!.agencia,
              width: width,
            ),
            _InfoCardInspectionAttributeData(
              text: inspection!.telefono,
              width: width,
            ),
            const SizedBox(
              height: 20,
            )
          ],
        )));
  }
}

class _InfoBrokerInspection extends StatelessWidget {
  final Lista? inspection;
  const _InfoBrokerInspection({Key? key, required this.inspection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 6,
        ),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'Broker: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.appThemeConfig.secondaryColor,
                )),
            TextSpan(
                text: inspection?.nombreBroker,
                style: TextStyle(
                    color: AppConfig.appThemeConfig.secondaryColor,
                    fontWeight: FontWeight.bold))
          ]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 16,
        ),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: 'Ejecutivo: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.appThemeConfig.secondaryColor,
                )),
            TextSpan(
                text: inspection?.nombreEjecutivo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.appThemeConfig.secondaryColor,
                ))
          ]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 16,
        ),
        Text.rich(
          TextSpan(children: [
            TextSpan(
                text: inspection?.proceso,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppConfig.appThemeConfig.secondaryColor,
                ))
          ]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _InfoCardInspectionAttributeData extends StatelessWidget {
  final String? text;
  final double? width;
  const _InfoCardInspectionAttributeData(
      {Key? key, required this.text, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
        duration: const Duration(milliseconds: 600),
        child: Container(
          height: 40,
          width: width,
          margin: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Text(
            text!,
            style: TextStyle(
                color: AppConfig.appThemeConfig.secondaryColor,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}

class _InfoDateTimeInspectionAttributeData extends StatelessWidget {
  final Lista? inspection;
  const _InfoDateTimeInspectionAttributeData(
      {Key? key, required this.inspection})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.42;
    return SizedBox(
      child: Row(
        children: [
          Expanded(
              child: SizedBox(
            child: Column(
              children: [
                _InfoCardInspectionAttributeData(
                    text: (inspection!.fechaInspeccion!=null)?Helper().dateToStringFormat(
                        inspection!.fechaInspeccion!, 'dd-MM-yyyy'):"--/--/----",
                    width: width),
              ],
            ),
          )),
          Expanded(
              child: SizedBox(
            child: Column(
              children: [
                _InfoCardInspectionAttributeData(
                  text: (inspection!.horaInspeccion!=null)
                  ?inspection!.horaInspeccion:"--:--",
                  width: width,
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
