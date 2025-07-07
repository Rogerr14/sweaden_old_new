import 'package:flutter/material.dart';

import '../../envs/app_config.dart';

class ButtonOpacityWidget extends StatefulWidget {
  const ButtonOpacityWidget({super.key, required this.child, required this.content});
  final Widget child;
  final Widget content;

  @override
  ButtonOpacityWidgetState createState() {
    return ButtonOpacityWidgetState();
  }
}

class ButtonOpacityWidgetState extends State<ButtonOpacityWidget> {
  bool _isAdded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAdded = !_isAdded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.linear,
        decoration: BoxDecoration(
          color: _isAdded ? Colors.transparent : AppConfig.appThemeConfig.secondaryColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(width: 3.0, color: AppConfig.appThemeConfig.secondaryColor),
        ),
        width: _isAdded ? 280 : 60,
        height: 60,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeIn,
                  opacity: _isAdded ? 0.0 : 1.0,
                  child: widget.child,
              )
                  //child: const Text('2d', style: TextStyle( color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold))),
            ),
            Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 550),
                opacity: _isAdded ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: widget.content,
                ),
                // child: const Text(
                //   "MESSAGE",
                //   style: TextStyle(
                //       fontSize: 18.0,
                //       color: Colors.blue,
                //       fontWeight: FontWeight.bold),
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}