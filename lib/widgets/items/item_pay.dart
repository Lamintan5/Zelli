import 'dart:convert';
import 'dart:io';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../home/actions/chat/message_screen.dart';
import '../../home/actions/chat/web_chat.dart';
import '../../main.dart';
import '../../models/messages.dart';
import '../../utils/colors.dart';
import '../profile_images/current_profile.dart';
import '../profile_images/user_profile.dart';
import '../shimmer_widget.dart';

class ItemPay extends StatefulWidget {
  final PaymentsModel payments;
  final Function removePay;
  final String from;
  const ItemPay({super.key, required this.payments, required this.removePay, required this.from});

  @override
  State<ItemPay> createState() => _ItemPayState();
}

class _ItemPayState extends State<ItemPay> {
  List<EntityModel> _enty = [];
  List<UserModel> _user = [];
  List<UnitModel> _unit = [];

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  bool _isExpanded = false;

  UserModel user = UserModel(uid: "");
  UserModel payer = UserModel(uid: "");
  EntityModel entity = EntityModel(eid: "");
  UnitModel unit = UnitModel(id: "");

  _getDetails()async{
    _getData();
    _getData();
  }

  _getData(){
    _enty = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    entity = _enty.firstWhere((element) => element.eid == widget.payments.eid, orElse: ()=> EntityModel(eid: "", image: "", title: "N/A"));
    payer = widget.payments.payerid == currentUser.uid
        ? currentUser
        : _user.firstWhere((element) => element.uid == widget.payments.payerid, orElse: () => UserModel(uid: "", image: "", username: "N/A"));
    unit = _unit.firstWhere((element) => element.id == widget.payments.uid, orElse: ()=> UnitModel(id: "", title: "N/A"));
    user = widget.payments.tid.toString().split(",").first == currentUser.uid
        ? currentUser
        : _user.firstWhere((element) => element.uid == widget.payments.tid.toString().split(",").first,
        orElse: () => UserModel(uid: "", image: "", username: "N/A"));
    start = DateTime.parse(widget.payments.time.toString().split(",").first);
    end = DateTime.parse(widget.payments.time.toString().split(",").last);
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bold = TextStyle(fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: (){},
        hoverColor: color1,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
            color: color1,
            borderRadius: BorderRadius.circular(5)
          ),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(widget.payments.type.toString().split(",").last,
                    style: TextStyle(
                      color: secondaryColor,
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    hoverColor: color1,
                    borderRadius: BorderRadius.circular(5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 5),
                        Text("${DateFormat.Hms().format(DateTime.parse(widget.payments.current.toString()))}" , style: TextStyle(fontSize: 13)),
                        SizedBox(width: 10),
                        AnimatedRotation(
                          duration: Duration(milliseconds: 500),
                          turns: _isExpanded ? 0.5 : 0.0,
                          child: Icon(Icons.keyboard_arrow_down),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  widget.from =="Entity" || widget.from == "Home"
                      ? user.uid == ""
                      ? ShimmerWidget.circular(width: 40, height: 40)
                      : user.uid==currentUser.uid? CurrentImage(radius: 20,) :  UserProfile(image: user.image.toString(), radius: 20,)

                      : widget.from=="Unit"
                      ? payer.uid == ""
                      ? ShimmerWidget.circular(width: 40, height: 40)
                      : payer.uid==currentUser.uid? CurrentImage(radius: 20,) :  UserProfile(image: payer.image.toString(), radius: 20,)

                      : SizedBox(),
                  SizedBox(width: 15,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            user.uid == "" || entity.eid == ""
                                ? Container(margin: EdgeInsets.only(bottom: 5) ,child: ShimmerWidget.rectangular(width: 100, height: 10))
                                : widget.from == "Entity" || widget.from == "Home"
                                ? Text(user.username.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: reverse),)
                                : widget.from=="Unit"
                                ? Text(payer.username.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: reverse),)
                                : Text(entity.title.toString(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: reverse),),
                            Expanded(child: SizedBox()),
                            Text(
                              '${widget.payments.type!.split(",").first == "EXP"?'-':'+'}${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.payments.amount.toString()))}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: widget.payments.type!.split(",").first != "EXP"? CupertinoColors.activeBlue : Colors.orange
                              ),
                            ),
                          ],
                        ),
                        RichText(
                            maxLines: _isExpanded?100:1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                                style: TextStyle(fontSize: 12, color: reverse),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Confirm ',
                                  ),
                                  TextSpan(
                                      text: widget.payments.type!.split(",").last,
                                      style: bold
                                  ),
                                  TextSpan(
                                    text: '  payment of ',
                                  ),
                                  TextSpan(
                                      text: '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.payments.amount.toString()))}',
                                      style: bold
                                  ),
                                  TextSpan(
                                    text: ' made at ',
                                  ),
                                  TextSpan(
                                      text: DateFormat.Hm().format(DateTime.parse(widget.payments.current.toString())),
                                      style: bold
                                  ),
                                  TextSpan(
                                    text: '. Transaction carried out by ',
                                  ),
                                  TextSpan(
                                      text: payer.username,
                                      style: bold
                                  ),
                                  TextSpan(
                                    text: ' via ',
                                  ),
                                  TextSpan(
                                      text:  widget.payments.method!,
                                      style: bold
                                  ),
                                  TextSpan(
                                    text:widget.payments.time.toString().split(",").length >1? ' for the months ' : ' for the month of ',
                                  ),
                                  TextSpan(
                                      text: widget.payments.time.toString().split(",").length >1
                                          ?'${DateFormat.yMMM().format(start)} - ${DateFormat.yMMM().format(end)}'
                                          :DateFormat.yMMM().format(DateTime.parse(widget.payments.time.toString().split(",").first)),
                                      style: bold
                                  ),
                                ]
                            )
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15,),
                ],
              ),
              SizedBox(height: 10,),
              Row(
                children: [
                  Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          widget.from == "Unit"
                              ? SizedBox()
                              :
                          entity.eid =="" || user.uid ==""
                              ?  ShimmerWidget.rectangular(width: 70, height: 20, borderRadius: 5,)
                              :  Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text(widget.from == "Entity"
                                ? payer.username.toString()
                                : entity.title.toString(), style: TextStyle(fontSize: 11),),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LineIcon.box(size: 11,),
                                SizedBox(width: 5,),
                                Text(unit.title.toString(), style: TextStyle(fontSize: 11, ),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LineIcon.wallet(size: 11,),
                                SizedBox(width: 5,),
                                Text(widget.payments.method.toString(), style: TextStyle(fontSize: 11, ),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(CupertinoIcons.calendar, size: 11,),
                                SizedBox(width: 5,),
                                Text(widget.payments.time.toString().split(",").length >1
                                    ?"${getMonthsBetween(start, end)+1} Months"
                                    :DateFormat.yMMM().format(DateTime.parse(widget.payments.time.toString().split(",").first)), style: TextStyle(fontSize: 11, ),)
                              ],
                            ),
                          ),
                          double.parse(widget.payments.balance.toString()) == 0? SizedBox() :  Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.payments.balance.toString()))}", style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),),
                          ),


                        ],
                      )
                  ),
                  entity.eid =="" || user.uid ==""
                      ? SizedBox()
                      : PopupMenuButton(
                      icon: widget.payments.checked.toString() == "false"
                          ?Icon(Icons.cloud_upload, color: Colors.red, size: 20)
                          :widget.payments.checked.toString().contains("DELETE") || widget.payments.checked.toString().contains("REMOVED")
                          ?Icon(CupertinoIcons.delete, color: Colors.red, size: 20)
                          : widget.payments.checked.toString().contains("EDIT")
                          ? Icon(Icons.edit,color: Colors.red, size: 20)
                          : Icon(CupertinoIcons.ellipsis, size: 20,),
                      padding: EdgeInsets.all(0),
                      itemBuilder: (context){
                        return [
                          PopupMenuItem(
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.delete),
                                SizedBox(width: 10,),
                                Text("Delete")
                              ],
                            ),
                            onTap: (){

                            },
                          ),
                          if(user.uid != currentUser.uid)
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.ellipses_bubble),
                                  SizedBox(width: 10,),
                                  Text("Message")
                                ],
                              ),
                              onTap: (){
                                Platform.isIOS || Platform.isAndroid
                                    ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user,), transition: Transition.rightToLeft)
                                    : Get.to(() => WebChat(selected: user,), transition: Transition.rightToLeft);
                              },
                            ),
                          if(Platform.isAndroid || Platform.isIOS)
                            if(user.uid != currentUser.uid)
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.phone),
                                    SizedBox(width: 10,),
                                    Text("Call")
                                  ],
                                ),
                                onTap: (){

                                },
                              ),
                        ];
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel messModel){}

  int getMonthsBetween(DateTime startDate, DateTime endDate) {
    int yearDifference = endDate.year - startDate.year;
    int monthDifference = endDate.month - startDate.month;

    return yearDifference * 12 + monthDifference;
  }
}
