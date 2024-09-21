import 'dart:convert';

import 'package:Zelli/models/payments.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/bar_model/bar_data.dart';
import '../../utils/colors.dart';

class MyBarChart extends StatefulWidget {
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;
  final bool grid;
  final List<PaymentsModel> pay;
  const MyBarChart({super.key, this.activeColor = screenBackgroundColor, this.inactiveColor = Colors.white, this.textColor = Colors.black, this.grid = false, required this.pay,});

  @override
  State<MyBarChart> createState() => _MyBarChartState();
}

class _MyBarChartState extends State<MyBarChart> {
  List<PaymentsModel> _pay = [];
  List<double> monthlySummary = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  bool _loading = false;
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

  _getSales()async{
    setState(() {
      _loading = true;
    });
    _pay =  widget.pay.where((pay) => pay.type!.split(",").first !="EXP").toList();
    setState(() {
      _jan = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.january && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _feb = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.february && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _march = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.march && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _april = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.april && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _may = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.may && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _jun = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.june && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _jully = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.july && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _agust = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.august && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _sep = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.september && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _oct = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.october && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _nov = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.november && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();
      _dec = _pay.where((element) => DateTime.parse(element.time.toString().split(",").first).month == DateTime.december && DateTime.parse(element.time.toString().split(",").first).year == DateTime.now().year).toList();

      jan = _jan.isEmpty ? 0.0 : _jan.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      feb = _feb.isEmpty ? 0.0 : _feb.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      march = _march.isEmpty ? 0.0 : _march.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      april = _april.isEmpty ? 0.0 : _april.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      may = _may.isEmpty ? 0.0 : _may.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      jun = _jun.isEmpty ? 0.0 : _jun.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      jully = _jully.isEmpty ? 0.0 : _jully.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      agust = _agust.isEmpty ? 0.0 : _agust.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      sep = _sep.isEmpty ? 0.0 : _sep.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      oct = _oct.isEmpty ? 0.0 : _oct.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      nov = _nov.isEmpty ? 0.0 : _nov.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));
      dec = _dec.isEmpty ? 0.0 : _dec.fold(0.0, (previousValue, element) => previousValue + (double.parse(element.amount.toString())));

      monthlySummary = [jan, feb, march, april, may, jun, jully, agust, sep, oct, nov, dec];

      highestMonth = monthlySummary.fold(0, (maxMonth, month) => month > maxMonth ? month : maxMonth);

      _loading = false;
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
    _getSales();
  }


  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      jan: monthlySummary[0],
      feb: monthlySummary[1],
      march: monthlySummary[2],
      april: monthlySummary[3],
      may: monthlySummary[4],
      june: monthlySummary[5],
      jully: monthlySummary[6],
      agust: monthlySummary[7],
      sep: monthlySummary[8],
      oct: monthlySummary[9],
      nov: monthlySummary[10],
      dec: monthlySummary[11],
    );

    myBarData.initializeBarData();

    return BarChart(
      BarChartData(
        maxY: highestMonth==0? 1000000 : adjustHighestNumber(highestMonth),
        minY: 0,
        gridData: FlGridData(show: widget.grid),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
                reservedSize: 44,
                showTitles: true,
                getTitlesWidget: getLeftTitles
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getBottomTitles),
          ),
        ),
        barGroups: myBarData.barData.map((data){
          return BarChartGroupData(
              x: data.x,
              barRods: [
                BarChartRodData(
                    toY: data.y,
                    color: widget.activeColor,
                    width: 25,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(2),
                      topLeft: Radius.circular(2),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: highestMonth==0? 1000000 : adjustHighestNumber(highestMonth),
                        color: widget.inactiveColor
                    )
                )
              ]
          );
        }).toList(),
      ),
      swapAnimationDuration: Duration(milliseconds: 1000), // Optional
      swapAnimationCurve: Curves.easeInOut,
    );
  }

  Widget getLeftTitles(double value, TitleMeta meta){
    final style = TextStyle(
        color: widget.textColor,fontSize: 11
    );
    Widget text;
    text = Text(NumberFormat.compact().format(value), style: style,);
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }

  Widget getBottomTitles(double value, TitleMeta meta){
    final style = TextStyle(
        color: widget.textColor
    );
    Widget text;
    switch (value.toInt()){
      case 0:
        text = Text('Jan', style: style);
        break;
      case 1:
        text =  Text('Feb', style: style);
        break;
      case 2:
        text = Text('Mar', style: style);
        break;
      case 3:
        text =  Text('Apr', style: style);
        break;
      case 4:
        text = Text('May', style: style);
        break;
      case 5:
        text = Text('Jun', style: style);
        break;
      case 6:
        text = Text('July', style: style);
        break;
      case 7:
        text = Text('Ags', style: style);
        break;
      case 8:
        text = Text('Sep', style: style);
        break;
      case 9:
        text = Text('Oct', style: style);
        break;
      case 10:
        text = Text('Nov', style: style);
        break;
      default:
        text =  Text('Dec', style: style);
        break;
    }
    return SideTitleWidget(child: text, axisSide: meta.axisSide);
  }
}
