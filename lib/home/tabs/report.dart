import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../models/payments.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../../widgets/graph/barchart.dart';
import '../../widgets/graph/linewidget.dart';
import '../../widgets/graph/small_line_graph.dart';
import '../../widgets/profile_images/user_profile.dart';
import '../../widgets/text/text_format.dart';

class Report extends StatefulWidget {
  final EntityModel entity;
  final String unitid;
  final String tid;
  final String lid;
  const Report({super.key, required this.entity, required this.unitid, required this.tid, required this.lid});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  final ScrollController _horizontal = ScrollController();
  List<String> title = ['REVENUE','EXPENSES', 'P/L'];
  List<PaymentsModel> _pay = [];
  List<PaymentsModel> _rent = [];
  List<PaymentsModel> _revenue = [];
  List<PaymentsModel> _expense = [];
  List<UserModel> _users = [];
  List<EntityModel> _entity = [];


  UserModel tenant = UserModel(uid: "",username: "N/A", image: "");
  EntityModel entity = EntityModel(eid: "",title: "N/A", image: "");

  double tRevenue = 0.0;
  double tExpense = 0.0;
  double profit = 0.0;

  double tRent = 0.0;
  double tDeposit = 0.0;
  double tUtils = 0.0;
  double tChrges = 0.0;

  _getData(){
    _entity = myEntity.map((e) => EntityModel.fromJson(json.decode(e))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _pay =  myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((test){
      bool matchesEid = widget.entity.eid.isEmpty || test.eid==widget.entity.eid;
      bool matchesUnit = widget.unitid.isEmpty || test.uid == widget.unitid;
      bool matchesTid = widget.tid.isEmpty || test.tid.toString().split(",") == widget.tid.toString();
      bool matchesLid = widget.lid.isEmpty || test.lid == widget.lid.toString();
      return matchesEid && matchesUnit  && matchesLid;
    }).toList();
    _rent = _pay.where((element) => element.type == "RENT").toList();
    _revenue = _pay.where((pay) => pay.type!.split(",").first != "EXP").toList();
    _expense = _pay.where((pay) => pay.type!.split(",").first == "EXP").toList();
    tRevenue = _revenue.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    tExpense = _expense.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    profit = tRevenue - tExpense;

    tRent = _rent.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    tDeposit = _pay.where((pay) => pay.type == "DEPOSIT").toList().fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    tUtils = _pay.where((pay) => pay.type!.split(",").first == "UTILITY").toList().fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
    tChrges = _pay.where((pay) => pay.type!.split(",").first == "TNTCHRG").toList().fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
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
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.entity.eid.isEmpty? SizedBox() :  AppBar(),
                Text(' Reports & Analytics', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                SizedBox(height: 10,),
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1
                    ),
                    itemCount: title.length,
                    itemBuilder: (context, index){
                      return Container(
                        margin: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: color1,
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          index == 2
                                              ?profit==0
                                              ?"P/L"
                                              :profit>0
                                              ?"Profit"
                                              :"Loss"
                                              :title[index],
                                          style: TextStyle(color: reverse),
                                        ),
                                        Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(
                                            index==0
                                                ?tRevenue
                                                :index==1
                                                ?tExpense
                                                :profit
                                        )}",
                                          style:TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: index == 2
                                                  ?profit==0
                                                  ?secondaryColor
                                                  :profit>0
                                                  ?CupertinoColors.activeBlue
                                                  :Colors.red
                                                  : CupertinoColors.activeBlue,
                                              fontSize: 18
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  index == 0
                                      ? SmallLineGraph(title: 'REVENUE', pay: _pay,)
                                      : index==1
                                      ? SmallLineGraph(title: 'EXPENSE', pay: _pay, )
                                      : SizedBox(),
                                ],
                              ),
                              SizedBox(height: 10,),
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: color2,
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    color:Colors.green,
                                    size: 15,
                                  ),
                                  Text('100%',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:Colors.green,
                                        fontSize: 11),
                                  ),
                                  SizedBox(width: 2,),
                                  Text("Last month", style: TextStyle(fontSize: 11)),

                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                SizedBox(height: 20,),
                Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  children: [
                    Container(
                      width: 500,
                      decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          LineWidget(icon:Icon(Icons.home, color: color5), title:"Rent", amount: tRent,  ),
                          LineWidget(icon:Icon(Icons.lock_outlined, color: color5), title:"Deposit", amount: tDeposit),
                          LineWidget(icon:Icon(Icons.list, color: color5), title:"Utilities", amount: tUtils),
                          LineWidget(icon:Icon(Icons.account_balance_wallet_outlined, color: color5), title:"Charges", amount: tChrges),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: color1,
                                  child: Icon(Icons.shopping_basket_outlined, color: color5,),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Expenses"),
                                                SizedBox(height: 5,),
                                              ],
                                            ),
                                          ),
                                          Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(tExpense)}")
                                        ],
                                      ),
                                      LinearPercentIndicator(
                                        animation: true,
                                        animateFromLastPercent: true,
                                        animationDuration: 800,
                                        padding: EdgeInsets.zero,
                                        lineHeight: 5,
                                        percent: tExpense==0.0? 0.0:  tExpense/adjustHighestNumber(tExpense),
                                        progressColor: Colors.deepOrange,
                                        backgroundColor: Colors.blue.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                        height: 250,width: 500,
                        child: MyBarChart(
                          activeColor: CupertinoColors.activeBlue,
                          inactiveColor: color1,
                          textColor: reverse,
                          pay: _pay,
                        )
                    ),
                  ],
                ),
                SizedBox(height: 40,),
                Scrollbar(
                  thumbVisibility: true,
                  controller: _horizontal,
                  child: SingleChildScrollView (
                    controller: _horizontal,
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowHeight: 40,
                      columns: [
                        DataColumn(
                          label: Text("", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Tenant", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Entity", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Account", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Method", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Paid", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Balance", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Amount", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Period", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Date", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                        DataColumn(
                          label: Text("Status", style: TextStyle(color: Colors.white),),
                          numeric: false,
                        ),
                      ],
                      rows: _pay.reversed.map((pay){
                        final style = TextStyle(color: secondaryColor);
                        String limitString(String input, int maxLength) {
                          if (input.length <= maxLength) {
                            return input;
                          } else {
                            return input.substring(0, maxLength)+ '...';
                          }
                        }
                        tenant = _users.isEmpty? UserModel(uid: "", username: "N/A", image: ""): _users.firstWhere((usr) => usr.uid == pay.tid.toString().split(",").first, orElse: ()=> UserModel(uid: "", username: "N/A"));
                        entity = _entity.isEmpty? EntityModel(eid: "",title: "N/A", image: ""): _entity.firstWhere((ent) => ent.eid == pay.eid, orElse: ()=>EntityModel(eid: "", title: "N/A"));
                        return DataRow(
                            cells: [
                              DataCell(
                                  UserProfile(image: tenant.image.toString(),radius: 15,),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Tooltip(
                                    message: tenant.username.toString(),
                                    child: Text(
                                        limitString(tenant.username.toString().toUpperCase(), 10),
                                        style: style),
                                  ),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Tooltip(
                                    message: entity.title.toString(),
                                    child: Text(
                                        limitString(entity.title.toString().toUpperCase(), 10),
                                        style: style),
                                  ),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Tooltip(
                                    message: pay.type!.split(",").last.toUpperCase(),
                                    child: Text(
                                        limitString(pay.type!.split(",").last.toUpperCase(), 10),
                                        style: style),
                                  ),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Text(pay.method.toString(),style:style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(pay.amount!))}',style: style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),

                              DataCell(
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(pay.balance!))}',style: style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(pay.balance!) + double.parse(pay.amount!))}',style: style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Text(DateFormat.yMMMd().format(DateTime.parse(pay.time!.split(",").first)),style: style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Center(child: Text(DateFormat.yMMMd().format(DateTime.parse(pay.current!)), style:style)),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                              DataCell(
                                  Text(double.parse(pay.balance!) == 0.0? "Completed": "Incomplete" , style:style),
                                  onTap: (){
                                    // _setValues(inventory);
                                    // _selectedInv = inventory;
                                  }
                              ),
                            ]
                        );
                      }
                      ).toList(),
                    ),
                  ),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
  double adjustHighestNumber(double number) {
    if (number >= 1 && number < 10) {
      return 10;
    } else if (number >= 10 && number < 100) {
      return 100;
    } else if (number >= 100 && number < 1000) {
      return 1000;
    } else if (number >= 1000 && number < 10000) {
      return 10000;
    } else if (number >= 10000 && number < 100000) {
      return 100000;
    } else if (number >= 100000 && number < 1000000) {
      return 1000000;
    } else if (number >= 1000000 && number < 10000000) {
      return 10000000;
    }
    return number;
  }
}
