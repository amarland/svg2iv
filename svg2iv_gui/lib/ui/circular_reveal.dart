import 'dart:math' show sqrt, max;

import 'package:flutter/material.dart';

class CircularRevealAnimation extends StatelessWidget {
  final Animation<double> animation;
  final Offset? center;
  final Widget child;

  const CircularRevealAnimation({
    super.key,
    required this.animation,
    this.center,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? _) {
        return ClipPath(
          clipper: _CircularRevealClipper(
            progress: animation.value,
            center: center,
          ),
          child: child,
        );
      },
    );
  }
}

class _CircularRevealClipper extends CustomClipper<Path> {
  _CircularRevealClipper({required this.progress, this.center});

  final double progress;
  final Offset? center;

  @override
  Path getClip(Size size) {
    final offset = center ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = _computeMaxRadius(size, offset);
    return Path()
      ..addOval(
        Rect.fromCircle(center: offset, radius: maxRadius * progress),
      );
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;

  static double _computeMaxRadius(Size size, Offset center) {
    final width = max(center.dx, size.width - center.dx);
    final height = max(center.dy, size.height - center.dy);
    return sqrt(width * width + height * height);
  }
}
