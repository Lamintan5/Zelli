import 'package:flutter/material.dart';

class RowLogoSingle extends StatelessWidget {
  final double height;
  const RowLogoSingle({super.key, this.height = 20});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black12;
    return  Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/logo/logo-48px.png',
          height: height
        ),
        SizedBox(width: 5,),
        Text('Z E L L I', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 18),),
      ],
    );
  }
}
