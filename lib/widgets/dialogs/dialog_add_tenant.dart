import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/notifications.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../models/lease.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../profile_images/user_profile.dart';
import 'dialog_title.dart';

class DialogAddTenant extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  final Function getUnits;
  final Function(String) onUpdateTid;
  const DialogAddTenant({super.key, required this.unit, required this.entity, required this.getUnits, required this.onUpdateTid});

  @override
  State<DialogAddTenant> createState() => _DialogAddTenantState();
}

class _DialogAddTenantState extends State<DialogAddTenant> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _user = [];
  List<UnitModel> _units = [];
  List<UnitModel> _filtUnits = [];
  bool _loading = false;
  bool _isLoading = false;
  bool isFilled = false;
  DateTime date = DateTime.now();
  String nid = '';
  String message = '';

  _getTenants()async{
    setState(() {
      _loading = true;
    });
    _user = await Services().getAllUsers();
    // _tenant = await Services().getAllTenants();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    setState(() {
      _user = _user.where((element) => element.uid != "" && element.uid != currentUser.uid).toList();
      _user.shuffle();
      _loading = false;
    });
  }
  _addTenant(UserModel user)async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _isLoading = true;
    });
    NotifModel notification = NotifModel(
        nid: nid,
        sid: currentUser.uid,
        rid: user.uid,
        eid: widget.unit.eid!,
        pid: widget.unit.pid.toString(),
        text: "${widget.unit.id.toString()},${widget.unit.title.toString()}",
        message: message,
        actions: "",
        type: "RQTNT",
        seen: "",
        deleted: "",
        checked: "true",
        time: "",
    );

    Services.addNotification(notification, null).then((response) {
      if(response=="Success"){
        _socketSend(user);
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
    setState(() {_isLoading = false;});
  }
  void _socketSend(UserModel user) async{
    List<String> _pidList = widget.entity.pid!.split(",");
    _pidList.add(user.uid);
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":user.uid,
      "eid":widget.entity.eid,
      "pid":_pidList,
      "message":message,
      "time":DateTime.now().toString(),
      "type":"RQTNT",
      "actions":"",
      "text":"${widget.unit.id.toString()},${widget.unit.title.toString()}",
      "title": widget.entity.title,
      "token": user.token.toString().split(","),
      "profile": "${Services.HOST}logos/LEGO_logo.svg.png",
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getTenants();
    message = "${currentUser.username} has sent you a request to commence leasing ${widget.unit.title} at ${widget.entity.title} as a tenant.";
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DialogTitle(title: "A D D  T E N A N T"),
          Text(
            'To lease this unit, please select a tenant from the list below. If the tenant is not listed, kindly instruct them to complete the tenant registration process.',
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
          SizedBox(height: 8,),
          TextFormField(
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
          SizedBox(height: 10,),
          _isLoading
              ? LinearProgressIndicator(color: revers,minHeight: 1,)
              : SizedBox(),
          _loading
              ? Center(child: CircularProgressIndicator(color: revers,))
              : Expanded(
            child: ListView.builder(
                itemCount: _search.text.isEmpty? filteredList.length < 20? filteredList.length : 20 : filteredList.length,
                itemBuilder: (context, index){
                  UserModel user = filteredList[index];
                  _filtUnits = _units.where((element) => element.tid.toString().split(",").contains(user.uid) && element.eid == widget.unit.eid).toList();
                  return  InkWell(
                    onTap: (){
                      dialogSelectedTenant(context, user);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          UserProfile(image: user.image!),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.username.toString()),
                                Text('${user.firstname} ${user.lastname}', style: TextStyle(color: secondaryColor, fontSize: 12),),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _filtUnits.isEmpty
                                  ? Text('Not Leasing',
                                style: TextStyle(color: secondaryColor, fontSize: 11, fontStyle: FontStyle.italic),
                              )
                                  : Text('Leasing',
                                style: TextStyle(color: secondaryColor, fontSize: 11, fontStyle: FontStyle.italic),
                              ),

                              Wrap(
                                runSpacing: 3,
                                spacing: 3,
                                children: _filtUnits.map((element){
                                  return Container(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text(element.title.toString(), style: TextStyle(fontSize: 12, color: secondaryColor),),
                                  );
                                }).toList(),
                              )

                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
  void dialogSelectedTenant(BuildContext context, UserModel user) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, color: revers);
    showDialog(context: context, builder: (context){
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "R E Q U E S T"),
                RichText(
                  textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Send a request to ",
                          style: style
                        ),
                        TextSpan(
                          text: "${user.username} ",
                          style: bold
                        ),
                        TextSpan(
                            text: "inorder to commence his/her leasing.",
                            style: style
                        ),
                      ]
                    )
                ),
                DoubleCallAction(action: (){_addTenant(user);})
              ],
            ),
          ),
        ),
      );
    });
  }
}
