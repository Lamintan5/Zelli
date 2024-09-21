import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';

import '../../../main.dart';
import '../../../models/entities.dart';
import '../../../models/payments.dart';
import '../../../widgets/items/item_pay.dart';

class PropPayments extends StatefulWidget {
  final EntityModel entity;
  const PropPayments({super.key, required this.entity});

  @override
  State<PropPayments> createState() => _PropPaymentsState();
}

class _PropPaymentsState extends State<PropPayments> {
  List<PaymentsModel> _pay = [];

  _getData(){
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) =>
        pay.eid == widget.entity.eid.toString()).toList();
    _pay.sort((a, b) => DateTime.parse(a.time!.split(",").first.toString()).compareTo(DateTime.parse(b.time!.split(",").first.toString())));
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }


  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final width = 500.0;
    return Column(
      children: [
        SizedBox(width: width,
          child: Row(
            children: [
              Text(" Payments",
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w700
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SizedBox(width: width,
            child: GroupedListView(
              order: GroupedListOrder.DESC,
              elements: _pay,
              shrinkWrap: true,
              groupBy: (_filterpay) => DateTime(
                DateTime.parse(_filterpay.current.toString()).year,
                DateTime.parse(_filterpay.current.toString()).month,
                DateTime.parse(_filterpay.current.toString()).day,
              ),
              itemComparator: (item1, item2) => DateTime.parse(item1.time.toString()).compareTo(DateTime.parse(item2.time.toString())),
              groupHeaderBuilder: (PaymentsModel payment) {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final yesterday = today.subtract(Duration(days: 1));
                final time = DateTime.parse(payment.current.toString());
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          height: 0.5,
                          color: color1,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          time.year == now.year && time.month == now.month && time.day == now.day
                              ? 'Today'
                              : time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day
                              ? 'Yesterday'
                              : DateFormat.yMMMd().format(time),
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          height: 0.5,
                          color: color1,
                        ),
                      ),
                    ],
                  ),
                );
              },
              indexedItemBuilder : (BuildContext context, PaymentsModel payment, int index) {
                return ItemPay(payments: payment, from: 'Entity', removePay: removePay,);
              },
            ),
          ),
        ),
      ],
    );
  }
  void removePay(String payid){
    print("Removing Payment");
    _pay.removeWhere((element) => element.payid == payid);
    setState(() {

    });
  }
}
