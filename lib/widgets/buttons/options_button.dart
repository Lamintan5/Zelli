import 'package:flutter/material.dart';


class OptionsButton extends StatelessWidget {
  final Widget icon;
  final String text;
  const OptionsButton({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black12;
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: color1,
          child: icon,
        ),
        SizedBox(height: 5,),
        Text(text),
      ],
    );;
  }
}
