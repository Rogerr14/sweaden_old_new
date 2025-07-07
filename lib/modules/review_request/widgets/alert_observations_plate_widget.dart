import 'package:flutter/material.dart';
import 'package:sweaden_old_new_version/envs/generic/app_theme_config.dart';
import 'package:sweaden_old_new_version/modules/review_request/models/plate_observation_response.dart';
import 'package:sweaden_old_new_version/shared/helpers/helper.dart';
import 'package:sweaden_old_new_version/shared/providers/functional_provider.dart';
import 'package:provider/provider.dart';

class AlertObservationsPlateWidget extends StatelessWidget {
  final List<PlateObservationsResponse> observations;

  const AlertObservationsPlateWidget({super.key, required this.observations});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final fp = Provider.of<FunctionalProvider>(context, listen: false);
    final List<Widget> children = [];

    observations.map((elemento) => children.add(_CardObservationsPLate(observations: elemento))).toList();

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
                'Observaciones',
                style: TextStyle(
                  color: AppThemeConfig().secondaryColor,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              // width: size.width - 30,

              height: observations.length > 5
                  ? size.height * 0.6
                  : size.height * (0.10 + (observations.length / 10)),
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

class _CardObservationsPLate extends StatelessWidget {
  final PlateObservationsResponse observations;

  const _CardObservationsPLate({super.key,required this.observations});

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
                  text: Helper().dateToStringFormat(observations.fechaInspeccionReal, 'dd-MM-yyyy'),
                  style: const TextStyle(fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
           Visibility(
            visible: observations.nombre != '',
            child: Text.rich(
              textAlign: TextAlign.left,
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Nombre Inspector: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: observations.nombre,
                    style: const TextStyle(
                      // fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
          ),
           const SizedBox(
            height: 5,
          ),
           Visibility(
            visible: observations.agenciaInspeccion != '',
            child: Text.rich(
              textAlign: TextAlign.left,
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Agencia Inpección: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: observations.agenciaInspeccion,
                    style: const TextStyle(
                      // fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Visibility(
            visible: observations.observaciones != '',
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Observaciones: ',
                    style:  TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: observations.observaciones,
                    style: const TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: observations.observaciones != '',
            child: const SizedBox(
              height: 5,
            ),
          ),
          Visibility(
            visible: observations.observacionEmision != '',
            child: Text.rich(
              textAlign: TextAlign.left,
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Observacion Emisión: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: observations.observacionEmision,
                    style: const TextStyle(
                      // fontSize: 15,
                      fontWeight: FontWeight.w300,
                    ),
                  )
                ],
              ),
            ),
          ),
          const Divider(thickness: 2 )
        ],
      ),
    );
  }
}
