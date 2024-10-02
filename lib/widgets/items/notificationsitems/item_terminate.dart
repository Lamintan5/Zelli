import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/messages.dart';
import '../../../models/notifications.dart';
import '../../../models/units.dart';
import '../../../models/users.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../logo/prop_logo.dart';
import '../../profile_images/user_profile.dart';
import '../../shimmer_widget.dart';
import '../../text/text_format.dart';

class ItemTerminate extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  final String from;
  const ItemTerminate({super.key, required this.notif, required this.getEntity, required this.remove, required this.from});

  @override
  State<ItemTerminate> createState() => _ItemTerminateState();
}

class _ItemTerminateState extends State<ItemTerminate> {
  List<UserModel> _user = [];
  List<String> uidList = [];
  List<UnitModel> _unit = [];

  NotifModel notifModel = NotifModel(nid: "");
  UnitModel unitmodel = UnitModel(id: "", title: "");
  EntityModel entityModel = EntityModel(eid: "",title: "",image: "");
  UserModel sender = UserModel(uid: "", username: "", image: "");
  UserModel receiver = UserModel(uid: "", username: "", image: "");

  bool _isExpanded = false;
  bool _loading = false;

  _getDetails()async{
    _getData();
    _getData();
  }

  _getData(){
    notifModel = widget.notif;
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    entityModel = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((test) =>
     test.eid == notifModel.eid, orElse: ()=> EntityModel(eid: "", title: ""));
    _user.add(currentUser);

    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    unitmodel =  _unit.firstWhere((element) => element.id == notifModel.text.toString().split(",").first, orElse: () => UnitModel(id: "", title: notifModel.text.toString().split(",").last));

    sender = _user.firstWhere((element) => element.uid == notifModel.sid, orElse: () => UserModel(uid: "", username: "", image: ""));
    receiver = _user.firstWhere((element) => element.uid == notifModel.rid, orElse: () => UserModel(uid: "", username: "", image: ""));

    Future.delayed(Duration.zero).then((value) {
      if (mounted) {
        setState(() {});
      }
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
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
                    Text("TERMINATE", style: TextStyle(color: secondaryColor),),
                    notifModel.actions == ""? SizedBox() :  Text("•  ${TFormat().toCamelCase("${notifModel.actions}")}", style: TextStyle(color: secondaryColor),),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   sender.uid ==""
                        ? ShimmerWidget.circular(width: 40, height: 40)
                        : sender.uid != currentUser.uid
                        ? UserProfile(image: sender.image!, radius: 20,)
                        : PropLogo(entity: entityModel, radius: 20),
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
                          Text(sender.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: notifModel.actions==""?reverse:secondaryColor),),
                          notifModel.actions == ""
                              ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: widget.notif.pid.toString().contains(currentUser.uid)
                                  ? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "${sender.username.toString()} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "has submitted a lease termination notice for unit ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "with a planned vacate date of ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${DateFormat.yMMMEd().format(DateTime.parse(notifModel.text.toString().split(",")[1]))}",
                                        style: bold
                                    ),
                                  ]
                              )
                                  : notifModel.sid == currentUser.uid? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: 'You have submitted a lease termination notice for unit ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: 'with a planned vacate date of ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${DateFormat.yMMMEd().format(DateTime.parse(notifModel.text.toString().split(",")[1]))}",
                                        style: bold
                                    ),
                                  ]
                              ) : TextSpan()
                          )
                              : notifModel.actions == "ACCEPTED"
                              ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text:widget.notif.sid == currentUser.uid
                                  ? TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Your request to terminate the lease for unit ",style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " has been approved.  Please note that you are required to vacate by ",style: style
                                    ),
                                    TextSpan(
                                        text: "${DateFormat.yMMMEd().format(DateTime.parse(notifModel.text.toString().split(",")[1]))}",
                                        style: bold
                                    ),
                                  ]
                              ) : TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '${sender.username.toString()}\'s ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "request to terminate the lease for unit ",style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "has been approved. Tenant is required to vacate by",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${DateFormat.yMMMEd().format(DateTime.parse(notifModel.text.toString().split(",")[1]))}",
                                        style: bold
                                    ),
                                  ]
                              )
                          )
                              : RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text:widget.notif.sid == currentUser.uid
                                  ? TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Your request to terminate the lease for unit ",style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "has been denied. Please contact your property manager for more clarifications ",style: style
                                    ),

                                  ]
                              )
                                  : TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '${sender.username.toString()}\'s ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text:'request to terminate the lease for unit ',style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.id==""? "${notifModel.text.toString().split(",").last}, " : "${unitmodel.title}, ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: 'was rejected.',style: style
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
                notifModel.pid.toString().contains(currentUser.uid)  && notifModel.actions == ""
                    ? AnimatedSize(
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                       unitmodel.tid == null
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5,))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){
                              _action("ACCEPTED");
                            },
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
                        unitmodel.tid == null
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
                )
                    : SizedBox(),
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
                                  LineIcon.box(color: secondaryColor,size: 12,),
                                  SizedBox(width: 5,),
                                  Text(unitmodel.id == "" ? notifModel.text.toString().split(",").last : unitmodel.title.toString(), style: TextStyle(fontSize: 11),),
                                ],
                              )
                          ),
                          notifModel.pid.toString().contains(currentUser.uid)  && notifModel.actions==""
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
                                    _callNumber(sender.phone.toString());
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
    setState(() {
      _loading = true;
    });
    await Services.updateNotifAct(notifModel.nid, actions).then((response)async{
      print("Response $response");
      if(response=="success"){
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

  void _updateCount(){}
  void _changeMess(MessModel mess){}

  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
