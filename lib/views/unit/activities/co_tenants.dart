import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';

import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../home/tabs/payments.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../utils/colors.dart';
import '../../../widgets/buttons/bottom_call_buttons.dart';
import '../../../widgets/dialogs/dialog_add_co_tenant.dart';
import '../../../widgets/dialogs/dialog_title.dart';

class CoTenants extends StatefulWidget {
  final UnitModel unit;
  final LeaseModel lease;
  const CoTenants({super.key, required this.unit, required this.lease});

  @override
  State<CoTenants> createState() => _CoTenantsState();
}

class _CoTenantsState extends State<CoTenants> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _users = [];
  List<String> _tenants = [];

  String selectedUid = "";

  _getData(){
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _tenants.addAll(widget.unit.tid.toString().split(","));
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
                  child: Icon(Icons.add),
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
                        return Column(
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
                                            BottomCallButtons(
                                                onTap: () {

                                                },
                                                icon: Icon(CupertinoIcons.person_badge_minus,
                                                    color: secondaryColor),
                                                actionColor: secondaryColor,
                                                backColor: Colors.transparent,
                                                title: "Remove"
                                            ),
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
                        );
                  }),
                )
            )
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
              Expanded(child: DialogAddCoTenant(unit:widget.unit))
            ],
          );
        });
  }

  void _updateCount(){}
  void _changeMess(MessModel messModel){}
  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
