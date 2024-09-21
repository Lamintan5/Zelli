import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/widgets/logo/prop_logo.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../main.dart';
import '../../../../models/entities.dart';
import '../../../../models/notifications.dart';
import '../../../../models/units.dart';
import '../../../../models/users.dart';
import '../../../../resources/services.dart';
import '../../../models/messages.dart';
import '../../../utils/colors.dart';
import '../../shimmer_widget.dart';

class ItemTntRq extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final String from;
  const ItemTntRq({super.key, required this.notif, required this.getEntity, required this.from});

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
  bool _accepting = false;
  bool _rejecting = false;

  bool _isExpanded = false;
  NotifModel notifModel = NotifModel(nid: "");

  _getDetails()async{
    _getData();
    // _unit = await Services().getCrrntUnit(notifModel.text.toString());
    // _entity = await Services().getOneEntity(notifModel.eid.toString());
    // _newUser = await Services().getOneUser(notifModel.sid!);
    // _receiver = await Services().getOneUser(notifModel.rid!);
    // _newUser.addAll(_receiver);
    // await Data().addOrUpdateUserList(_newUser);
    // await Data().updateOrAddUnits(_unit);
    // await Data().updateOrAddEntity(_entity);
    _getData();
  }

  _getData(){
    notifModel = widget.notif;
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode  (jsonString))).toList();
    unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).firstWhere((element) =>
    element.id == notifModel.text, orElse: ()=>UnitModel(id: "", title: "", tid: ""));
    entityModel = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((element) =>
    element.eid == notifModel.eid, orElse: ()=>EntityModel(eid:"", title: ""));
    newEnty = _entity.map((entityModel) => jsonEncode(entityModel.toJson())).toList();
    sender = _user.firstWhere((element) => element.uid == notifModel.sid, orElse: ()=>UserModel(uid: "", username: "", image: ""));
    receiver = _user.firstWhere((element) =>  notifModel.rid!.contains(element.uid), orElse: ()=>UserModel(uid: "", username: "", image: ""));

    setState(() {

    });
  }

  _actionUpdate(String action)async{
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    NotifModel notification = NotifModel(
      nid: notifModel.nid,
      text: notifModel.text,
      type: notifModel.type,
      actions: action,
    );
    setState(() {
      if(action=="ACCEPT"){
        _accepting = true;
      } else if(action=="REJECTED"){
        _rejecting = true;
      }
    });
    // _unit = await Services().getCrrntUnit(notifModel.text.toString());
    var newUnit = _unit.isEmpty? UnitModel(tid: "") : _unit.first;
    if(newUnit.tid==""){
      // Services.updateNotification(notification).then((response){
      //   if(response=='success'){
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         backgroundColor: dilogbg,
      //         content: Text(action=="ACCEPT"?'Request Accepted Successfully':'Request declined', style: TextStyle(color: reverse,)),
      //         action: SnackBarAction(
      //           onPressed: (){
      //             setState(() {
      //               // _undo();
      //             });
      //           },
      //           label: 'Undo',
      //         ),
      //       ),
      //     );
      //     if(action=='ACCEPT'){
      //       setState(() {
      //         if(action=="ACCEPT"){
      //           _accepting = false;
      //         } else if(action=="REJECTED"){
      //           _rejecting = false;
      //         }
      //       });
      //       setState(() {
      //         notifModel.actions = 'ACCEPT';
      //         Services.addTenants(
      //           notifModel.sid!,
      //           notifModel.eid.toString(),
      //           notifModel.text.toString(),
      //           notifModel.pid.toString(),
      //           DateTime.now().toString(),
      //           "",).then((response){
      //           if(response=='success'){
      //             Services.updateUnitTid(notifModel.text.toString(), notifModel.sid!);
      //             widget.getEntity();
      //           }
      //         });
      //       });
      //     } else if(action=='REJECTED'){
      //       widget.getEntity();
      //       setState(() {
      //         notifModel.actions = 'REJECTED';
      //       });
      //     }
      //   } else if(response=='failed'){
      //     setState(() {
      //       if(action=="ACCEPT"){
      //         _accepting = false;
      //       } else if(action=="REJECTED"){
      //         _rejecting = false;
      //       }
      //     });
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         backgroundColor: dilogbg,
      //         content: Text('Request was not sent', style: TextStyle(color: reverse,),),
      //         action: SnackBarAction(
      //           onPressed: _actionUpdate(action),
      //           label: 'Try Again',
      //         ),
      //       ),
      //     );
      //   } else {
      //     setState(() {
      //       if(action=="ACCEPT"){
      //         _accepting = false;
      //       } else if(action=="REJECTED"){
      //         _rejecting = false;
      //       }
      //     });
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         backgroundColor: dilogbg,
      //         content: Text('mmhmm🤔 something went wrong.', style: TextStyle(color: reverse,)),
      //       ),
      //     );
      //   }
      // });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: dilogbg,
          content: Text('This unit is currently under lease. Kindly contact your agent for further assistance.', style: TextStyle(color: reverse,)),
          action: SnackBarAction(
            onPressed: (){
              setState(() {
                // _undo();
              });
            },
            label: 'Undo',
          ),
        ),
      );
    }
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
    final bold = TextStyle(fontWeight: FontWeight.w800,fontSize: 13,color: reverse);
    final style = TextStyle(fontSize: 13,color: reverse);
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
                SizedBox(height: 10,),
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
                            Text(sender.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),),
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
                                : notifModel.actions == "ACCEPT"
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
                            onTap: (){_actionUpdate("ACCEPT");},
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
                            onTap: (){_actionUpdate("REJECTED");},
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
                        ],
                      ),
                    ),
                    PopupMenuButton(
                        icon: Icon(CupertinoIcons.ellipsis),
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
                            PopupMenuItem(
                              child: Row(
                                children: [
                                  Icon(CupertinoIcons.ellipses_bubble),
                                  SizedBox(width: 10,),
                                  Text("Message")
                                ],
                              ),
                              onTap: (){
                                // Platform.isIOS || Platform.isAndroid
                                //     ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user,), transition: Transition.rightToLeft)
                                //     : Get.to(() => WebChat(selected: user,), transition: Transition.rightToLeft);;
                              },
                            ),
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
        ],
      ),
    );
  }
  _updateCount(){}
  _changeMess(MessModel messModel){}

}
