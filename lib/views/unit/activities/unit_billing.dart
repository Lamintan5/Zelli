import 'dart:convert';
import 'dart:math';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../models/account.dart';
import '../../../models/billing.dart';
import '../../../models/gateway.dart';
import '../../../resources/services.dart';
import '../../../widgets/buttons/call_actions/double_call_action.dart';
import '../../../widgets/dialogs/dialog_title.dart';


class UnitBilling extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final Function reload;
  const UnitBilling({super.key, required this.entity, required this.unit, required this.reload});

  @override
  State<UnitBilling> createState() => _UnitBillingState();
}

class _UnitBillingState extends State<UnitBilling> {
  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];

  List<BillingModel> _allBills = [];
  List<BillingModel> _bills = [];
  List<AccountModel> _accounts = [];

  bool _loading = false;


  _getData(){
    _allBills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).where((test) => test.eid ==widget.unit.eid).toList();
    _bills = _allBills;
    _bills.forEach((bill) {
      bill.access
          .split('*')
          .where((jsonString) => jsonString.isNotEmpty)
          .map((jsonString) => AccountModel.fromJson(json.decode(jsonString)))
          .forEach((account) {
        // Check for duplicates before adding
        if (!_accounts.any((existing) =>
        existing.bid == account.bid &&
            existing.uid == account.uid &&
            existing.accountno == account.accountno &&
            existing.account == account.account)) {
          if(account.uid == widget.unit.id){
            _accounts.add(account);
          }
        }
      });
    });
    _allBills.forEach((e){
      print(e.toJson());
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing'),
        actions: [
          _loading
              ? Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 3,color: reverse,)
                )
              : SizedBox()
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Payment Methods", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),),
            Expanded(
                child: ListView.builder(
                    itemCount: _accounts.length + 1,
                    itemBuilder: (context, index){
                      if (index == _accounts.length) {
                      return TextButton(
                        onPressed: () {
                          dialogAddAccount(context);
                        },
                          child: Text("Add Account"),
                        );
                      } else {
                        AccountModel account = _accounts[index];
                        BillingModel bill = _bills.firstWhere((test) => test.bid == account.bid);
                        var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:  Image.asset(
                            crd.logo,
                            width: 30,
                            height: 30,
                          ),
                          title: Text(bill.businessno),
                          subtitle: bill.type == 'Different'
                            ? Text(account.accountno)
                            : Text(bill.accountno),
                          trailing: PopupMenuButton(
                              icon: Icon(CupertinoIcons.ellipsis_vertical, size: 20,),
                              padding: EdgeInsets.all(0),
                              itemBuilder: (context){
                                return [
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.delete),
                                        SizedBox(width: 10,),
                                        Text("Remove")
                                      ],
                                    ),
                                    onTap: (){
                                      dialogRemove(context, account);
                                    },
                                  ),
                                ];
                              })
                        );
                      }
                })
            )
          ],
        ),
      ),
    );
  }
  void dialogAddAccount(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final size = MediaQuery.of(context).size;
    _allBills = _allBills.where((test) => test.account.contains('Rent')).toList();
    _allBills.removeWhere((bill) => _accounts.any((acc) => bill.accountno.contains(acc.accountno) && bill.type == 'Same'));

    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height * 3/4,
            minHeight: size.height/2 - 100,
            maxWidth: 450,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return _allBills.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: CupertinoColors.activeBlue.withOpacity(0.15  )
                      ),
                      child: Icon(CupertinoIcons.collections, color: CupertinoColors.activeBlue,)
                  ),
                    SizedBox(height: 10,),
                    Text(
                    "Accounts",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                    Text(
                    'There are no additional billing entries available for this entity. Please visit the entity\'s billing section to add new payment methods.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor),
                  ),
                    MaterialButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Text("Close"),
                      color: CupertinoColors.activeBlue,
                    )
                  ],
                ),
              )
              : Column(
                children: [
                  DialogTitle(title: 'A C C O U N T S'),
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        itemCount: _allBills.length,
                        itemBuilder: (context, index){
                          BillingModel bill = _allBills[index];
                          var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: ListTile(
                              onTap: (){
                                Navigator.pop(context);
                                dialogAdd(context, bill);
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: Image.asset(width: 30, height: 30, crd.logo),
                              title: Text(bill.businessno),
                              subtitle: bill.type=='Different'
                                  ? Text('Different account for different units', style: TextStyle(color: secondaryColor),)
                                  : Text(bill.accountno, style: TextStyle(color: secondaryColor),),
                              trailing: Icon(Icons.keyboard_arrow_right_outlined),
                            ),
                          );
                        }
                    ),
                  ),
                ],
              );
        });
  }
  void dialogAdd(BuildContext context, BillingModel bill){
    TextEditingController _accno = TextEditingController();
    final _key = GlobalKey<FormState>();
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Form(
          key: _key,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Container(
            width: 450,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "A C C O U N T"),
                RichText(
                  textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Would you like to add this account as a payment method for Unit ',
                          style: TextStyle(color: secondaryColor)
                        ),
                        TextSpan(
                            text: '${widget.unit.title}? ',
                            style: TextStyle()
                        ),
                        if(bill.type=='Different')
                          TextSpan(
                              text: 'Kindly provide the account.',
                              style: TextStyle(color: secondaryColor)
                          ),
                      ]
                    )
                ),
                bill.type=='Different'
                    ? TextFormField(
                      controller: _accno,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        label: Text("Account Number"),
                        fillColor: color1,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter account number.';
                        }
                        if (value.contains('*')) {
                          return 'The account number cannot contain the "*" character.';
                        }
                        return null; // Return null if the input is valid
                      },
                    )
                    : SizedBox(),
                DoubleCallAction(
                    title: "Add",
                    action: (){
                      _add(
                          AccountModel(
                              bid: bill.bid,
                              uid: widget.unit.id!,
                              accountno: bill.type=='Different'? _accno.text : bill.accountno,
                              account: 'Rent'
                          )
                      );
                    })
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRemove(BuildContext context, AccountModel accountModel){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "A C C O U N T"),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      children: [
                        TextSpan(
                            text: 'Are you sure you wish to remove this account from this unit.',
                            style: TextStyle(color: secondaryColor)
                        ),
                      ]
                  )
              ),
              DoubleCallAction(
                  title: "Remove",
                  titleColor: Colors.red,
                  action: (){
                    _remove(accountModel);
                  })
            ],
          ),
        ),
      );
    });
  }

  void _add(AccountModel account)async{
    List<BillingModel> _bll = [];
    List<String> uniqueBill = [];
    List<String> _accString = [];
    List<AccountModel> _account = [];

    setState(() {
      _loading = true;
    });

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _bll = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();

    _account.add(account);

    _accString = _account.map((model) => jsonEncode(model.toJson())).toList();

    BillingModel billingModel = _bll.firstWhere((test) => test.bid == account.bid);

    var oldAcc = billingModel.access.split("*");
    List<String> newAcc = _accString;
    List<String> finalAcc = [];

    finalAcc = [...oldAcc, ...newAcc];

    String result = finalAcc.join("*");

    _bll.firstWhere((test) => test.bid == account.bid).access = result;

    Services.updateAccess(account.bid, _accString.join('*')).then((value){
      print(value);
      if(value=="success"){
        uniqueBill = _bll.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mybills', uniqueBill);
        myBills = uniqueBill;
        widget.reload();
        setState(() {
          _accounts.add(account);
          _loading = false;
        });
      } else if(value=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Account was not added. Please try again"),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      } else if(value=='Does not exist'){
        setState(() {
          _loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      }
      Navigator.pop(context);
    });
  }
  void _remove(AccountModel account)async{
    List<BillingModel> _bll = [];
    List<String> uniqueBill = [];
    List<String> _accString = [];
    List<AccountModel> _account = [];

    setState(() {
      _loading = true;
    });

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _bll = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();

    _account.add(account);

    _accString = _account.map((model) => jsonEncode(model.toJson())).toList();

    BillingModel billingModel = _bll.firstWhere((test) => test.bid == account.bid);

    var oldAcc = billingModel.access.split("*");
    oldAcc.remove(_accString.join('*'));

    _bll.firstWhere((test) => test.bid == account.bid).access = oldAcc.join('*');

    await Services.removeAccess(account.bid, _accString.first).then((value){
      if(value=="success"||value=='Does not exist'){
        uniqueBill = _bll.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mybills', uniqueBill);
        myBills = uniqueBill;
        widget.reload();
        setState(() {
          _accounts.remove(account);
          _loading = false;
        });
      } else if(value=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account was not removed. Please try again"),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      }  else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      }
      Navigator.pop(context);
    });
  }
}
