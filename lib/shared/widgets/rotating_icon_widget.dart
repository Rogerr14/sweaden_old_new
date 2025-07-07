import 'package:flutter/material.dart';
import 'dart:math' as math;

class RotatingIcon extends StatefulWidget {
  final Icon icon;

  const RotatingIcon({
    super.key,
    required this.icon,
  });

  @override
  State<RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..repeat()
      ..forward()
      ..addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        _controller..repeat()
        ..forward();
      }
      if(status == AnimationStatus.dismissed){
         _controller..repeat()
        ..forward();
      }
    });

    _rotationAnimation = Tween<double>(begin: 0.0, end: math.pi * 10).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: -_rotationAnimation.value,
          child: widget.icon,
        );
      },
    );
  }
}