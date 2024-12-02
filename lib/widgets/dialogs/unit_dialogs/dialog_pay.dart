import 'package:Zelli/main.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/month_model.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/widgets/text/text_filed_input.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../models/data.dart';
import '../../../models/units.dart';
import '../../../utils/colors.dart';

class DialogPay extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  final double amount;
  final String account;
  final String cost;
  final bool isMax;
  final Function reload;
  final MonthModel lastPaid;
  const DialogPay({super.key, required this.unit, required this.amount, required this.entity, required this.account, required this.reload, required this.lastPaid, required this.lease, required this.cost, required this.isMax});

  @override
  State<DialogPay> createState() => _DialogPayState();
}

class _DialogPayState extends State<DialogPay> {
  late TextEditingController _amount;
  final _key = GlobalKey<FormState>();
  String? method;
  bool _loading = false;
  double balance = 0;
  double amount = 0;
  late MonthModel month;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    month = MonthModel.copy(widget.lastPaid);
    _amount = TextEditingController();
    method = "Electronic";
    if(widget.account=="RENT"){
      if(widget.amount == 0){
        amount = double.parse(widget.lease.rent.toString());
        if (month.month == 12) {
          month.year += 1;
          month.month = 1;
        } else {
          month.month += 1;
        }
      } else {
        amount = widget.amount;
      }
    } else {
      amount = widget.amount;
    }
    _amount.text = amount.toString();

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final bgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Form(
      key: _key,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          RichText(
              text: TextSpan(
                  children: [
                    TextSpan(
                        text: "Record ",
                        style: TextStyle(color: secondaryColor)
                    ),
                    TextSpan(
                        text: "tenant ",
                        style: TextStyle(color: secondaryColor)
                    ),
                    TextSpan(
                        text: "${widget.account.toLowerCase()} ",
                        style: TextStyle(color: reverse)
                    ),
                    TextSpan(
                        text: "payment amount of ",
                        style: TextStyle(color: secondaryColor,)
                    ),
                    TextSpan(
                        text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}.",
                        style: TextStyle(color: reverse, )
                    ),
                  ]
              )
          ),
          SizedBox(height: 5),
          TextFieldInput(
            textEditingController: _amount,
            textInputType: TextInputType.number,
            textAlign: TextAlign.center,
            labelText: "Amount",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              double? amnt = double.tryParse(value);
              if (amnt == null ) {
                return 'Please enter a valid number ';
              }
              if (value.contains('.') && value.split('.')[1].length > 2) {
                return 'Please enter a number with no more than 2 decimal places';
              }
              if(widget.isMax == true && amnt > widget.amount){
                return 'Amount is more than ${TFormat().formatNumberWithCommas(widget.amount)}';
              }
              return null;
            },
          ),
          Row(
            children: [
              Text('Payment Method :  ', style: TextStyle(color: method==null?Theme.of(context).colorScheme.error:secondaryColor),),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12,),
            decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    width: 1,
                    color: method==null?Theme.of(context).colorScheme.error:color1
                )
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: method,
                icon: Icon(Icons.arrow_drop_down, color: method==null?Theme.of(context).colorScheme.error:secondaryColor),
                isExpanded: true,
                dropdownColor: bgColor,
                items: Data().items.map(buildMenuItem).toList(),
                onChanged: (value) => setState(() => this.method = value),
              ),
            ),
          ),
          method==null
              ?Row(
            children: [
              Text("   Please enter payment method", style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),),
            ],
          )
              :SizedBox(),
          Divider(
            thickness: 0.1,
            color: reverse,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                      onTap: (){Navigator.pop(context);},
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                            textAlign: TextAlign.center
                          ),
                        ),
                      ),
                    )
                ),
                VerticalDivider(
                  thickness: 0.1,
                  color: reverse,
                ),
                Expanded(
                    child: InkWell(
                      onTap: (){
                        final form = _key.currentState!;
                        if(form.validate()&&method!=null&&!_loading) {
                          _pay();
                          //calculatePayments(80000, 15000, 5000);
                        }
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(height: 40,
                        child: Center(
                          child: _loading
                              ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                              :Text(
                            "Pay",
                            style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                            textAlign: TextAlign.center,),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _pay()async{
    String payid = "";
    Uuid uuid = Uuid();
    setState(() {
      _loading = true;
      payid = uuid.v1();
    });
    int months = 0;
    double firstMonthPaid = month.balance;
    double paid = double.parse(_amount.text);
    double rent = double.parse(widget.lease.rent.toString());
    double remainingAmount = paid - firstMonthPaid;
    DateTime start = DateTime.now();
    DateTime end = DateTime.now();

    // print('Month 1: Paid \$${firstMonthPaid.toStringAsFixed(2)}, Remaining balance for Month 1: \$${(rent - firstMonthPaid).toStringAsFixed(2)}');

    while (remainingAmount >= rent) {
      months++;
      remainingAmount -= rent;
      // print('Month ${months + 1}: Paid \$${rent.toStringAsFixed(2)}, Remaining balance: \$${remainingAmount.toStringAsFixed(2)}');
    }

    if (remainingAmount > 0) {
      months++;
      // print('Month ${months + 1}: Paid \$${remainingAmount.toStringAsFixed(2)}, Remaining balance for Month ${months + 1}: \$${(rent - remainingAmount).toStringAsFixed(2)}');
    }
    balance = remainingAmount == 0? 0 :  rent - remainingAmount;
    start = DateTime(month.year,month.balance==0?month.month+1:month.month);
    end = DateTime(month.year,month.month+months);
    // print("Balance ${balance}");
    // print('Total months covered: $months');
    // print('Final remaining balance: \$${remainingAmount.toStringAsFixed(2)}');
    // print("Start : ${DateFormat.yMMMEd().format(start)}, End : ${DateFormat.yMMMEd().format(end)}");

    PaymentsModel paymodel = PaymentsModel(
        payid: payid,
        pid: widget.entity.pid,
        admin: widget.entity.admin,
        tid: widget.unit.tid,
        lid:  widget.unit.lid,
        eid: widget.entity.eid,
        uid: widget.unit.id,
        payerid: currentUser.uid,
        amount: double.parse(_amount.text).toString(),
        balance: widget.account == "DEPOSIT"? (widget.amount -  double.parse(_amount.text)).toString() : balance.toString(),
        method: method,
        type: widget.account,
        time: DateTime(month.year, month.month).toString(),
        current: DateTime.now().toString(),
        checked: "true",
    );

    await Services.pay(paymodel).then((response)async{
      Navigator.pop(context);
      if(response=="Success"){
        await Data().addPayment(paymodel, widget.reload).then((value){
          setState(() {
            _loading = value;
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Payment was recorded Successfully."),
              showCloseIcon: true,
            )
        );
      } else if(response=="Failed"){
        setState(() {
          _loading = false;

        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Payment was not recorded. Please try again"),
              showCloseIcon: true,
          )
        );
      } else {
        setState(() {
          _loading = false;

        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
      }
    });
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item + " Transaction",
    ),
  );
}
