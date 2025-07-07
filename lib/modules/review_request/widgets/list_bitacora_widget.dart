import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/generic/app_theme_config.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/models/bitacora_response.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:provider/provider.dart';

class ListBitacoraWidget extends StatelessWidget {
  final List<ListBitacoraResponse> bitacora;
  const ListBitacoraWidget({super.key, required this.bitacora});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final List<Widget> children = [];

    bitacora
        .map((elemento) => children.add(_BitacoraCardWidget(
            dateTime: elemento.fecha,
            nameInspector: elemento.nombre,
            detalle: elemento.detalle)))
        .toList();

    return Material(
      type: MaterialType.transparency,
      child: Container(
        // height: size.height * 0.4,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20)),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Text(
                'Gestiones',
                style: TextStyle(
                  color: AppThemeConfig().secondaryColor,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              // width: size.width - 30,

              height: bitacora.length > 5
                  ? size.height * 0.6
                  : size.height * (0.10 + (bitacora.length / 10)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children,
                ),
                //   child: SizedBox(
                //   ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton(
                  onPressed: () {
                    fp.dismissAlert();
                  },
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                        color: AppThemeConfig().secondaryColor, fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
        // child: Stack(children: [
        //   Positioned.fill(
        //     // left: 0.0,
        //     // right: 0.0,

        //     child: Align(
        //       alignment: Alignment.topCenter,
        //       child: Padding(
        //         padding: EdgeInsets.symmetric(
        //           vertical: 20,
        //         ),
        //         child: Text(
        //           'Bitacoras',
        //           style: TextStyle(
        //             color: AppThemeConfig().secondaryColor,
        //             fontSize: 20,
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        //   Center(
        //     child: SingleChildScrollView(
        //       child: Padding(
        //         padding:
        //             const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        //         child: Column(
        //           children: children,
        //         ),
        //       ),
        //     ),
        //   ),
        //   Positioned(
        //     left: 0.0,
        //     right: 0.0,
        //     bottom: 0.0,
        //     child: TextButton(
        //         onPressed: () {
        //           fp.dismissAlert();
        //         },
        //         child: Text(
        //           'Salir',
        //           style: TextStyle(
        //               color: AppThemeConfig().secondaryColor, fontSize: 20),
        //         )),
        //   )
        // ]),
      ),
    );
  }
}

class _BitacoraCardWidget extends StatelessWidget {
  final DateTime dateTime;
  final String nameInspector;
  final String detalle;

  const _BitacoraCardWidget(
      {super.key,
      required this.dateTime,
      required this.nameInspector,
      required this.detalle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.max,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Fecha: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: Helper().dateToStringFormat(dateTime, 'dd-MM-yyyy'),
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Nombre: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: nameInspector,
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text.rich(
            textAlign: TextAlign.left,
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Detalle: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: detalle.toUpperCase(),
                  style: const TextStyle(
                    // fontSize: 15,
                    fontWeight: FontWeight.w300,
                  ),
                )
              ],
            ),
          ),
          const Divider(
            thickness: 2,
          )
        ],
      ),
    );
  }
}
