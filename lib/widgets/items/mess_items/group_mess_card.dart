import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/users.dart';
import '../../../resources/services.dart';
import '../../profile_images/user_profile.dart';


class GroupMessCard extends StatefulWidget {
  final MessModel messModel;
  const GroupMessCard({super.key, required this.messModel});

  @override
  State<GroupMessCard> createState() => _GroupMessCardState();

}

class _GroupMessCardState extends State<GroupMessCard> {
  UserModel user = UserModel(uid: "", image: "", username: "");
  List<UserModel> _user = [];

  _getDetails()async{
    setState(() {
      _getData();
    });
    _user = await Services().getCrntUsr(widget.messModel.sourceId.toString());
    await Data().addOrUpdateUserList(_user);
    _getData();
  }

  _getData(){
    user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere(
          (element) => element.uid == widget.messModel.sourceId.toString(), orElse: () => UserModel(uid: "", image: "", username: ""),
    );
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfile(image: user.image.toString(), radius: 15,),
            SizedBox(width: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: 300,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.username.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      widget.messModel.path!=""
                          ?InkWell(
                            onTap: (){
                             // Get.to(()=>MediaScreen(message: widget.messModel));
                            },
                            child: Hero(
                              tag: widget.messModel,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomLeft:  Radius.circular(10),
                                  bottomRight:  Radius.circular(10),
                                ),
                                child: CachedNetworkImage(
                                  cacheManager: customCacheManager,
                                  imageUrl: 'http://192.168.0.105:5000/uploads/${widget.messModel.path}',
                                  key: UniqueKey(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 200,
                                    width: 500,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "STUDIO5IVE",
                                        style: TextStyle(fontWeight: FontWeight.w100, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 200,
                                    width: 200,
                                    child: Center(
                                      child: Icon(Icons.error_outline_rounded, size: 50),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          :SizedBox(),
                      Text(
                        widget.messModel.message!,
                        textAlign: TextAlign.start,
                      ),
                      Text(DateFormat('hh:mm a').format(DateTime.parse(widget.messModel.time!)), style: TextStyle(fontSize: 11),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  static final customCacheManager = CacheManager(
      Config(
        'customCacheManager',
        maxNrOfCacheObjects: 1,
      )
  );
}
