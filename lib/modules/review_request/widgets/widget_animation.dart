import 'package:flutter/material.dart';

class WidgetAnimation extends StatefulWidget {
  final Widget child;
  final Alignment align;

  final int millisecondsDelay;
  final int millisecondsAnimated;
  const WidgetAnimation({super.key, required this.child,
      this.align = Alignment.center,
      this.millisecondsDelay = 300,
      this.millisecondsAnimated = 500});

  @override
  State<WidgetAnimation> createState() => _WidgetAnimationState();
}

class _WidgetAnimationState extends State<WidgetAnimation> with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _valueAnimate;

  bool shouldRestartAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.millisecondsAnimated),
    )..repeat(reverse: true);
    _valueAnimate = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.isAnimating ? _controller.stop() : null;
    _controller.dispose();
    // if(widget.listenerChange) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   return AnimatedBuilder(
      animation: _valueAnimate,
      builder: (context, child) {
        return Transform.scale(
          scale: _valueAnimate.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}