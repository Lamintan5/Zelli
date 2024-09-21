import 'dart:convert';

import 'package:Zelli/widgets/items/item_pay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/entities.dart';
import '../../../models/month_model.dart';
import '../../../models/payments.dart';
import '../../../models/lease.dart';
import '../../../models/units.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/items/item_month.dart';
import '../../../widgets/map_key.dart';
import '../unit_profile.dart';


class PayPeriods extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  final LeaseModel tenant;
  final Function addPay;
  final Function updatePay;
  const PayPeriods({super.key, required this.unit, required this.entity, required this.tenant, required this.addPay, required this.updatePay});

  @override
  State<PayPeriods> createState() => _PayPeriodsState();
}

class _PayPeriodsState extends State<PayPeriods> {
  TextEditingController _search = TextEditingController();
  List<PaymentsModel> _paySortList = [];
  List<PaymentsModel> _fltPaySort = [];
  List<PaymentsModel> _sortedPay = [];

  List<MonthModel> monthsList = [];
  late DateTime startDate;
  late DateTime endDate;

  double blncRent = 0;
  double blncDepo = 0;

  double oldRent = 0;
  double oldDepo = 0;


  _getPayments(){
    _paySortList = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) => pay.uid == widget.unit.id.toString()).toList();
    _fltPaySort = _paySortList.where((element) => element.eid == widget.unit.eid.toString() && element.tid == widget.unit.tid.toString()).toList();
    _sortedPay = _fltPaySort;
    DateTime currentMonth = DateTime.now();
    DateTime firstRentDate =  _sortedPay.isEmpty
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(widget.entity.due.toString()))
        : DateTime.parse(_sortedPay.first.time.toString());
    DateTime lastRentDate =  _sortedPay.isEmpty
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(widget.entity.due.toString()))
        : DateTime.parse(_sortedPay.last.time.toString());
    startDate = DateTime(firstRentDate.year, firstRentDate.month, int.parse(widget.entity.due.toString()));
    endDate = lastRentDate.month < currentMonth.month
        ?  DateTime(currentMonth.year, currentMonth.month, int.parse(widget.entity.due.toString()))
        : DateTime(lastRentDate.year, lastRentDate.month, int.parse(widget.entity.due.toString()));
    monthsList = generateMonthsList(startDate, endDate);
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPayments();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      monthsList.forEach((item) {
        if (item.monthName.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.year.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = monthsList;
    }
    final width = 500.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          SizedBox(width: width,
            child: TextFormField(
              controller: _search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "🔎  Search for Periods...",
                hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                fillColor: color1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(5)
                  ),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
              onChanged:  (value) => setState((){}),
            ),
          ),
          SizedBox(height: 10,),
          SizedBox(width: width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MapKeys(color: color1, text: 'Occupied'),
                MapKeys(color: CupertinoColors.activeOrange, text: 'Incomplete'),
                MapKeys(color: Colors.green, text: 'Prepaid'),
                MapKeys(color: Colors.red, text: 'Accrual'),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: SizedBox(width: 1000,
              child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index){
                    MonthModel monthModel = filteredList[index];
                    return InkWell(
                      onTap: (){
                        // dialogActivities(context, monthModel.monthName, monthModel.year, index, monthModel.month);
                      },
                      borderRadius: BorderRadius.circular(10),
                      splashColor: CupertinoColors.activeBlue,
                      child: ItemMonthCard(
                        month: monthModel,
                        due: int.parse(widget.entity.due!), unit: widget.unit,
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  List<MonthModel> generateMonthsList(DateTime startDate, DateTime endDate) {
    List<MonthModel> monthsList = [];

    for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = DateTime(date.year, date.month + 1, date.day)) {
      String monthName = DateFormat('MMM').format(date);
      monthsList.add(MonthModel(year: date.year, monthName: monthName, month: date.month, amount: 0, balance: 0));
    }
    return monthsList;
  }
}
