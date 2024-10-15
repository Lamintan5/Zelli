import 'dart:convert';
import 'dart:io';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/widgets/logo/prop_logo.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../../main.dart';
import '../../../../models/entities.dart';
import '../../../../models/notifications.dart';
import '../../../../models/units.dart';
import '../../../../models/users.dart';
import '../../../../resources/services.dart';
import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../models/messages.dart';
import '../../../utils/colors.dart';
import '../../shimmer_widget.dart';

class ItemTntRq extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  final String from;
  const ItemTntRq({super.key, required this.notif, required this.getEntity, required this.from, required this.remove});

  @override
  State<ItemTntRq> createState() => _ItemTntRqState();
}

class _ItemTntRqState extends State<ItemTntRq> {
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  List<UserModel> _receiver = [];
  List<EntityModel> _entity = [];
  UserModel sender = UserModel(uid: "", username: "", image: "");
  UserModel receiver = UserModel(uid: "", username: "", image: "");
  UnitModel unit = UnitModel(id: "", title: "");
  EntityModel entityModel = EntityModel(eid: "", title: "", image: "");
  List<UnitModel> _unit = [];
  List<String> newEnty = [];

  bool _loading = false;

  bool _isExpanded = false;
  NotifModel notifModel = NotifModel(nid: "");

  _getDetails()async{
    _getData();
    _getData();
  }

  _getData(){
    notifModel = widget.notif;
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode  (jsonString))).toList();
    unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).firstWhere((element) =>
    element.id == notifModel.text.toString().split(",").first, orElse: ()=>UnitModel(id: "", title: "", tid: ""));
    entityModel = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((element) =>
    element.eid == notifModel.eid, orElse: ()=>EntityModel(eid:"", title: ""));

    newEnty = _entity.map((entityModel) => jsonEncode(entityModel.toJson())).toList();
    sender = _user.firstWhere((element) => element.uid == notifModel.sid, orElse: ()=>UserModel(uid: "", username: "", image: ""));
    receiver = _user.firstWhere((element) =>  notifModel.rid!.contains(element.uid), orElse: ()=>UserModel(uid: "", username: "", image: ""));
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
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final bold = TextStyle(fontWeight: FontWeight.w700,fontSize: 13,color: notifModel.actions==""?reverse:secondaryColor);
    final style = TextStyle(fontSize: 13,color: notifModel.actions==""?reverse:secondaryColor);
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 8, right: 8, top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.xmark_circle, size: 12,color: secondaryColor,),
                    SizedBox(width: 5,),
                    Text("REQUEST", style: TextStyle(color: secondaryColor),),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 5),
                          Text(timeago.format(DateTime.parse(notifModel.time.toString())), style: TextStyle(fontSize: 13)),
                          SizedBox(width: 5),
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
                Row(
                  children: [
                    sender.uid == currentUser.uid
                        ? PropLogo(entity: entityModel)
                        : UserProfile(image: sender.image!),
                    SizedBox(width: 15,),
                    Expanded(
                        child: sender.uid == ""
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.rectangular(width: 100, height: 10),
                            SizedBox(height: 5,),
                            ShimmerWidget.rectangular(width: double.infinity, height: 10),
                            SizedBox(height: 5,),
                            ShimmerWidget.rectangular(width: double.infinity, height: 10),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sender.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:  notifModel.actions==""?reverse:secondaryColor),),
                            notifModel.actions == ""
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: sender.uid == currentUser.uid
                                            ? "" : sender.username!,
                                        style: bold
                                    ),
                                    TextSpan(
                                        text:sender.uid == currentUser.uid
                                            ? 'You have sent a request to commence leasing a unit : '
                                            : ' has sent a request to start leasing unit ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: unit.title.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' as a tenant at ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: entityModel.title.toString(),
                                        style: bold
                                    ),
                                  ]
                              ),
                            )
                                : notifModel.actions == "ACCEPTED"
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: sender.username.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "\'s commercial lease agreement for unit " ,style: style
                                    ),
                                    TextSpan(
                                        text: unit.title.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " at " ,style: style
                                    ),
                                    TextSpan(
                                        text: entityModel.title.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' commenced on ${DateFormat.yMMMd().format(DateTime.parse(notifModel.time.toString()))}',style: style
                                    ),

                                  ]
                              ),
                            )
                                : notifModel.actions == "REJECTED"
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: sender.username.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: ' request to initiate leasing for ',style: style
                                    ),
                                    TextSpan(
                                        text: entityModel.title.toString(),
                                        style:bold
                                    ),
                                    TextSpan(
                                        text: ' was declined',style: style
                                    ),
                                  ]
                              ),
                            )
                                : SizedBox(),
                          ],
                        )
                    ),

                  ],
                ),
                unit.id == "" || unit.tid != "" || notifModel.actions != "" || sender.uid == currentUser.uid
                    ?  SizedBox()
                    :  AnimatedSize(
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        entityModel.eid == ""
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5,))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){_action("ACCEPTED");},
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 1)
                              ),
                              child: Center(child: Text("Accept")),
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        entityModel.eid == ""
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){_action("REJECTED");},
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 1)
                              ),
                              child: Center(child: Text("Reject")),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      : SizedBox(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: [
                          entityModel.eid ==""
                              ? ShimmerWidget.rectangular(width: 100, height: 10, borderRadius: 5,)
                              : Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: color1, width: 0.5)
                            ),
                            child: Text(entityModel.title.toString(), style: TextStyle(fontSize: 11),),
                          ),
                          unit.id ==""
                              ? ShimmerWidget.rectangular(width: 100, height: 10, borderRadius: 5,)
                              : Container(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 0.5)
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LineIcon.box(color: secondaryColor,size: 12,),
                                  SizedBox(width: 5,),
                                  Text(unit.title.toString(), style: TextStyle(fontSize: 11),),
                                ],
                              )
                          ),
                          entityModel.pid.toString().contains(currentUser.uid) && notifModel.actions=="" && unit.tid == ""
                              ? Container(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 0.5)
                              ),
                              child: Text("Action Required", style: TextStyle(fontSize: 11, color: Colors.green))
                          )
                              :SizedBox(),
                        ],
                      ),
                    ),
                    PopupMenuButton(
                        icon: Icon(Icons.more_horiz),
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
                              onTap: ()async{
                                await Data().deleteNotif(context, notifModel, widget.remove);
                              },
                            ),
                            if(sender.uid!=currentUser.uid)
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
                                      ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: sender,), transition: Transition.rightToLeft)
                                      : Get.to(() => WebChat(selected: sender,), transition: Transition.rightToLeft);
                                },
                              ),

                            if(sender.uid!=currentUser.uid&&sender.phone.toString()!=""&&Platform.isAndroid||Platform.isIOS)
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.phone),
                                    SizedBox(width: 10,),
                                    Text("Call")
                                  ],
                                ),
                                onTap: (){
                                  if(sender.phone==""||sender.phone==null){
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(Data().noPhone),
                                          width: 500,
                                          showCloseIcon: true,
                                        )
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Feature not available."),
                                          showCloseIcon: true,
                                        )
                                    );
                                  }
                                },
                              ),

                            if(notifModel.pid.toString().contains(currentUser.uid)  && notifModel.actions=="REJECTED")
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.restart),
                                    SizedBox(width: 10,),
                                    Text("Undo")
                                  ],
                                ),
                                onTap: _undo,
                              ),
                          ];
                        })
                  ],
                ),

              ],
            ),
          ),
          _loading ? LinearProgressIndicator(backgroundColor: color1,minHeight: 1,) : SizedBox()
        ],
      ),
    );
  }

  void _action(String actions)async{
    String lid = "";
    Uuid uuid = Uuid();
    setState(() {
      _loading = true;
      lid = uuid.v1();
    });
    await Services.updateNotifAct(notifModel.nid, actions).then((response)async{
      print("Response $response");
      if(response=="success"){
        if(actions=="ACCEPTED"){
          await Services.updateUnitTid(notifModel.text.toString().split(",").first, sender.uid, lid).then((value)async{
            print("Value $value");
            if(value=="success"){
              LeaseModel lease = LeaseModel(
                  lid: lid,
                  tid: sender.uid,
                  ctid: "",
                  eid: notifModel.eid,
                  pid: notifModel.pid.toString(),
                uid: notifModel.text.toString(),
                start: DateTime.now().toString(),
                end: "",
                checked: "true"
              );
              Services.addLeases(lid, sender.uid, notifModel.eid.toString(), notifModel.text.toString(), notifModel.pid.toString(), DateTime.now().toString(), "",).then((state){
                print("State $state");
              });
              unit.tid = sender.uid;
              unit.lid = lid;
              await Data().addEntity(entityModel);
              await Data().addUnit(unit);
              await Data().addLease(lease);
            }
          });
        }
        notifModel.actions=actions;
        notifModel.time=DateTime.now().toString();
        await Data().addNotification(notifModel);
        widget.getEntity();
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(actions=="ACCEPTED"?'Request Accepted Successfully':'Request declined'),
            width: 500,
            showCloseIcon: true,
          ),
        );
      } else if(response=="failed"){
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action not processed.'),
            showCloseIcon: true,
            width: 500,
          ),
        );
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Data().failed),
            showCloseIcon: true,
            width: 500,
          ),
        );
      }
    });
  }
  void _undo()async{
    setState(() {
      _loading = true;
    });
    await Services.updateNotifAct(notifModel.nid, "").then((response)async{
      if(response=="success"){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action restored'),
            width: 500,
            showCloseIcon: true,
          ),
        );
        notifModel.actions="";
        notifModel.time=DateTime.now().toString();
        await Data().addNotification(notifModel);
      }
      setState(() {
        _loading = false;
      });
    });
  }

  _updateCount(){}
  _changeMess(MessModel messModel){}
}
