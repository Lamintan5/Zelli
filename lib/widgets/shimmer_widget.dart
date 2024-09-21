import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShapeBorder shapeBorder;

   ShimmerWidget.rectangular({super.key,
    required this.width,
    required this.height,
     this.borderRadius = 10
  }) : this.shapeBorder =  RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius)));

  const ShimmerWidget.circular({super.key,
    required this.width,
    required this.height,
    this.shapeBorder = const CircleBorder(), this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: Colors.grey.withOpacity(0.3),
    highlightColor: Colors.white.withOpacity(0.3),
    child: Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: Colors.grey.withOpacity(0.4),
        shape: shapeBorder,
      ),
    ),
  );
}
