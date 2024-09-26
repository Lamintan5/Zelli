import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/tabs/payments.dart';
import 'package:Zelli/main.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../home/actions/chat/message_screen.dart';
import '../../../home/actions/chat/web_chat.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/payments.dart';
import '../../../models/lease.dart';
import '../../../models/units.dart';
import '../../../models/users.dart';
import '../../../widgets/buttons/bottom_call_buttons.dart';
import '../../../widgets/buttons/call_actions/single_call_action.dart';
import '../../../widgets/dialogs/dialog_grid.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/text/text_format.dart';
import '../../unit/unit_profile.dart';
import '../../unit/unit_profile_page.dart';

class Leases extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  const Leases({super.key, required this.entity, required this.unit, required this.lease});

  @override
  State<Leases> createState() => _LeasesState();
}

class _LeasesState extends State<Leases> {
  late TextEditingController _search;
  List<LeaseModel> _leases = [];
  List<UserModel> _user = [];
  List<UnitModel> _units = [];
  List<PaymentsModel> _pay = [];
  List<PaymentsModel> _filtPay = [];

  List<String> admin = [];

  String expanded = "";
  bool _loading = false;

  double amount = 0;
  int units = 0;

  _getDetails(){
    _getData();
  }

  _getData(){
    admin = widget.entity.admin.toString().split(",");
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _leases = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    _units = _units.where((test) => test.eid == widget.entity.eid).toList();
    _pay = _pay.where((test){
      bool matchesEid = widget.entity.eid.isEmpty || test.eid == widget.entity.eid;
      bool matchesUid = widget.unit.id.toString().isEmpty || test.uid == widget.unit.id;
      bool matchesRevenue = test.type!.split(",").first != "EXP";
      return matchesEid && matchesUid && matchesRevenue;
    }).toList();
    _leases = _leases.where((test){
      bool matchesEid = widget.entity.eid.isEmpty || test.eid == widget.entity.eid;
      bool matchesUid = widget.unit.id.toString().isEmpty || test.uid!.split(",").first == widget.unit.id.toString();
      // bool matchesEnd = widget.unit.id.toString().isEmpty || test.end != "";
      return matchesEid  && matchesUid;
    }).toList();
    _user = _user.where((test) => _leases.any((element) => element.tid == test.uid)).toList();
    // _leases.forEach((e){
    //   print("LID:${e.lid}, TID:${e.tid}, UID:${e.uid}");
    // });
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = TextEditingController();
    _getDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final color3 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white38
        : Colors.black38;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _user.forEach((item) {
        if (item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _user;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Leases"),
      ),
      body: Column(
        children: [
          Row(),
          Container(
            width: 500,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: TextFormField(
              controller: _search,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "🔎 Search for tenants...",
                hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                fillColor: color1,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
              ),
              onChanged: (text) => setState(() {}),
            ),
          ),
          Expanded(
            child: SizedBox(width: 1000,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index){
                    UserModel user = filteredList[index];

                    List<LeaseModel> _filtTenant = _leases.where((e) => e.tid == user.uid).toList();
                    List<UnitModel> _filtUnt = _units.isEmpty? [] : _units.where((u) => _filtTenant.any((t) => t.uid == u.id)).toList();
                    _filtPay = _pay.where((p) => p.tid == user.uid).toList();
                    amount = _filtPay.fold(0.0, (previous, element) => previous + double.parse(element.amount.toString()));
                    units = _filtUnt.length;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0,),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if(expanded.contains(user.uid)){
                                  expanded = "";
                                } else {
                                  expanded = user.uid;
                                }
                              });
                            },
                            hoverColor: color1,
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                              child: Row(
                                children: [
                                  UserProfile(image: user.image.toString()),
                                  SizedBox(width: 10,),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user.username.toString()),
                                        Text(
                                          '${user.firstname} ${user.lastname} ',
                                          style: TextStyle(color: secondaryColor, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Text(
                                        admin.contains(user.uid)? "Admin" : "",
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
                                          _filtTenant.length < 2? SizedBox() :Container(
                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                            decoration: BoxDecoration(
                                                color: color1,
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(CupertinoIcons.doc_text ,size: 12,color: secondaryColor,),
                                                SizedBox(width: 5,),
                                                Text('${_filtTenant.length} leases', style: TextStyle(fontSize: 11, color: secondaryColor),)
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
                                  user.uid==currentUser.uid
                                      ? SizedBox()
                                      : AnimatedRotation(
                                    duration: Duration(milliseconds: 500),
                                    turns: expanded == user.uid ? 0.5 : 0.0,
                                    child: Icon(Icons.keyboard_arrow_down, color: secondaryColor,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          user.uid==currentUser.uid
                              ?  SizedBox()
                              :  AnimatedSize(
                            duration: Duration(milliseconds: 500),
                            alignment: Alignment.topCenter,
                            curve: Curves.easeInOut,
                            child: expanded ==user.uid
                                ? Column(
                              children: [
                                SizedBox(height: 5,),
                                IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      BottomCallButtons(
                                          onTap: () {
                                            dialogLeases(context, user, _filtTenant);
                                          },
                                          icon: Icon(CupertinoIcons.doc_text ,
                                              color: secondaryColor),
                                          actionColor: secondaryColor,
                                          backColor: Colors.transparent,
                                          title: "Leases"
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
                                            Get.to(()=>Payments(eid: widget.entity.eid, unitid: widget.unit.id.toString(), tid: user.uid, lid: widget.lease.lid,),transition: Transition.rightToLeft);
                                          },
                                          icon: LineIcon.wallet(color: secondaryColor,),
                                          actionColor: secondaryColor,
                                          backColor: Colors.transparent,
                                          title: "Payments"),
                                      widget.unit.id.toString().isEmpty?Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        child: VerticalDivider(
                                          thickness: 1,
                                          width: 15,
                                          color: secondaryColor,
                                        ),
                                      ) : SizedBox(),
                                      widget.unit.id.toString().isEmpty?BottomCallButtons(
                                          onTap: () {
                                            _filtUnt.length == 1
                                                ? Get.to(()=> ShowCaseWidget(
                                              builder: (context) => UnitProfile(unit: _filtUnt.first,  reload: _getData, removeTenant: _removeTenant, removeFromList: _removeFromList, user: user, leasid: '',),
                                            ), transition: Transition.rightToLeft)
                                                : dialogChooseUnit(context, _filtUnt, user);
                                          },  
                                          icon: Icon(units==1?Icons.crop_square:CupertinoIcons.square_grid_2x2, color: secondaryColor),
                                          actionColor: secondaryColor,
                                          backColor: Colors.transparent,
                                          title: units==1? "Unit" : "Units"
                                      ) : SizedBox(),
                                      Platform.isAndroid || Platform.isIOS ? Padding(
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
                          ),
                        ],
                      ),
                    );

              }),
            ),
          ),
        ],
      ),
    );
  }
  void dialogChooseUnit(BuildContext context, List<UnitModel> units, UserModel user) {
    showDialog(context: context, builder: (context){
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
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
                DialogGrid(units: units, user: user, entity: widget.entity,),
                SingleCallAction()
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogLeases(BuildContext context, UserModel user, List<LeaseModel> leases){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    showDialog(context: context, builder: (context){
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: SizedBox(width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "L E A S E S"),
                Text(
                  'Select a lease item to view detailed information.',
                  style: TextStyle( color: secondaryColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5,),
                ListView.builder(
                    shrinkWrap: true,
                    itemCount: leases.length,
                    itemBuilder: (context, index){
                      LeaseModel lease = leases[index];
                      UserModel user = _user.firstWhere((test) => test.uid == lease.tid, orElse: ()=>UserModel(uid: ""));
                      UnitModel unit = _units.firstWhere((test) => test.id == lease.uid!.split(",").first, orElse: ()=> UnitModel(id: "", title: ""));
                      return Padding(
                        padding: EdgeInsets.only(bottom: 5), 
                        child: InkWell(
                          onTap: (){
                            if(widget.lease.lid==lease.lid && lease.end == ""){

                            } else {
                              Get.to(() =>  ShowCaseWidget(
                                builder:  (_) => UnitProfile(unit: unit, reload: (){}, removeTenant: (){}, removeFromList: (){}, user: user, leasid: lease.lid,),
                              ), transition: Transition.rightToLeft);
                            }
                          },
                          borderRadius: BorderRadius.circular(5),
                          hoverColor: color1,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: color1,
                                  child: Icon(CupertinoIcons.doc_text, color: reverse,),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${lease.lid.split("-").first.toUpperCase()}, ${unit.title.toString()}"),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                            decoration: BoxDecoration(
                                                color: color1,
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Text("Start : ${DateFormat.yMMMEd().format(DateTime.parse(lease.start.toString()))}" , style: TextStyle(fontSize: 11, color: secondaryColor),),
                                          ),
                                          lease.end.toString().isEmpty? SizedBox() : Container(
                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                            decoration: BoxDecoration(
                                                color: color1,
                                                borderRadius: BorderRadius.circular(5)
                                            ),
                                            child: Text("End : ${DateFormat.yMMMEd().format(DateTime.parse(lease.end.toString()))}" , style: TextStyle(fontSize: 11, color: secondaryColor),),
                                          ),
                                        ],
                                      )

                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                }),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _updateCount(){}
  void _changeMess(MessModel messModel){}
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
  _callNumber(String number) async{
    await FlutterPhoneDirectCaller.callNumber(number);
  }
}
