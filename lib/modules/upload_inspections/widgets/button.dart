import 'package:flutter/material.dart';

ElevatedButton button({required String nameButton, required Color colorButton, required void Function()? onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: colorButton),
      onPressed: onPressed,
      child: Text(nameButton),
    );
  }
