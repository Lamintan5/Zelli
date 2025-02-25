import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/actions/view_request.dart';
import 'package:Zelli/main.dart';
import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/request.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../models/notifications.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../logo/prop_logo.dart';
import '../../shimmer_widget.dart';
import '../../text/text_format.dart';

class ItemReq extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  const ItemReq({super.key, required this.notif, required this.getEntity});

  @override
  State<ItemReq> createState() => _ItemReqState();
}

class _ItemReqState extends State<ItemReq> {
  RequestModel request = RequestModel(id: "", text: "", message: "");
  NotifModel notifModel = NotifModel(nid: "");
  EntityModel entityModel = EntityModel(eid: "");
  UnitModel unitmodel = UnitModel(id: "");
  UserModel user = UserModel(uid: '');
  UserModel sender = UserModel(uid: '');
  UserModel receiver = UserModel(uid: '');

  List<UserModel> _user = [];
  List<String> uidList = [];

  bool _isExpanded = true;
  bool _loading = false;

  _getData(){
    notifModel = widget.notif;
    request = Data().requests.firstWhere((test) => test.id == notifModel.text.toString().split(",").first, orElse: () =>
      RequestModel(id: "", text: "", message: ""));
    entityModel = myEntity.map((jsonDecode) => EntityModel.fromJson(json.decode(jsonDecode))).firstWhere((test) =>
     test.eid == notifModel.eid, orElse: () => EntityModel(eid: "", title: 'N/A', image: ''));

    unitmodel = myUnits.map((jsonDecode) => UnitModel.fromJson(json.decode(jsonDecode))).firstWhere((test) =>
      test.id == notifModel.text.toString().split(",")[1], orElse: ()=> UnitModel(id: "", title: 'N/A'));

    uidList.add(notifModel.sid.toString());
    uidList.add(notifModel.rid.toString());
    uidList.remove(currentUser.uid);

    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _user.add(currentUser);

    user = _user.firstWhere((element) => element.uid == uidList.first, orElse: () => UserModel(uid: "", username: "", image: ""));
    sender = _user.firstWhere((element) => element.uid == notifModel.sid, orElse: () => UserModel(uid: "", username: "", image: ""));
    receiver = _user.firstWhere((element) => element.uid == notifModel.rid, orElse: () => UserModel(uid: "", username: "", image: "" ));
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
                    Icon(request.icon, size: 12,color: secondaryColor,),
                    SizedBox(width: 5,),
                    Text(request.text, style: TextStyle(color: secondaryColor)),
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
                          Text(
                            user.uid != currentUser.uid
                              ?user.username.toString():entityModel.title.toString(),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:  notifModel.actions==""?reverse:secondaryColor),
                          ),
                          notifModel.actions == ""
                              ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: user.uid == currentUser.uid ? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "You have submitted ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${request.text} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "Request for unit ",
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
                                  ]
                              ) : TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "${sender.username.toString()} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "has submitted ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "${request.text} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "request for unit ",
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
                                        text: "${entityModel.title}. ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: "Please review the details at your earliest convenience to proceed with the necessary actions.",
                                        style: style
                                    ),
                                  ]
                              )
                          )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(width: 5,),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: _isExpanded ? 0 : 50,
                      width: _isExpanded ? 0 : 50,
                      margin: EdgeInsets.only(left: 5),
                      child: CachedNetworkImage(
                        cacheManager: customCacheManager,
                        imageUrl: '${Services.HOST}uploads/${notifModel.image}',
                        key: UniqueKey(),
                        fit: BoxFit.cover,
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Container(
                          color: Colors.black,
                          child: Center(
                            child: Text(
                              "5",
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          child: Center(
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          _loading ? LinearProgressIndicator(backgroundColor: color1,minHeight: 1) : SizedBox(),
          Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: _isExpanded? 150 : 0,
                width: double.infinity,
                margin: EdgeInsets.only(top: 5),
                child: CachedNetworkImage(
                  cacheManager: customCacheManager,
                  imageUrl: '${Services.HOST}uploads/${notifModel.image}',
                  key: UniqueKey(),
                  fit: BoxFit.cover,
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10)
                      ),
                      shape: BoxShape.rectangle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  placeholder: (context, url) => Container(
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        "S T U D I O 5 I V E",
                        style: TextStyle(
                          fontWeight: FontWeight.w100,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    child: Center(
                      child: Icon(
                        Icons.error_outline_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      alignment: Alignment.topCenter,
                      curve: Curves.easeInOut,
                      child: _isExpanded
                          ? Container(
                        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: (){},
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
                            SizedBox(width: 5,),
                            Expanded(
                              child: InkWell(
                                onTap: (){
                                  Get.to(()=>ViewRequest(notif: notifModel), transition: Transition.rightToLeft);
                                },
                                borderRadius: BorderRadius.circular(5),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: color1, width: 1)
                                  ),
                                  child: Center(child: Text("View Request")),
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
                        SizedBox(width: 5,),
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
                                    color: Colors.black38,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black54, width: 0.5)
                                ),
                                child: Text(entityModel.title.toString(), style: TextStyle(fontSize: 11, color: Colors.white),),
                              ),
                              Container(
                                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: Colors.black54, width: 0.5)
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LineIcon.box(color: Colors.white,size: 12,),
                                      SizedBox(width: 5,),
                                      Text(unitmodel.title.toString(), style: TextStyle(fontSize: 11, color: Colors.white),),
                                    ],
                                  )
                              ),
                              notifModel.rid == currentUser.uid && notifModel.actions=="" && !unitmodel.tid.toString().contains(currentUser.uid)
                                  ? Container(
                                  padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(color: color1, width: 0.5)
                                  ),
                                  child: Text("Action Required", style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w700))
                              )
                                  :SizedBox(),
                            ],
                          ),
                        ),
                        PopupMenuButton(
                            icon: Icon(Icons.more_horiz),
                            padding: EdgeInsets.zero,
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
                                    // await Data().deleteNotif(context, notifModel, widget.remove);
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
                                    //     : Get.to(() => WebChat(selected: user,), transition: Transition.rightToLeft);
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
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Feature not available."),
                                              showCloseIcon: true,
                                            )
                                        );
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
                                    onTap: (){},
                                  ),
                              ];
                            })
                      ],
                    ),
                  ],
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}
