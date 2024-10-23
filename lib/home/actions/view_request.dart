import 'dart:convert';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/notifications.dart';
import 'package:Zelli/models/request.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../resources/services.dart';

class ViewRequest extends StatefulWidget {
  final NotifModel notif;
  const ViewRequest({super.key, required this.notif});

  @override
  State<ViewRequest> createState() => _ViewRequestState();
}

class _ViewRequestState extends State<ViewRequest> {
  NotifModel notifModel = NotifModel(nid: "");
  RequestModel request = RequestModel(id: "", text: "", message: "");
  EntityModel entityModel = EntityModel(eid: "");
  UnitModel unitmodel = UnitModel();
  UserModel sender = UserModel(uid: "");

  List<UserModel> _user = [];

  _getData(){
    notifModel = widget.notif;
    request = Data().requests.firstWhere((test) => test.id == notifModel.text.toString().split(",").first, orElse: () =>
        RequestModel(id: "", text: "", message: ""));
    entityModel = myEntity.map((jsonDecode) => EntityModel.fromJson(json.decode(jsonDecode))).firstWhere((test) =>
    test.eid == notifModel.eid, orElse: () => EntityModel(eid: "", title: 'N/A', image: ''));
    unitmodel = myUnits.map((jsonDecode) => UnitModel.fromJson(json.decode(jsonDecode))).firstWhere((test) =>
    test.id == notifModel.text.toString().split(",")[1], orElse: ()=> UnitModel(id: "", title: 'N/A'));
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _user.add(currentUser);
    sender = _user.firstWhere((element) => element.uid == notifModel.sid, orElse: () => UserModel(uid: "", username: "", image: ""));
    setState(() {

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
    return Scaffold(
      appBar: AppBar(
        title: Text(request.text),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${sender.username} ',
                        style: TextStyle(fontWeight: FontWeight.w800,color: secondaryColor)
                      ),
                      TextSpan(
                        text: 'commented : ${notifModel.text.toString().split(",").last}',
                        style: TextStyle(color: secondaryColor)
                      )
                    ]
                  )
              ),
              SizedBox(height: 10),
              CachedNetworkImage(
                cacheManager: customCacheManager,
                imageUrl: '${Services.HOST}uploads/${notifModel.image}',
                key: UniqueKey(),
                fit: BoxFit.cover,
                imageBuilder: (context, imageProvider) => Container(
                  width: double.infinity,
                  constraints: BoxConstraints(
                    minHeight: 100,
                    maxHeight: 400,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      "S T U D I O 5 I V E",
                      style: TextStyle(
                        fontWeight: FontWeight.w100,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  child: Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
