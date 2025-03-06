import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/billing.dart';
import 'package:Zelli/models/chats.dart';
import 'package:Zelli/models/duties.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/notifications.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/stars.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/resources/services.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../api/api_service.dart';
import '../models/data.dart';
import '../models/messages.dart';

class SocketManager extends GetxController  {
  late IO.Socket _socket;
  RxList<MessModel> messages = <MessModel>[].obs;
  RxList<ChatsModel> chats = <ChatsModel>[].obs;
  RxList<NotifModel> notifications = <NotifModel>[].obs;
  List<MessModel> _mess = [];
  List<ChatsModel> _chat = [];
  List<NotifModel> _notif = [];
  List<NotifModel> _notification = [];
  List<LeaseModel> _lease = [];
  List<DutiesModel> _duties = [];
  List<StarModel> _stars = [];

  List<EntityModel> _entity = [];
  List<EntityModel> _newEnt = [];
  List<UnitModel> _unit = [];
  List<UserModel> _user = [];
  List<PaymentsModel> _pay = [];
  List<BillingModel> _bill = [];

  List<String?> _eidList = [];
  List<String?> _pidList = [];

  EntityModel newEntModel = EntityModel(eid: "");

  SocketManager._();

  static final SocketManager _instance = SocketManager._();

  factory SocketManager() {
    return _instance;
  }

  IO.Socket get socket => _socket;
  bool isConnected = false;

  Future<bool> getDetails() async {
    _entity = await Services().getPropEntity(currentUser.uid);
    _unit = await Services().getMyUnits(currentUser.uid);
    _duties = await Services().getMyDuties(currentUser.uid);
    _pay = await Services().getMyPay(currentUser.uid);
    _lease = await Services().getMyLeases(currentUser.uid);
    _notification = await Services().getMyNotif(currentUser.uid);
    _stars = await Services().getMyStars(currentUser.uid);
    _bill = await Services().getMyBills(currentUser.uid);


    if (_lease.isNotEmpty) {
      List<LeaseModel> _filtLease = _lease
          .where((lease) => lease.end.toString().isEmpty &&
          (lease.tid == currentUser.uid ||
              lease.ctid.toString().contains(currentUser.uid)))
          .toList();

      for (var lease in _filtLease) {
        var list = await Services().getCrrntUnit(lease.uid!.split(",").first);

        // Check if the list is not empty
        if (list.isNotEmpty) {
          if (!_unit.any((unt) => unt.id.toString().contains(list.first.id.toString()))) {
            _unit.add(list.first);
          }
        } else {
          // Handle the case where the list is empty if needed
          print('No units found for lease with UID: ${lease.uid}');
        }
      }
    }



    // Loop through entities and process
    for (var enty in _entity) {
      var list = enty.pid.toString().split(",");
      for (var pid in list) {
        if (!_pidList.contains(pid) && pid != currentUser.uid) {
          _pidList.add(pid);
          var users = await Services().getCrntUsr(pid);
          if (users.isNotEmpty) {
            _user.add(users.first);
          }
        }
      }
    }
    // Loop through units and process
    for (var unt in _unit) {
      if (!_pidList.contains(unt.tid) && unt.tid != currentUser.uid) {
        _pidList.addAll(unt.tid.toString().split(","));
        unt.tid.toString().split(",").forEach((e)async{
          var users = await Services().getCrntUsr(e);
          if (users.isNotEmpty) {
            _user.add(users.first);
          }
        });
      }
    }
    for (var lease in _lease){
      if(!_user.any((e) => e.uid == lease.tid)){
        var users = await Services().getCrntUsr(lease.tid.toString());
        if (users.isNotEmpty) {
          _user.add(users.first);
        }
      }
    }

    _eidList = _unit.map((e) => e.eid).toList();
    Set<String?> uniqueEid = _eidList.toSet();

    // Loop through uniqueEid and process
    for (var element in uniqueEid) {
      if (!_entity.any((enty) => enty.eid == element)) {
        _newEnt = await Services().getOneEntity(element.toString());
        if (_newEnt.isNotEmpty) {
          newEntModel = _newEnt.first;
          _entity.add(newEntModel);
        }
      }
    }

    for (var entity in List.from(_entity.where((test) => !test.pid.toString().contains(currentUser.uid)))) {
      List<BillingModel> _newBills = [];
      _newBills = await Services().getCurrentBills(entity.eid.toString());
      await Data().addOrUpdateBillList(_newBills);
    }


    // Update the data storage
    await Data().addOrUpdateEntity(_entity);
    await Data().addOrUpdateUnit(_unit);
    await Data().addOrUpdateUserList(_user);
    await Data().addOrUpdatePayments(_pay);
    await Data().addOrUpdateNotif(_notification);
    await Data().addOrUpdateLease(_lease);
    await Data().addOrUpdateDutyList(_duties);
    await Data().addOrUpdateStarList(_stars);
    await Data().addOrUpdateBillList(_bill);
    return false;
  }

  void connect() {
    _socket = IO.io('https://more-crow-hardly.ngrok-free.app', <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });
    _socket.connect();
    _socket.on("connect", (data) {
      print("Connected");
      _socket.emit("signin", currentUser.uid);
    });
    _socket.on("message", (msg) {
      print(msg);
      setMessage(
        msg['mid'],
        msg['gid'],
        msg['sourceId'],
        msg['targetId'],
        msg['message'],
        msg["path"],
        msg['time'],
        msg['type'],
      );
    });
    _socket.on("group", (gmsg) {
      print(gmsg);
      setMessage(
        gmsg['mid'],
        gmsg['gid'],
        gmsg['sourceId'],
        gmsg['targetId'].join(','),
        gmsg['message'],
        gmsg["path"],
        gmsg['time'],
        gmsg['type'],
      );
    });
    _socket.on("notif", (notif){
      print(notif);
      setNotif(
          notif['nid'],
          notif['sourceId'],
          notif['targetId'],
          notif['message'],
          notif['eid'],
          notif['pid'].join(",").toString(),
          notif['time'],
          notif['type'],
          notif['actions'],
          notif['text'],
      );
    });

    _socket.on("disconnect", (_) {
      if(currentUser.uid!=""){
        print("Disconnected. Reconnecting : ${DateTime.now().toString().substring(10, 16)}");
        Future.delayed(Duration(seconds: 1), () {
          _socket.connect();
        });
      }
    });
    _socket.on("connect_error", (err) {
      print("Connection error: $err");
    });
    print('${_socket.connected}: ${DateTime.now().toString().substring(10, 16)}');
  }
  void setData(){
    _mess = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    _chat = myChats.map((jsonString) => ChatsModel.fromJson(json.decode(jsonString))).toList();
    _notif = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    _notif = _notif.where((test) => !test.deleted.toString().contains(currentUser.uid)).toList();
    messages.addAll(_mess);
    chats.addAll(_chat);
    notifications.addAll(_notif);
  }
  void signout(){
    _socket.emit("signout", currentUser.uid);
    print("User Sign Out");
  }
  void disconnect() {
    if (_socket != null) {
      _socket.disconnect();
      print("Socket disconnected");
    }
  }
  void setMessage(String mid, String gid,String sourceId, String targetId, String message, String path,  String time, String type){
    MessModel messageModel = MessModel(
      mid: mid,
      gid: gid,
      targetId: targetId,
      sourceId: sourceId,
      message: message,
      time: time,
      path: path,
      type: type,
      deleted: "",
      seen: "",
      delivered: "",
      checked: "false",
    );
    List<String> _cidList = [sourceId,targetId];
    _cidList.sort();
    ChatsModel chatsModel= ChatsModel(cid: "");
    if(type=='individual'){
      chatsModel = ChatsModel(
        cid: _cidList.join(","),
        title: "",
        time: time,
      );
    } else {
      chatsModel = ChatsModel(
        cid: gid,
        title: "",
        time: time,
      );
    }
    messages.add(messageModel);
    if(chats.contains(chatsModel)){
      chats.firstWhere((element) => element.cid == chatsModel.cid).time = chatsModel.time;
    } else {
      chats.add(chatsModel);
    }
    Data().addOrUpdateChats(chats);
    // Data().updateOrAddMessage(messages);
  }
  void setNotif(String nid, String sourceId, String targetId, String message, String eid, String pid, String time, String type, String actions,String text){
    NotifModel notif =  NotifModel(
        nid: nid,
        sid: sourceId,
        rid: targetId,
        eid: eid,
        pid: pid,
        text: text,
        message: message,
        actions: actions,
        image: "",
        type: type,
        seen: "",
        deleted: "",
        checked: "true",
        time: time,
    );
    if(notifications.any((element) => element.nid == notif.nid)){
      notifications.forEach((element) {
        if(element.nid == notif.nid && element.type == "MNTNRQ" && element.actions == "" && element.text!.split(",").first == notif.text!.split(",").first){
          element.actions = "DONE";
          element.time = DateTime.now().toString();
        } else if(element.nid == notif.nid && element.type == "MNTNRQ" && element.actions == "DONE" && element.text!.split(",").first == notif.text!.split(",").first){
          element.actions = actions;
          element.time = DateTime.now().toString();
        }
      });
    } else {
      notifications.add(notif);
    }
    Data().addOrUpdateNotif(notifications);
  }
  Future<void> initPlatform()async{
    if(Platform.isAndroid || Platform.isIOS){
      await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      await OneSignal.Debug.setAlertLevel(OSLogLevel.none);
      OneSignal.initialize("41db0b95-b70f-44a5-a5bf-ad849c74352e");
      await OneSignal.Notifications.requestPermission(true);
      await OneSignal.User.getOnesignalId().then((value){
        APIService().getUserData(value!);
      });
    }
  }
}
