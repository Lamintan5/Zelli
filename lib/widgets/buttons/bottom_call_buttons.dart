import 'package:flutter/material.dart';

class BottomCallButtons extends StatelessWidget {
  final void Function() onTap;
  final Widget icon;
  final String title;
  final Color actionColor;
  final Color backColor;
  const BottomCallButtons({super.key, required this.onTap, required this.icon, required this.actionColor, required this.title,
    this.backColor = Colors.black12});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        hoverColor: color1,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              icon,
              SizedBox(height: 5,),
              Text(title,
                style: TextStyle(color: actionColor, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            ],
          ),
        ),
      ),
    );
  }
}
