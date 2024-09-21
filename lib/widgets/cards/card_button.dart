import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final void Function() onTap;
  final String text;
  final Color backcolor;
  final Color forecolor;
  final Widget icon;
  const CardButton({super.key, required this.text, required this.backcolor, required this.forecolor, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    double textScaleFactor = MediaQuery.of(context).textScaleFactor;
    double largeTextThreshold = 1;
    bool isLargeText = textScaleFactor >= largeTextThreshold;
    final width = MediaQuery.of(context).size.width;

    return Tooltip(
      message: text,
      child: Card(
        color: backcolor,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                SizedBox(width: 5),
                Text(
                  width > 450
                      ? text
                      : isLargeText?'':text, style: TextStyle(color: forecolor),),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
