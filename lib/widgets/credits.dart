import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

class Credit extends StatelessWidget {
  final String title;
  final String subtitle;
  const Credit({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title,
          style: TextStyle(
              color: secondaryColor
          ),
        ),
        SizedBox(height: 10,),
        Text(subtitle,
          style: TextStyle(
            fontSize: 20,
            color: CupertinoColors.activeBlue,
            fontWeight: FontWeight.w900
          ),
        ),
      ],
    );
  }
}
