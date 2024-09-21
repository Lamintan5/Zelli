import 'dart:convert';

import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/widgets/logo/prop_logo.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:Zelli/widgets/star_items/small_star.dart';
import 'package:Zelli/widgets/text/text_filed_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:line_icons/line_icon.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

import '../../../../main.dart';
import '../../../../models/entities.dart';
import '../../../../models/units.dart';
import '../../../../models/users.dart';
import '../../../../resources/services.dart';
import '../../../models/data.dart';
import '../../../models/notifications.dart';
import '../../../models/payments.dart';
import '../../../models/stars.dart';
import '../../../resources/socket.dart';
import '../../dialogs/dialog_title.dart';
import '../../shimmer_widget.dart';

class ItemMainReq extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final String from;
  const ItemMainReq(
      {super.key,
      required this.notif,
      required this.getEntity,
      required this.from});

  @override
  State<ItemMainReq> createState() => _ItemMainReqState();
}

class _ItemMainReqState extends State<ItemMainReq> {
  List<UserModel> _user = [];
  List<UserModel> _receivers = [];
  late UserModel sender;
  late UserModel reciver;
  List<EntityModel> _entity = [];
  List<UnitModel> _unit = [];
  List<String> pidListAsList = [];
  List<String> newEnty = [];
  String pidList = "";
  String uid = '';
  bool _accepting = false;
  bool rating = false;
  bool _rejecting = false;
  List<UserModel> _newUser = [];
  List<UserModel> _receiver = [];

  String message = "";
  List<String> _tokens = [];



  late TextEditingController _textEditingController;

  bool _isExpanded = false;
  final _key = GlobalKey<FormState>();

  NotifModel notifModel = NotifModel(nid: "");
  UnitModel unit = UnitModel(id: "", title: "");
  EntityModel entityModel = EntityModel(eid: "", title: "", image: "");

  _getDetails() async {
    _getData();
    // _unit = await Services().getMyUnits(currentUser.uid);
    // _entity = await Services().getOneEntity(widget.notif.eid.toString());
    // _newUser = await Services().getOneUser(widget.notif.sid!);
    // _user.add(_newUser.first);
    // await Future.forEach(widget.notif.pid!.split(","), (element) async {
    //   _receiver = await Services().getOneUser(element);
    //   reciver = _receiver.first;
    //   if (_user.any((user) => user.uid == element)) {} else {
    //     _user.add(reciver);
    //   }
    // });
    // await Data().addOrUpdateUserList(_user);
    // await Data().updateOrAddUnits(_unit);
    // await Data().updateOrAddEntity(_entity);
    _getData();
  }

  _getData() {
    _user =
        myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString)))
            .toList();
    unit =
        myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString)))
            .firstWhere((element) =>
        element.id == widget.notif.text!.split(',').last.trim(),
            orElse: () => UnitModel(id: "", title: "N/A", tid: ""));
    entityModel = myEntity.map((jsonString) =>
        EntityModel.fromJson(json.decode(jsonString))).firstWhere((
        element) => element.eid == widget.notif.eid,
        orElse: () => EntityModel(eid: "", title: ""));
    newEnty =
        _entity.map((entityModel) => jsonEncode(entityModel.toJson())).toList();
    sender = _user.firstWhere((element) => element.uid == widget.notif.sid,
        orElse: () => UserModel(uid: "", username: "", image: ""));
    _receivers =
        _user.where((element) => widget.notif.pid!.contains(element.uid) &&
            element.token != "").toList();
    _receivers.add(sender);
    _receivers.removeWhere((element) => element.uid == currentUser.uid);
    _receivers = _receivers.toSet().toList();
    _tokens = _receivers.map((e) => e.token.toString()).toList();
    setState(() {});
  }

  void _socketSend(String message, String title, String type, String text,
      String rate) {
    List<String> _pidList = widget.notif.pid!.split(",");
    _pidList.add(sender.uid);
    _pidList = _pidList.toSet().toList();
    SocketManager().socket.emit("notif", {
      "nid": widget.notif.nid,
      "sourceId": currentUser.uid,
      "targetId": sender.uid,
      "eid": widget.notif.eid,
      "pid": _pidList,
      "message": message,
      "time": DateTime.now().toString(),
      "type": "MNTNRQ",
      "text": text,
      "title": title,
      "actions": type,
      "token": _tokens,
      "profile": entityModel.image
    });
  }

  _actionUpdate(String action, String rate) async {
    final dilogbg = Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark ? Colors.white
        : Colors.black;
    NotifModel notification = NotifModel(
      nid: widget.notif.nid,
      text: widget.notif.text,
      type: widget.notif.type,
      actions: action,
    );
    setState(() {
      _accepting = true;
      message = rate != ''
          ? "${currentUser
          .username} has provided a ${rate} star rating for the ${widget.notif
          .text!.split(",").first} request"
          : "Kindly verify the attendance of ${currentUser
          .username} in response to the ${widget.notif.text!
          .split(",")
          .first}.";
    });
    // Services.updateNotification(notification).then((response) {
    //   if (response == 'success') {
    //     _socketSend(
    //         message,
    //         rate != ''
    //             ?"${currentUser.username} : ${widget.notif.text!.split(",").first}"
    //             :"${entityModel.title} : ${widget.notif.text!.split(",").first}",
    //         action,
    //         "${widget.notif.text},${widget.notif.nid}",
    //         rate);
    //     widget.getEntity();
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         backgroundColor: dilogbg,
    //         content: Text(
    //             rate != ''
    //                 ? 'Successfully rated ${rate} stars.'
    //                 : 'Request Completed Successfully. We have sent a prompt to ${sender
    //                 .username} to rate his or her experience during this action',
    //             style: TextStyle(
    //               color: reverse,
    //             )),
    //
    //       ),
    //     );
    //     setState(() {
    //       _accepting = false;
    //       widget.notif.actions = 'DONE';
    //     });
    //   } else if (response == 'failed') {
    //     setState(() {
    //       _accepting = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         backgroundColor: dilogbg,
    //         content: Text(
    //           'Action was not modified',
    //           style: TextStyle(
    //             color: reverse,
    //           ),
    //         ),
    //         action: SnackBarAction(
    //           onPressed: _actionUpdate(action, ""),
    //           label: 'Try Again',
    //         ),
    //       ),
    //     );
    //   } else {
    //     setState(() {
    //       _accepting = false;
    //     });
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         backgroundColor: dilogbg,
    //         content: Text('mmhmm🤔 something went wrong.',
    //             style: TextStyle(
    //               color: reverse,
    //             )),
    //       ),
    //     );
    //   }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _textEditingController = TextEditingController();
    notifModel = widget.notif;
    _getDetails();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final reverse = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bold =
    TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: reverse);
    final style = TextStyle(fontSize: 13, color: reverse);
    return Form(
      key: _key,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Card(
        margin: EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(notifModel.text!.split(",").first, style: TextStyle(color: secondaryColor),),
                      Expanded(child: SizedBox()),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        hoverColor: color1,
                        borderRadius: BorderRadius.circular(5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: 5),
                            Text(timeago.format(DateTime.parse(notifModel.time.toString())), style: TextStyle(fontSize: 13)),
                            SizedBox(width: 5),
                            AnimatedRotation(
                              duration: Duration(milliseconds: 500),
                              turns: _isExpanded ? 0.5 : 0.0,
                              child: Icon(Icons.keyboard_arrow_down),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.notif.sid != currentUser.uid
                          ? UserProfile(image: sender.image!, radius: 20,)
                          : PropLogo(entity: entityModel, radius: 20),
                      SizedBox(width: 15,),
                      Expanded(
                        child: sender.uid == ""
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerWidget.rectangular(width: 100, height: 10),
                            SizedBox(height: 5,),
                            ShimmerWidget.rectangular(width: double.infinity, height: 10),
                            SizedBox(height: 5,),
                            ShimmerWidget.rectangular(width: double.infinity, height: 10),
                          ],
                        )
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sender.username.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: reverse),),
                            widget.notif.actions == ""
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: widget.notif.sid != currentUser.uid
                                        ? sender.username.toString()
                                        : "",
                                    style: bold),
                                TextSpan(
                                    text: widget.notif.sid != currentUser.uid
                                        ? ' submitted a request for assistance regarding a '
                                        : 'Thank you for submitting a request regarding ',
                                    style: style),
                                TextSpan(
                                    text: widget.notif.text!.split(',').first,
                                    style: bold),
                                TextSpan(text: " for unit ", style: style),
                                TextSpan(text: unit.title, style: bold),
                                TextSpan(
                                    text: widget.notif.sid != currentUser.uid
                                        ? '. Kindly address and resolve this matter promptly.'
                                        : ' We appreciate your patience as our property managers work to address and provide feedback on this matter.',
                                    style: style),
                              ]),
                            )
                                : widget.notif.actions == "DONE"
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: <TextSpan>[
                                TextSpan(text: "The ", style: style),
                                TextSpan(
                                    text: widget.notif.text!
                                        .split(',')
                                        .first
                                        .toString(),
                                    style: bold),
                                TextSpan(text: " for unit ", style: style),
                                TextSpan(text: unit.title, style: bold),
                                TextSpan(text: " requested by ", style: style),
                                TextSpan(text: sender.username, style: bold),
                                TextSpan(
                                    text: widget.notif.sid != currentUser.uid
                                        ? " has been successfully addressed and resolved. Kindly await the tenant's feedback."
                                        : ' has been successfully addressed and resolved. We value your feedback; please take a moment to rate your experience below.',
                                    style: style),
                              ]),
                            )
                                : widget.notif.actions!.split(",").first == "RATED"
                                ? RichText(
                              maxLines: _isExpanded?100:1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: DefaultTextStyle
                                      .of(context)
                                      .style,
                                  children: [
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? sender.username.toString()
                                            : "",
                                        style: bold),
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? ' responded with a '
                                            : 'We appreciate your positive feedback. If you have any further concerns or requests, feel free to let us know. Thank you.',
                                        style: style),
                                    WidgetSpan(
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 15,
                                        )),
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? "${widget.notif.actions!
                                            .split(",")
                                            .last} Star"
                                            : "",
                                        style: bold),
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? ' rating for the  '
                                            : '',
                                        style: style),
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? widget.notif.text!
                                            .split(',')
                                            .first
                                            : "",
                                        style: bold),
                                    TextSpan(
                                        text: widget.notif.sid !=
                                            currentUser.uid
                                            ? ' request'
                                            : "",
                                        style: style),
                                  ]),
                            )
                                : SizedBox(),
                          ],
                        ),
                      ),
                      SizedBox(width: 15,),
                    ],
                  ),
                  AnimatedSize(
                    duration: Duration(milliseconds: 500),
                    alignment: Alignment.topCenter,
                    curve: Curves.easeInOut,
                    child: _isExpanded
                        ? Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: Column(
                        children: [
                          widget.notif.sid != currentUser.uid
                              ? widget.notif.actions == ""
                              ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _textEditingController,
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      filled: true,
                                      isDense: true,
                                      fillColor: color1,
                                      hintText: "Enter amount spent (not compulsory)",
                                      hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.w400, fontSize: 13),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    ),
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
                                SizedBox(width: 5,),
                                InkWell(
                                  onTap: (){
                                    final form = _key.currentState!;
                                    if(form.validate()) {

                                    }
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    width: 120,
                                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                        color: color1,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: color1, width: 1)
                                    ),
                                    child: Center(child: Text("Done")),
                                  ),
                                )
                              ]
                          )
                              : SizedBox()
                              : SizedBox(),
                          widget.notif.actions == "DONE" &&
                              widget.notif.sid == currentUser.uid
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                  initialRating: 0,
                                  minRating: 0.0,
                                  direction: Axis.horizontal,
                                  allowHalfRating: true,
                                  itemCount: 5,
                                  glowColor: Colors.amber,
                                  unratedColor: color2,
                                  itemSize: 30.0,
                                  itemPadding:
                                  EdgeInsets.symmetric(horizontal: 5.0),
                                  itemBuilder: (context, _) =>
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                  onRatingUpdate: (rating) {
                                    print(rating);
                                    _rate(rating);
                                  }),
                              rating
                                  ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 2,
                                  ))
                                  : SizedBox()
                            ],
                          ):SizedBox(),


                        ],
                      ),
                    ) : SizedBox(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            entityModel.eid ==""
                                ? ShimmerWidget.rectangular(width: 100, height: 10, borderRadius: 5,)
                                : Container(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: color1, width: 0.5)
                              ),
                              child: Text(entityModel.title.toString(), style: TextStyle(fontSize: 11),),
                            ),
                            unit.id ==""
                                ? ShimmerWidget.rectangular(width: 100, height: 10, borderRadius: 5,)
                                : Container(
                                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: color1,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: color1, width: 0.5)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    LineIcon.box(color: secondaryColor,size: 12,),
                                    SizedBox(width: 5,),
                                    Text(unit.title.toString(), style: TextStyle(fontSize: 11),),
                                  ],
                                )
                            ),
                            widget.notif.actions!.split(",").first == "RATED"
                                ? Container(
                                padding: EdgeInsets.symmetric(vertical: 3, horizontal: 10),
                                decoration: BoxDecoration(
                                    color: color1,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: color1, width: 0.5)
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(CupertinoIcons.star_fill, size: 12,color: secondaryColor,),
                                    SizedBox(width: 5,),
                                    Text( "${widget.notif.actions!.split(",").last} Star", style: TextStyle(fontSize: 11),),
                                  ],
                                )
                            ) : SizedBox()

                          ],
                        ),
                      ),
                      PopupMenuButton(
                          icon: Icon(CupertinoIcons.ellipsis),
                          padding: EdgeInsets.all(0),
                          itemBuilder: (context){
                            return [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.delete),
                                    SizedBox(width: 10,),
                                    Text("Delete")
                                  ],
                                ),
                                onTap: (){
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.ellipses_bubble),
                                    SizedBox(width: 10,),
                                    Text("Message")
                                  ],
                                ),
                                onTap: (){
                                  // Platform.isIOS || Platform.isAndroid
                                  //     ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user,), transition: Transition.rightToLeft)
                                  //     : Get.to(() => WebChat(selected: user,), transition: Transition.rightToLeft);;
                                },
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(CupertinoIcons.phone),
                                    SizedBox(width: 10,),
                                    Text("Call")
                                  ],
                                ),
                                onTap: (){

                                },
                              ),
                            ];
                          })
                    ],
                  )
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                      children: [
                        widget.notif.actions == "DONE" &&
                            widget.notif.sid == currentUser.uid
                            ? Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ),
                          child: Divider(
                            thickness: 1,
                            height: 1,
                            color: color2,
                          ),
                        )
                            : SizedBox(),
                        widget.notif.actions == "DONE" &&
                            widget.notif.sid == currentUser.uid
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RatingBar.builder(
                                initialRating: 0,
                                minRating: 0.0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                glowColor: Colors.amber,
                                unratedColor: color2,
                                itemSize: 30.0,
                                itemPadding:
                                EdgeInsets.symmetric(horizontal: 5.0),
                                itemBuilder: (context, _) =>
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                onRatingUpdate: (rating) {
                                  print(rating);
                                  _rate(rating);
                                }),
                            rating
                                ? SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                  strokeWidth: 2,
                                ))
                                : SizedBox()
                          ],
                        )
                            : SizedBox(),
                      ],
                    )),
              ],
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }

  _rate(double rate) {
    final dgcolor = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    String action = "RATED,${rate}";
    _actionUpdate(action, "${rate}");
    String sid = "";
    setState(() {
      Uuid uuid = Uuid();
      sid = uuid.v1();
      rating = true;
    });
    StarModel star = StarModel(
      sid: sid,
      rid: "",
      eid: entityModel.eid,
      pid: entityModel.pid,
      uid: currentUser.uid,
      rate: rate.toString(),
      type: "MNTNCE",
    );
    // Services.addMntncStar(star).then((response) {
    //   print(response);
    //   if (response == "Exists") {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         backgroundColor: dgcolor,
    //         content: Text(
    //           "Rating already exists",
    //           style: TextStyle(color: reverse),
    //         )));
    //   } else if (response == "Success") {} else if (response == "Failed") {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: dgcolor,
    //       content: Text(
    //         "Rating failed.",
    //         style: TextStyle(color: reverse),
    //       ),
    //       action: SnackBarAction(
    //         label: "Try again",
    //         onPressed: () {
    //           _rate(rate);
    //         },
    //       ),
    //     ));
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //       backgroundColor: dgcolor,
    //       content: Text(
    //         "mhmm 🤔 seems like something went wrong.",
    //         style: TextStyle(color: reverse),
    //       ),
    //       action: SnackBarAction(
    //         label: "Try again",
    //         onPressed: () {
    //           _rate(rate);
    //         },
    //       ),
    //     ));
    //   }
    //   setState(() {
    //     rating = false;
    //   });
    // });
  }

  void dialogRecordExp(BuildContext context, String title) {
    final dialogBg = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme
        .of(context)
        .brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
              ),
              child: SizedBox(width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'R E C O R D  E X P E N S E'),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "Have you incurred any expenses in responding to the $title request? Kindly specify the expenses below.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryColor),
                      ),
                    ),
                    // DialogRecordExp(
                    //   addPay: _addPay,
                    //   updatePay: _updatePay,
                    //   unit: unit,
                    //   entity: entityModel,
                    //   title: title, updateAction: _actionUpdate,
                    //   from: 'NOTIFICATION',
                    // ),
                    SizedBox(height: 10,)
                  ],
                ),
              ),
            ));
  }

  void _updatePay(String payid) {
  }

  void _addPay(PaymentsModel paymentsModel, double paid, String account) {

  }
}
