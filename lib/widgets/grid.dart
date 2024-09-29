import 'dart:convert';
import 'dart:ui';

import 'package:Zelli/main.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../models/entities.dart';
import '../models/payments.dart';
import '../models/units.dart';
import '../models/users.dart';
import '../utils/colors.dart';
import '../views/unit/floor_units.dart';
import '../views/unit/unit_profile.dart';
import 'dialogs/dialog_add_unit.dart';

class GridUnits extends StatefulWidget {
  final Function getUnits;
  final String title;
  final EntityModel entity;
  final int floor;
  const GridUnits({super.key, required this.title, required this.floor, required this.entity, required this.getUnits});

  @override
  State<GridUnits> createState() => _GridUnitsState();
}

class _GridUnitsState extends State<GridUnits> {
  List<UnitModel> _unitList = [];
  List<UnitModel> _newUnits = [];
  bool _loading = false;
  final currentMonth = DateTime.now().month;
  List<PaymentsModel> _payList = [];
  List<PaymentsModel> _filterpay = [];

  _getUnit()async{
    // widget.getUnits();
    // _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    // _newUnits = await Services().getAllUnits(currentUser.uid);
    //
    // await Data().updateOrAddUnits(_newUnits);
    // setState(() {
    //   _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    // });
    _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUnit();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Column(
      mainAxisSize: MainAxisSize.min,
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
                      dialogAddUnit(context);
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
                    (element) => element.uid == unit.tid,
                orElse: () => UserModel(uid: "", image: ""), // Provide a default value
              ));

              return InkWell(
                onTap: (){
                  Get.to(()=> ShowCaseWidget(
                    builder: (_) => UnitProfile(unit: unit, reload: _getUnit, removeTenant: _removeTenant, removeFromList: _removeFromList, user: UserModel(uid: ""), leasid: '',),
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
                        child:UserProfile(radius: 10, image: user.image.toString(),)
                    ),
                    Positioned(
                        bottom: 5,
                        right: 5,
                        child: unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                            ? Icon(CupertinoIcons.delete, color: Colors.red,size: 20,)
                            : unit.checked.toString().contains("EDIT")
                            ? Icon(Icons.edit, color: Colors.red,size: 20,)
                            : unit.checked == "false"
                            ? Icon(Icons.cloud_upload, color: Colors.red,size: 20,)
                            : SizedBox()
                    )
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
                  Get.to(()=>FloorUnits(floor: widget.floor, entity: widget.entity, reload: _getUnit,), transition: Transition.rightToLeftWithFade);
                },
                child: Text('See All ${_unitList.length} Units')
            )
                : SizedBox(),
            IconButton(onPressed: (){
              Get.to(()=>FloorUnits(floor: widget.floor, entity: widget.entity, reload: _getUnit,), transition: Transition.rightToLeftWithFade);
            },
                tooltip: "View all units",
                icon: Icon(CupertinoIcons.square_grid_2x2)),
            IconButton(
                onPressed: (){dialogAddUnit(context);},
                tooltip: "Add unit",
                icon: Icon(CupertinoIcons.add_circled)
            ),
          ],
        )
            :  SizedBox()
      ],
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
                DialogAddUnit(reload: _getUnit, entity: widget.entity, floor: widget.floor)
              ],
            ),
          ),
        ),
      );
    });
  }

  _removeTenant(){
  }



  void _removeFromList(String id){
    print("Removing Unit");
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
}



