import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

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

class ItemReqCoTnt extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final Function remove;
  final String from;
  const ItemReqCoTnt({super.key, required this.notif, required this.getEntity, required this.from, required this.remove});

  @override
  State<ItemReqCoTnt> createState() => _ItemReqCoTntState();
}

class _ItemReqCoTntState extends State<ItemReqCoTnt> {
  bool _loading = false;

  List<EntityModel> _entity = [];
  List<EntityModel> _newEntity = [];
  List<UserModel> _newUser = [];
  List<UserModel> _user = [];
  List<UnitModel> _unit = [];
  List<UnitModel> _newUnit = [];
  List<String> uidList = [];

  NotifModel notifModel = NotifModel(nid: "");
  UnitModel unitmodel = UnitModel(id: "", title: "");
  EntityModel entityModel = EntityModel(eid: "",title: "",image: "");
  UserModel sender = UserModel(uid: "", username: "", image: "");
  UserModel receiver = UserModel(uid: "", username: "", image: "");
  UserModel user = UserModel(uid: "", username: "", image: "");

  bool _isExpanded = false;

  _getDetails()async{
    _getData();
    _newEntity = await Services().getOneEntity(notifModel.eid.toString());
    _newUser = await Services().getCrntUsr(uidList.first);
    _newUnit = await Services().getCrrntUnit(notifModel.text.toString().split(",").first);
    await Data().addNotMyEntity(_newEntity);
    await Data().addOrUpdateUserList(_newUser);
    _getData();
  }

  _getData(){
    notifModel = widget.notif;
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    entityModel = _entity.any((test) => test.eid == notifModel.eid)
        ? _entity.firstWhere((element) => element.eid == notifModel.eid, orElse: () => EntityModel(eid: ""))
        : notMyEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((element)
    => element.eid == notifModel.eid, orElse: () => EntityModel(eid: "", title: "", image: "", checked: "false"));

    unitmodel = _unit.any((test) => test.id == notifModel.text.toString().split(",").first)
        ? _unit.firstWhere((element) => element.id == notifModel.text.toString().split(",").first, orElse: () => UnitModel(id: "", title: notifModel.text.toString().split(",").last))
        : _newUnit.firstWhere((element) => element.id == notifModel.text.toString().split(",").first, orElse: () => UnitModel(id: "", title: notifModel.text.toString().split(",").last));

    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _user.add(currentUser);

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
                    Text("REQUEST", style: TextStyle(color: secondaryColor)),
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
                          Text(user.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:  notifModel.actions==""?reverse:secondaryColor),),
                          notifModel.actions == ""
                              ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: widget.notif.rid == currentUser.uid ? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "You have received a request to commence co-leasing ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${unitmodel.title} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "at ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${entityModel.title} ",
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
                                            child: Text("Co-Tenant", style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w700),)
                                        )
                                    )
                                  ]
                              ) : TextSpan(
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
                                        text: 'to initiate the co-leasing process for Unit ',
                                        style: style
                                    ),
                                    TextSpan(
                                        text: '${unitmodel.title} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: 'at ',
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
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text:widget.notif.rid == currentUser.uid ? TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: "Your commercial co-lease agreement for ",style: style
                                    ),
                                    TextSpan(
                                        text: '${unitmodel.title} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " at ",style: style
                                    ),
                                    TextSpan(
                                        text: '${entityModel.title} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "commenced on ",style: style
                                    ),
                                    TextSpan(
                                        text: '${DateFormat.yMMMd().format(DateTime.parse(notifModel.time.toString()))}',
                                        style: bold
                                    ),
                                  ]
                              ) : TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '${receiver.username.toString()}\'s ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "commercial co-lease agreement for unit ",style: style
                                    ),
                                    TextSpan(
                                        text: '${unitmodel.title.toString()} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "at ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: '${entityModel.title.toString()} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "commenced on ",style: style
                                    ),
                                    TextSpan(
                                        text: '${DateFormat.yMMMd().format(DateTime.parse(notifModel.time.toString()))}.',
                                        style: bold
                                    ),
                                  ]
                              )
                          )
                              : RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text:widget.notif.rid == currentUser.uid
                                  ? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "You have declined the request to commence co-leasing  ",style: style
                                    ),
                                    TextSpan(
                                        text: unitmodel.title.toString(),
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: " at ",style: style
                                    ),
                                    TextSpan(
                                        text: '${entityModel.title.toString()} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "as a ",style: style
                                    ),
                                    unitmodel.tid == null
                                        ?  TextSpan(
                                        text: "Co-Tenant",
                                        style: style
                                    )
                                        : WidgetSpan(
                                        child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                                            decoration: BoxDecoration(
                                                color:unitmodel.tid.toString().contains(currentUser.uid)  ? Colors.orange.withOpacity(0.2) : unitmodel.tid != ""? Colors.red.withOpacity(0.2) :Colors.lightBlueAccent.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Text("Co-Tenant", style: TextStyle(color:unitmodel.tid.toString().contains(currentUser.uid)  ? Colors.orange : unitmodel.tid != ""? Colors.red : CupertinoColors.activeBlue, fontWeight: FontWeight.w700),)
                                        )
                                    ),
                                  ]
                              )
                                  : TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: '${receiver.username.toString()}\'s ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text:'request to initiate co-leasing ',style: style
                                    ),
                                    TextSpan(
                                        text: '${unitmodel.title} ',
                                        style: bold
                                    ),
                                    TextSpan(
                                        text:'at ',style: style
                                    ),
                                    TextSpan(
                                        text: '${entityModel.title.toString()} ',
                                        style:bold
                                    ),
                                    TextSpan(
                                        text: ' was rejected.',style: style
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
                notifModel.rid == currentUser.uid && notifModel.actions == ""
                    ? AnimatedSize(
                  duration: Duration(milliseconds: 500),
                  alignment: Alignment.topCenter,
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Container(
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      children: [
                        entityModel.eid == "" || unitmodel.tid == null
                            ?  Expanded(child: ShimmerWidget.rectangular(width: 10, height: 30, borderRadius: 5,))
                            :  Expanded(
                          child: InkWell(
                            onTap: (){
                              if(!unitmodel.tid.toString().contains(currentUser.uid) ){
                                _action("ACCEPTED");
                              } else if(unitmodel.tid.toString().contains(currentUser.uid) ){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("This are currently leasing ${unitmodel.title}"),
                                      width: 500,
                                      showCloseIcon: true,
                                    )
                                );
                              } else if(unitmodel.tid == null){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(Data().failed),
                                      width: 500,
                                      showCloseIcon: true,
                                    )
                                );
                              }
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
                        entityModel.eid == ""|| unitmodel.tid == null
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
                                  Text(unitmodel.title.toString(), style: TextStyle(fontSize: 11),),
                                ],
                              )
                          ),
                          notifModel.rid == currentUser.uid && notifModel.actions=="" && !unitmodel.tid.toString().contains(currentUser.uid) 
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
                        })
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
      print("Response $response");
      if(response=="success"){
        if(actions=="ACCEPTED"){
          await Services.updateUnitTid(notifModel.text.toString().split(",").first, currentUser.uid, unitmodel.lid.toString()).then((value)async{
            print("Value $value");
            if(value=="success"){
              Services.updateLeaseCtid(unitmodel.lid.toString(), currentUser.uid).then((state){
                print("State $state");
              });
              List<String> tids = [];
              tids = unitmodel.tid.toString().split(",");
              if(!tids.contains(currentUser.uid)){
                tids.add(currentUser.uid);
              }
              unitmodel.tid = tids.join(",");
              await Data().addEntity(entityModel);
              await Data().addUnit(unitmodel);
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
    List<EntityModel> _entity = [];
    List<UnitModel> _unit = [];
    List<String> uniqueEntities = [];
    List<String> uniqueUnit = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

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

        unitmodel.tid = "";
        notifModel.actions="";
        notifModel.time=DateTime.now().toString();


        await Data().addNotification(notifModel);

        _entity.removeWhere((test) => test.eid == entityModel.eid);
        _unit.removeWhere((test) => test.id == unitmodel.id);

        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        sharedPreferences.setStringList('myunit', uniqueUnit);
        myEntity = uniqueEntities;
        myUnits = uniqueUnit;
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
