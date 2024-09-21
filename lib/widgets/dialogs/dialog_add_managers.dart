import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/notifications.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../buttons/call_actions/double_call_action.dart';
import '../profile_images/user_profile.dart';
import 'dialog_title.dart';

class DialogAddManagers extends StatefulWidget {
  final EntityModel entity;
  const DialogAddManagers({super.key, required this.entity});

  @override
  State<DialogAddManagers> createState() => _DialogAddManagersState();
}

class _DialogAddManagersState extends State<DialogAddManagers> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _user = [];
  bool _loading = false;
  bool _isLoading = false;
  List<String> pidList = [];
  String nid = "";
  String message = "";

  _getManagers()async{
    setState(() {
      _loading = true;
    });
    pidList = widget.entity.pid.toString().split(",");
    _user = await Services().getAllUsers();
    _user = _user.where((usr) => !pidList.contains(usr.uid)).toList();
    setState(() {
      _loading = false;
    });
  }
  _addManager(UserModel user)async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _isLoading = true;
    });
    NotifModel notification = NotifModel(
      nid: nid,
      sid: currentUser.uid,
      rid: user.uid,
      eid: widget.entity.eid,
      pid: widget.entity.pid.toString(),
      text: "",
      message: message,
      actions: "",
      type: "RQMNG",
      seen: "",
      deleted: "",
      checked: "true",
      time: "",
    );
    Services.addNotification(notification).then((response) {
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
      "type":"RQMNG",
      "actions":"",
      "text":"",
      "title": widget.entity.title,
      "token": user.token.toString().split(","),
      "profile": "${Services.HOST}logos/LEGO_logo.svg.png",
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getManagers();
    message = "${currentUser.username} has submitted a request for you to begin managing ${widget.entity.title} as the designated manager.";
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
          TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "🔎  Search for Property Managers...",
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
              ? Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: color2,)))
              : Expanded(
            child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index){
                  UserModel user = filteredList[index];
                  return InkWell(
                    onTap: (){
                      dialogSendRequest(context, user);
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
  void dialogSendRequest(BuildContext context, UserModel user) {
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
                              text: "inorder to commence managing ",
                              style: style
                          ),
                          TextSpan(
                              text: "${widget.entity.title}.",
                              style: bold
                          ),

                        ]
                    )
                ),
                DoubleCallAction(action: (){
                  Navigator.pop(context);
                  _addManager(user);
                })
              ],
            ),
          ),
        ),
      );
    });
  }
}
