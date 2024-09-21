import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RowButton extends StatelessWidget {
  final void Function() onTap;
  final Widget icon;
  final String title;
  final String subtitle;
  const RowButton({super.key, required this.onTap, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          hoverColor: color1,
          splashColor: CupertinoColors.activeBlue,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 3),
            child: Row(
              children: [
                icon,
                SizedBox(
                  width: 20,
                ),
                Text(
                  title,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 5,),
      ],
    );
  }
}
