part of 'new_request_widgets.dart';

class InfoTileWidget extends StatelessWidget {
  final String informativeTitle;
  const InfoTileWidget({Key? key, required this.informativeTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppConfig.appThemeConfig.secondaryColor,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(15), bottomLeft: Radius.circular(15))),
      child: Text(
        informativeTitle,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
