import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../utils/colors.dart';

class LineWidget extends StatefulWidget {
  final Widget icon;
  final String title;
  final double amount;
  const LineWidget({super.key, required this.icon, required this.title, required this.amount});

  @override
  State<LineWidget> createState() => _LineWidgetState();
}

class _LineWidgetState extends State<LineWidget> {
  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color1,
            child: widget.icon,
          ),
          SizedBox(width: 10,),
          Expanded(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title),
                          Text('Revenue', style: TextStyle(color: secondaryColor),),
                        ],
                      ),
                    ),
                    Text("Ksh.${TFormat().formatNumberWithCommas(widget.amount)}")
                  ],
                ),
                LinearPercentIndicator(
                  animation: true,
                  animateFromLastPercent: true,
                  animationDuration: 800,
                  padding: EdgeInsets.zero,
                  lineHeight: 5,
                  percent: widget.amount==0.0? 0.0: widget.amount/adjustHighestNumber(widget.amount),
                  progressColor: CupertinoColors.activeBlue,
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  double adjustHighestNumber(double number) {
    if (number >= 1 && number < 10) {
      return 10;
    } else if (number >= 10 && number < 100) {
      return 100;
    } else if (number >= 100 && number < 1000) {
      return 1000;
    } else if (number >= 1000 && number < 10000) {
      return 10000;
    } else if (number >= 10000 && number < 100000) {
      return 100000;
    } else if (number >= 100000 && number < 1000000) {
      return 1000000;
    } else if (number >= 1000000 && number < 10000000) {
      return 10000000;
    }
    return number;
  }

}
