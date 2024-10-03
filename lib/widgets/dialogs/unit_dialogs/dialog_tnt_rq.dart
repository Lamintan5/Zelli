import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/notifications.dart';
import '../../../models/users.dart';
import '../../../resources/services.dart';
import '../../../resources/socket.dart';

class DialogTntRq extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  const DialogTntRq({super.key, required this.entity, required this.unit});

  @override
  State<DialogTntRq> createState() => _DialogTntRqState();
}

class _DialogTntRqState extends State<DialogTntRq> {
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  List<String> _tokens = [];

  String nid = "";
  String message = "";

  bool _loading = false;

  _request()async{
    setState(() {
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _loading = true;
    });
    message = "${currentUser.username} has submitted a request to initiate leasing unit ${widget.unit.title}.";
    NotifModel notification = NotifModel(
      nid: nid,
      sid: currentUser.uid,
      rid: widget.entity.pid.toString().split(",").first,
      eid: widget.unit.eid!,
      pid: widget.unit.pid.toString(),
      text: "${widget.unit.id.toString()},${widget.unit.title.toString()}",
      message: message,
      actions: "",
      type: "TNTRQ",
      seen: "",
      deleted: "",
      checked: "true",
      time: "",
    );

    Services.addNotification(notification).then((response) {
      if(response=="Success"){
        _socketSend();
        setState(() {_loading = false;});
        Navigator.pop(context);
        Get.snackbar(
            'Success',
            'Request Sent Successfully',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.check, color: Colors.green,)
        );
      } else if(response=='Exists') {
        setState(() {_loading = false;});
        Get.snackbar(
            'Pending',
            'Request pending response from receiver...',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.watch_later, color: Colors.blue,)
        );
        Navigator.pop(context);
      } else if(response=='Failed') {
        setState(() {_loading = false;});
        Get.snackbar(
            'Failed',
            'Request was not sent please try again',
            shouldIconPulse: true,
            maxWidth: 500,
            icon: Icon(Icons.close, color: Colors.red,)
        );
      } else {
        setState(() {_loading = false;});
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
      "type":"TNTRQ",
      "actions":"",
      "text":"${widget.unit.id.toString()},${widget.unit.title.toString()}",
      "title": widget.entity.title,
      "token": _tokens,
      "profile": "${Services.HOST}logos/${widget.entity.image}",
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
        _tokens.addAll(user.token.toString().split(","));
        _tokens.remove("");
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
                    onTap: (){
                      if(!_loading){
                        _request();
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: SizedBox(height: 40,
                      child: Center(
                        child: _loading
                            ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: CupertinoColors.activeBlue,strokeWidth: 2,))
                            :Text(
                          "Request",
                          style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
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
