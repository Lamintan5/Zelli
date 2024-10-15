import 'dart:convert';
import 'dart:io';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/messages.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/views/property/activities/permissions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/actions/chat/message_screen.dart';
import '../../home/actions/chat/web_chat.dart';
import '../../main.dart';
import '../../models/duties.dart';
import '../../models/entities.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../buttons/bottom_call_buttons.dart';
import '../buttons/call_actions/double_call_action.dart';
import '../dialogs/dialog_title.dart';
import '../profile_images/user_profile.dart';

class ItemManagers extends StatefulWidget {
  final UserModel user;
  final EntityModel entity;
  final Function reload;
  final Function remove;
  const ItemManagers({super.key, required this.user, required this.entity, required this.reload, required this.remove});

  @override
  State<ItemManagers> createState() => _ItemManagersState();
}

class _ItemManagersState extends State<ItemManagers> {
  List<DutiesModel> _duties = [];
  List<DutiesModel> _newDuties = [];
  List<String> pidList = [];
  List<String> admin = [];
  bool _loading = false;
  bool _expanded = false;
  DutiesModel dutiesModel = DutiesModel(did: "");

  _getDetails()async{
    _getData();
    _newDuties = await Services().getMyDuties(widget.user.uid);
    await Data().addOrUpdateDutyList(_newDuties);
    _getData();
  }

  _getData(){
    _duties = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    dutiesModel = _duties.firstWhere(
            (test) => test.eid == widget.entity.eid && test.pid == widget.user.uid,
        orElse: () => DutiesModel(did: ""));
    admin = widget.entity.admin.toString().split(",");
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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            hoverColor: color1,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Row(
                children: [
                  Stack(
                    children: [
                      UserProfile(image: widget.user.image.toString()),
                      Positioned(
                          bottom: 0,
                          right: 0,
                          child: admin.contains(widget.user.uid)
                              ? Icon(CupertinoIcons.checkmark_seal_fill, color: CupertinoColors.activeBlue,size: 15,)
                              : SizedBox()
                      )
                    ],
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.username.toString()),
                        Text(
                          '${widget.user.firstname} ${widget.user.lastname}',
                          style: TextStyle(color: secondaryColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _loading
                      ? Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: reverse, strokeWidth: 2)
                  )
                      : SizedBox(),
                  SizedBox(width: 10,),
                  widget.user.uid==currentUser.uid
                      ? SizedBox()
                      : AnimatedRotation(
                    duration: Duration(milliseconds: 500),
                    turns: _expanded ? 0.5 : 0.0,
                    child: Icon(Icons.keyboard_arrow_down, color: secondaryColor,),
                  ),
                ],
              ),
            ),
          ),
          widget.user.uid==currentUser.uid
              ?  SizedBox()
              : AnimatedSize(
            duration: Duration(milliseconds: 500),
            alignment: Alignment.topCenter,
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
              children: [
                SizedBox(
                  height: 5,
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      !admin.contains(currentUser.uid) || admin.contains(widget.user.uid)
                          ? SizedBox()
                          : BottomCallButtons(
                          onTap: () {
                            Get.to(() => Permissions(
                                entity: widget.entity, duties: dutiesModel, reload: _getDetails, user: widget.user,
                            ),
                                transition: Transition.rightToLeft);
                          },
                          icon: Icon(CupertinoIcons.lock,
                              color: secondaryColor),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: "Permissions"
                      ),
                      !admin.contains(currentUser.uid) || admin.contains(widget.user.uid)? SizedBox()
                          : Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ),
                      !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid
                          ? SizedBox()
                          : BottomCallButtons(
                          onTap: () {
                            if(admin.contains(widget.user.uid)){
                              dialogAdmin(context,"Remove");
                            } else {
                              dialogAdmin(context, "Add");
                            }
                          },
                          icon: Icon(CupertinoIcons.checkmark_seal,
                              color: secondaryColor),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: admin.contains(widget.user.uid)?"-Admin":"+Admin"
                      ),
                      !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid ? SizedBox()
                          : Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ),
                      !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid
                          ? SizedBox()
                          : BottomCallButtons(
                              onTap: () {
                                dialogRemove(context);
                              },
                              icon: LineIcon.removeUser(color: secondaryColor,),
                              actionColor: secondaryColor,
                              backColor: Colors.transparent,
                              title: "Remove"
                          ),
                      !admin.contains(currentUser.uid) || admin.first.toString() == widget.user.uid? SizedBox()
                          : Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ),
                      Platform.isAndroid || Platform.isIOS?  BottomCallButtons(
                          onTap: () {
                              if(widget.user.phone.toString()==""){
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(Data().noPhone),
                                      width: 500,
                                      showCloseIcon: true,
                                    )
                                );
                              }else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Feature not available."),
                                      showCloseIcon: true,
                                    )
                                );
                              }
                            },
                          icon: Icon(
                            CupertinoIcons.phone,
                            color: secondaryColor,
                          ),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: "Call") : SizedBox(),
                      Platform.isAndroid || Platform.isIOS?  Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ) : SizedBox(),
                      BottomCallButtons(
                          onTap: () {
                            Platform.isAndroid || Platform.isIOS
                                ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: widget.user), transition: Transition.rightToLeft)
                                : Get.to(() => WebChat(selected: widget.user), transition: Transition.rightToLeft);
                          },
                          icon: Icon(
                            CupertinoIcons.ellipses_bubble,
                            color: secondaryColor,
                          ),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: "Message"
                      ),
                    ],
                  ),
                ),
              ],
            )
                : SizedBox(),
          )
        ],
      ),
    );
  }
  void dialogRemove(BuildContext context) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, color: revers);
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "R E M O V E"),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Are you sure yo wan to remove ",
                              style: style
                          ),
                          TextSpan(
                              text: "${widget.user.username} ",
                              style: bold
                          ),
                          TextSpan(
                              text: "from your managers list",
                              style: style
                          ),
                        ]
                    )
                ),
                DoubleCallAction(
                    action: ()async{
                  Navigator.pop(context);
                  _remove();
                  await Data().removeAdmin(context, widget.entity, widget.user, _reload);
                })
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogAdmin(BuildContext context, String action) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, color: revers);
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "A D M I N"),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: action=="Remove"?"Are you sure you want to remove " : "Are you sure you want to assign ",
                              style: style
                          ),
                          TextSpan(
                              text: "${widget.user.username} ",
                              style: bold
                          ),
                          TextSpan(
                              text: "as the entity's admin? ",
                              style: style
                          ),
                          TextSpan(
                              text: action=="Remove"?"":"This action will grant them full access to manage all data related to  ",
                              style: style
                          ),
                          TextSpan(
                              text: action=="Remove"?"":"${widget.entity.title}.",
                              style: bold
                          ),
                        ]
                    )
                ),
                DoubleCallAction(action: ()async{
                  Navigator.pop(context);
                  setState(() {
                    _loading = true;
                  });
                  if(action=="Remove"){
                    await Data().removeAdmin(context, widget.entity, widget.user, _reload).then((value){
                      setState(() {
                        _loading = value;
                      });
                    });
                  } else {
                    await Data().makeAdmin(context, widget.entity, widget.user, _reload).then((value){
                      setState(() {
                        _loading = value;
                      });
                    });
                  }

                })
              ],
            ),
          ),
        ),
      );
    });
  }
  void _remove() async{
    setState(() {
      _loading = true;
    });
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    EntityModel entity = _entity.firstWhere((test) => test.eid == widget.entity.eid);
    List<String> _pid = [];
    _pid = entity.pid.toString().split(",");
    _pid.remove(widget.user.uid);



    await Services.removePid(widget.entity.eid, widget.user.uid).then((response){

      if(response=="success"||response=="Does not exist"){
        _entity.firstWhere((test) => test.eid == widget.entity.eid).pid = _pid.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;

        widget.remove(widget.user);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Manager removed from list"),
              showCloseIcon: true,
              width: 500,
            )
        );
        setState(() {
          _loading = false;
        });
      } else if(response=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Manager was not removed from list. Please try again"),
              showCloseIcon: true,
              width: 500,
            )
        );
        setState(() {
          _loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
              width: 500,
            )
        );
        setState(() {
          _loading = false;
        });
      }
    });
  }
  void _updateCount(){}
  void _changeMess(MessModel mess){}
  void _reload(UserModel user, String action){
    if(action=="Add"){
      if(!admin.contains(user.uid)){
        admin.add(user.uid);
        print("Adding : ${user.username}");
      }
    } else {
      if(admin.contains(user.uid)){
        admin.remove(user.uid);
        print("Removing : ${user.username}");
      }
    }

    widget.reload();
    setState(() {

    });
  }

}
