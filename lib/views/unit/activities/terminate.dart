import 'dart:convert';

import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/resources/socket.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/notifications.dart';
import '../../../models/units.dart';
import '../../../resources/services.dart';
import '../../../widgets/text/text_format.dart';

class Terminate extends StatefulWidget {
  final UserModel tenant;
  final UnitModel unit;
  final LeaseModel lease;
  final EntityModel entity;
  final double accrued;
  final double prepaid;
  final double depositPaid;
  final Function reload;

  const Terminate({super.key, required this.tenant, required this.unit, required this.lease, required this.entity, required this.accrued, required this.prepaid, required this.depositPaid, required this.reload});

  @override
  State<Terminate> createState() => _TerminateState();
}

class _TerminateState extends State<Terminate> {
  final _key = GlobalKey<FormState>();
  late TextEditingController _deduct;
  late TextEditingController _refund;
  late UnitModel unit;
  late LeaseModel lease;
  late UserModel tenant;
  late EntityModel entity;

  late DateTime startTime;
  late DateTime endTime;



  List<PaymentsModel> _pay = [];
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];

  List<String> _tokens = [];
  List<String> _admins = [];
  List<int> _exp = [];

  DateTime _dateTime = DateTime.now();

  String nid = "";
  String message = "";

  int totalMonths = 0;

  double paidAmount = 0;
  double accrued = 0;
  double prepaid = 0;
  double depositPaid = 0;
  double remainDeposit = 0;
  double balance = 0;
  double deduct = 0;
  double refund = 0;

  bool _edit = false;
  bool _editBalance = false;
  bool _loading = false;

  _getData(){
    unit = widget.unit;
    lease = widget.lease;
    tenant = widget.tenant;
    entity = widget.entity;
    prepaid = widget.prepaid;
    accrued = prepaid == 0 ? widget.accrued : 0;
    depositPaid = widget.depositPaid;
    _getBalance();

    _admins = entity.admin.toString().split(',');

    startTime = DateTime.parse(lease.start.toString());
    endTime =  DateTime.now();

    int yearDiff = endTime.year - startTime.year;
    int monthDiff = endTime.month - startTime.month;

    totalMonths = (yearDiff * 12) + monthDiff;

    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    _pay = _pay.where((test) => test.lid == unit.lid).toList();
    paidAmount = _pay.where((test) => test.type == "RENT").fold(0, (previous, element) => previous + double.parse(element.amount.toString()));
  }

  _getBalance(){
    remainDeposit = depositPaid - deduct;
    balance = remainDeposit + prepaid - accrued - refund;
  }

  _getDetails(){
    setState(() {
      _loading = true;
    });
    widget.unit.pid.toString().split(",").forEach((pid)async{
      _newUsers = await Services().getCrntUsr(pid);
      UserModel user = _newUsers.first;
      if(!_users.any((test) => test.uid==pid)){
        _users.add(user);
        await Data().addUser(user);
        _tokens.addAll(user.token.toString().split(","));
        _tokens.remove("");
        setState(() {
          _loading = false;
        });
      }
    });
  }

  _terminate()async{
    List<UnitModel> _unit = [];
    List<LeaseModel> _lease = [];
    List<String> uniqueUnit = [];
    List<String> uniqueLease = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();

    setState(() {
      _loading = true;
    });
    await Services.updateUnitTid(widget.unit.id.toString(), "", "").then((response)async{
      print("Response $response");
      if(response=="success"){
        await Services.terminateLease(widget.lease.lid, deduct.toString(), refund.toString(), balance.toString()).then((value){
          print("Value $value");
          if(value=="success"){

            _unit.firstWhere((test)=>test.id==widget.unit.id).tid="";
            _unit.firstWhere((test)=>test.id==widget.unit.id).lid="";
            _lease.firstWhere((test)=>test.lid==widget.lease.lid).end=DateTime.now().toString();

            uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
            uniqueLease = _lease.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myunit', uniqueUnit);
            sharedPreferences.setStringList('mylease', uniqueLease);
            myUnits = uniqueUnit;
            myLease = uniqueLease;
            widget.reload();
            setState(() {
              _loading = false;
            });
            Navigator.pop(context);
          }
        });
      } else {
        Navigator.pop(context);
      }
    });
  }
  _send()async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _loading = true;
      message = "${currentUser.username} has submitted a lease termination notice for unit ${widget.unit.title}, with a planned vacate date of ${DateFormat.yMMMEd().format(_dateTime)}.";
    });
    NotifModel notification = NotifModel(
      nid: nid,
      sid: currentUser.uid,
      rid: widget.unit.pid.toString().split(",").first,
      eid: widget.unit.eid!,
      pid: widget.unit.pid.toString(),
      text: "${widget.unit.id.toString()},${_dateTime},${widget.unit.title.toString()}",
      message: message,
      actions: "",
      type: "TRMLEASE",
      seen: "",
      deleted: "",
      checked: "true",
      time: "",
    );
    Services.addNotification(notification, null).then((response) {
      if(response=="Success"){
        _socketSend();
        Navigator.pop(context);
        Get.snackbar(
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.check, color: Colors.green,)
        );
      } else if(response=='Exists') {
        Get.snackbar(
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.watch_later, color: Colors.blue,)
        );
        Navigator.pop(context);
      } else if(response=='Failed') {
        Get.snackbar(
            'Failed',
            'Request was not sent please try again',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.close, color: Colors.red,)
        );
      } else {
        Get.snackbar(
            'Error',
            Data().failed,
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.error, color: Colors.red,)
        );
      }
    });
    setState(() {_loading = false;});
  }
  void _socketSend() async{
    List<String> _pidList = widget.entity.pid!.split(",");
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":widget.unit.pid.toString().split(",").first,
      "eid":widget.entity.eid,
      "pid":_pidList,
      "message":message,
      "time":DateTime.now().toString(),
      "type":"TRMLEASE",
      "actions":"",
      "text":"${widget.unit.id.toString()},${_dateTime},${widget.unit.title.toString()}",
      "title": widget.entity.title,
      "token": _tokens,
      "profile": "${Services.HOST}logos/LEGO_logo.svg.png",
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
    _getDetails();
    _deduct = TextEditingController();
    _refund = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _deduct.dispose();
    _refund.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    final style = TextStyle(fontWeight: FontWeight.w600, color: reverse);
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: _key,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: 500,
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.red.withOpacity(0.2)
                        ),
                        child: Icon(CupertinoIcons.clear_circled, size: 40,color: Colors.red,),
                      ),
                      SizedBox(height: 10,),
                      Text(
                        "Terminate Lease", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      widget.tenant.uid == currentUser.uid
                          ?  balance < 0
                          ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "You have an outstanding balance of ",
                                  style: TextStyle(color: secondaryColor),
                                ),
                                TextSpan(
                                    text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance).replaceAll("-", "")} ",
                                    style: TextStyle(fontWeight: FontWeight.w800, color: CupertinoColors.systemRed)
                                ),
                                TextSpan(
                                  text: "owed to  ",
                                  style: TextStyle(color: secondaryColor, ),
                                ),
                                TextSpan(
                                    text: "${widget.entity.title} ",
                                    style: style
                                ),
                                TextSpan(
                                    text:  "for Unit ",
                                    style: TextStyle(color: secondaryColor, )
                                ),
                                TextSpan(
                                    text: "${widget.unit.title}. ",
                                    style: style
                                ),
                                TextSpan(
                                  text: "Kindly ensure that the full amount is settled promptly.",
                                    style: TextStyle(color: secondaryColor, )
                                )
                              ]
                          )
                      )
                          : balance > 0
                          ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "${widget.entity.title} ",
                                    style: style
                                ),
                                TextSpan(
                                  text: "has an outstanding balance of ",
                                  style: TextStyle(color: secondaryColor, ),
                                ),
                                TextSpan(
                                    text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)} ",
                                    style: TextStyle(fontWeight: FontWeight.w800, color: CupertinoColors.systemGreen)
                                ),
                                TextSpan(
                                    text:  "for Unit ",
                                    style: TextStyle(color: secondaryColor, )
                                ),
                                TextSpan(
                                    text: '${widget.unit.title}. ',
                                    style: style
                                ),
                                TextSpan(
                                  text: "Kindly ensure the full amount is reimbursed.",
                                    style: TextStyle(color: secondaryColor, )

                                )
                              ]
                          )
                      )
                          : SizedBox()

                          :  balance < 0
                          ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${TFormat().toCamelCase(widget.tenant.username.toString())} ",
                                  style: style
                                ),
                                TextSpan(
                                  text: "has an outstanding balance of ",
                                  style: TextStyle(color: secondaryColor),
                                ),
                                TextSpan(
                                  text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance).replaceAll("-", "")} ",
                                  style: TextStyle(fontWeight: FontWeight.w800, color: CupertinoColors.systemGreen)
                                ),
                                TextSpan(
                                  text: "owed to  ",
                                  style: TextStyle(color: secondaryColor, ),
                                ),
                                TextSpan(
                                  text: "${widget.entity.title} ",
                                  style: style
                                ),
                                TextSpan(
                                  text:  "for Unit ",
                                  style: TextStyle(color: secondaryColor, )
                                ),
                                TextSpan(
                                  text: widget.unit.title,
                                  style: style
                                ),
                              ]
                          )
                      )
                          : balance > 0
                          ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "${widget.entity.title} ",
                                    style: style
                                ),
                                TextSpan(
                                  text: "owes ",
                                  style: TextStyle(color: secondaryColor, ),
                                ),
                                TextSpan(
                                    text: "${widget.tenant.username} ",
                                    style: style
                                ),
                                TextSpan(
                                  text: "a total of ",
                                  style: TextStyle(color: secondaryColor),
                                ),
                                TextSpan(
                                    text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)} ",
                                    style: TextStyle(fontWeight: FontWeight.w800, color: CupertinoColors.systemBlue)
                                ),
                                TextSpan(
                                    text:  "for Unit ",
                                    style: TextStyle(color: secondaryColor, )
                                ),
                                TextSpan(
                                    text: widget.unit.title,
                                    style: style
                                ),

                              ]
                          )
                      )
                          : SizedBox(),
                      SizedBox(height: 20,),
                      // Basic Info
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
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if(_exp.contains(1)){
                                       _exp.remove(1);
                                    } else {
                                      _exp.add(1);
                                    }
                                  });
                                },
                                hoverColor: color1,
                                borderRadius: BorderRadius.circular(5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Basic Information", style: heading,),
                                    Expanded(child: SizedBox()),
                                    AnimatedRotation(
                                      duration: Duration(milliseconds: 500),
                                      turns:  _exp.contains(1)? 0.5 : 0.0,
                                      child: Icon(Icons.keyboard_arrow_down),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 500),
                                alignment: Alignment.topCenter,
                                curve: Curves.easeInOut,
                                child: _exp.contains(1)?  Column(
                                  children: [
                                    horizontalItems("Lease ID", lease.lid.split("-").first.toUpperCase()),
                                    horizontalItems("Property", entity.title.toString().split("-").first),
                                    horizontalItems("Unit Number", unit.title.toString()),
                                  ],
                                ) : SizedBox(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Lease Details
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
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if(_exp.contains(2)){
                                      _exp.remove(2);
                                    } else {
                                      _exp.add(2);
                                    }
                                  });
                                },
                                hoverColor: color1,
                                borderRadius: BorderRadius.circular(5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text("Lease Details", style: heading,),
                                    Expanded(child: SizedBox()),
                                    AnimatedRotation(
                                      duration: Duration(milliseconds: 500),
                                      turns:  _exp.contains(2)? 0.5 : 0.0,
                                      child: Icon(Icons.keyboard_arrow_down),
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 500),
                                alignment: Alignment.topCenter,
                                curve: Curves.easeInOut,
                                child: _exp.contains(2)?  Column(
                                  children: [
                                    horizontalItems("Tenant", tenant.username.toString()),
                                    horizontalItems("No of Co-Tenants", lease.ctid.toString().split(",").length.toString()),
                                    horizontalItems("Start Date", '${DateFormat('HH:mm').format(DateTime.parse(lease.start!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.start!))}'),
                                    horizontalItems("End Date", '${DateFormat('HH:mm').format(DateTime.now())}, ${DateFormat.yMMMEd().format(DateTime.now())}'),
                                    horizontalItems("Duration", '${totalMonths} months'),
                                  ],
                                ) : SizedBox(),
                              ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Deposit Summary
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
                              Row(
                                children: [
                                  Text("Deposit Summary", style: heading,),
                                  Expanded(child: SizedBox()),
                                  _admins.contains(currentUser.uid)
                                      ? InkWell(
                                      onTap: (){
                                        setState(() {
                                          _edit = !_edit;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_edit? Icons.close : Icons.edit, size: 15,color: _edit? Colors.red : CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text(
                                              _edit? "Cancel" : "Edit",
                                              style: TextStyle(color: _edit? Colors.red : CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                                      : SizedBox(),
                                  _admins.contains(currentUser.uid) && _edit
                                      ? InkWell(
                                      onTap: (){
                                        setState(() {
                                          final form = _key.currentState!;
                                          if(form.validate()){
                                            deduct = double.parse(_deduct.text);
                                            _getBalance();
                                            _edit = !_edit;
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(CupertinoIcons.floppy_disk, size: 15,color: CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text(
                                              "Save",
                                              style: TextStyle(color: CupertinoColors.systemBlue,
                                                  fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                                      : SizedBox()
                                ],
                              ),
                              horizontalItems("Total Deposit Paid", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(depositPaid)}'),
                              _edit
                                  ? TextFormField(
                                      controller: _deduct,
                                      maxLines: 1,
                                      minLines: 1,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text("Deductions from Deposit"),
                                        fillColor: color1,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                    )
                                  : horizontalItems("Total Deductions from Deposit", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(deduct)}'),
                              horizontalItems("Remaining Deposit After Deductions", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(remainDeposit)}'),
                              // horizontalItems("Renewal Option", "true"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Rent and Accruals
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Rent and Accruals", style: heading,),
                                ],
                              ),
                              horizontalItems("Monthly Rent Amount", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(lease.rent.toString()))}'),
                              horizontalItems("Total Rent Paid", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paidAmount)}'),
                              horizontalItems("Amount Accrued", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(accrued)}'),
                              horizontalItems("Prepaid Rent Amount", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(prepaid)}'),
                              // horizontalItems("Renewal Option", "true"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Balance Summary
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Balance Summary", style: heading,),
                                  Expanded(child: SizedBox()),
                                  _admins.contains(currentUser.uid) && balance > 0
                                      ? InkWell(
                                      onTap: (){
                                        setState(() {
                                          _editBalance = !_editBalance;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_editBalance? Icons.close : Icons.edit, size: 15,color: _editBalance? Colors.red : CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text(
                                              _editBalance? "Cancel" : "Edit",
                                              style: TextStyle(color: _editBalance? Colors.red : CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                                      : SizedBox(),
                                  _admins.contains(currentUser.uid) && _editBalance
                                      ? InkWell(
                                      onTap: (){
                                        setState(() {
                                          final form = _key.currentState!;
                                          if(form.validate()){
                                            refund = double.parse(_refund.text);
                                            _getBalance();
                                            _editBalance = !_editBalance;
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(CupertinoIcons.floppy_disk, size: 15,color: CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text(
                                              "Save",
                                              style: TextStyle(color: CupertinoColors.systemBlue,
                                                  fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                                      : SizedBox()
                                ],
                              ),
                              balance < 0
                                  ? SizedBox()
                                  : _editBalance
                                  ? TextFormField(
                                      controller: _refund,
                                      maxLines: 1,
                                      minLines: 1,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text("Refunding Amount"),
                                        fillColor: color1,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                    )
                                  : horizontalItems("Refunding Amount", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(refund)}'),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Outstanding Balance', style: TextStyle(fontSize: 15, color: secondaryColor),),
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}',
                                    style: TextStyle(
                                        color: widget.tenant.uid == currentUser.uid
                                            ? balance<0
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGreen
                                            : balance<0
                                            ? CupertinoColors.systemGreen
                                            : CupertinoColors.systemBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            widget.tenant.uid == currentUser.uid && balance < 0
                ? SizedBox()
                : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: (){
                      if(_loading){
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please wait"),
                              showCloseIcon: true,
                          )
                        );
                      } else {
                        if(widget.tenant.uid == currentUser.uid){
                          _send();
                        } else {
                          _terminate();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 450,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: CupertinoColors.systemRed
                      ),
                      child: Center(child: _loading
                          ?SizedBox(width: 15,height: 15,
                            child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                          )
                          :Text("Terminate", style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),)),
                    ),
                  ),
                ),
            SizedBox(height: 10)
          ],
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
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor)),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
