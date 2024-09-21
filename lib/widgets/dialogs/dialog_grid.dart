import 'dart:ui';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/views/unit/unit_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../main.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../views/unit/unit_profile_page.dart';

class DialogGrid extends StatefulWidget {
  final List<UnitModel> units;
  final UserModel user;
  final EntityModel entity;

  const DialogGrid({super.key, required this.units, required this.user, required this.entity});

  @override
  State<DialogGrid> createState() => _DialogGridState();
}

class _DialogGridState extends State<DialogGrid> {
  List<UnitModel> _units = [];

  void _removeFromList(String id){
    print("Removing Unit");
    _units.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }
  void _removeTenant(){

  }

  void _getUnit(){}

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _units = widget.units;
  }

  @override
  Widget build(BuildContext context) {

    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 120,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1
        ),
        itemCount: _units.length,
        itemBuilder: (context, index){
          UnitModel unit = _units[index];
          double _accrdAmount = 0;
          double _prdAmount = 0;
          return InkWell(
            onTap: (){
              unit.tid == currentUser.uid
                   ? Get.to(()=> ShowCaseWidget(
                    builder:  (_) => UnitProfilePage(unit: unit, entity: widget.entity,),
                  ), transition: Transition.rightToLeft)
                  : Get.to(()=> ShowCaseWidget(
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

                unit.checked == "false"
                    ?Positioned(
                    bottom: 0,
                    right: 5,
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      size: 20,color: Colors.red,
                    )
                )
                    : SizedBox()
              ],
            ),
          );
        });
  }
}
