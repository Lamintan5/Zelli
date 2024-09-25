import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';

class DialogTerminate extends StatefulWidget {
  final UnitModel unit;
  final LeaseModel lease;
  final Function reload;
  const DialogTerminate({super.key, required this.unit, required this.lease, required this.reload});

  @override
  State<DialogTerminate> createState() => _DialogTerminateState();
}

class _DialogTerminateState extends State<DialogTerminate> {
  bool _loading = false;

  _terminate()async{
    List<UnitModel> _unit = [];
    List<LeaseModel> _lease = [];
    List<String> uniqueUnit = [];
    List<String> uniqueLease = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();

    setState(() {
      _loading = true;
    });
    await Services.updateUnitTid(widget.unit.id.toString(), "", "").then((response)async{
      print("Response $response");
      if(response=="success"){
        await Services.terminateLease(widget.lease.lid).then((value){
          print("Value $value");
          if(value=="success"){

            _unit.firstWhere((test)=>test.id==widget.unit.id).tid="";
            _unit.firstWhere((test)=>test.id==widget.unit.id).lid="";
            _lease.firstWhere((test)=>test.lid==widget.lease.lid).end=DateTime.now().toString();

            uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
            uniqueLease = _lease.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myunit', uniqueUnit);
            sharedPreferences.setStringList('mylease', uniqueLease);
            myUnits = uniqueUnit;
            myLease = uniqueLease;
            widget.reload();
            setState(() {
              _loading = false;
            });
            Navigator.pop(context);
          }
        });
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(
          thickness: 0.1,
          color: reverse,
        ),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                    onTap: (){Navigator.pop(context);},
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  )
              ),
              VerticalDivider(
                thickness: 0.1,
                color: reverse,
              ),
              Expanded(
                  child: InkWell(
                    onTap: _terminate,
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child:_loading
                            ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                            : Text(
                          "Terminate",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 15),
                          textAlign: TextAlign.center,),
                      ),
                    ),
                  )
              ),
            ],
          ),
        ),
      ],
    );
  }
}
