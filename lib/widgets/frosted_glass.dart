import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedGlass extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final double radius;
  final Color backColor;
  const FrostedGlass({super.key, required this.width, required this.height, this.child = const SizedBox(), this.radius = 10, this.backColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: width,
        height: height,
        color: backColor,
        child: Stack(
          children: [
            BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaY: 4,
                  sigmaX: 4,
                ),
              child: Container(),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: reverse.withOpacity(0.13),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    reverse.withOpacity(0.15),
                    reverse.withOpacity(0.05),
                  ]
                )
              ),
              child: Center(child: child),
            )
          ],
        ),
      ),
    );
  }
}
