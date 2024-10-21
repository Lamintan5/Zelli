import 'dart:convert';
import 'dart:io';

import 'package:Zelli/main.dart';
import 'package:http/http.dart' as http;


import '../api/crypto.dart';
import '../models/duties.dart';
import '../models/entities.dart';
import '../models/inventories.dart';
import '../models/manager.dart';
import '../models/messages.dart';
import '../models/notifications.dart';
import '../models/payments.dart';
import '../models/reviews.dart';
import '../models/stars.dart';
import '../models/lease.dart';
import '../models/units.dart';
import '../models/users.dart';



class Services{
  static String HOST = "http://${domain}/Zelli/";

  static var _USERS = HOST + 'users.php';
  static var _ENTITY = HOST + 'entity.php';
  static var _UNIT = HOST + 'unit.php';
  static var _LEASE = HOST + 'lease.php';
  static var _NOTIFICATIONS = HOST + 'notifications.php';
  static var _DUTIES = HOST + 'duties.php';
  static var _MESSAGE = HOST + 'messages.php';
  static var _PAY = HOST + 'payments.php';
  static var _STAR = HOST + 'star.php';
  static var _REVIEW = HOST + 'reviews.php';

  static const String _ADD  = 'ADD';
  static const String _REGISTER  = 'REGISTER';
  static const String _LOGIN  = 'LOGIN';
  static const String _LOGIN_EMAIL  = 'LOGIN_EMAIL';
  static const String _GET  = 'GET';
  static const String _GET_CURRENT  = 'GET_CURRENT';
  static const String _GET_MY  = 'GET_MY';
  static const String _GET_CURRENT_PROP  = 'GET_CURRENT_PROP';
  static const String _GET_ALL  = 'GET_ALL';
  static const String _GET_BY_ENTITY  = 'GET_BY_ENTITY';
  static const String _UPDATE  = 'UPDATE';
  static const String _UPDATE_PASS  = 'UPDATE_PASS';
  static const String _UPDATE_TOKEN  = 'UPDATE_TOKEN';
  static const String _UPDATE_ACTION  = 'UPDATE_ACTION';
  static const String _UPDATE_DELETE  = 'UPDATE_DELETE';
  static const String _UPDATE_PID  = 'UPDATE_PID';
  static const String _UPDATE_ADMIN  = 'UPDATE_ADMIN';
  static const String _REMOVE_PID  = 'REMOVE_PID';
  static const String _REMOVE_COTID  = 'REMOVE_COTID';
  static const String _REMOVE_TID  = 'REMOVE_TID';
  static const String _REMOVE_ADMIN  = 'REMOVE_ADMIN';
  static const String _UPDATE_TID  = 'UPDATE_TID';
  static const String _UPDATE_COTID  = 'UPDATE_COTID';
  static const String _UPDATE_SEEN  = 'UPDATE_SEEN';
  static const String _UPDATE_PROFILE  = 'UPDATE_PROFILE';
  static const String _UPDATE_UTIL  = 'UPDATE_UTIL';
  static const String _DELETE  = 'DELETE';

  // Method to create the table Users.
  List<UserModel> userFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<UserModel>.from(data.map((item)=>UserModel.fromJson(item)));
  }
  // Method to create the table Entity.
  List<EntityModel> entityFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<EntityModel>.from(data.map((item)=>EntityModel.fromJson(item)));
  }
  // Method to create the table Inventory.
  List<InventModel> inventFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<InventModel>.from(data.map((item)=>InventModel.fromJson(item)));
  }

  // Method to create the table Unit.
  List<UnitModel> unitFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<UnitModel>.from(data.map((item)=>UnitModel.fromJson(item)));
  }

  // Method to create the table Notification.
  List<NotifModel> notifFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<NotifModel>.from(data.map((item)=>NotifModel.fromJson(item)));
  }

  // Method to create the table Manager.
  List<ManagerModel> managerFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<ManagerModel>.from(data.map((item)=>ManagerModel.fromJson(item)));
  }

  // Method to create the table lease.
  List<LeaseModel> leaseFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<LeaseModel>.from(data.map((item)=>LeaseModel.fromJson(item)));
  }

  // Method to create the table Message.
  List<MessModel> messFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<MessModel>.from(data.map((item)=>MessModel.fromJson(item)));
  }

  // Method to create the table Payment.
  List<PaymentsModel> payFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<PaymentsModel>.from(data.map((item)=>PaymentsModel.fromJson(item)));
  }

  // Method to create the table Star.
  List<StarModel> starFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<StarModel>.from(data.map((item)=>StarModel.fromJson(item)));
  }

  // Method to create the table Review.
  List<ReviewModel> reviewFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<ReviewModel>.from(data.map((item)=>ReviewModel.fromJson(item)));
  }

  // Method to create the table Duties.
  List<DutiesModel> dutyFromJson(String jsonString) {
    final data = json.decode(jsonString);
    return List<DutiesModel>.from(data.map((item)=>DutiesModel.fromJson(item)));
  }


  // REGISTER USER
  static Future registerUsers(String uid, String username, String first, String last, String email, String phone, String password, File? image, String url,String status, String token, String country) async {
    print('Url : $url');
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_USERS));
      request.fields['action'] = _REGISTER;
      request.fields['uid'] = uid;
      request.fields['username'] = username;
      request.fields['first'] = first;
      request.fields['last'] = last;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['password'] = password;
      request.fields['status'] = status;
      request.fields['token'] = token;
      request.fields['country'] = country;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = url;
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }
  // LOGIN USERS
  static Future<String> loginUsers(String email, String password) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _LOGIN;
      map["email"] = email;
      map["password"] = password;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error : ${e}';
    }
  }
  // LOGIN USERS WITH EMAIL
  static Future<String> loginUserWithEmail(String email) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _LOGIN_EMAIL;
      map["email"] = email;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error : ${e}';
    }
  }
  // ADD ENTITY
  static Future addEntity(String eid, String pid, String admin,String title, String category, File? image, String due, String late, List utilities) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_ENTITY));
      request.fields['action'] = _ADD;
      request.fields['eid'] = eid;
      request.fields['pid'] = pid;
      request.fields['admin'] = admin;
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['due'] = due;
      request.fields['late'] = late;
      request.fields['utilities'] = utilities.join(',');
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = "";
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }
  // ADD_UNIT_ACTIONS
  static Future<String> addUnits(UnitModel unit) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["id"] = unit.id;
      map["pid"] = unit.pid;
      map["eid"] = unit.eid;
      map["tid"] = unit.tid;
      map["lid"] = "";
      map["title"] = unit.title;
      map["room"] = unit.room;
      map["floor"] = unit.floor;
      map["price"] = unit.price;
      map["deposit"] = unit.deposit;
      map["status"] = unit.status;
      final response = await http.post(Uri.parse(_UNIT), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // ADD NOTIFICATION
  static Future<String> addNotification(NotifModel notif) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["nid"] = notif.nid;
      map["sid"] = notif.sid;
      map["rid"] = notif.rid;
      map["pid"] = notif.pid;
      map["eid"] = notif.eid;
      map["text"] = notif.text;
      map["actions"] = notif.actions;
      map["type"] = notif.type;
      map["message"] = notif.message;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // ADD lease
  static Future<String> addLeases(String lid, String tid, String eid, String uid, String pid, String start, String end) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["lid"] = lid;
      map["tid"] = tid;
      map["eid"] = eid;
      map["uid"] = uid;
      map["pid"] = pid;
      map["start"] = start;
      map["end"] = end;
      final response = await http.post(Uri.parse(_LEASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // ADD DUTIES
  static Future<String> addDuties(String did, String eid, String pid, List duties) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["did"] = did;
      map["pid"] = pid;
      map["eid"] = eid;
      map["duties"] = duties.join(',');
      final response = await http.post(Uri.parse(_DUTIES), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // RECORD PAYMENT
  static Future<String> pay(PaymentsModel pay) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["payid"] = pay.payid;
      map["pid"] = pay.pid;
      map["admin"] = pay.admin;
      map["eid"] = pay.eid;
      map["tid"] = pay.tid;
      map["lid"] = pay.lid;
      map["uid"] = pay.uid;
      map["payerid"] = pay.payerid;
      map["amount"] = pay.amount;
      map["balance"] = pay.balance;
      map["method"] = pay.method;
      map["type"] = pay.type;
      map["time"] = pay.time;
      final response = await http.post(Uri.parse(_PAY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // ADD REVIEW
  static Future addReview(ReviewModel review, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_REVIEW));
      request.fields['action'] = _ADD;
      request.fields['rid'] = review.rid;
      request.fields['eid'] = review.eid.toString();
      request.fields['pid'] = review.pid.toString();
      request.fields['sid'] = review.sid.toString();
      request.fields['uid'] = review.uid.toString();
      request.fields['message'] = review.message.toString();
      request.fields['star'] = review.star.toString();
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }
  // ADD STAR
  static Future<String> addStar(StarModel star) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _ADD;
      map["sid"] = star.sid;
      map["pid"] = star.pid;
      map["eid"] = star.eid;
      map["rid"] = star.rid;
      map["uid"] = star.uid;
      map["rate"] = star.rate;
      map["type"] = star.type;
      final response = await http.post(Uri.parse(_STAR), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }


  // GET LOGGED IN USER
  Future<List<UserModel>> getUser(String email)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET;
    map["email"] = email;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }
  // GET CURRENT USER
  Future<List<UserModel>> getCrntUsr(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }
  // GET ALL USERS
  Future<List<UserModel>> getAllUsers()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_USERS),body: map);
    if(response.statusCode==200) {
      List<UserModel> user = userFromJson(response.body);
      return user;
    } else {
      return <UserModel>[];
    }
  }
  // GET ALL ENTITY
  Future<List<EntityModel>> getAllEntity()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_ENTITY),body: map);
    if(response.statusCode==200) {
      List<EntityModel> entity = entityFromJson(response.body);
      return entity;
    } else {
      return <EntityModel>[];
    }
  }
  // GET ONE ENTITY
  Future<List<EntityModel>> getOneEntity(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_ENTITY),body: map);
    if(response.statusCode==200) {
      List<EntityModel> entity = entityFromJson(response.body);
      return entity;
    } else {
      return <EntityModel>[];
    }
  }
  // GET CURRENT PROPERTY ENTITY
  Future<List<EntityModel>> getPropEntity(String pid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT_PROP;
    map["pid"] = pid;
    final response = await http.post(Uri.parse(_ENTITY),body: map);
    if(response.statusCode==200) {
      List<EntityModel> entity = entityFromJson(response.body);
      return entity;
    } else {
      return <EntityModel>[];
    }
  }
  // GET ALL UNIT
  Future<List<UnitModel>> getMyUnits(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_UNIT),body: map);
    if(response.statusCode==200) {
      List<UnitModel> unit = unitFromJson(response.body);
      return unit;
    } else {
      return <UnitModel>[];
    }
  }
  // GET MY PAYMENT
  Future<List<PaymentsModel>> getMyPay(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_PAY),body: map);
    if(response.statusCode==200) {
      List<PaymentsModel> pay = payFromJson(response.body);
      return pay;
    } else {
      return <PaymentsModel>[];
    }
  }
  // GET MY NOTIFICATIONS
  Future<List<NotifModel>> getMyNotif(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_NOTIFICATIONS),body: map);
    if(response.statusCode==200) {
      List<NotifModel> notif = notifFromJson(response.body);
      return notif;
    } else {
      return <NotifModel>[];
    }
  }
  // GET MY STARS
  Future<List<StarModel>> getMyStars(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_STAR),body: map);
    if(response.statusCode==200) {
      List<StarModel> star = starFromJson(response.body);
      return star;
    } else {
      return <StarModel>[];
    }
  }
  // GET CURRENT UNIT
  Future<List<UnitModel>> getCrrntUnit(String id)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["id"] = id;
    final response = await http.post(Uri.parse(_UNIT),body: map);
    if(response.statusCode==200) {
      List<UnitModel> unit = unitFromJson(response.body);
      return unit;
    } else {
      return <UnitModel>[];
    }
  }
  // GET ALL UNIT
  Future<List<UnitModel>> getAllUnit()async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_ALL;
    final response = await http.post(Uri.parse(_UNIT),body: map);
    if(response.statusCode==200) {
      List<UnitModel> unit = unitFromJson(response.body);
      return unit;
    } else {
      return <UnitModel>[];
    }
  }
  // GET UNITS BY EID
  Future<List<UnitModel>> getEntityUnit(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_BY_ENTITY;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_UNIT),body: map);
    if(response.statusCode==200) {
      List<UnitModel> unit = unitFromJson(response.body);
      return unit;
    } else {
      return <UnitModel>[];
    }
  }
  // GET MY leaseS
  Future<List<LeaseModel>> getMyLeases(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["uid"] = uid;
    final response = await http.post(Uri.parse(_LEASE),body: map);
    if(response.statusCode==200) {
      List<LeaseModel> leases = leaseFromJson(response.body);
      return leases;
    } else {
      return <LeaseModel>[];
    }
  }
  // GET MY DUTIES
  Future<List<DutiesModel>> getMyDuties(String uid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_MY;
    map["pid"] = uid;
    final response = await http.post(Uri.parse(_DUTIES),body: map);
    if(response.statusCode==200) {
      List<DutiesModel> data = dutyFromJson(response.body);
      return data;
    } else {
      return <DutiesModel>[];
    }
  }

  // GET CURRENT REVIEW
  Future<List<ReviewModel>> getCrntReview(String eid)async{
    var map = new Map<String, dynamic>();
    map["action"] = _GET_CURRENT;
    map["eid"] = eid;
    final response = await http.post(Uri.parse(_REVIEW),body: map);
    if(response.statusCode==200) {
      List<ReviewModel> review = reviewFromJson(response.body);
      return review;
    } else {
      return <ReviewModel>[];
    }
  }



  // UPDATE USER TOKEN
  static Future<String> updateToken(String uid,String token) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_TOKEN;
      map["uid"] = uid;
      map["token"] = token;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE USER PROFILE
  static Future updateProfile(String uid, String username, String first, String last, String url, File? image) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_USERS));
      request.fields['action'] = _UPDATE_PROFILE;
      request.fields['uid'] = uid;
      request.fields['username'] = username;
      request.fields['first'] = first;
      request.fields['last'] = last;
      request.fields['url'] = url;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = "";
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE USER PASSWORD
  static Future<String> updatePassword(String uid,String password) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PASS;
      map["uid"] = uid;
      map["password"] = password;
      final response = await http.post(Uri.parse(_USERS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE ENTITY
  static Future updateEntity(String eid, String title, String category, File? image, String oldImage, String due, String late) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_ENTITY));
      request.fields['action'] = _UPDATE;
      request.fields['eid'] = eid;
      request.fields['title'] = title;
      request.fields['category'] = category;
      request.fields['due'] = due;
      request.fields['late'] = late;
      if (image != null) {
        var pic = await http.MultipartFile.fromPath("image", image.path);
        request.files.add(pic);
      } else {
        request.fields['image'] = oldImage;
      }
      var response = await request.send();
      return response;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE UNITS
  static Future<String> updateUnit(UnitModel unit) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["id"] = unit.id;
      map["title"] = unit.title;
      map["room"] = unit.room;
      map["price"] = unit.price;
      map["deposit"] = unit.deposit;
      final response = await http.post(Uri.parse(_UNIT), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE NOTIFICATION ACTION
  static Future<String> updateNotifAct(String nid,String actions) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ACTION;
      map["nid"] = nid;
      map["actions"] = actions;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE NOTIFICATION DELETE
  static Future<String> updateNotifDel(String nid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_DELETE;
      map["nid"] = nid;
      map["uid"] = currentUser.uid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE NOTIFICATION DELETE
  static Future<String> updateNotifSeen(String nid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_SEEN;
      map["nid"] = nid;
      map["uid"] = currentUser.uid;
      final response = await http.post(Uri.parse(_NOTIFICATIONS), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE UNIT TID
  static Future<String> updateUnitTid(String id, String tid, String lid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_TID;
      map["id"] = id;
      map["tid"] = tid;
      map["lid"] = lid;
      final response = await http.post(Uri.parse(_UNIT), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE LEASE CTID
  static Future<String> updateLeaseCtid(String lid, String tid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_COTID;
      map["lid"] = lid;
      map["tid"] = tid;
      final response = await http.post(Uri.parse(_LEASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE PID
  static Future<String> updatePid(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_PID;
      map["eid"] = eid;
      map["uid"] = currentUser.uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // REMOVE PID
  static Future<String> removePid(String eid, String uid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_PID;
      map["eid"] = eid;
      map["uid"] = uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // REMOVE UNIT TID
  static Future<String> removeUnitTid(String id, String tid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_TID;
      map["id"] = id;
      map["tid"] = tid;
      final response = await http.post(Uri.parse(_UNIT), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // REMOVE LEASE CTID
  static Future<String> removeLeaseCtid(String lid, String tid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_COTID;
      map["lid"] = lid;
      map["tid"] = tid;
      final response = await http.post(Uri.parse(_LEASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE ADMIN
  static Future<String> updateAdmin(String eid, String uid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_ADMIN;
      map["eid"] = eid;
      map["uid"] = uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  //REMOVE ADMIN
  static Future<String> removeAdmin(String eid, String uid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _REMOVE_ADMIN;
      map["eid"] = eid;
      map["uid"] = uid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE ENTITY UTIL
  static Future<String> updateEntityUtil(String eid, List utilities) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE_UTIL;
      map["eid"] = eid;
      map["utilities"] = utilities.join('&');
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

  // UPDATE DUTIES
  static Future<String> updateDuties(String did,List duties) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["did"] = did;
      map["duties"] = duties.join(',');
      final response = await http.post(Uri.parse(_DUTIES), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // UPDATE LEASE END
  static Future<String> terminateLease(String lid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _UPDATE;
      map["lid"] = lid;
      map["end"] = DateTime.now().toString();
      final response = await http.post(Uri.parse(_LEASE), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }



  // DELETE ENTITY
  static Future<String> deleteEntity(String eid) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["eid"] = eid;
      final response = await http.post(Uri.parse(_ENTITY), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }
  // DELETE UNIT
  static Future<String> deleteUnit(String id) async {
    try {
      var map = new Map<String, dynamic>();
      map["action"] = _DELETE;
      map["id"] = id;
      final response = await http.post(Uri.parse(_UNIT), body: map);
      return response.body;
    } catch (e) {
      return 'error';
    }
  }

}