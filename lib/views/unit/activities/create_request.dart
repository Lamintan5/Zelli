import 'dart:io';
import 'dart:math';

import 'package:Zelli/models/request.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/widgets/text/text_filed_input.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../auth/camera.dart';
import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/notifications.dart';
import '../../../models/users.dart';
import '../../../resources/services.dart';
import '../../../resources/socket.dart';
import '../../../widgets/dialogs/dialog_title.dart';


class CreateRequest extends StatefulWidget {
  final RequestModel request;
  final EntityModel entity;
  final UnitModel unit;
  const CreateRequest({super.key, required this.request, required this.entity, required this.unit});

  @override
  State<CreateRequest> createState() => _CreateRequestState();
}

class _CreateRequestState extends State<CreateRequest> {
  final ScrollController _horizontal = ScrollController();
  late TextEditingController _comment;
  var pickedImage;
  final picker = ImagePicker();


  List<String> _pidList = [];
  List<String> _admins = [];
  List<String> _tokens = [];

  UserModel target = UserModel(uid: "");

  File? _image;

  bool loading = false;
  bool _isLoading = false;

  String nid = "";
  String message = "";
  String text = "";

  _getUsers(){
    _pidList = widget.entity.pid!.split(",");
    _pidList.forEach((pid)async{
      var _user = await Services().getCrntUsr(pid);
      _tokens.add(_user.first.token.toString());
      _tokens.remove("");
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _comment = TextEditingController();
    _getUsers();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _comment.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.request.text),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                controller: _horizontal,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                          shrinkWrap: true,
                          controller: _horizontal,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.request.types?.length,
                          itemBuilder: (context,index){
                            String content = widget.request.types![index];
                            return  Container(
                              margin: EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '●',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor)
                                  ),
                                  SizedBox(width: 5,),
                                  Expanded(
                                    child: RichText(
                                        text: TextSpan(
                                            children: [
                                              TextSpan(
                                                  text: '${content.split(":").first} :',
                                                  style: TextStyle(fontWeight: FontWeight.bold, color: secondaryColor)
                                              ),
                                              TextSpan(
                                                  text: content.split(":").last,
                                                  style: TextStyle(color: secondaryColor)
                                              ),
                                            ]
                                        )
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      SizedBox(height: 10,),
                      Text("Add images (Optional)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                      SizedBox(height: 5,),
                      Row(
                        children: [
                          _image == null
                              ? InkWell(
                            onTap: (){
                              dialogSelectImage(context);
                            },
                            splashColor: CupertinoColors.activeBlue,
                            borderRadius: BorderRadius.circular(10),
                            hoverColor: color1,
                            child: DottedBorder(
                                borderType: BorderType.RRect,
                                color: reverse,
                                radius: Radius.circular(5),
                                dashPattern: [5,5],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: SizedBox(width: 80,height: 80,
                                    child: Icon(Icons.add, color: CupertinoColors.activeBlue),
                                  ),
                                )
                            ),
                          )
                              : SizedBox(width: 90,height: 90,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Container(
                                        width: 80,height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(5),
                                          image: DecorationImage(image: FileImage(_image!))
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0, right: 0,
                                        child: InkWell(
                                            onTap: (){
                                              choiceImage();
                                            },
                                            child: Icon(Icons.change_circle))),
                                    Positioned(
                                        top: 0, left: 0,
                                        child: InkWell(
                                            onTap: (){
                                              setState(() {
                                                _image = null;
                                              });
                                            },
                                            child: Icon(Icons.cancel))),
                                  ],
                                ),
                              )
                        ],
                      ),
                      _image==null?SizedBox():Text(_image!.path),
                      SizedBox(height: 20,),
                      Text("Additional Comments (Optional)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),),
                      SizedBox(height: 5,),
                      TextFieldInput(
                        textEditingController: _comment,
                        hintText: 'Write your comment here',
                        maxLine: 5,
                        maxLength: 250,
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            InkWell(
              onTap: (){
                _request();
              },
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: 450,
                margin: EdgeInsets.symmetric(horizontal: 10),
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(5)
                ),
                child: Center(
                    child: _isLoading
                        ? SizedBox(
                            width: 15, height:15 ,
                            child:  CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                        )
                        : Text(
                          "Continue",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                        )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _request()async{
    setState(() {
      message = "${currentUser.username} has submitted ${widget.request.text} Request. Please review the details at your earliest convenience to proceed with the necessary actions.";
      text = '${widget.request.id},${widget.unit.id},${_comment.text.trim()}';
      Uuid uuid = Uuid();
      nid = uuid.v1();
      _isLoading = true;
    });
    NotifModel notification = NotifModel(
      nid: nid,
      sid: currentUser.uid,
      rid: widget.entity.admin!.split(",").first,
      eid: widget.entity.eid,
      pid: widget.entity.pid.toString(),
      text: text,
      message: message,
      actions: "",
      type: "REQUEST",
      seen: "",
      deleted: "",
      checked: "true",
      time: DateTime.now().toString(),
    );
    Services.addNotification(notification, _image).then((response) {
      if(response=="Success"){
        _socketSend();
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
  void _socketSend() async{
    String path = '${Services.HOST}uploads/${_image!.path.contains("/")?_image!.path.split("/").last:_image!.path.split("\\").last}';
    SocketManager().socket.emit("notif", {
      "nid": nid,
      "sourceId":currentUser.uid,
      "targetId":widget.entity.admin!.split(",").first,
      "eid":widget.entity.eid,
      "pid":_pidList,
      "message":message,
      "time":DateTime.now().toString(),
      "type":"REQUEST",
      "actions":"",
      "text":text,
      "title": widget.entity.title,
      "token": _tokens,
      "profile": "${Services.HOST}logos/${currentUser.image}",
      "path": _image==null?"":path,
    });
  }


  void dialogSelectImage(BuildContext context){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    showDialog(
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(title: "M E D I A"),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      choiceImage();
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.photo),
                          SizedBox(width: 10,),
                          Text("Gallery")
                        ],
                      ),
                    ),
                  ),
                  Platform.isAndroid || Platform.isIOS
                      ? InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      Get.to(()=>CameraScreen(setPicture: _setPicture,), transition: Transition.downToUp);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.camera),
                          SizedBox(width: 10,),
                          Text("Camera")
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  _image != null
                      ? InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      setState(() {
                        _image = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.remove),
                          SizedBox(width: 10,),
                          Text("Remove Photo")
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ), context: context
    );
  }
  Future choiceImage() async {
    setState(() {
      loading = true;
    });
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
      loading = false;
    });
  }
  _setPicture(File? image){
    setState(() {
      _image = image;
    });
  }
}
