import 'dart:convert';

import 'package:Zelli/resources/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/units.dart';
import '../buttons/call_actions/double_call_action.dart';

class DialogAddUnit extends StatefulWidget {
  final Function reload;
  final EntityModel entity;
  final int floor;
  const DialogAddUnit({super.key, required this.reload, required this.entity, required this.floor});

  @override
  State<DialogAddUnit> createState() => _DialogAddUnitState();
}

class _DialogAddUnitState extends State<DialogAddUnit> {
  TextEditingController _title = TextEditingController();
  TextEditingController _rent = TextEditingController();
  TextEditingController _deposit = TextEditingController();
  List<UnitModel> unitsList = [];
  bool _adding = false;
  int roomNo = 0;
  final formKey = GlobalKey<FormState>();

  List<String> _newUnits = [];
  String id = "";


  _addUnit()async{
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    DateTime now = DateTime.now();
    Uuid uuid = Uuid();
    id = uuid.v1();
    UnitModel unitModel = UnitModel(
        id: id,
        pid: widget.entity.pid.toString(),
        eid: widget.entity.eid,
        tid: "",
        lid: "",
        tenant: "",
        accrual: "",
        prepaid: "",
        price: _rent.text.trim(),
        room: roomNo.toString(),
        floor: widget.floor.toString(),
        deposit: _deposit.text.trim(),
        status: "",
        title: _title.text.trim(),
        time: now.toString(),
        checked :  "false"
    );
    if(!_unit.any((test)=>test.id==id)){
      _unit.add(unitModel);
    }
    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
    widget.reload();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Unit added to units list"),
          showCloseIcon: true,
        )
    );

    await Services.addUnits(unitModel).then((response){
      print(response);
      if(response=="Success"){
        _unit.firstWhere((test) => test.id==unitModel.id).checked = "true";
        uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myunit', uniqueUnit);
        myUnits = uniqueUnit;
        widget.reload();
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _title,
            keyboardType: TextInputType.text,
            maxLines: 1,
            minLines: 1,
            decoration: InputDecoration(
              label: Text("Unit Title"),
              fillColor: color1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(5)
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
            onChanged:  (value) => setState((){}),
            validator: (value){
              if(value!.isEmpty || value==""){
                return "Please enter unit title";

              }
            },
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Text(roomNo == 0 ? "  Studio" : " ${roomNo} Bedroom"),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: (){
                    setState(() {
                      if(roomNo >0){
                        roomNo--;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Icon(Icons.remove_circle),
                ),
                SizedBox(width: 5,),
                InkWell(
                    onTap: (){
                      setState(() {
                        roomNo++;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Icon(Icons.add_circle)
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rent,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Rent"),
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  onChanged:  (value) => setState((){}),
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }

                    if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return null;
                    } else {
                      return 'Please enter a valid number with only one decimal point.';
                    }

                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TextFormField(
                  controller: _deposit,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Deposit"),
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  onChanged:  (value) => setState((){}),
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }

                    if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return null;
                    } else {
                      return 'Please enter a valid number with only one decimal point.';
                    }
                  },
                ),
              ),
            ],
          ),
          DoubleCallAction(
              action: (){
                final form = formKey.currentState!;
                if(form.validate()) {
                  _addUnit();
                }
              })
        ],
      ),
    );
  }
}