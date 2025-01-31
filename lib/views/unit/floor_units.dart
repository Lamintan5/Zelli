import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/views/unit/activities/add_unit.dart';
import 'package:Zelli/views/unit/unit_profile.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../../widgets/dialogs/dialog_add_unit.dart';
import '../../widgets/grid.dart';
import '../../widgets/profile_images/user_profile.dart';

class FloorUnits extends StatefulWidget {
  final int floor;
  final EntityModel entity;
  final Function reload;
  const FloorUnits({super.key, required this.floor, required this.entity, required this.reload});

  @override
  State<FloorUnits> createState() => _FloorUnitsState();
}

class _FloorUnitsState extends State<FloorUnits> {
  TextEditingController _search = TextEditingController();

  final currentMonth = DateTime.now().month;

  List<UnitModel> _units = [];

  String floorNumber = '';

  bool isFilled = false;
  
  _getData()async{
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    setState(() {
      if(widget.floor == 0){
        setState(() {
          floorNumber = "Ground Floor";
        });
      } else {
        setState(() {
          floorNumber = "Floor ${widget.floor.toString()}";
        });
      }
      widget.reload();
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
        ? Colors.white12
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    List<UnitModel> filteredList = [];
    filteredList.clear();
    if (_search.text.isNotEmpty) {
      _units.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase())) {
          filteredList.add(item);
        }
      });
    } else {
      filteredList = List.from(_units); // Create a copy of the _units list to avoid direct reference issues
    }
    setState(() {});

    return Scaffold(
      appBar: AppBar(
        title: Text('Units under ${floorNumber}'),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.filter_list))
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Row(),
            Expanded(
              child: Container(
                width: 800,
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(width: 500,
                      child: TextFormField(
                        controller: _search,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: "Search",
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          isDense: true,
                          hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                          prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
                          prefixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 30
                          ),
                          suffixIcon: isFilled?InkWell(
                              onTap: (){
                                _search.clear();
                                setState(() {
                                  isFilled = false;
                                });
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Icon(Icons.cancel, size: 20,color: secondaryColor)
                          ) :SizedBox(),
                          suffixIconConstraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 30
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                        ),
                        onChanged: (value) => setState(() {
                          if(value.isNotEmpty){
                            isFilled = true;
                          } else {
                            isFilled = false;
                          }
                        }),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Expanded(
                        child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 120,
                                childAspectRatio: 3 / 2,
                                crossAxisSpacing: 1,
                                mainAxisSpacing: 1
                            ),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index){
                              UnitModel unit = filteredList[index];
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
                                        : Positioned(
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
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: widget.entity.pid!.contains(currentUser.uid)? FloatingActionButton.extended(
          onPressed: (){
            Get.to(() => AddUnit(entity: widget.entity, reload: _getData, floor: widget.floor),transition: Transition.rightToLeft);
          },
          elevation: 5,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
          backgroundColor: CupertinoColors.systemBlue,
          icon: Icon(Icons.add_circle),
          label: Text('Unit')
      ) : SizedBox(),
    );
  }
  void _removeFromList(String id){
    print("Removing Unit");
    _units.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }
  _removeTenant(){
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
               DialogTitle(title: "A D D  U N I T S"),
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
  

}
