import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../../main.dart';
import '../../../../models/data.dart';
import '../../../../models/entities.dart';
import '../../../../models/notifications.dart';
import '../../../../models/users.dart';
import '../../../../resources/services.dart';
import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../models/messages.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../logo/prop_logo.dart';
import '../../profile_images/user_profile.dart';
import '../../shimmer_widget.dart';

class ItemNotif extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  final String from;
  const ItemNotif({super.key, required this.notif, required this.getEntity, required this.from, required this.remove});

  @override
  State<ItemNotif> createState() => _ItemNotifState();
}

class _ItemNotifState extends State<ItemNotif> {
  List<UserModel> _newUser = [];
  List<UserModel> _user = [];
  UserModel sender = UserModel(uid: "", username: "", image: "");
  UserModel receiver = UserModel(uid: "", username: "", image: "");
  UserModel user = UserModel(uid: "", username: "", image: "");
  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  EntityModel entityModel = EntityModel(eid: "", title: "", image: "");
  List<String> pidListAsList = [];
  String pidList = "";
  String did = '';
  bool _loading = false;
  List<NotifModel> _notifications = [];
  List<String> uidList = [];

  bool _isExpanded = false;
  NotifModel notifModel = NotifModel(nid: "");

  _getDetails()async{
    _getData();
    _newEntity = await Services().getOneEntity(notifModel.eid.toString());
    _newUser = await Services().getCrntUsr(uidList.first);
    await Data().addNotMyEntity(_newEntity);
    await Data().addOrUpdateUserList(_newUser);
    await Data().updateSeen(notifModel);
    widget.getEntity();
    _getData();
  }


  _getData()async{
    notifModel = widget.notif;
    entityModel = _entity.any((test) => test.eid == notifModel.eid)
        ? _entity.firstWhere((element) => element.eid == notifModel.eid, orElse: () => EntityModel(eid: ""))
        : notMyEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((element)
    => element.eid == notifModel.eid, orElse: () => EntityModel(eid: "", title: "", image: "", checked: "false"));
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _user.add(currentUser);

    pidList = entityModel.pid.toString();
    pidListAsList = pidList.split(",");
    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    user = _user.firstWhere((element) => element.uid == uidList.first, orElse: () => UserModel(uid: "", username: "", image: ""));
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
                        Icon(CupertinoIcons.arrow_up_right_circle, size: 12,color: secondaryColor,),
                        SizedBox(width: 5,),
                        Text("REQUEST ", style: TextStyle(color: secondaryColor),),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 5),
                              Text(timeago.format(DateTime.parse(notifModel.time.toString())), style: TextStyle(fontSize: 13)),
                              SizedBox(width: 5),
                              notifModel.actions.toString() == ""? AnimatedRotation(
                                duration: Duration(milliseconds: 500),
                                turns: _isExpanded ? 0.5 : 0.0,
                                child: Icon(Icons.keyboard_arrow_down),
                              ) : SizedBox(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        entityModel.eid == "" || user.uid ==""
                            ? ShimmerWidget.circular(width: 40, height: 40)
                            : user.uid != currentUser.uid
                            ? UserProfile(image: user.image!, radius: 20,)
                            : PropLogo(entity: entityModel, radius: 20),
                        SizedBox(width: 15,),
                        Expanded(
                            child: user.uid == "" || entityModel.eid == ""
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
                                    Text(user.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
                                        color:  notifModel.actions==""?reverse:secondaryColor),),
                                    notifModel.actions == ""
                                        ? RichText(
                                        maxLines: _isExpanded?100:1,
                                        overflow: TextOverflow.ellipsis,
                                        text: widget.notif.rid == currentUser.uid ? TextSpan(
                                          children: [
                                            TextSpan(
                                                text: "You have received an invitation to join ",
                                                style: style
                                            ),
                                            TextSpan(
                                                text: '${entityModel.title} ',
                                                style: bold
                                            ),
                                            TextSpan(
                                                text: "as a ",
                                                style: style
                                            ),
                                            WidgetSpan(
                                                child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                    decoration: BoxDecoration(
                                                        color:Colors.lightBlueAccent.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    child: Text("Manager", style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700),)
                                                )
                                            )
                                          ]
                                        )
                                            : TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: 'An invitation has been sent to ',
                                                  style: style
                                              ),
                                              TextSpan(
                                                  text: "${receiver.username.toString()} ",
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: 'to commence managing ',
                                                  style: style
                                              ),
                                              TextSpan(
                                                  text: '${entityModel.title.toString()}. ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: 'This request was submitted by ',
                                                  style: style
                                              ),
                                              TextSpan(
                                                  text: '${sender.username.toString()} ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: 'and is currently awaiting a response from the recipient.',
                                                  style: style
                                              ),
                                            ]
                                        )
                                    )
                                        : notifModel.actions == "ACCEPTED"
                                        ? RichText(
                                        text:widget.notif.rid == currentUser.uid ? TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "You have joined ",
                                                style: style
                                              ),
                                              TextSpan(
                                                  text: '${entityModel.title.toString()} ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: "as a ",
                                                  style: style
                                              ),
                                              WidgetSpan(
                                                  child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                      decoration: BoxDecoration(
                                                          color:Colors.green.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child: Text("Manager", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),)
                                                  )
                                              )
                                            ]
                                          ) : TextSpan(
                                          children: [
                                            TextSpan(
                                                text: '${user.username.toString()} ',
                                                style: bold
                                            ),
                                            TextSpan(
                                              text: "has accepted to join ",
                                              style: style,
                                            ) ,
                                            TextSpan(
                                                text: '${entityModel.title.toString()} ',
                                                style: bold
                                            ),
                                            TextSpan(
                                                text: "as a ",
                                                style: style
                                            ),
                                            WidgetSpan(
                                                child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                    decoration: BoxDecoration(
                                                        color:Colors.green.withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(5)
                                                    ),
                                                    child: Text("Manager", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w700),)
                                                )
                                            )
                                          ]
                                        )
                                        )
                                        : RichText(

                                        text:widget.notif.rid == currentUser.uid ? TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: "You have declined to join",
                                                  style: style
                                              ),
                                              TextSpan(
                                                  text: '${entityModel.title.toString()} ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: "as a ",
                                                  style: style
                                              ),
                                              WidgetSpan(
                                                  child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                      decoration: BoxDecoration(
                                                          color:Colors.red.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child: Text("Manager", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),)
                                                  )
                                              )
                                            ]
                                        ) : TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: '${user.username.toString()} ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                text: "has declined to join ",
                                                style: style,
                                              ) ,
                                              TextSpan(
                                                  text: '${entityModel.title.toString()} ',
                                                  style: bold
                                              ),
                                              TextSpan(
                                                  text: "as a ",
                                                  style: style
                                              ),
                                              WidgetSpan(
                                                  child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                                      decoration: BoxDecoration(
                                                          color:Colors.red.withOpacity(0.2),
                                                          borderRadius: BorderRadius.circular(5)
                                                      ),
                                                      child: Text("Manager", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),)
                                                  )
                                              )
                                            ]
                                        )
                                    ),
                                  ],
                                )
                        ),
                      ],
                    ),
                    widget.from == "Prop"  || notifModel.actions != "" || notifModel.rid != currentUser.uid
                        ? SizedBox()
                        : AnimatedSize(
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
                                notifModel.rid == currentUser.uid && notifModel.actions==""
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
                            )
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
                                if(user.phone.toString()!=""&&Platform.isAndroid||Platform.isIOS)
                                  PopupMenuItem(
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.phone),
                                        SizedBox(width: 10,),
                                        Text("Call")
                                      ],
                                    ),
                                    onTap: (){
                                      if(user.phone==""||user.phone==null){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(Data().noPhone),
                                              width: 500,
                                              showCloseIcon: true,
                                            )
                                        );
                                      } else {
                                        _callNumber(user.phone.toString());
                                      }
                                    },
                                  ),

                                if(notifModel.rid==currentUser.uid && notifModel.actions=="REJECTED")
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
                            }),
                      ],
                    ),
                  ],
                ),
              ),
              _loading ? LinearProgressIndicator(backgroundColor: color1,minHeight: 1) : SizedBox()
            ],
          ),
    );
  }



  void _action(String actions)async{
    setState(() {
      _loading = true;
    });
    await Services.updateNotifAct(notifModel.nid, actions).then((response)async{
      if(response=="success"){
        if(actions=="ACCEPTED"){
          await Services.updatePid(entityModel.eid).then((value){
            if(response=="success"){
              Uuid uuid = Uuid();
              did = uuid.v1();
              Services.addDuties(did, notifModel.eid!, currentUser.uid, Data().dutiesList);
              SocketManager().getDetails();
              widget.getEntity();
            }
          });
        }
        notifModel.actions=actions;
        notifModel.time=DateTime.now().toString();
        await Data().addNotification(notifModel);
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
  void _updateCount(){}
  void _changeMess(MessModel mess){

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
  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
