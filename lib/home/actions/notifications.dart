import 'dart:convert';

import 'package:Zelli/main.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/data.dart';
import '../../models/notifications.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../../widgets/items/notificationsitems/item_main_req.dart';
import '../../widgets/items/notificationsitems/item_notif.dart';
import '../../widgets/items/notificationsitems/item_req_tnt.dart';
import '../../widgets/items/notificationsitems/item_tnt_rq.dart';

class Notifications extends StatefulWidget {
  final Function reload;
  final Function updateCount;
  final String eid;
  const Notifications({super.key, required this.reload, required this.updateCount, required this.eid});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;
  final socketManager = Get.find<SocketManager>();
  List<NotifModel> _notifs = [];
  String eid = "";

  _getDetatils()async{
    _getData();
    await Data().checkNotifications(_notifs, (){});
    _getData();
    // _notifs.forEach((e){
    //   print("Nid:${e.nid}, Seen:${e.seen}, Checked:${e.checked}");
    // });
  }

  _getData()async{
    _notifs = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    eid = widget.eid;
    _getDetatils();

  }

  @override
  Widget build(BuildContext context) {
    final socketManager = Get.find<SocketManager>();
    List<NotifModel> mynotifs = socketManager.notifications;


    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications',),
      ),
      body: Column(
        children: [
          Row(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 450,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Obx((){
                          mynotifs = eid==""
                              ? mynotifs
                              : mynotifs.where((test) => test.eid == eid).toList();

                          if (mounted && _key.currentState != null) {
                            int itemIndex = 0;
                            if (itemIndex >= 0 && itemIndex <= mynotifs.length) {
                              _key.currentState!.insertItem(itemIndex, duration: Duration(milliseconds: 800));
                            } else {

                            }
                          }
                          void _remove(NotifModel notif){
                            mynotifs.removeWhere((test) => test.nid == notif.nid);
                          }

                          return AnimatedList(
                            key: _key,
                            controller: _scrollcontroller,
                            initialItemCount: mynotifs.length,
                            itemBuilder: (context, index, animation) {
                              NotifModel notification = NotifModel(nid: "");
                              if (index >= 0 && index < mynotifs.length) {
                                int newIndex = mynotifs.length - 1 - index;
                                notification = mynotifs[newIndex];
                              }
                              return FadeTransition(
                                opacity: animation,
                                child: SizeTransition(
                                  key: UniqueKey(),
                                  sizeFactor: animation,
                                  child: notification.type == 'RQMNG'
                                      ? ItemNotif(
                                        notif: notification,
                                        getEntity: widget.reload,
                                        from:  eid!=""?"Entity":'Notification', remove: _remove
                                      )
                                      : notification.type == 'RQTNT'
                                      ? ItemReqTnt(notif: notification, getEntity: widget.reload, from: eid!=""?"Entity":'Notification', remove: _remove,)
                                      : notification.type == 'TNTRQ'
                                      ? ItemTntRq(notif: notification, getEntity: widget.reload, from:  eid!=""?"Entity":'Notification')
                                      :notification.type == 'MNTNRQ'
                                      ? ItemMainReq(notif: notification, getEntity: widget.reload, from:  eid!=""?"Entity":'Notification')
                                      : SizedBox(),
                                ),
                              );
                            },
                          );
                        })
                    )
                  ],
                ),
              ),
            ),
          ),
          Text(
            Data().message,
            style: TextStyle(color: secondaryColor, fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
