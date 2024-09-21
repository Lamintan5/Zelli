import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SingleCallAction extends StatelessWidget {
  final String title;
  final VoidCallback? action;
  const SingleCallAction({super.key, this.title = "Continue",  this.action});

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      children: [
        action == null?SizedBox():Divider(
          thickness: 0.1,
          color: reverse,
        ),
        action == null
            ? SizedBox()
            : InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
        action != null?SizedBox():Divider(
          thickness: 0.1,
          color: reverse,
        ),
        action != null? SizedBox(): InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: Text(
                "Cancel",
                style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        )
      ],
    );
  }
}
