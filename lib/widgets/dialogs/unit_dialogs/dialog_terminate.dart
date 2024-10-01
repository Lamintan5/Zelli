import 'dart:convert';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/notifications.dart';
import '../../../models/users.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';

class DialogTerminate extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  final Function reload;
  final UserModel tenant;
  const DialogTerminate({super.key, required this.unit, required this.lease, required this.reload, required this.tenant, required this.entity});

  @override
  State<DialogTerminate> createState() => _DialogTerminateState();
}

class _DialogTerminateState extends State<DialogTerminate> {
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];

  DateTime _dateTime = DateTime.now();

  String nid = "";
  String message = "";

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
  _send()async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _loading = true;
      message = "${currentUser.username} has submitted a lease termination notice for unit ${widget.unit.title}, with a planned vacate date of ${DateFormat.yMMMEd().format(_dateTime)}.";
    });
    NotifModel notification = NotifModel(
      nid: nid,
      sid: currentUser.uid,
      rid: widget.unit.pid.toString().split(",").first,
      eid: widget.unit.eid!,
      pid: widget.unit.pid.toString(),
      text: "${widget.unit.id.toString()},${widget.unit.title.toString()}",
      message: message,
      actions: "",
      type: "TRMLEASE",
      seen: "",
      deleted: "",
      checked: "true",
      time: "",
    );

    Services.addNotification(notification).then((response) {
      if(response=="Success"){
        _socketSend();
        Navigator.pop(context);
        Get.snackbar(
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.check, color: Colors.green,)
        );
      } else if(response=='Exists') {
        Get.snackbar(
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.watch_later, color: Colors.blue,)
        );
        Navigator.pop(context);
      } else if(response=='Failed') {
        Get.snackbar(
            'Failed',
            'Request was not sent please try again',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.close, color: Colors.red,)
        );
      } else {
        Get.snackbar(
            'Error',
            Data().failed,
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.error, color: Colors.red,)
        );
      }
    });
    setState(() {_loading = false;});
  }

  void _socketSend() async{
    List<String> _pidList = widget.entity.pid!.split(",");
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":widget.unit.pid.toString().split(",").first,
      "eid":widget.entity.eid,
      "pid":_pidList,
      "message":message,
      "time":DateTime.now().toString(),
      "type":"RQTNT",
      "actions":"",
      "text":"${widget.unit.id.toString()},${widget.unit.title.toString()}",
      "title": widget.entity.title,
      "token": _users.map((test)=>test.token).toList(),
      "profile": "${Services.HOST}logos/LEGO_logo.svg.png",
    });
  }


  _getData(){
    setState(() {
      _loading = true;
    });
    widget.unit.pid.toString().split(",").forEach((pid)async{
      _newUsers = await Services().getCrntUsr(pid);
      UserModel user = _newUsers.first;
      if(!_users.any((test) => test.uid==pid)){
        _users.add(user);
        setState(() {
          _loading = false;
        });
      }
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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.tenant.uid == currentUser.uid
            ?  Text(
                "Would you like to terminate this lease? Please provide the date you wish to vacate the unit. ",
                style: TextStyle(color: secondaryColor),
                textAlign: TextAlign.center,
              )
            :  RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
                children: [
                  TextSpan(
                    text: "Are you certain you want to proceed with terminating ",
                    style: TextStyle(color: secondaryColor, ),
                  ),
                  TextSpan(
                    text: "${widget.tenant.username}'s ",
                  ),
                  TextSpan(
                    text: "lease for this unit?",
                    style: TextStyle(color: secondaryColor, ),
                  ),
                ]
            )
        ),
        InkWell(
          onTap: _showDatePicker,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: BoxDecoration(
                color: _dateTime.isBefore(justToday)?Colors.red.withOpacity(0.5):color1,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: color1,
                    width: 1
                )
            ),
            child: Row(
              children: [
                Expanded(
                    child: Center(
                        child: Text(
                          DateFormat.yMMMd().format(_dateTime),
                        )
                    )
                ),
                Icon(CupertinoIcons.calendar)
              ],
            ),
          ),
        ),
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
                    onTap: (){
                      if(!_loading){
                        if(widget.tenant.uid == currentUser.uid){

                        } else {
                          _terminate();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child:_loading
                            ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                            : Text(
                              widget.tenant.uid == currentUser.uid? "Continue" : "Terminate",
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 15),
                              textAlign: TextAlign.center,
                            ),
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
  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    ).then((value) {
      setState(() {
        _dateTime = value!;
      });
    });
  }
}
