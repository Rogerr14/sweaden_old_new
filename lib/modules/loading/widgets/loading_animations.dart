part of 'loading_widgets.dart';

class LoadingAnimation extends StatelessWidget {
  final String animation;
  final Widget child;
  const LoadingAnimation(
      {Key? key, required this.animation, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Widget animationSelected;
    switch (animation) {
      case 'NONE':
        animationSelected = child;
        break;
      case 'FadeIn':
        animationSelected = FadeIn(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInDown':
        animationSelected = FadeInDown(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInDownBig':
        animationSelected = FadeInDownBig(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInUp':
        animationSelected = FadeInUp(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInLeft':
        animationSelected = FadeInLeft(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInLeftBig':
        animationSelected = FadeInLeftBig(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInRight':
        animationSelected = FadeInRight(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'FadeInRightBig':
        animationSelected = FadeInRightBig(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'ZoomIn':
        animationSelected = ZoomIn(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
      case 'ZoomOut':
        animationSelected = ZoomOut(
            duration: AppConfig.appThemeConfig.durationLoadingAnimation,
            child: child);
        break;
    }
    return animationSelected;
  }
}
