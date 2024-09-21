import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/payments.dart';
import '../../models/units.dart';
import '../../models/utils.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../text/text_filed_input.dart';

class DialogPayUtil extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  final String period;
  final Function addPay;
  final Function updatePay;
  final UtilsModel utils;
  final double amountcf;
  final String status;
  const DialogPayUtil({super.key, required this.utils, required this.amountcf, required this.unit, required this.entity, required this.period, required this.addPay, required this.updatePay, required this.status});

  @override
  State<DialogPayUtil> createState() => _DialogPayUtilState();
}

class _DialogPayUtilState extends State<DialogPayUtil> {
  TextEditingController _pay = TextEditingController();

  final formKey = GlobalKey<FormState>();
  List<PaymentsModel> _payList = [];
  double utilAmount = 0.0;
  double balance = 0.0;
  String? method;
  String payid = "";

  String formatNumberWithCommas(double number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  void _payRent() {
    setState(() {
      _payList = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
      Uuid uuid = Uuid();
      payid = uuid.v1();
      balance = utilAmount - double.parse(_pay.text);
    });

    PaymentsModel paymentsModel = PaymentsModel(
      payid: payid,
      pid: widget.entity.pid.toString(),
      eid: widget.entity.eid,
      tid: widget.unit.tid,
      uid: widget.unit.id.toString(),
      amount: _pay.text.toString(),
      payerid: currentUser.uid,
      balance: balance.toString(),
      method: method!,
      type: "UTILITY,${widget.utils.text.toUpperCase()}",
      time: widget.period,
      current: DateTime.now().toString(),
      checked: "false",
    );

    // Add payment to local list and update SharedPreferences
    widget.addPay(paymentsModel, double.parse(_pay.text.toString()), widget.utils.text.toUpperCase());
    _payList.add(paymentsModel);
    Data().addOrUpdatePayments(_payList);
    Navigator.pop(context);

    // Perform network request
    // Services.pay(
    //   payid,
    //   widget.entity.pid.toString(),
    //   widget.unit.tid!,
    //   widget.entity.eid,
    //   widget.unit.id.toString(),
    //   currentUser.uid,
    //   _pay.text,
    //   balance.toString(),
    //   method!,
    //   "UTILITY,${widget.utils.text.toUpperCase()}",
    //   widget.period,
    // ).then((response) {
    //   if (response == 'Success') {
    //     // Update local list and SharedPreferences on successful payment
    //     widget.updatePay(payid);
    //     Data().updateOrAddPay(_payList);
    //
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Payment recorded successfully")),
    //     );
    //   } else if (response == 'Failed') {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Payment was not recorded")),
    //     );
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Something went wrong")),
    //     );
    //   }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    method = "Electronic";
    utilAmount = widget.amountcf;
    _pay.text = widget.amountcf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final bgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child:Column(
          children: [
            SizedBox(height:10,),
            TextFieldInput(
              textEditingController: _pay,
              textInputType: TextInputType.number,
              labelText: 'Amount Paid',
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'Please enter the correct amount';
                } else if (RegExp(r'^[0-9.]+$').hasMatch(value)) {
                  double enteredAmount = double.parse(value);
                  if (enteredAmount > utilAmount) {
                    return 'Amount is more than ${formatNumberWithCommas(utilAmount)}';
                  } else {
                    return null;
                  }
                } else {
                  return 'Please enter a valid number';
                }
              },
            ),
            SizedBox(height:5,),
            Row(
              children: [
                Text('Payment Method :  ', style: TextStyle(color: secondaryColor),),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12,),
              decoration: BoxDecoration(
                  color: color1,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      width: 1,
                      color: color1
                  )
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: method,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                  isExpanded: true,
                  dropdownColor: bgColor,
                  items: Data().items.map(buildMenuItem).toList(),
                  onChanged: (value) => setState(() => this.method = value),
                ),
              ),
            ),
            SizedBox(height: 5,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: (){
                        final form = formKey.currentState!;
                        if(form.validate()) {
                          // _payRent();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBlue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(child:Text('RECORD'),),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 1, color: color5,
                          )
                      ),
                      child: Center(child: Text("CANCEL")),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item + " Transaction",
    ),
  );
}
