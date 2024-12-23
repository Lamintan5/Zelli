import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/actions/receipt.dart';
import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/users.dart';
import '../../widgets/items/item_pay.dart';
import '../../widgets/profile_images/current_profile.dart';
import '../../widgets/profile_images/user_profile.dart';
import '../../widgets/shimmer_widget.dart';
import '../actions/chat/message_screen.dart';
import '../actions/chat/web_chat.dart';

class Payments extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final String tid;
  final String lid;
  final String month;
  final String year;
  final String type;
  final String from;
  const Payments({super.key, required this.entity, required this.unit, required this.tid, required this.lid, this.month = "", this.year = "", this.type ="", required this.from});

  @override
  State<Payments> createState() => _PaymentsState();
}

class _PaymentsState extends State<Payments> {
  List<PaymentsModel> _pay = [];
  List<EntityModel> _enty = [];
  List<UserModel> _user = [];
  List<UnitModel> _unit = [];

  bool _isAdmin = false;

  _getData(){
    _enty = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((test){
      bool matchesEid = widget.entity.eid.isEmpty || test.eid == widget.entity.eid.toString();
      bool matchesUnit = widget.unit.id.toString().isEmpty || test.uid == widget.unit.id.toString();
      bool matchesTid = widget.tid.isEmpty || test.tid.toString().contains(widget.tid.toString());
      bool matchesLid = widget.lid.isEmpty || test.lid == widget.lid.toString();
      bool matchesType = widget.type.isEmpty || test.type == widget.type.toString();
      bool matchesPeriod = widget.month.isEmpty || DateTime.parse(test.time!).month == int.parse(widget.month) && DateTime.parse(test.time!).year == int.parse(widget.year);
      return matchesEid && matchesUnit && matchesTid && matchesLid && matchesPeriod && matchesType;
    }).toList();
    _pay.sort((a, b) => DateTime.parse(a.time.toString()).compareTo(DateTime.parse(b.time.toString())));
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
    final width = 500.0;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  widget.from.isEmpty
                      ? SizedBox()
                      : Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          hoverColor: color1,
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back),
                          ),
                        ),
                      ),
                  Text(
                    " Payments",
                    style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.bold
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: (){

                    },
                    hoverColor: color1,
                    borderRadius: BorderRadius.circular(5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.filter_list_rounded),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(width: width,
                  child: GroupedListView(
                    order: GroupedListOrder.DESC,
                    elements: _pay,
                    shrinkWrap: true,
                    groupBy: (_filterpay) => DateTime(
                      DateTime.parse(_filterpay.current.toString()).year,
                      DateTime.parse(_filterpay.current.toString()).month,
                      DateTime.parse(_filterpay.current.toString()).day,
                    ),
                    itemComparator: (item1, item2) => DateTime.parse(item1.time.toString()).compareTo(DateTime.parse(item2.time.toString())),
                    groupHeaderBuilder: (PaymentsModel payment) {
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final yesterday = today.subtract(Duration(days: 1));
                      final time = DateTime.parse(payment.current.toString());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                              decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                time.year == now.year && time.month == now.month && time.day == now.day
                                    ? 'Today'
                                    : time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day
                                    ? 'Yesterday'
                                    : DateFormat.yMMMd().format(time),
                                style: TextStyle(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    indexedItemBuilder : (BuildContext context, PaymentsModel payment, int index) {
                      EntityModel entity;
                      UserModel payer;
                      UnitModel unit;
                      var user;
                      entity = _enty.firstWhere((element) => element.eid == payment.eid,
                          orElse: ()=> widget.entity);
                      payer = payment.payerid == currentUser.uid
                          ? currentUser
                          : _user.firstWhere((element) => element.uid == payment.payerid, orElse: () => UserModel(uid: "", image: "", username: "N/A"));
                      unit = _unit.firstWhere((element) => element.id == payment.uid, orElse: ()=> widget.unit);
                      user = payment.tid.toString().split(",").first == currentUser.uid
                          ? currentUser
                          : _user.firstWhere((element) => element.uid == payment.tid.toString().split(",").first,
                          orElse: () => UserModel(uid: "", image: "", username: "N/A"));
                      _isAdmin = entity.admin.toString().contains(currentUser.uid);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Slidable(
                          startActionPane: payer.uid!=currentUser.uid? ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context){
                                  Platform.isIOS || Platform.isAndroid
                                      ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: payer,), transition: Transition.rightToLeft)
                                      : Get.to(() => WebChat(selected: payer,), transition: Transition.rightToLeft);
                                },
                                backgroundColor: color1,
                                borderRadius: BorderRadius.circular(25),
                                foregroundColor: reverse,
                                icon: CupertinoIcons.text_bubble,
                              ),
                              SizedBox(width: 5,),
                              SlidableAction(
                                onPressed: (context){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Feature currently unavailable"),
                                        showCloseIcon: true,
                                    )
                                  );
                                },
                                backgroundColor: color1,
                                borderRadius: BorderRadius.circular(25),
                                foregroundColor: reverse,
                                icon: CupertinoIcons.phone,
                              ),
                              SizedBox(width: 5,),
                            ],
                          ): null,
                          endActionPane:  ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SizedBox(width: _isAdmin? 5 : 0,),
                              _isAdmin? SlidableAction(
                                onPressed: null,
                                backgroundColor: CupertinoColors.systemRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                                foregroundColor: CupertinoColors.systemRed,
                                icon: CupertinoIcons.delete,
                              ) : SizedBox(),
                              SizedBox(width: 5,),
                              SlidableAction(
                                onPressed: (context){
                                  Get.to(() => Receipt(payment: payment), transition: Transition.rightToLeft);
                                },
                                backgroundColor: color1,
                                borderRadius: BorderRadius.circular(25),
                                foregroundColor: reverse,
                                icon: CupertinoIcons.doc_plaintext,
                              ),
                            ],
                          ),
                          child: InkWell(
                                  onTap: (){
                                    Get.to(() => Receipt(payment: payment), transition: Transition.rightToLeft);
                                  },
                                  borderRadius: BorderRadius.circular(25),
                                  splashColor: CupertinoColors.activeBlue,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(25)
                                    ),
                                    child: Row(
                                      children: [
                                        payer.uid == ""
                                            ? ShimmerWidget.circular(width: 40, height: 40)
                                            : payer.uid==currentUser.uid? CurrentImage(radius: 20,)
                                            :  UserProfile(image: payer.image.toString(), radius: 20,),
                                        SizedBox(width: 15,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(payer.username.toString(), style: TextStyle(fontSize: 16)),
                                              Text(
                                                  '${TFormat().toCamelCase(payment.type.toString().split(',').last)} ● ${unit.title}',
                                                  style: TextStyle(color: secondaryColor)
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${payment.type!.split(",").first == "EXP"?'-':'+'}${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(payment.amount.toString()))}',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: payment.type!.split(",").first != "EXP"? CupertinoColors.activeGreen : CupertinoColors.activeOrange
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel messModel){}

  void removePay(String payid){
    print("Removing Payment");
    _pay.removeWhere((element) => element.payid == payid);
    setState(() {

    });
  }
}
