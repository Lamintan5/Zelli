import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/payments.dart';


class SmallLineGraph extends StatefulWidget {
  final List<PaymentsModel> pay;
  final String title;
  const SmallLineGraph({super.key,required this.title, required this.pay,});

  @override
  State<SmallLineGraph> createState() => _SmallLineGraphState();
}

class _SmallLineGraphState extends State<SmallLineGraph> {
  List<PaymentsModel> _payments = [];
  List<PaymentsModel> _payType = [];
  List<double> monthlySummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  DateTime currentDate = DateTime.now();

  List<PaymentsModel> _jan = [];
  List<PaymentsModel> _feb = [];
  List<PaymentsModel> _march = [];
  List<PaymentsModel> _april = [];
  List<PaymentsModel> _may = [];
  List<PaymentsModel> _jun = [];
  List<PaymentsModel> _jully = [];
  List<PaymentsModel> _agust = [];
  List<PaymentsModel> _sep = [];
  List<PaymentsModel> _oct = [];
  List<PaymentsModel> _nov = [];
  List<PaymentsModel> _dec = [];

  double jan = 0.0;
  double feb = 0.0;
  double march = 0.0;
  double april = 0.0;
  double may = 0.0;
  double jun = 0.0;
  double jully = 0.0;
  double agust = 0.0;
  double sep = 0.0;
  double oct = 0.0;
  double nov = 0.0;
  double dec = 0.0;

  double highestMonth = 0.0;

  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  _getPayments(){
    _payments = widget.title == "REVENUE"
        ? widget.pay.where((pay) => pay.type!.split(",").first != "EXP").toList()
        : widget.title == "EXPENSE"
        ? widget.pay.where((pay) => pay.type!.split(",").first == "EXP"
    ).toList()
        :[];
    setState(() {
      _jan = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.january && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _feb = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.february && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _march = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.march && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _april = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.april && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _may = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.may && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _jun = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.june && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _jully = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.july && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _agust = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.august && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _sep = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.september && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _oct = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.october && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _nov = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.november && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();
      _dec = _payments.where((element) => DateTime.parse(element.time.toString()).month == DateTime.december && DateTime.parse(element.time.toString()).year == DateTime.now().year).toList();

      jan = _jan.isEmpty ? 0.0 : _jan.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      feb = _feb.isEmpty ? 0.0 : _feb.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      march = _march.isEmpty ? 0.0 : _march.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      april = _april.isEmpty ? 0.0 : _april.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      may = _may.isEmpty ? 0.0 : _may.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      jun = _jun.isEmpty ? 0.0 : _jun.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      jully = _jully.isEmpty ? 0.0 : _jully.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      agust = _agust.isEmpty ? 0.0 : _agust.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      sep = _sep.isEmpty ? 0.0 : _sep.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      oct = _oct.isEmpty ? 0.0 : _oct.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      nov = _nov.isEmpty ? 0.0 : _nov.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));
      dec = _dec.isEmpty ? 0.0 : _dec.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount.toString()));

      monthlySummary = [jan, feb, march, april, may, jun, jully, agust, sep, oct, nov, dec];

      highestMonth = monthlySummary.fold(0, (maxMonth, month) => month > maxMonth ? month : maxMonth);

    });
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPayments();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 30,height: 20,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: false,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.cyan,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.cyan,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: false,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: bottomTitleWidgets
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true,),),
          ),
          borderData: FlBorderData(show: false,),
          maxY: 10,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, jan==0? 0 :double.parse((jan/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(1, feb==0? 0 :double.parse((feb/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(2, march==0? 0 :double.parse((march/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(3, april==0? 0 :double.parse((april/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(4, may==0? 0 :double.parse((may/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(5, jun==0? 0 :double.parse((jun/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(6, jully==0? 0 :double.parse((jully/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(7, agust==0? 0 :double.parse((agust/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(8, sep==0? 0 :double.parse((sep/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(9, oct==0? 0 :double.parse((oct/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(10, nov==0? 0 :double.parse((nov/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
                FlSpot(11, dec==0? 0 :double.parse((dec/adjustHighestNumber(highestMonth)*10).toStringAsFixed(2))),
              ],
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              barWidth: 1,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 11,
    );
    Widget text;
    switch (value.toInt()){
      case 0:
        text = Text('Mon', style: style);
        break;
      case 1:
        text = Text('Tue', style: style);
        break;
      case 2:
        text = Text('Wed', style: style);
        break;
      case 3:
        text = Text('Thr', style: style);
        break;
      case 4:
        text = Text('Fri', style: style);
        break;
      case 5:
        text = Text('Sat', style: style);
        break;
      default:
        text = Text('Sun', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }
  Widget leftTitleWidgets(double value, TitleMeta meta){
    final style = TextStyle(
        color: Colors.white,fontSize: 11
    );
    Widget text;
    text = Text(NumberFormat.compact().format(value), style: style,);
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
}
