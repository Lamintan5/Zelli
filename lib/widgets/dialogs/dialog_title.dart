import 'package:flutter/material.dart';

class DialogTitle extends StatelessWidget {
  final String title;
  const DialogTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 10,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 0.5,
                  color: reverse,
                ),
              ),
            ),
            Text(title,
              style: TextStyle(fontWeight: FontWeight.w100),
              softWrap: true,
            ),
            Expanded(
              child : Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  height: 0.5,
                  color: reverse,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5,),
      ],
    );
  }
}
