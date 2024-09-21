import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/month_model.dart';
import '../../models/payments.dart';
import '../../models/units.dart';
import '../../utils/colors.dart';

class ItemMonthCard extends StatefulWidget {
  final UnitModel unit;
  final MonthModel month;
  final int due;
  const ItemMonthCard({super.key, required this.month, required this.due, required this.unit});

  @override
  State<ItemMonthCard> createState() => _ItemMonthCardState();
}

class _ItemMonthCardState extends State<ItemMonthCard> {
  DateTime current = DateTime.now();
  late DateTime period;

  List<PaymentsModel> _payList = [];
  List<PaymentsModel> _filtPay = [];

  double totalAmount = 0;

  _getPayment(){
    _payList = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) => pay.uid == widget.unit.id.toString() && pay.tid == widget.unit.tid).toList();
    _filtPay = _payList.where((element) => DateTime.parse(element.time!).year ==  widget.month.year && DateTime.parse(element.time!).month == widget.month.month).toList();
    totalAmount = _filtPay.fold(0, (previousValue, element) => previousValue + double.parse(element.amount!));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    period = DateTime(widget.month.year, widget.month.month, widget.due);
    _getPayment();
  }


  @override
  Widget build(BuildContext context) {
    final cont2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Container(
      decoration: BoxDecoration(
        color: _filtPay.isEmpty
            ? cont2
            : period.isAfter(current)
            ? Colors.green
            : totalAmount > 0 && totalAmount < double.parse(widget.unit.price!)
            ? Colors.orange
            : totalAmount == 0
            ? Colors.red
            : cont2,
        borderRadius: BorderRadius.circular(10),
      ),
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.month.monthName.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Text(widget.month.year.toString(),
            style: TextStyle(color: secondaryColor),
          ),
        ],
      ),
    );
  }
}
