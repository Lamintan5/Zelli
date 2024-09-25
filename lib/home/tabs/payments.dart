import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/payments.dart';
import '../../widgets/items/item_pay.dart';

class Payments extends StatefulWidget {
  final String eid;
  final String unitid;
  final String tid;
  final String lid;
  final String month;
  final String year;
  final String type;
  const Payments({super.key, required this.eid, required this.unitid, required this.tid, required this.lid, this.month = "", this.year = "", this.type =""});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  List<PaymentsModel> _pay = [];

  _getData(){
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((test){
      bool matchesEid = widget.eid.isEmpty || test.eid == widget.eid.toString();
      bool matchesUnit = widget.unitid.isEmpty || test.uid == widget.unitid;
      bool matchesTid = widget.tid.isEmpty || test.tid == widget.tid.toString();
      bool matchesLid = widget.lid.isEmpty || test.lid == widget.lid.toString();
      bool matchesType = widget.type.isEmpty || test.type == widget.type.toString();
      bool matchesPeriod = widget.month.isEmpty || DateTime.parse(test.time!).month == int.parse(widget.month) && DateTime.parse(test.time!).year == int.parse(widget.year);
      return matchesEid && matchesUnit && matchesTid && matchesLid && matchesPeriod && matchesType;
    }).toList();
    _pay = widget.eid ==""?_pay
        :_pay.where((test) => test.eid==widget.eid).toList();
    _pay.sort((a, b) => DateTime.parse(a.time.toString()).compareTo(DateTime.parse(b.time.toString())));
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
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final width = 500.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  widget.eid.isEmpty && widget.unitid.isEmpty && widget.tid.isEmpty
                      ? SizedBox()
                      : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          hoverColor: color1,
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                  Text(
                    " Payments",
                    style: TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: (){

                      },
                      hoverColor: color1,
                      borderRadius: BorderRadius.circular(5),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.filter_list_rounded),
                      ),
                    ),
                  ),
                ],
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                height: 0.5,
                                color: reverse,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: color1,
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
                                color: reverse,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    indexedItemBuilder : (BuildContext context, PaymentsModel payment, int index) {
                      return ItemPay(payments: payment, from: 'Home', removePay: removePay,);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void removePay(String payid){
    print("Removing Payment");
    _pay.removeWhere((element) => element.payid == payid);
    setState(() {

    });
  }
}
