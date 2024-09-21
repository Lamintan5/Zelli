import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../models/duties.dart';
import '../../../models/duty.dart';
import '../../../resources/services.dart';
import '../../../widgets/items/item_duties.dart';

class Permissions extends StatefulWidget {
  final DutiesModel duties;
  final EntityModel entity;
  final UserModel user;
  final Function reload;
  const Permissions({super.key, required this.entity, required this.duties, required this.reload, required this.user});

  @override
  State<Permissions> createState() => _PermissionsState();
}

class _PermissionsState extends State<Permissions> {
  List<String> newDuties = [];
  String _dutiesString = "";
  String did = "";
  List<String> _dutiesList = [];
  bool _loading = false;


  _getDuties(){
    _dutiesString = widget.duties.duties.toString();
    _dutiesList = _dutiesString.split(",");
    newDuties = widget.duties.duties.toString().split(",");
    setState(() {
    });
  }

  _saveDuties(){
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    setState(() {
      _loading = true;
    });
    Services.updateDuties(widget.duties.did, newDuties).then((response){
      if(response=='success'){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dialogBg,
              content: Text("Duties Updated Successfully", style: TextStyle(color: reverse),),
            )
        );
        widget.reload();
        setState(() {
          _loading = true;
        });
      } else if(response=='failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("Duties was not updated", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("mmhm🤔 seems like something went wrong", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      }
    });
  }
  _addDuties(){
    final dialogBg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    setState(() {
      Uuid uuid = Uuid();
      did = uuid.v1();
      _loading = true;
      newDuties.remove("null");
    });
    Services.addDuties(did, widget.entity.eid, widget.user.uid, newDuties).then((response){
      if(response=='Success'){
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dialogBg,
              content: Text("Duties Updated Successfully", style: TextStyle(color: reverse),),
            )
        );
        widget.reload();
        setState(() {
          _loading = true;
        });
      } else if(response=='Failed'){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("Duties was not updated", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dialogBg,
                content: Text("mmhm🤔 seems like something went wrong", style: TextStyle(color: reverse),),
                action: SnackBarAction(label: "Try Again", onPressed: _saveDuties)
            )
        );
        setState(() {
          _loading = true;
        });
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDuties();
  }

  @override
  Widget build(BuildContext context) {
    bool isEqual = listsAreEqualIgnoringOrder(_dutiesList, newDuties);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(),
          Expanded(
            child: Container(
              width: 700,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   "Permissions",
                   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                 ),
                 SizedBox(height: 10,),
                 Expanded(
                     child: ListView.builder(
                         itemCount: Data().dutyList.length,
                         itemBuilder: (context, index){
                           DutyModel duty = Data().dutyList[index];
                           return ItemDuties(
                             duty: duty,
                             dutiesModel: widget.duties,
                             removeDuty: removeDuty,
                             addDuty: addDuty,
                           );
                         })

                 ),
               ],
              ),
            ),
          ),
          isEqual
              ? SizedBox()
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: MaterialButton(
              onPressed: (){
                if(widget.duties.did==""){
                  _addDuties();
                } else {
                  _saveDuties();
                }
              },
              child: _loading
                  ? SizedBox(width: 15,height: 15,child: CircularProgressIndicator(strokeWidth: 1,color: Colors.black,))
                  : Text("S A V E", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              color: CupertinoColors.activeBlue,
              elevation: 8,
              minWidth: 400,
              padding: EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          Text(
              Data().message,
            style: TextStyle(fontSize: 12, color: secondaryColor),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
  void removeDuty(String duty) {
    if (newDuties.isNotEmpty) {
      newDuties.remove(duty);
      setState(() {});
    }
  }
  void addDuty(String duty) {
    newDuties.add(duty);
    setState(() {});
  }

  bool listsAreEqualIgnoringOrder(List<String> list1, List<String> list2) {
    Set<String> set1 = Set.from(list1);
    Set<String> set2 = Set.from(list2);

    return set1.length == set2.length && set1.containsAll(set2);
  }
}
