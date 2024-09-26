import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../models/notifications.dart';
import '../../models/users.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../buttons/call_actions/double_call_action.dart';
import '../profile_images/user_profile.dart';
import 'dialog_title.dart';

class DialogAddCoTenant extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  final List<String> tenants;
  const DialogAddCoTenant({super.key, required this.unit, required this.entity, required this.tenants});

  @override
  State<DialogAddCoTenant> createState() => _DialogAddCoTenantState();
}

class _DialogAddCoTenantState extends State<DialogAddCoTenant> {
  late TextEditingController _search;

  List<UserModel> _users = [];

  bool _loading = false;
  bool _isLoading = false;

  DateTime date = DateTime.now();

  String nid = '';
  String message = '';

  _getUsers()async{
    setState(() {
      _loading = true;
    });
    _users = await Services().getAllUsers();
    _users = _users.where((usr) => !widget.tenants.contains(usr.uid)).toList();
    setState(() {
      _loading = false;
    });
  }

  _request(UserModel user)async{
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
      type: "RQCOTNT",
      seen: "",
      deleted: "",
      checked: "true",
      time: DateTime.now().toString(),
    );
    Services.addNotification(notification).then((response) {
      if(response=="Success"){
        _socketSend(user);
        setState(() {_isLoading = false;});
        Navigator.pop(context);
        Get.snackbar(
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.check, color: Colors.green,)
        );
      } else if(response=='Exists') {
        setState(() {_isLoading = false;});
        Get.snackbar(
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.watch_later, color: Colors.blue,)
        );
        Navigator.pop(context);
      } else if(response=='Failed') {
        setState(() {_isLoading = false;});
        Get.snackbar(
            'Failed',
            Data().failed,
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.close, color: Colors.red,)
        );
      } else {
        setState(() {_isLoading = false;});
        Get.snackbar(
            'Error',
            Data().failed,
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.error, color: Colors.red,)
        );
      }
    });

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
      "type":"RQCOTNT",
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
    _search = TextEditingController();
    _getUsers();
    message = "${currentUser.username} has sent you a request to commence co-leasing ${widget.unit.title} at ${widget.entity.title}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _users.forEach((item) {
        if (item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _users;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "🔎  Search for Tenants...",
              hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
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
          SizedBox(height: 10,),
          _loading
              ? Center(child: SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: color2,strokeWidth: 2,)))
              : Expanded(
            child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index){
                  UserModel user = filteredList[index];
                  return InkWell(
                    onTap: (){
                      dialogRequest(context, user);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5)
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
                        ],
                      ),
                    ),
                  );
                }),
          ),
          _isLoading? LinearProgressIndicator(backgroundColor: color1,color: reverse,) : SizedBox()
        ],
      ),
    );
  }
  void dialogRequest(BuildContext context, UserModel user){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width:450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "R E Q U E S T"),
              RichText(
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Send a request to ",
                          style: TextStyle(color: secondaryColor, fontSize: 13),
                        ),
                        TextSpan(
                          text:"${user.username} ",
                          style: TextStyle(color: reverse, fontSize: 13),
                        ),
                        TextSpan(
                          text: "to initiate co-leasing for this unit.",
                          style: TextStyle(color: secondaryColor, fontSize: 13),
                        ),
                      ]
                  )
              ),
              DoubleCallAction(action: (){
                Navigator.pop(context);
                _request(user);
              })
            ],
          ),
        ),
      );
    });
  }
}
