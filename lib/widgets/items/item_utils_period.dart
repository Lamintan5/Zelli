import 'package:Zelli/widgets/items/item_pay.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/entities.dart';
import '../../models/month_model.dart';
import '../../models/payments.dart';
import '../../models/units.dart';
import '../../models/util.dart';
import '../../models/utils.dart';
import '../../utils/colors.dart';
import '../dialogs/dialog_pay_util.dart';
import '../dialogs/dialog_title.dart';

class ItemUtilPeriod extends StatefulWidget {
  final UtilsModel utils;
  final UtilModel util;
  final UnitModel unit;
  final EntityModel entity;
  final Function addPay;
  final Function updatePay;
  final List<PaymentsModel> periods;
  final MonthModel month;
  const ItemUtilPeriod({super.key, required this.utils, required this.unit, required this.entity, required this.addPay, required this.updatePay, required this.util, required this.periods, required this.month});

  @override
  State<ItemUtilPeriod> createState() => _ItemUtilPeriodState();
}

class _ItemUtilPeriodState extends State<ItemUtilPeriod> {
  double balance = 0;
  double oldbalance = 0;
  double thisAmount = 0;


  _getData(){
    thisAmount = widget.periods.where((element) => element.type?.toUpperCase() == widget.utils.text.toUpperCase()).fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    oldbalance = double.parse(widget.utils.amount) - thisAmount;
    balance = oldbalance;
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
        ? Colors.white12
        : Colors.black12;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(width: 1, color: color)),
            child: Center(
                child: Icon(widget.util.icon)),
          ),
          SizedBox(width: 10,),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.utils.text),
                  balance==0 || balance <0
                      ?Text('Kshs.${formatNumberWithCommas(double.parse(widget.utils.amount))} ● ${widget.utils.period}', style: TextStyle(color: secondaryColor),)
                      :balance==double.parse(widget.utils.amount)
                      ? TextButton(
                      onPressed: (){
                        dialogpayUtil(context, widget.utils, double.parse(widget.utils.amount), balance, widget.month.month, widget.month.monthName, widget.month.year);
                      },
                      child: Text("Kshs.${formatNumberWithCommas(double.parse(widget.utils.amount))} ● ${widget.utils.period}"))
                      :TextButton(
                      onPressed: (){
                        dialogpayUtil(context, widget.utils, double.parse(widget.utils.amount), balance, widget.month.month, widget.month.monthName, widget.month.year);
                      },
                      child: Text("Balance ${balance}")),
                ],
              )
          ),
          InkWell(
            onTap: (){
              dialogPayStatements(context, widget.utils.text.toUpperCase(), widget.periods.where((element) => element.type == widget.utils.text.toUpperCase()).toList());
            },
            child: CircleAvatar(
              radius: 15,
              backgroundColor: color1,
              child: Center(
                child: Icon(
                  Icons.chevron_right_rounded, color: color2,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
  void dialogpayUtil(BuildContext context, UtilsModel utils, double amount, double balance,int monthIndex,String month, int year,){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(fontWeight: FontWeight.w700,);

    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title:  utils.text.toUpperCase()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(fontSize: 12, color: reverse),
                          children: [
                            TextSpan(
                              text: 'Wish to record ',
                            ),
                            TextSpan(
                                text: utils.text.toLowerCase(),
                                style: style
                            ),
                            TextSpan(
                              text: balance == amount? ' bill of ' : ' bill balance of ',
                            ),
                            TextSpan(
                                text: "Ksh.${formatNumberWithCommas(balance)}",
                                style: style
                            ),
                            TextSpan(
                              text: utils.period == "Once"
                                  ? ''
                                  : utils.period == "Annually"
                                  ? ' for the year'
                                  :' for the month ',
                            ),
                            TextSpan(
                                text: "${month} ${year}",
                                style: style
                            ),
                          ]
                      )
                  ),
                ),
                DialogPayUtil(
                  utils: utils,
                  amountcf: balance,
                  unit: widget.unit,
                  entity: widget.entity,
                  addPay: _addPay,
                  updatePay: widget.updatePay,
                  period: DateTime(year, monthIndex, int.parse(widget.entity.due!)).toString(),
                  status: '',
                )
              ],
            ),
          ),
        )
    );
  }
  void _addPay(PaymentsModel paymentsModel, double paid,String account){
    widget.addPay(paymentsModel, paid, account);
    balance = oldbalance - paid;
    setState(() {

    });
  }
  void dialogStatements(BuildContext context, UtilsModel utils, double amount, double balance,int monthIndex,String month, int year,){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(fontWeight: FontWeight.w700,);

    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title:  utils.text.toUpperCase()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          style: TextStyle(fontSize: 12, color: reverse),
                          children: [
                            TextSpan(
                              text: 'Wish to record ',
                            ),
                            TextSpan(
                                text: utils.text.toLowerCase(),
                                style: style
                            ),
                            TextSpan(
                              text: balance == amount? ' bill of ' : ' bill balance of ',
                            ),
                            TextSpan(
                                text: "Ksh.${formatNumberWithCommas(balance)}",
                                style: style
                            ),
                            TextSpan(
                              text: utils.period == "Once"
                                  ? ''
                                  : utils.period == "Annually"
                                  ? ' for the year'
                                  :' for the month ',
                            ),
                            TextSpan(
                                text: "${month} ${year}",
                                style: style
                            ),
                          ]
                      )
                  ),
                ),
                DialogPayUtil(
                  utils: utils,
                  amountcf: balance,
                  unit: widget.unit,
                  entity: widget.entity,
                  addPay: widget.addPay,
                  updatePay: widget.updatePay,
                  period: DateTime(year, monthIndex, int.parse(widget.entity.due!)).toString(),
                  status: '',
                )
              ],
            ),
          ),
        )
    );
  }
  void dialogPayStatements(BuildContext context,String account, List<PaymentsModel> payments){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final style = TextStyle(fontWeight: FontWeight.w700,);
    final padding = EdgeInsets.symmetric(horizontal: 10);
    void removePay(String payid){
      print("Removing Payment");
      payments.removeWhere((element) => element.payid == payid);
      setState(() {

      });
    }
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: account),
                Padding(
                  padding: padding,
                  child: Text(
                    payments.length == 0? 'No transactions occurred during the current month.' : 'The following list displays all transactions for the current period',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor),
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: payments.length,
                    itemBuilder: (context, index){
                      PaymentsModel paymentsModel = payments[index];
                      return ItemPay(payments: paymentsModel, removePay: removePay,from: "Entity", entity: widget.entity, unit: widget.unit,);
                    }),
                SizedBox(height: 10,)
              ],
            ),
          ),
        )
    );
  }
  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }
}
