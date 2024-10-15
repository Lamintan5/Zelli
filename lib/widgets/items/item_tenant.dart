import 'dart:convert';
import 'dart:io';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/buttons/call_actions/single_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../home/actions/chat/message_screen.dart';
import '../../home/actions/chat/web_chat.dart';
import '../../home/tabs/payments.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/units.dart';
import '../../utils/colors.dart';
import '../../views/unit/unit_profile.dart';
import '../buttons/bottom_call_buttons.dart';
import '../dialogs/dialog_grid.dart';
import '../dialogs/dialog_title.dart';
import '../profile_images/user_profile.dart';
import '../text/text_format.dart';

class ItemTenant extends StatefulWidget {
  final UserModel user;
  final EntityModel entity;
  const ItemTenant({super.key, required this.user, required this.entity});

  @override
  State<ItemTenant> createState() => _ItemTenantState();
}

class _ItemTenantState extends State<ItemTenant> {
  List<String> admin = [];
  List<PaymentsModel> _pay = [];
  List<UnitModel> _units = [];

  bool _expanded = false;
  bool _loading = false;

  double amount = 0;
  int units = 0;

  _getData(){
    admin = widget.entity.admin.toString().split(",");
    _units = widget.entity.eid == ""
        ?  myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((unt) => unt.tid.toString().contains(widget.user.uid)).toList()
        : myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((unt) => unt.tid.toString().contains(widget.user.uid) && unt.eid == widget.entity.eid).toList();
    _pay = widget.entity.eid == ""
        ? myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) => pay.type!.split(",").first != "EXP" && pay.tid.toString().contains(widget.user.uid.toString())).toList()
        : myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) =>
    pay.type!.split(",").first != "EXP" && pay.tid.toString().contains(widget.user.uid) && pay.eid == widget.entity.eid).toList();
    amount = _pay.fold(0.0, (previous, element) => previous + double.parse(element.amount.toString()));
    units = _units.length;

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
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
                  UserProfile(image: widget.user.image.toString()),
                  SizedBox(width: 10,),
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
                  Column(
                    children: [
                      Text(
                        admin.contains(widget.user.uid)? "Admin" : "",
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                      Wrap(
                        runSpacing: 5,
                        spacing: 5,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                            decoration: BoxDecoration(
                              color: color1,
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              children: [
                                LineIcon.wallet(size: 12,color: secondaryColor,),
                                SizedBox(width: 5,),
                                Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}', style: TextStyle(fontSize: 11, color: secondaryColor),)
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                            decoration: BoxDecoration(
                                color: color1,
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              children: [
                                LineIcon.box(size: 12,color: secondaryColor,),
                                SizedBox(width: 5,),
                                Text('$units ${units==1? "unit":"units"}', style: TextStyle(fontSize: 11, color: secondaryColor),)
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  SizedBox(width: 10,),
                  _loading
                      ? Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: reverse, strokeWidth: 3)
                  )
                      : SizedBox(),
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
                SizedBox(height: 5,),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      BottomCallButtons(
                          onTap: () {
                            Get.to(()=>Payments(entity: widget.entity, unit: UnitModel(id: "" ), tid: widget.user.uid, lid: '', from: 'item',),transition: Transition.rightToLeft);
                          },
                          icon: LineIcon.wallet(color: secondaryColor,),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: "Payments"),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ),
                      BottomCallButtons(
                          onTap: () {
                            _units.length == 1
                                ? Get.to(()=> ShowCaseWidget(
                                  builder: (context) => UnitProfile(unit: _units.first,  reload: _getData, removeTenant: _removeTenant, removeFromList: _removeFromList, user: UserModel(uid: ""), leasid: '', entity: widget.entity,),
                                ), transition: Transition.rightToLeft)
                                : dialogChooseUnit(context, _units);
                          },
                          icon: Icon(units==1?Icons.crop_square:CupertinoIcons.square_grid_2x2, color: secondaryColor),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: units==1? "Unit" : "Units"
                      ),
                      Platform.isAndroid || Platform.isIOS? Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ) : SizedBox(),
                      Platform.isAndroid || Platform.isIOS? BottomCallButtons(
                          onTap: () {
                            if(widget.user.phone.toString()==""){
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
                          icon: Icon(
                            CupertinoIcons.phone,
                            color: secondaryColor,
                          ),
                          actionColor: secondaryColor,
                          backColor: Colors.transparent,
                          title: "Call") : SizedBox(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: VerticalDivider(
                          thickness: 1,
                          width: 15,
                          color: secondaryColor,
                        ),
                      ),
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
  void _updateCount(){}
  void _changeMess(MessModel messModel){}
  dialogChooseUnit(BuildContext context, List<UnitModel> units) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context){
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        backgroundColor: dilogbg,
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogTitle(title: "S E L E C T  U N I T"),
                Text(
                  'Launch unit profile by clicking on any unit listed below in order to get more details of the unit and leasing tenant',
                  style: TextStyle(fontSize: 11, color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                DialogGrid(units: units, user: widget.user, entity: widget.entity,),
                SingleCallAction()
              ],
            ),
          ),
        ),
      );
    });
  }
  void _removeFromList(String id){
    print("Removing Unit");
    _units.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }
  void _removeTenant(){
    print("Removing Tenant");
   //  _units.first.tid ="";
    setState(() {

    });
  }
}
