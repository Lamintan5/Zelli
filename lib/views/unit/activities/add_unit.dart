import 'dart:convert';

import 'package:Zelli/models/account.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/billing.dart';
import '../../../models/entities.dart';
import '../../../models/gateway.dart';
import '../../../models/units.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/dialog_title.dart';


class AddUnit extends StatefulWidget {
  final EntityModel entity;
  final Function reload;
  final int floor; 
  const AddUnit({super.key, required this.entity, required this.reload, required this.floor});

  @override
  State<AddUnit> createState() => _AddUnitState();
}

class _AddUnitState extends State<AddUnit> {
  TextEditingController _title = TextEditingController();
  TextEditingController _rent = TextEditingController();
  TextEditingController _deposit = TextEditingController();

  final formKey = GlobalKey<FormState>();
  
  List<UnitModel> unitsList = [];
  List<String> _newUnits = [];
  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];
  List<BillingModel> _bills = [];
  
  bool _adding = false;
  
  int roomNo = 0;

  String id = "";
  String selectedid = "";

  _addUnit()async{
    List<UnitModel> _unit = [];
    List<BillingModel> _bll = [];
    List<String> uniqueUnit = [];
    List<String> uniqueBill = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _bll = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList();

    DateTime now = DateTime.now();
    Uuid uuid = Uuid();
    id = uuid.v1();
    UnitModel unitModel = UnitModel(
        id: id,
        pid: widget.entity.pid.toString(),
        eid: widget.entity.eid,
        tid: "",
        lid: "",
        tenant: "",
        accrual: "",
        prepaid: "",
        account: "",
        price: _rent.text.trim(),
        room: roomNo.toString(),
        floor: widget.floor.toString(),
        deposit: _deposit.text.trim(),
        status: "",
        title: _title.text.trim(),
        time: now.toString(),
        checked :  "false"
    );
    if(!_unit.any((test)=>test.id==id)){
      _unit.add(unitModel);
    }
    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
    widget.reload();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unit added to units list"),
          showCloseIcon: true,
        )
    );

    await Services.addUnits(unitModel).then((response){
      setState(() {
        _adding = true;
      });
      if(response=="Success"){
        List<AccountModel> _account = [];
        List<String> _accString = [];

        _bills.where((test) => test.checked == 'true').forEach((bill)async{
          var accountModel = AccountModel(bid: bill.bid, uid: id, accountno: bill.accountno, account: 'Rent');
          _account.add(accountModel);
          _accString = _account.map((model) => jsonEncode(model.toJson())).toList();

          BillingModel billingModel = _bll.firstWhere((test) => test.bid == bill.bid);

          var oldAcc = billingModel.access.split("*");
          List<String> newAcc = _accString;
          List<String> finalAcc = [];

          finalAcc = [...oldAcc, ...newAcc];

          String result = finalAcc.join("*");

          _bll.firstWhere((test) => test.bid == bill.bid).access = result;

          Services.updateAccess(bill.bid, _accString.join('*')).then((value){
            print(value);
          });
        });

        _unit.firstWhere((test) => test.id==unitModel.id).checked = "true";
        uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
        uniqueBill = _bll.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myunit', uniqueUnit);
        sharedPreferences.setStringList('mybills', uniqueBill);
        myUnits = uniqueUnit;
        myBills = uniqueBill;
        _clear();
        widget.reload();
        _getData();
        setState(() {
          _adding = false;
        });
      } else {
        setState(() {
          _adding = false;
        });
      }
    });
  }

  _getData(){
    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList()
        .where((test)=> test.eid == widget.entity.eid && test.account.contains("Rent")).toList();
    _bills.forEach((bill){
      if(bill.type == "Same"){
        bill.checked = 'true';
      } else if(bill.type=='Different'){
        bill.accountno = '';
        bill.checked = 'false';
      } else {
        bill.checked = 'false';
      }
    });
    // print(_bills.map((e) => e.toJson()));
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Unit"),
      ),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                width:500,
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Unit Details",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 5,),
                      TextFormField(
                        controller: _title,
                        keyboardType: TextInputType.text,
                        maxLines: 1,
                        minLines: 1,
                        decoration: InputDecoration(
                          label: Text("Unit Title"),
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5)
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        onChanged:  (value) => setState((){}),
                        validator: (value){
                          if(value!.isEmpty || value==""){
                            return "Please enter unit title";

                          }
                        },
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "Unit Type",
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                          color: color1,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            Text(roomNo == 0 ? "  Studio" : " ${roomNo} Bedroom"),
                            Expanded(child: SizedBox()),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  if(roomNo >0){
                                    roomNo--;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(5),
                              child: Icon(Icons.remove_circle),
                            ),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){
                                  setState(() {
                                    roomNo++;
                                  });
                                },
                                borderRadius: BorderRadius.circular(5),
                                child: Icon(Icons.add_circle)
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30,),
                      Text(
                        "Payment Details",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 5,),
                      TextFormField(
                        controller: _rent,
                        maxLines: 1,
                        minLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text("Rent"),
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5)
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        onChanged:  (value) => setState((){}),
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value.';
                          }

                          if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            return null;
                          } else {
                            return 'Please enter a valid number with only one decimal point.';
                          }

                        },
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        controller: _deposit,
                        maxLines: 1,
                        minLines: 1,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          label: Text("Deposit"),
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(5)
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                        ),
                        onChanged:  (value) => setState((){}),
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value.';
                          }

                          if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            return null;
                          } else {
                            return 'Please enter a valid number with only one decimal point.';
                          }
                        },
                      ),
                      SizedBox(height: 30,),
                      _bills.isEmpty
                          ? SizedBox()
                          : Text(
                        "Payment Method",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      _bills.isEmpty
                          ? SizedBox()
                          : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _bills.length,
                          itemBuilder: (context, index){
                            BillingModel bill = _bills[index];
                            var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));
                            return ListTile(
                              onTap: (){
                                setState(() {
                                  if(bill.checked == "false"){
                                    if(bill.type=="Different"){
                                      dialogAddAccount(context, bill);
                                    } else {
                                      bill.checked = 'true';
                                    }
                                  } else {
                                    if(bill.type=="Different"){
                                      bill.accountno = '';
                                    }
                                    bill.checked = 'false';
                                  }
                                });
                              },
                              contentPadding: EdgeInsets.zero,
                              leading: Image.asset(
                                crd.logo,
                                width: 30,
                                height: 30,
                              ),
                              title: Text(bill.businessno),
                              subtitle: Text(
                                bill.accountno.isEmpty
                                    ? "Different accounts for different units"
                                    : bill.accountno,
                                style: TextStyle(color: secondaryColor),
                              ),
                              trailing: CupertinoCheckbox(
                                  shape: CircleBorder(),
                                  checkColor: Colors.black,
                                  value: bill.checked == 'true'? true : false,
                                  onChanged: (value){
                                    setState(() {
                                      if(bill.checked == "false"){
                                        if(bill.type=="Different"){
                                          dialogAddAccount(context, bill);
                                        } else {
                                          bill.checked = 'true';
                                        }
                                      } else {
                                        if(bill.type=="Different"){
                                          bill.accountno = '';
                                        }
                                        bill.checked = 'false';
                                      }
                                    });
                                  }
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: ()async{
                  final form = formKey.currentState!;
                  if(form.validate()){
                    _addUnit();
                  }
                },
                child: Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.activeBlue
                  ),
                  child: Center(
                      child: _adding
                      ? SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                      : Text("Add", style: TextStyle(color: Colors.black,fontSize: 15, fontWeight: FontWeight.w700),)
                  ),
                ),
              ),
            ),
            Row(),
          ],
        ),
      ),
    );
  }
  void dialogAddAccount(BuildContext context, BillingModel bill){
    TextEditingController _accno = TextEditingController();
    final _key = GlobalKey<FormState>();
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Container(
              width: 450,
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: 'A C C O U N T'),
                  RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Kindly provide the account details for Pay Bill ",
                                style: TextStyle(color: secondaryColor)
                            ),
                            TextSpan(
                                text: "${bill.businessno} ",
                                style: TextStyle(color: reverse)
                            ),
                            TextSpan(
                                text: "that you wish to associate specifically with this unit.",
                                style: TextStyle(color: secondaryColor)
                            ),
                          ]
                      )
                  ),
                  SizedBox(height: 5,),
                  TextFormField(
                    controller: _accno,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      label: Text("Account Number"),
                      fillColor: color1,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(5)
                        ),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                    ),
                    validator: (value){
                      if (value == null || value.isEmpty) {
                        return 'Please enter account number.';
                      }
                      if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                        return null; // Valid input (contains only digits)
                      } else {
                        return 'Please enter a valid account number';
                      }
                    },
                  ),
                  SizedBox(height: 5,),
                  DoubleCallAction(action: (){
                      final form = _key.currentState!;
                      if(form.validate()) {
                        setState(() {
                          _bills.firstWhere((test) => test.bid == bill.bid).checked = 'true';
                          _bills.firstWhere((test) => test.bid == bill.bid).accountno = _accno.text;
                        });
                        Navigator.pop(context);
                      }
                  })
                ],
              ),
            ),
          ),
        )
    );
  }
  void _clear(){
    _title.clear();
    _rent.clear();
    _deposit.clear();
  }
}
