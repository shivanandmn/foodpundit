import 'package:flutter/material.dart';

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset centerOffset;
  final Color? backgroundColor;

  CircularRevealRoute({
    required this.page,
    required this.centerOffset,
    this.backgroundColor,
  }) : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );

            return Stack(
              children: [
                Container(color: backgroundColor ?? Colors.transparent),
                ClipPath(
                  clipper: CircularRevealClipper(
                    centerOffset: centerOffset,
                    progress: curvedAnimation.value,
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.1, 0.8),
                    )),
                    child: child,
                  ),
                ),
              ],
            );
          },
        );
}

class CircularRevealClipper extends CustomClipper<Path> {
  final Offset centerOffset;
  final double progress;

  CircularRevealClipper({
    required this.centerOffset,
    required this.progress,
  });

  @override
  Path getClip(Size size) {
    final center = centerOffset;
    final radius = progress * 
        (size.width > size.height ? size.width : size.height) * 1.8;

    final path = Path()
      ..addOval(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
