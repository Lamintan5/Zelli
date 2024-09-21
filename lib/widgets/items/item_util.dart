import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/util.dart';
import '../../models/utils.dart';
import '../../utils/colors.dart';
import '../dialogs/dialog_title.dart';
import '../dialogs/dialog_util_details.dart';

class ItemUtil extends StatefulWidget {
  final UtilModel util;
  final Function removeUtil;
  final Function addUtil;
  final List<UtilsModel> utils;
  const ItemUtil({super.key, required this.util, required this.removeUtil, required this.addUtil, required this.utils});

  @override
  State<ItemUtil> createState() => _ItemUtilState();
}

class _ItemUtilState extends State<ItemUtil> {
  double amount = 0;
  String period = "";
  bool _isChecked = false;
  late UtilModel util;
  List<UtilsModel> _utils = [];

  _getData(){
    _utils = widget.utils.where((element) => element.text == widget.util.text).toList();
    if(_utils.isNotEmpty) {
      _isChecked = true;
      amount = double.parse(_utils.first.amount);
      period = _utils.first.period;
    }
  }

  _setDate(String newPeriod, double newAmount){
    UtilsModel utilsModel = UtilsModel(
      text: util.text,
      period: newPeriod,
      amount: newAmount.toString(),
      checked: 'false',
    );
    amount = newAmount;
    period = newPeriod;
    widget.addUtil(utilsModel);
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    util = widget.util;
    _getData();

  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: color1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          util.icon,
          const SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(util.text),
                Text(util.message,
                  style: TextStyle(
                      color: secondaryColor,
                      fontSize: 11
                  ),
                ),
                _isChecked
                    ? amount == 0
                    ? TextButton(onPressed: (){
                  dialogAddData(context);
                },
                    child: Text("Click here to enter amount",)
                ) : TextButton(onPressed: (){dialogAddData(context);}, child: Text("Ksh.${formatNumberWithCommas(amount)} ● ${period}"))
                    : const SizedBox()
              ],
            ),
          ),
          Switch(
            value: _isChecked,
            activeColor: CupertinoColors.activeBlue,
            onChanged: (value){
              setState(() {
                _isChecked = value;
                if(value==true){
                  // widget.addUtil(util.text.toUpperCase());
                } else {
                  amount = 0;
                  period = "";
                  widget.removeUtil(widget.util.text);
                }
              });
            },
          )
        ],
      ),
    );
  }
  void dialogAddData(BuildContext context){
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;

    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "U T I L I T Y"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text('Enter the amount and mode of payment in the fields below',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, ),
                  ),
                ),
                DialogUtilDetail(
                  setData: _setDate, period: period, amount: amount,
                ),
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
