import 'dart:convert';

import 'package:Zelli/models/payments.dart';
import 'package:Zelli/widgets/grid.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../main.dart';
import '../models/data.dart';
import '../models/entities.dart';
import '../models/units.dart';
import '../models/users.dart';
import '../resources/services.dart';
import '../utils/colors.dart';
import '../views/unit/activities/add_unit.dart';
import '../views/unit/floor_units.dart';
import '../views/unit/unit_profile.dart';
import 'dialogs/dialog_add_unit.dart';
import 'dialogs/dialog_title.dart';
// import '../views/units/floor_units.dart';
// import 'grid.dart';


class ExpandFloor extends StatefulWidget {
  final int floor;
  final String title;
  final EntityModel entity;
  const ExpandFloor({super.key, required this.floor, required this.title, required this.entity});

  @override
  State<ExpandFloor> createState() => _ExpandFloorState();
}

class _ExpandFloorState extends State<ExpandFloor> {
  List<UnitModel> _unitList = [];
  List<UnitModel> _newUnits = [];
  List<PaymentsModel> _newPay = [];
  int available = 0;
  final currentPeriod = DateTime.now();

  _getUnits()async {
    // _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    //
    // available = _unitList.where((element) => element.tid == "").toList().length;
    // _newPay =  !widget.entity.pid!.contains(currentUser.uid)
    //     ? await Services().getPayByTenant(currentUser.uid)
    //     : await Services().getCrrntPay(currentUser.uid);
    // Data().updateOrAddPay(_newPay);
    // _newUnits = await Services().getAllUnits(currentUser.uid);
    // await Data().checkAndUploadUnits(_updateUnit);
    // await Data().updateOrAddUnits(_newUnits);
    // setState(() {
    //   _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    //   available = _unitList.where((element) => element.tid == "").toList().length;
    //
    // });
  }


  _getData(){
    _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    available = _unitList.where((element) => element.tid == "").toList().length;
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }


  void _removeFromList(String id){
    _unitList.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }

  void _updateUnitData(UnitModel unitModel){
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).title = unitModel.title;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).room = unitModel.room;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).price = unitModel.price;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).deposit = unitModel.deposit;
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
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    DateTime now = DateTime.now();
    DateTime desiredDate =  DateTime(now.year, now.month, 5);
    DateTime nextMonth = DateTime(desiredDate.year, desiredDate.month + 1, desiredDate.day);
    if (nextMonth.month > 12) {
      nextMonth = DateTime(desiredDate.year + 1, 1, desiredDate.day);
    }
    return ExpandablePanel(
      theme: ExpandableThemeData(iconColor: color),
      header: Text(
        widget.floor == 0 ? 'Ground Floor' : "Floor ${widget.floor}",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      collapsed: _unitList.length == 0
          ? Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Finish setting up units under this floor', style: TextStyle(color: secondaryColor),),
          SizedBox(width: 10,),
          MaterialButton(
            onPressed: (){
              Get.to(() => AddUnit(entity: widget.entity, reload: _getData, floor: widget.floor),transition: Transition.rightToLeft);
            },
            height: 0,minWidth: 0,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: Text('Continue', style: TextStyle(fontSize: 11),),
            color: CupertinoColors.systemBlue,)
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //${DateFormat('yyyy-MM-dd').format(nextMonth)}
          Text("${available} Available", style: TextStyle( color: secondaryColor),),
          TextButton(
            onPressed: (){Get.to(()=>FloorUnits(floor: widget.floor, entity: widget.entity, reload: _getUnits,), transition: Transition.rightToLeftWithFade);
            },

            child: Text('Sell All ${_unitList.length} Units',
            ),
          )
        ],
      ),
      expanded: Column(
        children: [
          _unitList.length == 0
              ?  Center(
            child: Container(
              height: 200,
              width: 410,
              margin: EdgeInsets.symmetric(vertical: 10),
              child: DottedBorder(
                color: color,
                borderType: BorderType.RRect,
                dashPattern: [5, 5, 5, 5],
                radius: Radius.circular(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Create Units', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                    Text('You have no unit entitled to this floor. Wish to add new units😉? Click create to get started',  textAlign: TextAlign.center,),
                    SizedBox(height: 10,),
                    MaterialButton(
                      onPressed: (){
                        Get.to(() => AddUnit(entity: widget.entity, reload: _getData, floor: widget.floor),transition: Transition.rightToLeft);
                      },

                      child: Text('Create'),color: Colors.blueAccent,),
                  ],
                ),
              ),
            ),
          )
              : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 120,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1
              ),
              itemCount: _unitList.length < 20? _unitList.length : 20,
              itemBuilder: (context, index){
                UnitModel unit = _unitList[index];
                double _accrdAmount = 0;
                double _prdAmount = 0;
                var user = unit.tid == ""
                    ? UserModel(uid: "", image: "")
                    : (myUsers
                    .map((jsonString) => UserModel.fromJson(json.decode(jsonString)))
                    .firstWhere(
                      (element) => element.uid == unit.tid!.split(",").first,
                  orElse: () => UserModel(uid: "", image: ""), // Provide a default value
                ));

                return InkWell(
                  onTap: (){
                    Get.to(()=> ShowCaseWidget(
                      builder: (_) => UnitProfile(unit: unit, reload: _getData, removeTenant: _removeTenant, removeFromList: _removeFromList, user: UserModel(uid: ""), leasid: '', entity: widget.entity,),
                    ), transition: Transition.rightToLeft);
                  },
                  borderRadius: BorderRadius.circular(5),
                  splashColor: CupertinoColors.activeBlue,
                  child: Stack (
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: color1,
                              width: 1
                          ),
                          color: unit.tid == ''
                              ? CupertinoColors.activeBlue
                              : _accrdAmount > 0.0
                              ?Colors.red
                              : _prdAmount > 0.0
                              ? Colors.green
                              : color1,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                            child: Text(unit.title.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            )
                        ),
                      ),
                      unit.tid == ""
                          ? SizedBox()
                          :Positioned(
                          right: 5,
                          bottom: 5,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                  ? Icon(CupertinoIcons.delete, color: Colors.red,size: 20,)
                                  : unit.checked.toString().contains("EDIT")
                                  ? Icon(Icons.edit, color: Colors.red,size: 20,)
                                  : unit.checked == "false"
                                  ? Icon(Icons.cloud_upload, color: Colors.red,size: 20,)
                                  : SizedBox(),
                              SizedBox(width: 3,),
                              user.uid==""
                                  ? SizedBox()
                                  : UserProfile(image: user.image.toString(), radius: 10,)
                            ],
                          )
                      ),
                    ],
                  ),
                );
              }),
          _unitList.length == 0
              ?  SizedBox()
              :  widget.entity.pid!.contains(currentUser.uid)
              ?  Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              _unitList.length > 20
                  ? TextButton(
                  onPressed: (){
                    Get.to(()=>FloorUnits(floor: widget.floor, entity: widget.entity, reload: _getData,), transition: Transition.rightToLeftWithFade);
                  },
                  child: Text('See All ${_unitList.length} Units')
              )
                  : SizedBox(),
              IconButton(onPressed: (){
                Get.to(()=>FloorUnits(floor: widget.floor, entity: widget.entity, reload: _getData,), transition: Transition.rightToLeftWithFade);
              },
                  tooltip: "View all units",
                  icon: Icon(CupertinoIcons.square_grid_2x2)),
              IconButton(
                  onPressed: (){
                    Get.to(() => AddUnit(entity: widget.entity, reload: _getData, floor: widget.floor),transition: Transition.rightToLeft);
                  },
                  tooltip: "Add unit",
                  icon: Icon(CupertinoIcons.add_circled)
              ),
            ],
          )
              :  SizedBox()
        ],
      ),
    );
  }
  void dialogAddUnit(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "A D D  U N I T"),
                Text(
                  'Please provide the unit details in the fields below to add a new unit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor),
                ),
                DialogAddUnit(reload: _getData, entity: widget.entity, floor: widget.floor)
              ],
            ),
          ),
        ),
      );
    });
  }
  _removeTenant(){
  }
}


