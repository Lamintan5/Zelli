import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DoubleCallAction extends StatelessWidget {
  final String title;
  final Color titleColor;
  final VoidCallback action;
  const DoubleCallAction({super.key, this.title = "Continue", required this.action, this.titleColor = CupertinoColors.activeBlue});

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          thickness: 0.1,
          color: reverse,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                    onTap: (){Navigator.pop(context);},
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  )
              ),
              VerticalDivider(
                thickness: 0.1,
                color: reverse,
              ),
              Expanded(
                  child: InkWell(
                    onTap: action,
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child: Text(
                          title,
                          style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 15),
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
