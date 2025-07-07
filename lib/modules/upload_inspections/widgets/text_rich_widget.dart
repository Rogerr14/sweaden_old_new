import 'package:flutter/material.dart';

class TextRichWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? colorSubtitle;
  final FontWeight? fontWeight;
  final double? fontSizeTitle;
  final double? fontSizeSubTitle;

  const TextRichWidget({super.key, required this.title, required this.subtitle, this.colorSubtitle, this.fontWeight, this.fontSizeTitle = 14, this.fontSizeSubTitle = 14});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: fontSizeTitle),
          ),
          TextSpan(
            text: subtitle,
            style: TextStyle(fontWeight: fontWeight ?? FontWeight.w300, color: colorSubtitle ?? Colors.black, fontSize: fontSizeSubTitle),
          )
        ],
      ),
    );
  }
}
