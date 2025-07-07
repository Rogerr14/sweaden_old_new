part of 'shared_widgets.dart';

class BackGround extends StatelessWidget {
  const BackGround({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Image(
        image: ResizeImage(AssetImage(AppConfig.appThemeConfig.backGroundImagePath), height: 1080),
        fit: BoxFit.fill,
      ),
    );
  }
}
