part of 'home_widgets.dart';

class TaskGrid extends StatelessWidget {
  final AuthResponse usuario;

  const TaskGrid({Key? key, required this.usuario}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FadeInUpBig(
        duration: const Duration(milliseconds: 500),
        child: GridView.count(
          physics: const BouncingScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          padding: const EdgeInsets.all(5),
          children: _buildTask(context),
        ),
      ),
    );
  }

  List<Widget> _buildTask(BuildContext context) {
    List<Widget> tasks = [];
    for (var item in AppConfig.appEnv.businessTask) {
      var task = InkWell(
        borderRadius: BorderRadius.circular(10),
        splashColor: AppConfig.appThemeConfig.primaryColor,
        onTap: _navigateTo(context, item.navigateTo), // add validation
        child: Ink(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: 100, child: Image(image: AssetImage(item.imagePath))),
              const SizedBox(
                height: 10,
              ),
              Text(
                item.titleTask,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: AppConfig.appThemeConfig.secondaryColor,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      tasks.add(task);
    }
    return tasks;
  }

  _navigateTo(BuildContext context, String routeName) {
    //? VERIFICAMOS FECHA DE CADUCIDAD DEL TOKEN

    switch (routeName) {
      case 'new-request':
        return () async {
          final fp = Provider.of<FunctionalProvider>(context, listen: false);
          final validToken = await Helper.tokenValidityCheck();
          if (!validToken) {
            fp.showAlert(
                content: AlertGenericError(
              message:
                  "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
              messageButton: "Entendido!",
              onPress: () async {
                fp.dismissAlert();
                await UserDataStorage().removeUserData();
                Navigator.pushReplacement(context,
                    Helper.navigationFadeIn(context, const LoginPage(), 800));
              },
            ));
          } else {
            Navigator.pushReplacement(context,
                CupertinoPageRoute(builder: (_) => const NewRequestPage()));
          }
        };
      case 'review-request':
        if (!usuario.informacion.permiteInspeccion) {
          return null;
        } else {
          return () async {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            final validToken = await Helper.tokenValidityCheck();
            if (!validToken) {
              fp.showAlert(
                  content: AlertGenericError(
                message:
                    "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
                messageButton: "Entendido!",
                onPress: () async {
                  fp.dismissAlert();
                  await UserDataStorage().removeUserData();
                  Navigator.pushReplacement(context,
                      Helper.navigationFadeIn(context, const LoginPage(), 800));
                },
              ));
            } else {
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const ReviewRequestPage()));
            }
          };
        }
      case 'offline-configuration':
        if (!usuario.informacion.permiteInspeccion) {
          return null;
        } else {
          return () async {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            final validToken = await Helper.tokenValidityCheck();
            if (!validToken) {
              fp.showAlert(
                  content: AlertGenericError(
                message:
                    "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
                messageButton: "Entendido!",
                onPress: () async {
                  fp.dismissAlert();
                  await UserDataStorage().removeUserData();
                  Navigator.pushReplacement(context,
                      Helper.navigationFadeIn(context, const LoginPage(), 800));
                },
              ));
            } else {
             //await LocalNotificationPush.viewNotification(title: 'Catalogos Desactualizados', body: 'Algunos catálogos no se han actualizado en 7 días, se recomienda actualizar para evitar problemas en modo offline.');
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const OfflineConfigurationPage()));
            }
          };
        }
       case 'cargar-inspecciones':
        if (!usuario.informacion.permiteInspeccion) {
          return null;
        } else {
          return () async {
            final fp = Provider.of<FunctionalProvider>(context, listen: false);
            final validToken = await Helper.tokenValidityCheck();
            if (!validToken) {
              fp.showAlert(
                  content: AlertGenericError(
                message:
                    "Su sesión a caducado, porfavor vuelva a ingresar para continuar el proceso.",
                messageButton: "Entendido!",
                onPress: () async {
                  fp.dismissAlert();
                  await UserDataStorage().removeUserData();
                  Navigator.pushReplacement(context,
                      Helper.navigationFadeIn(context, const LoginPage(), 800));
                },
              ));
            } else {
             //await LocalNotificationPush.viewNotification(title: 'Catalogos Desactualizados', body: 'Algunos catálogos no se han actualizado en 7 días, se recomienda actualizar para evitar problemas en modo offline.');
              Navigator.pushReplacement(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const UploadInspectionsPage()));
            }
          };
        }
      default:
        return () {
          Navigator.pushReplacement(context,
              CupertinoPageRoute(builder: (_) => const NotFoundPage()));
        };
    }
  }
}
