import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../home/tabs/payments.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/payments.dart';
import '../../../utils/colors.dart';
import '../../../widgets/buttons/bottom_call_buttons.dart';
import '../../../widgets/dialogs/dialog_add_co_tenant.dart';
import '../../../widgets/dialogs/dialog_title.dart';

class CoTenants extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  final LeaseModel lease;
  final Function reload;
  const CoTenants({super.key, required this.unit, required this.lease, required this.entity, required this.reload});

  @override
  State<CoTenants> createState() => _CoTenantsState();
}

class _CoTenantsState extends State<CoTenants> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _users = [];
  List<String> _tenants = [];
  List<String> _admin = [];

  String selectedUid = "";
  String mainTenant = "";
  String loading = "";

  _getData(){
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _admin = widget.entity.admin.toString().split(",");
    _tenants.addAll(widget.unit.tid.toString().split(","));
    mainTenant = widget.unit.tid.toString().split(",").first;
    widget.lease.ctid.toString().split(",").forEach((e){
      if(!_tenants.contains(e)){
        _tenants.add(e);
      }
    });
    _users = _users.where((usr)=>_tenants.any((tnt) => usr.uid==tnt)).toList();
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
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _users.forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()) )
          filteredList.add(item);
      });
    } else {
      filteredList = _users;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Co-Tenants"),
        actions: [
          Tooltip(
            message: "Add new co-tenants",
            child: InkWell(
                onTap: (){dialogGetCoTenants(context);},
                borderRadius: BorderRadius.circular(5),
                hoverColor: color1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.add_circle),
                )
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          children: [
            Row(),
            SizedBox(width: 500,
              child: TextFormField(
                controller: _search,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "🔎  Search for Tenants...",
                  hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                  fillColor: color1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(5)
                    ),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                ),
                onChanged:  (value) => setState((){}),
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
                child: SizedBox(width: 800,
                  child: ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index){
                        UserModel user = filteredList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: (){
                                  if(selectedUid==user.uid){
                                    setState(() {
                                      selectedUid="";
                                    });
                                  } else {
                                    setState(() {
                                      selectedUid=user.uid;
                                    });
                                  }
                                },
                                hoverColor: color1,
                                borderRadius: BorderRadius.circular(5),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                                  child: Row(
                                    children: [
                                      UserProfile(image: user.image.toString()),
                                      SizedBox(width: 10 ,),
                                      Expanded(child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user.username.toString()),
                                          Text('${user.firstname} ${user.lastname}', style: TextStyle(color: secondaryColor),),
                                        ],
                                      )),
                                      loading == user.uid? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: secondaryColor,strokeWidth: 3,)) : SizedBox(),
                                      SizedBox(width: 10,),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 500),
                                        turns: selectedUid==user.uid ? 0.5 : 0.0,
                                        child: Icon(Icons.keyboard_arrow_down, color: secondaryColor,),
                                      )
                                    ],
                                  ),
                                ),

                              ),
                              AnimatedSize(
                                duration: Duration(milliseconds: 500),
                                alignment: Alignment.topCenter,
                                curve: Curves.easeInOut,
                                child: selectedUid==user.uid
                                    ? Column(
                                      children: [
                                        SizedBox(height: 5),
                                        IntrinsicHeight(
                                          child: Row(
                                            children: [
                                              _admin.contains(currentUser.uid) || mainTenant == currentUser.uid? BottomCallButtons(
                                                  onTap: () {
                                                    dialogRemoveTenant(context, user);
                                                  },
                                                  icon: Icon(CupertinoIcons.person_badge_minus,
                                                      color: secondaryColor),
                                                  actionColor: secondaryColor,
                                                  backColor: Colors.transparent,
                                                  title: "Remove"
                                              ) : SizedBox(),
                                              _admin.contains(currentUser.uid) || mainTenant == currentUser.uid? Padding(
                                                padding: EdgeInsets.symmetric(vertical: 10),
                                                child: VerticalDivider(
                                                  thickness: 1,
                                                  width: 15,
                                                  color: secondaryColor,
                                                ),
                                              ) :SizedBox(),
                                              BottomCallButtons(
                                                  onTap: () {
                                                    Get.to(()=>Payments(eid: widget.unit.eid.toString(), unitid: widget.unit.id.toString(), tid: user.uid, lid: widget.lease.lid,),transition: Transition.rightToLeft);
                                                  },
                                                  icon: LineIcon.wallet(color: secondaryColor,),
                                                  actionColor: secondaryColor,
                                                  backColor: Colors.transparent,
                                                  title: "Payments"),
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
                                                    if(user.phone.toString()==""){
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
                                                        ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user), transition: Transition.rightToLeft)
                                                        : Get.to(() => WebChat(selected: user), transition: Transition.rightToLeft);
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
                  }),
                )
            ),
            Text(
              Data().message,
              style: TextStyle(color: secondaryColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  void dialogGetCoTenants(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height-100,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            children: [
              DialogTitle(title: 'T E N A N T S'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tap on any user send request to commence co-lease ',
                          style: TextStyle(color: secondaryColor, fontSize: 12)
                        ),
                        TextSpan(
                          text: widget.unit.title,
                          style: TextStyle(color: reverse, fontSize: 12)
                        )
                      ]
                    )
                ),
              ),
              Expanded(child: DialogAddCoTenant(unit:widget.unit, entity: widget.entity, tenants: _tenants,))
            ],
          );
        });
  }
  void dialogRemoveTenant(BuildContext context, UserModel user){
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width: 450,
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
                          text: "Are you certain you want to remove ",
                          style: TextStyle(color: secondaryColor, ),
                        ),
                        TextSpan(
                          text: "${user.username} ",
                        ),
                        TextSpan(
                          text: "as a co-tenant of Unit ",
                          style: TextStyle(color: secondaryColor, ),
                        ),
                        TextSpan(
                          text: "${widget.unit.title}'s ",
                        ),
                      ]
                  )
              ),
              DoubleCallAction(
                  titleColor: Colors.red,
                  title: "Remove",
                  action: (){
                    Navigator.pop(context);
                    _remove(user);
                  }
              )
            ],
          ),
        ),
      );
    });
  }

  void _remove(UserModel user)async{
    List<UnitModel> _unit = [];
    List<LeaseModel> _lease = [];
    List<PaymentsModel> _payments = [];
    List<String> uniqueUnit = [];
    List<String> uniqueLease = [];
    List<String> uniquePay = [];
    
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    
    setState(() {
      loading = user.uid;
    });
    await Services.removeUnitTid(widget.unit.id.toString(), user.uid).then((response)async{
      print("Response ${response}");
      if(response=="success"){
        await Services.removeLeaseCtid(widget.lease.lid, user.uid).then((value){
          print("Value ${value}");
          
          if(value=="success"){
            List<String> _tids = [];
            List<String> _ctids = [];
            _tids = widget.unit.tid.toString().split(",");
            _ctids = widget.lease.ctid.toString().split(",");
            _tids.remove(user.uid);
            _ctids.remove(user.uid);

            _unit.firstWhere((test) => test.id==widget.unit.id).tid = _tids.join(",");
            _lease.firstWhere((test) => test.lid==widget.lease.lid).ctid = _ctids.join(",");
            _payments.firstWhere((test) => test.lid==widget.lease.lid).tid = _ctids.join(",");

            uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
            uniqueLease = _lease.map((model) => jsonEncode(model.toJson())).toList();
            uniquePay = _payments.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myunit', uniqueUnit);
            sharedPreferences.setStringList('mylease', uniqueLease);
            sharedPreferences.setStringList('mypay', uniquePay);
            myUnits = uniqueUnit;
            myLease = uniqueLease;
            myPayment = uniquePay;
            _users.remove(user);
            widget.reload();
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${user.username} was removed successfully"),
                  showCloseIcon: true,
                )
            );
            setState(() {
              loading = "";
            });
          } else if(value=="error"){
            setState(() {
              loading = "";
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("${user.username} was not removed. Please try again"),
                showCloseIcon: true,
              )
            );
          } else {
            setState(() {
              loading = "";
            });
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(Data().failed),
                  showCloseIcon: true,
                )
            );
          }
        });
      }else{
        setState(() {
          loading = "";
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
      }
    });

  }
  void _updateCount(){}
  void _changeMess(MessModel messModel){}
  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
