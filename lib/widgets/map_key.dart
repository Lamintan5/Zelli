import 'package:flutter/material.dart';

import '../utils/colors.dart';

class MapKeys extends StatelessWidget {
  final Color color;
  final String text;
  const MapKeys({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 13,height: 13,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3)
          ),
        ),
        SizedBox(width: 5,),
        Text(text, style: TextStyle(color: secondaryColor, fontSize: 11),)
      ],
    );
  }
}
