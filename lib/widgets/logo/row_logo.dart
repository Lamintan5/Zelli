import 'package:flutter/material.dart';

class RowLogo extends StatelessWidget {
  final String text;
  const RowLogo({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black12;
    return  SizedBox(
      child: Row(
        children: [
          Image.asset(
            'assets/logo/logo-48px.png',
            height: 35,
          ),
          SizedBox(width: 5,),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Z E L L I',
                style: TextStyle(fontWeight: FontWeight.w100),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              text == "" ? SizedBox() :Text(text,style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),)
            ],
          )
        ],
      ),
    );
  }
}
