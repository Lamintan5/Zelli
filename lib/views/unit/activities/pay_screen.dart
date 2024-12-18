import 'dart:convert';

import 'package:Zelli/main.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';

import '../../../models/account.dart';
import '../../../models/billing.dart';
import '../../../models/entities.dart';
import '../../../models/gateway.dart';
import '../../../models/lease.dart';
import '../../../models/month_model.dart';
import '../../../models/units.dart';
import '../../../utils/colors.dart';
import '../../../widgets/text/text_filed_input.dart';

class PayScreen extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  final double amount;
  final String account;
  final String cost;
  final bool isMax;
  final Function reload;
  final MonthModel lastPaid;
  const PayScreen({super.key, required this.entity, required this.unit, required this.lease, required this.amount, required this.account, required this.cost, required this.isMax, required this.reload, required this.lastPaid});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  List<BillingModel> _bills = [];
  List<AccountModel> _accounts = [];
  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];

  late EntityModel entity;
  late UnitModel unit;
  late LeaseModel lease;
  late MonthModel lastPaid;

  double amount = 0.0;
  double balance = 0.0;
  double paid = 0.0;

  String accountType = "";
  String cost = "";
  String selectedAccount = "";

  bool isMax = false;

  _getData(){
    balance = amount - paid;

    _bills = myBills
        .map((jsonString) => BillingModel.fromJson(json.decode(jsonString)))
        .where((test) {
      if (widget.account == 'DEPOSIT' && test.account.contains('Rent')) {
        return true;
      }
      return test.account.toLowerCase().contains(widget.account.toLowerCase());
    })
        .toList();


    for (int i = 0; i < _bills.length; i++) {
      BillingModel bill = _bills[i];

      bill.access
          .split('*')
          .where((jsonString) => jsonString.isNotEmpty)
          .map((jsonString) => AccountModel.fromJson(json.decode(jsonString)))
          .forEach((account) {
        if (!_accounts.any((existing) =>
        existing.bid == account.bid &&
            existing.uid == account.uid &&
            existing.accountno == account.accountno &&
            existing.account == account.account)) {
          if (account.uid == widget.unit.id) {
            _accounts.add(account);
            if (_accounts.isNotEmpty && i == 0) {
              selectedAccount = bill.type == 'Different' ? account.accountno : bill.accountno;
            }
          }
        }
      });
    }
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    entity = widget.entity;
    unit = widget.unit;
    lease = widget.lease;
    amount = widget.amount;
    accountType = widget.account;
    cost = widget.cost;
    isMax = widget.isMax;
    lastPaid = widget.lastPaid;
    paid = amount;
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    return Scaffold(
      appBar: AppBar(
        title: Text(TFormat().toCamelCase(accountType)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: CupertinoColors.activeBlue.withOpacity(0.15  )
                            ),
                            child: LineIcon.wallet(color: CupertinoColors.activeBlue, size: 30,)
                        ),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(3),
                                child: Text(
                                  '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}',
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: (){
                                    dialogAddPaid(context);
                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: CupertinoColors.activeBlue
                                    ),
                                    child: Icon(Icons.edit, color: Colors.black,size: 15,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Basic Information", style: heading,),
                                horizontalItems("Lease ID", lease.lid.split("-").first.toUpperCase()),
                                horizontalItems("Property", entity.title.toString().split("-").first),
                                horizontalItems("Unit", unit.title.toString()),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Payment Details", style: heading,),
                                horizontalItems("Remitter", currentUser.username!),
                                horizontalItems("Account", accountType.toUpperCase()),
                                horizontalItems("Amount Due", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}'),
                                horizontalItems("Balance", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}'),
                                horizontalItems("Amount Paid", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                '  Payment Method',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        _accounts.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.red.withOpacity(0.15),
                                child: Text(
                                    'It appears that no account is currently linked to this unit. Kindly contact your property manager to set up the necessary payment gateways.',
                                    style: TextStyle(color: Colors.red),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _accounts.length,
                                itemBuilder: (context, index){
                                  AccountModel account = _accounts[index];
                                  BillingModel bill = _bills.firstWhere((test) => test.bid == account.bid);
                                  var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));
                                  var accno = bill.type == 'Different'? account.accountno :bill.accountno;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading:  Image.asset(
                                      crd.logo,
                                      width: 30,
                                      height: 30,
                                    ),
                                    title: Text(bill.businessno),
                                    subtitle: Text(accno),
                                    trailing: CupertinoCheckbox(
                                        shape: CircleBorder(),
                                        checkColor: Colors.black,
                                        value: selectedAccount == accno? true : false,
                                        onChanged: (value){
                                          setState(() {
                                            selectedAccount = accno;
                                          });
                                    }),
                                    onTap: (){
                                      setState(() {
                                        selectedAccount = accno;
                                      });
                                    },
                                  );

                            })
                      ],
                    ),
                  )
              ),
              Container(
                width: 450,
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _accounts.isEmpty || paid == 0
                      ?CupertinoColors.activeBlue.withOpacity(0.4)
                      :CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                  child: Text(
                    "Pay",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),

              )
            ],
          ),
        ),
      ),
    );
  }
  Widget horizontalItems(String title, String value){
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor),),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }
  void dialogAddPaid(BuildContext context){
    final  _key = GlobalKey<FormState>();
    TextEditingController _paid = TextEditingController();
    _paid.text = paid == 0? amount.toString() : paid.toString();
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            padding: EdgeInsets.all(8),
            child: Form(
                key: _key,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'A M O U N T'),
                    SizedBox(height: 5,),
                    TextFieldInput(
                      textEditingController: _paid,
                      textInputType: TextInputType.number,
                      textAlign: TextAlign.center,
                      labelText: "Amount Paid",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        double? amnt = double.tryParse(value);
                        if (amnt == null || amnt <= 0) {
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
                    DoubleCallAction(
                        action: (){
                          final form = _key.currentState!;
                          if(form.validate()){
                            Navigator.pop(context);
                            setState(() {
                              paid = double.parse(_paid.text);
                              balance = amount - paid;
                            });

                          }
                    })
                  ],
                )
            ),
          ),
        )
    );
  }
}
