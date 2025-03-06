import 'dart:convert';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/account.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/views/property/billing/bill_screen.dart';
import 'package:Zelli/views/property/billing/create_bill.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/billing.dart';
import '../../../models/gateway.dart';
import '../../../widgets/dialogs/dialog_title.dart';

class Billing extends StatefulWidget {
  final EntityModel entity;
  const Billing({super.key, required this.entity});

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];
  List<BillingModel> _bills = [];

  _getData(){
    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).toList()
        .where((test)=> test.eid == widget.entity.eid).toList();
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
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Billing"),
      ),
      body:  _bills.isNotEmpty
          ? Center(
            child: Container(
                    width: 700,
              margin: EdgeInsets.symmetric(horizontal:5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment methods", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _bills.length + 1,
                          itemBuilder: (context, index) {
                            // Check if this is the "Add payment method" item
                            if (index == _bills.length) {
                              return TextButton(
                                onPressed: () {
                                  dialogAddBilling(context);
                                },
                                child: Text("Add payment method"),
                              );
                            } else {
                              // Safely access the list item
                              BillingModel bill = _bills[index];
                              var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));

                              // Handle if `crd` is null
                              if (crd == null) {
                                return ListTile(
                                  title: Text("Unknown Bill"),
                                  subtitle: Text("No details available"),
                                );
                              }

                              List<AccountModel> accnts = bill.type == 'Different' && bill.accountno.isNotEmpty
                                  ?  bill.accountno.split('*').map((jsonString) {
                                    if (jsonString.isNotEmpty) {
                                      return AccountModel.fromJson(json.decode(jsonString));
                                    } else {
                                      // Handle empty jsonString (if needed)
                                      return AccountModel(bid: '', uid: '', accountno: '', account: '');
                                    }
                                  }).toList()
                                  : [];

                              print(accnts.map((e) => e.toJson()));

                              return ListTile(
                                onTap: () {
                                  Get.to(
                                        () => BillScreen(
                                      card: crd,
                                      bill: bill,
                                      reload: _getData,
                                      removeBill: _removeBill,
                                          entity: widget.entity,
                                    ),
                                    transition: Transition.rightToLeft,
                                  );
                                },
                                leading: Image.asset(
                                  crd.logo,
                                  width: 30,
                                  height: 30,
                                ),
                                title: Text(bill.businessno),
                                subtitle: bill.account.isNotEmpty && bill.type == 'Different'
                                    ? Wrap(
                                  runSpacing: 2,spacing: 5,
                                     children: bill.account.split(",").map((account){
                                       return Container(
                                         padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                         decoration: BoxDecoration(
                                           borderRadius: BorderRadius.circular(5),
                                           color: color1
                                         ),
                                         child: Text(account, style: TextStyle(color: secondaryColor),),
                                       );
                                     }).toList(),
                                    )
                                    : Text(
                                      bill.type == 'Different'
                                          ? "Different accounts for different units"
                                          : bill.accountno,
                                      style: TextStyle(color: secondaryColor),
                                    ),
                                trailing: bill.checked == "REMOVED"
                                    ? Icon(
                                        CupertinoIcons.delete,
                                        color: Colors.red,
                                      )
                                    : Icon(
                                        Icons.keyboard_arrow_right_outlined,
                                        color: secondaryColor,
                                      ),
                              );
                            }
                          },
                        )
                      ),
                    ],
                  ),
            ),
          )
          : Container(
            width: size.width,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: CupertinoColors.activeBlue.withOpacity(0.2)
                  ),
                  child: Icon(CupertinoIcons.creditcard, size: 40,color: CupertinoColors.activeBlue,),
                ),
                SizedBox(height: 10,),
                Text("Billing", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                Text(
                  'You have not yet set up a billing method. Please click here to begin selecting your preferred billing options.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor),
                ),
                SizedBox(height: 10,),
                InkWell(
                  onTap: (){
                    dialogAddBilling(context);
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    width: 150,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: CupertinoColors.activeBlue
                    ),
                    child: Center(child: Text("Get Started", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),)),
                  ),
                )
              ],
            ),
          ),
    );
  }
  void dialogAddBilling(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final size = MediaQuery.of(context).size;
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
          return Column(
            children: [
              DialogTitle(title: 'C H O O S E  B I L L I N G'),
              SizedBox(height: 20,),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                    itemCount: billCard.length,
                    itemBuilder: (context, index){
                      GateWayModel card = billCard[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5.0),
                        child: ListTile(
                          onTap: (){
                            Navigator.pop(context);
                            Get.to(() => CreateBill(card: card, entity: widget.entity, addBill: _addBill,), transition: Transition.rightToLeft);
                          },
                          tileColor: color1,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          leading: Image.asset(width: 30, height: 30, card.logo),
                          title: Text(card.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
                          trailing: Icon(Icons.keyboard_arrow_right_outlined),
                        ),
                      );
                    }
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: CupertinoColors.activeGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_shield_fill, color: CupertinoColors.activeGreen,size: 50,),
                    SizedBox(width: 10,),
                    Expanded(
                        child: Text('We adhere entirely to the data security standards of the payment card industry.')
                    ),
                    SizedBox(width: 10,),
                  ],
                ),
              ),
            ],
          );
        });
  }
  void _removeBill(BillingModel newBill){
    _bills.removeWhere((test) => test.bid == newBill.bid);
    print('Removing ${newBill.businessno}');
    setState(() {

    });
  }
  void _addBill(BillingModel newBill){
    _bills.add(newBill);
    setState(() {

    });
  }
}
