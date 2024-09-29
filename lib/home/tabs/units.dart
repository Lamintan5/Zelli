import 'dart:convert';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/profile_images/current_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../models/entities.dart';
import '../../models/units.dart';
import '../../views/unit/unit_profile.dart';
import '../../widgets/map_key.dart';
import '../../widgets/profile_images/user_profile.dart';

class Units extends StatefulWidget {
  const Units({super.key});

  @override
  State<Units> createState() => _UnitsState();
}

class _UnitsState extends State<Units> {
  TextEditingController _search = TextEditingController();
  List<UnitModel> _units = [];
  List<EntityModel> _entity = [];
  List<UserModel> _users = [];

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _users.add(currentUser);
    Future.delayed(Duration.zero).then((onValue){
      setState(() {

      });
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
    final cont2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _units.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _units;
    }
    return Scaffold(
      body: SafeArea(
          child:
          Column(
            children: [
              Row(
                children: [
                  Text('  ${_units.length} Units', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 10,),
              Container(
                width: 500,
                child: TextFormField(
                  controller: _search,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "🔎  Search for Units...",
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MapKeys(color: cont2, text: 'Occupied'),
                  MapKeys(color: CupertinoColors.systemBlue, text: 'Available'),
                  MapKeys(color: Colors.green, text: 'Prepaid'),
                  MapKeys(color: Colors.red, text: 'Accrual'),
                ],
              ),
              SizedBox(height: 10,),
              Expanded(
                  child: GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1
                      ),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index){
                        EntityModel entity = EntityModel(eid: "");
                        UnitModel unit = filteredList[index];
                        double _accrdAmount = 0;
                        double _prdAmount = 0;
                        final currentMonth = DateTime.now().month;
                        entity = _entity.firstWhere((element) => element.eid == unit.eid, orElse: ()=>EntityModel(eid: "", title: "", image: ""));
                        UserModel user = UserModel(uid: "");
                        user = _users.firstWhere((test) => test.uid == unit.tid!.split(",").first, orElse: ()=> UserModel(uid: ""));
                        void _removeTenant(){
                          unit.tid ="";
                          setState(() {
                          });
                        }
                        return InkWell(
                          onTap: (){
                             Get.to(()=> ShowCaseWidget(
                                    builder: (_) => UnitProfile(unit: unit, reload: _getData, removeTenant: _removeTenant, removeFromList: _removeFromList, user: UserModel(uid: ""), leasid: '',),
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                      })
              ),
            ],
          )
      ),
    );
  }
  void _removeFromList(String id){
    print("Removing Unit");
    _units.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }
}
