import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:Zelli/models/charge.dart';
import 'package:Zelli/models/chats.dart';
import 'package:Zelli/models/maintain.dart';
import 'package:Zelli/models/notifications.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/stars.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/third.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/models/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import 'duties.dart';
import 'duty.dart';
import 'entities.dart';
import 'messages.dart';

class Data{
  String message = 'Copyright © 2015-2024 Studio5ive Inc. All Rights Reserved. Accessibility, User Agreement, Privacy, Payments Terms of Use, Cookies, Your Privacy Choices and AdChoice';
  String failed = "mhmm🤔 seems like something went wrong. Please try again";
  String noPhone = "Phone number not available";
  List<String> dutiesList = ["TENANTS","PAYMENTS", "UNITS", "UTILITIES"];
  List<DutyModel> dutyList = [
    DutyModel(text: 'Tenants', message: 'Grant the manager permission to add or remove tenant data, including the ability to update tenant records, manage lease details, and oversee tenant-related transactions.', icon: LineIcon.user()),
    DutyModel(text: 'Payments', message: 'Grant the manager permission to record deposits, rent payments, expenses, and other forms of revenue.', icon: LineIcon.wallet()),
    DutyModel(text: 'Units', message: 'Grant the manager permission to add, remove, or edit unit data. This will enable the manager to effectively manage property details, ensuring accurate and up-to-date information for each unit.', icon: LineIcon.box()),
    DutyModel(text: 'Utilities', message: 'Grant the manager permission to add, remove, or edit utilities data. This allows the manager to maintain accurate records of household utilities, ensuring efficient tracking and management of utility services.', icon: Icon(CupertinoIcons.lightbulb)),
  ];
  final socketManager = Get.find<SocketManager>();
  List<String> items = ['Cash', 'Electronic'];
  List<ChargeModel> charge = [
    ChargeModel(title: "Maintenance Charges", message: "Charges for repairs or maintenance that result from tenant-caused damages beyond normal wear and tear."),
    ChargeModel(title: "Lease Renewal Fees", message: "Fees associated with renewing a lease agreement for a specified period."),
    ChargeModel(title: "Pet Fees", message: "Fees charged for allowing pets in the rental unit."),
    ChargeModel(title: "Parking Fees", message: "Charges for parking spaces, if applicable."),
    ChargeModel(title: "Storage Fees", message: "Charges for additional storage space, if available."),
    ChargeModel(title: "Appliance Rental Fees", message: "Charges for renting appliances or additional amenities."),
    ChargeModel(title: "Key Replacement Fees", message: "Fees for replacing lost keys or access cards."),
    ChargeModel(title: "Cleaning Fees", message: "Charges for cleaning services after a tenant moves out, if necessary."),
    ChargeModel(title: "Tenant Insurance", message: "Some property managers may require tenants to have renter's insurance, and the cost may be passed on to the tenant."),
    ChargeModel(title: "Amenity Fees", message: "Charges for the use of shared amenities, such as a gym or community space."),
    ChargeModel(title: "Internet and Cable Fees", message: "If the property provides these services, the associated fees may be part of the tenant's responsibility."),
  ];
  List<UtilModel> utilList = [
    UtilModel(text: 'Electricity', message: 'The cost of electrical power used within the rented premises.', icon: Icon(CupertinoIcons.bolt)),
    UtilModel(text: 'Water', message: 'Charges for water usage, which can include both water consumption and sewage fees.', icon: Icon(CupertinoIcons.drop)),
    UtilModel(text: 'Gas', message: 'If the property uses gas for heating, cooking, or other purposes, tenants may be responsible for the associated costs.', icon: Icon(CupertinoIcons.flame)),
    UtilModel(text: 'Heating/Cooling', message: 'In some cases, tenants may have to pay for heating or cooling, especially if the AC is individually metered.', icon: Icon(CupertinoIcons.thermometer)),
    UtilModel(text: 'Trash/Recycling', message: 'Charges for waste removal and recycling services.', icon: Icon(CupertinoIcons.trash)),
    UtilModel(text: 'Internet/Cable/TV', message: ' If these services are not included in the rent, tenants may need to pay for them separately.', icon: Icon(CupertinoIcons.wifi)),
    UtilModel(text: 'Telephone', message: 'The cost of landline telephone service if it\'s not included in the rent.', icon: Icon(CupertinoIcons.phone)),
    UtilModel(text: 'HOA', message: 'If the property is part of a homeowners association (HOA), tenants may be responsible for associated fees.', icon: Icon(CupertinoIcons.person_crop_square)),
    UtilModel(text: 'Security System Fees', message: 'If the rental property has a security system in place, tenants might be responsible for any associated monitoring or service fees.', icon: Icon(CupertinoIcons.lock_shield)),
  ];
  List<MaintainModel> maintainList = [
    MaintainModel(text: "Emergency", maintain: ['Issues requiring immediate attention, such as medical attention , gas leaks, major water leaks, electrical emergencies'], icon: Icon(Icons.local_hospital)),
    MaintainModel(text: "Routine Maintenance", maintain: ['HVAC System', 'Plumbing', 'Electrical Systems', 'Appliances'], icon: Icon(Icons.build)),
    MaintainModel(text: "Interior Repairs", maintain: ['Wall and Ceiling Repairs', 'Flooring Repairs', 'Window and Door Repairs'], icon: Icon(Icons.build_circle)),
    MaintainModel(text: "Landscape and Outdoor Maintenance", maintain: ['Lawn Care and landscaping requests', 'Tree and Shrub Pruning', 'Irrigation Systems', 'Sprinkler system issues'], icon: Icon(Icons.eco)),
    MaintainModel(text: "Utility Outages", maintain: ['Power Outages', 'Water or Gas Outages'], icon: Icon(Icons.power_off)),
    MaintainModel(text: "Pest Control", maintain: ['Presence of pests like rodents, insects, or termites', 'Need for routine pest control services'], icon: LineIcon.bug()),
    MaintainModel(text: "Security and Locks", maintain: ['Broken locks or doorknobs', 'Issues with security systems or alarms'], icon: Icon(Icons.shield_moon)),
    MaintainModel(text: "Lighting", maintain: ['Non-functioning or flickering lights', 'Exterior lighting problems'], icon: Icon(Icons.wb_sunny)),
    MaintainModel(text: "Garbage Disposal", maintain: ['Malfunctioning garbage disposal unit', 'Clogged sink drains'], icon: Icon(Icons.delete)),
    MaintainModel(text: "Smoke Detector and Alarm Issues", maintain: ['Battery replacements', 'Malfunctioning alarms'], icon: Icon(Icons.smoke_free)),
    MaintainModel(text: "General Maintenance", maintain: ['Routine inspections and maintenance checks', 'Cleaning or servicing of common areas'], icon: Icon(Icons.construction)),
  ];

  Future<void> addOrUpdateEntity(List<EntityModel> newDataList, {String from = ""}) async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newEntity in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingEntityIndex = _entity.indexWhere((user) => user.eid == newEntity.eid);
      if (existingEntityIndex != -1) {
        // User with the same uid exists, compare other attributes
        EntityModel existingEntity = _entity[existingEntityIndex];
        if (existingEntity.toJson().toString() != newEntity.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _entity[existingEntityIndex] = newEntity;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _entity.add(newEntity);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    for (var existingEntity in _entity) {
      bool existsInNewDataList = newDataList.any((newEntity) => newEntity.eid == existingEntity.eid);
      if (!existsInNewDataList && existingEntity.checked.toString().contains("true")) {
        existingEntity.checked = "REMOVED";
      }
    }

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
  }
  Future<void> addNotMyEntity(List<EntityModel> newDataList) async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = notMyEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newEntity in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingEntityIndex = _entity.indexWhere((user) => user.eid == newEntity.eid);
      if (existingEntityIndex != -1) {
        // User with the same uid exists, compare other attributes
        EntityModel existingEntity = _entity[existingEntityIndex];
        if (existingEntity.toJson().toString() != newEntity.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _entity[existingEntityIndex] = newEntity;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _entity.add(newEntity);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    for (var existingEntity in _entity) {
      bool existsInNewDataList = newDataList.any((newEntity) => newEntity.eid == existingEntity.eid);
      if (!existsInNewDataList && existingEntity.checked.toString().contains("true")) {
        existingEntity.checked = "REMOVED";
      }
    }

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('notmyentity', uniqueEntities);
    notMyEntity = uniqueEntities;
  }
  Future<void> addOrUpdateUnit(List<UnitModel> newDataList) async {
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newUnit in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingUnitIndex = _unit.indexWhere((unit) => unit.id == newUnit.id);
      if (existingUnitIndex != -1) {
        // User with the same uid exists, compare other attributes
        UnitModel existingUnit = _unit[existingUnitIndex];
        if (existingUnit.toJson().toString() != newUnit.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _unit[existingUnitIndex] = newUnit;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _unit.add(newUnit);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    for (var existingUnit in _unit) {
      bool existsInNewDataList = newDataList.any((newEntity) => newEntity.id == existingUnit.id);
      if (!existsInNewDataList && existingUnit.checked.toString().contains("true")) {
        existingUnit.checked = "REMOVED";
      }
    }

    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
  }
  Future<void> addOrUpdatePayments(List<PaymentsModel> newDataList) async {
    List<PaymentsModel> _payments = [];
    List<String> uniquePay = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newPay in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingPayIndex = _payments.indexWhere((pay) => pay.payid == newPay.payid);
      if (existingPayIndex != -1) {
        // User with the same uid exists, compare other attributes
        PaymentsModel existingPay = _payments[existingPayIndex];
        if (existingPay.toJson().toString() != newPay.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _payments[existingPayIndex] = newPay;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _payments.add(newPay);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    for (var existingPay in _payments) {
      bool existsInNewDataList = newDataList.any((newPay) => newPay.payid == existingPay.payid);
      if (!existsInNewDataList && existingPay.checked.toString().contains("true")) {
        existingPay.checked = "REMOVED";
      }
    }

    uniquePay = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypay', uniquePay);
    myPayment = uniquePay;
  }
  Future<void> addOrUpdateNotif(List<NotifModel> newDataList) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    // entities.removeWhere((ent) => ent.checked == "true" && !newDataList.any((newEnt) => newEnt.eid == ent.eid));
    for (var newNotif in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingNotifIndex = _notification.indexWhere((notif) => notif.nid == newNotif.nid);
      if (existingNotifIndex != -1) {
        // User with the same uid exists, compare other attributes
        NotifModel existingNotif = _notification[existingNotifIndex];
        if (existingNotif.toJson().toString() != newNotif.toJson().toString()) {
          // If any attribute is different, update the existing user with the new data
          _notification[existingNotifIndex] = newNotif;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _notification.add(newNotif);
      }
    }
    // Mark Entity as DELETED if they are not in newDataList
    if(newDataList.length != 0 || newDataList.isNotEmpty){
      for (var existingNotif in _notification) {
        bool existsInNewDataList = newDataList.any((newNotif) => newNotif.nid == existingNotif.nid);
        if (!existsInNewDataList && existingNotif.checked.toString().contains("true")) {
          existingNotif.checked = "REMOVED";
        }
      }
    }
    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
  }
  Future<void> addOrUpdateLease(List<LeaseModel> newDataList) async {
    List<LeaseModel> _lease = [];
    List<String> uniqueLease = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();

    for (var newLease in newDataList) {
      int existingLeaseIndex = _lease.indexWhere((tnt) => tnt.lid == newLease.lid);
      if (existingLeaseIndex != -1) {
        LeaseModel existingTenant = _lease[existingLeaseIndex];
        if (existingTenant.toJson().toString() != newLease.toJson().toString()) {
          _lease[existingLeaseIndex] = newLease;
        }
      } else {
        _lease.add(newLease);
      }
    }
    for (var existingTenant in _lease) {
      bool existsInNewDataList = newDataList.any((newLease) => newLease.lid == existingTenant.lid);
      if (!existsInNewDataList && existingTenant.checked.toString().contains("true")) {
        existingTenant.checked = "REMOVED";
      }
    }

    uniqueLease = _lease.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mylease', uniqueLease);
    myLease = uniqueLease;
  }
  Future<void> addOrUpdateDutyList(List<DutiesModel> newDataList)async{
    List<String> uniqueDuties= [];
    List<DutiesModel> _duty = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).toList();
    for (var newDuty in newDataList) {
      int existingDutyIndex = _duty.indexWhere((dty) => dty.did == newDuty.did);
      if (existingDutyIndex != -1) {
        DutiesModel existingDuty = _duty[existingDutyIndex];
        if (existingDuty.toJson().toString() != newDuty.toJson().toString()) {
          _duty[existingDutyIndex] = newDuty;
        }
      } else {
        _duty.add(newDuty);
      }
    }
    for (var existingDuty in _duty) {
      bool existsInNewDataList = newDataList.any((dty) => dty.did == existingDuty.did);
      if (!existsInNewDataList && existingDuty.checked.toString().contains("true")) {
        existingDuty.checked = "REMOVED";
      }
    }
    uniqueDuties = _duty.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myduties', uniqueDuties);
    myDuties = uniqueDuties;
  }
  Future<void> addOrUpdateMessagesList(List<MessModel> newDataList)async{
    List<String> uniqueMessages= [];
    List<MessModel> _messages = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _messages = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    for (var newMessages in newDataList) {
      int existingMessIndex = _messages.indexWhere((mess) => mess.mid == newMessages.mid);
      if (existingMessIndex != -1) {
        MessModel existingMess = _messages[existingMessIndex];
        if (existingMess.toJson().toString() != newMessages.toJson().toString()) {
          _messages[existingMessIndex] = newMessages;
        }
      } else {
        _messages.add(newMessages);
      }
    }
    for (var existingMessages in _messages) {
      bool existsInNewDataList = newDataList.any((newMess) => newMess.mid == existingMessages.mid);
      if (!existsInNewDataList && existingMessages.checked.toString().contains("true")) {
        existingMessages.checked = "REMOVED";
      }
    }
    uniqueMessages = _messages.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mymess', uniqueMessages);
    myMess = uniqueMessages;
  }

  Future<void> addUser(UserModel user) async {
    List<UserModel> _users = [];
    List<String> uniqueUser = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].uid == user.uid) {
        _users[i] = user;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _users.add(user);
    }

    uniqueUser = _users.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('myusers', uniqueUser);
    myUsers = uniqueUser;
  }
  Future<void> addEntity(EntityModel entity) async {
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _entity.length; i++) {
      if (_entity[i].eid == entity.eid) {
        _entity[i] = entity;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _entity.add(entity);
    }

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
  }
  Future<void> addUnit(UnitModel unit) async {
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _unit.length; i++) {
      if (_unit[i].id == unit.id) {
        _unit[i] = unit;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _unit.add(unit);
    }

    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
  }
  Future<void> addLease(LeaseModel lease) async {
    List<LeaseModel> _lease = [];
    List<String> uniqueLease = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _lease.length; i++) {
      if (_lease[i].lid == lease.lid) {
        _lease[i] = lease;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _lease.add(lease);
    }

    uniqueLease = _lease.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mylease', uniqueLease);
    myLease = uniqueLease;
  }
  Future<void> addNotification(NotifModel notif) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _notification.length; i++) {
      if (_notification[i].nid == notif.nid) {
        _notification[i] = notif;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _notification.add(notif);
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
  }
  Future<bool> addPayment(PaymentsModel payment, Function reload)async{
    List<PaymentsModel> _payments = [];
    List<String> uniquePay = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _payments = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();

    bool exists = false;
    for (int i = 0; i < _payments.length; i++) {
      if (_payments[i].payid == payment.payid) {
        _payments[i] = payment;
        exists = true;
        break;
      }
    }
    if (!exists) {
      _payments.add(payment);
    }

    uniquePay = _payments.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mypay', uniquePay);
    myPayment = uniquePay;
    reload();
    return false;
  }

  Future<void> addOrUpdateUserList(List<UserModel> newDataList)async{
    List<String> uniqueUsers= [];
    List<UserModel> _user = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    for (var newUser in newDataList) {
      // Check if a user with the same uid exists in _user
      int existingUserIndex = _user.indexWhere((user) => user.uid == newUser.uid);
      if (existingUserIndex != -1) {
        // User with the same uid exists, compare other attributes
        UserModel existingUser = _user[existingUserIndex];
        if (existingUser.toJsonAdd().toString() != newUser.toJsonAdd().toString()) {
          // If any attribute is different, update the existing user with the new data
          _user[existingUserIndex] = newUser;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _user.add(newUser);
      }
    }
    uniqueUsers = _user.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('myusers', uniqueUsers);
    myUsers = uniqueUsers;
  }
  Future<void> addMyThirdData(List<String> list, String eid, String type)async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> uniqueThird = [];
    List<ThirdModel> thirdata = myThird.map((jsonString) => ThirdModel.fromJson(json.decode(jsonString))).toList();
    for (var Uid in list) {
      bool isUidExists = thirdata.any((user) => user.uid == Uid && user.eid == eid && user.type == type);
      if (!isUidExists) {
        thirdata.add(ThirdModel(
          eid: eid,
          uid: Uid,
          type: type,
        ));
      }
    }
    uniqueThird = thirdata.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mythird', uniqueThird);
    myThird = uniqueThird;
  }
  Future<void> addOrUpdateChats(List<ChatsModel> newChats) async {
    List<String> uniqueChats = [];
    List<ChatsModel> _chat = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _chat = myChats.map((jsonString) => ChatsModel.fromJson(json.decode(jsonString))).toList();

    for (var newChat in newChats) {
      // Check if a chat with the same cid exists in _chat
      int existingChatIndex = _chat.indexWhere((chat) => chat.cid == newChat.cid);

      if (existingChatIndex != -1) {
        // Chat with the same cid exists, update only specific attributes
        ChatsModel existingChat = _chat[existingChatIndex];
        if(existingChat.title == "" || existingChat.title == null){
          existingChat.title = newChat.title;
        } else {

        }
        if(newChat.time != "new"){
          existingChat.time = newChat.time;
        }
      } else {
        // Chat with the same cid doesn't exist, add the new chat
        _chat.add(newChat);
      }
    }

    uniqueChats = _chat.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('mychats', uniqueChats);
    myChats = uniqueChats;
  }
  Future<void> addOrUpdateStarList(List<StarModel> newStarList)async{
    List<String> uniqueStars= [];
    List<StarModel> _star = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _star = myStars.map((jsonString) => StarModel.fromJson(json.decode(jsonString))).toList();
    for (var newStar in newStarList) {
      // Check if a user with the same uid exists in _user
      int existingUserIndex = _star.indexWhere((str) => str.sid == newStar.sid);
      if (existingUserIndex != -1) {
        // User with the same uid exists, compare other attributes
        StarModel existingStar = _star[existingUserIndex];
        if (existingStar.toJsonAdd().toString() != newStar.toJsonAdd().toString()) {
          // If any attribute is different, update the existing user with the new data
          _star[existingUserIndex] = newStar;
        }
      } else {
        // User with the same uid doesn't exist, add the new user
        _star.add(newStar);
      }
    }
    uniqueStars = _star.map((model) => jsonEncode(model.toJsonAdd())).toList();
    sharedPreferences.setStringList('mystars', uniqueStars);
    myStars = uniqueStars;
  }

  Future<bool> checkAndUploadEntity(List<EntityModel> entities, Function reload) async {
    List<String> uniqueEntity = [];
    List<EntityModel> _entity = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    for(var entity in entities){
      if(entity.checked.contains("DELETE")){
        if(entity.checked.contains("false")){
          _entity.removeWhere((test) => test.eid == entity.eid);
          uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('myentity', uniqueEntity);
          myEntity = uniqueEntity;
        } else {
          await Services.deleteEntity(entity.eid).then((response){
            if(response=="success"){
              _entity.removeWhere((test) => test.eid == entity.eid);
              uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
              sharedPreferences.setStringList('myentity', uniqueEntity);
              myEntity = uniqueEntity;
            }
          });
        }
      } else if (entity.checked == "false") {
        final response = await Services.addEntity(
          entity.eid,
          entity.pid.toString(),
          entity.admin.toString(),
          entity.title.toString(),
          entity.category.toString(),
            entity.image.toString() != ""?File(entity.image.toString()):null,
          entity.due.toString(),
          entity.late.toString(),
          entity.utilities.toString().split(","),
        );
        final String responseString = await response.stream.bytesToString();
        if (responseString.contains("Success")) {
          entity.checked = 'true';
          _entity.firstWhere((test) => test.eid == entity.eid).checked = "true";
          uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
          sharedPreferences.setStringList('myentity', uniqueEntity);
          myEntity = uniqueEntity;
        } else {
          print("Error: $responseString");
        }
      } else if (entity.checked.contains("EDIT")){
        if(entity.checked.contains("false")){
          final response = await Services.addEntity(
            entity.eid,
            entity.pid.toString(),
            entity.admin.toString(),
            entity.title.toString(),
            entity.category.toString(),
            entity.image.toString() != ""?File(entity.image.toString()):null,
            entity.due.toString(),
            entity.late.toString(),
            entity.utilities.toString().split(","),
          );
          final String responseString = await response.stream.bytesToString();

          if (responseString.contains("Success")) {
            entity.checked = 'true';
            _entity.firstWhere((test) => test.eid == entity.eid).checked = "true";
            uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myentity', uniqueEntity);
            myEntity = uniqueEntity;
          } else {
            print("Error: $responseString");
          }
        } else {
          final response = await Services.updateEntity(entity.eid, entity.title.toString(), entity.category.toString(), File(entity.image.toString()), entity.image.toString(), entity.due.toString(), entity.late.toString());
          final String responseString = await response.stream.bytesToString();
          if(responseString.contains("success")){
            entity.checked = 'true';
            _entity.firstWhere((test) => test.eid == entity.eid).checked = "true";
            uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myentity', uniqueEntity);
            myEntity = uniqueEntity;
          }
        }
      }
    }

    uniqueEntity = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntity);
    myEntity = uniqueEntity;
    reload();
    return false;
  }
  Future<bool> checkNotifications(List<NotifModel> notifications, Function reload) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    for (var notif in notifications){
      if(notif.checked.toString().contains("DELETE")){
        await Services.updateNotifDel(notif.nid).then((value){
          if(value=="success"|| value=="Does not exist"){
            _notification.removeWhere((test) => test.nid == notif.nid);
            socketManager.notifications.removeWhere((test) => test.nid == notif.nid);
          }
        });
      } else if(notif.checked.toString().contains("SEEN")){
        await Services.updateNotifDel(notif.nid).then((value){
          if(value=="success" || value=="Does not exist"){
            List<String> checked = [];
            checked=notif.checked.toString().split(",");
            checked.remove("SEEN");
            _notification.firstWhere((test) => test.nid == notif.nid).checked = checked.join(",");
            if(socketManager.notifications.any((test) => test.nid == notif.nid)){
              socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = checked.join(",");
            }
          }
        });
      }
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;
    return false;
  }

  Future<bool> removeEntity(EntityModel entity, Function reload, BuildContext context)async{
    List<EntityModel> _entity = [];
    List<UnitModel> _units = [];
    List<NotifModel> _notif = [];
    List<PaymentsModel> _payments = [];

    List<String> uniqueEntities = [];
    List<String> uniqueUnit = [];
    List<String> uniqueNotif = [];
    List<String> uniquePayments = [];


    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _notif = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();

    EntityModel initial = _entity.firstWhere((element) =>element.eid == entity.eid);

    if(entity.checked.toString().contains("true")){
      _entity.firstWhere((element) => element.eid == entity.eid).checked = initial.checked.toString().contains("DELETE")
          ? initial.checked
          : "${initial.checked},DELETE";
    } else {
      _entity.removeWhere((element) => element.eid == entity.eid);
    }
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload();

    await Services.deleteEntity(entity.eid).then((response)async{
      if(response=="success"||response=="Does not exist"){
        // await Services.deletePrdctByEid(entity.eid);
        // await Services.deleteSpplrByEid(entity.eid);
        // await Services.deletePrchByEid(entity.eid);
        // await Services.deleteInvByEid(entity.eid);
        // await Services.deleteSaleByEid(entity.eid);
        // await Services.deleteDutityByEid(entity.eid);
        // await Services.deleteNotifByEid(entity.eid);
        // await Services.deletePayByEid(entity.eid);

        _entity.removeWhere((element) => element.eid == entity.eid);
        _units.removeWhere((element) => element.eid == entity.eid);
        _payments.removeWhere((element) => element.eid == entity.eid);
        _notif.removeWhere((element) => element.eid == entity.eid);

        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        uniqueUnit = _units.map((model) => jsonEncode(model.toJson())).toList();
        uniqueNotif = _notif.map((model) => jsonEncode(model.toJson())).toList();
        uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();
        
        sharedPreferences.setStringList('myentity', uniqueEntities);
        sharedPreferences.setStringList("myunit", uniqueUnit);
        sharedPreferences.setStringList("mynotif", uniqueNotif);
        sharedPreferences.setStringList('mypay', uniquePayments);

        myEntity = uniqueEntities;
        myUnits = uniqueUnit;
        myNotif = uniqueNotif;
        myPayment = uniquePayments;
        reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Entity was removed from Entity list successfully"),
              showCloseIcon: true,
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Entity was removed from Entity list. Awaiting internet connection."),
              showCloseIcon: true,
            )
        );
      }
    });
    return false;
  }

  Future<bool> removeUnit(UnitModel unit, Function reload, BuildContext context)async{
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    UnitModel newUnit = unit;
    newUnit.checked = newUnit.checked.toString().contains("DELETE")? newUnit.checked : "${newUnit.checked},DELETE";

    if(unit.checked.toString().contains("false")){
      _unit.removeWhere((test) => test.id==unit.id);
    } else {
      _unit.firstWhere((test) => test.id == newUnit.id).checked = newUnit.checked;
    }

    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
    reload();

    await Services.deleteUnit(unit.id.toString()).then((response)async{
      if(response=="success"||response=="Does not exist"){
        await Services.terminateLease(unit.lid.toString());
        _unit.removeWhere((test) => test.id==unit.id);
        uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myunit', uniqueUnit);
        myUnits = uniqueUnit;
        reload();
      } else if(response=="error"){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Unit was removed. Awaiting internet connection"),
              showCloseIcon: true,
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failed),
              showCloseIcon: true,
            )
        );
      }
    });

    return false;
  }

  Future<bool> deleteNotif(BuildContext context, NotifModel notif, Function remove) async {
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    List<String> del = notif.deleted.toString().isEmpty ? [] : notif.deleted.toString().split(",");
    if (notif.deleted.toString().isEmpty) {
      del.add(currentUser.uid);
    }

    NotifModel targetNotif = _notification.firstWhere((test) => test.nid == notif.nid);
    targetNotif.deleted = notif.deleted.toString().contains(currentUser.uid) ? notif.deleted : del.join(",");
    targetNotif.checked = notif.checked.toString().contains("DELETE") ? notif.checked : "${notif.checked},DELETE";

    socketManager.notifications.removeWhere((test) => test.nid == notif.nid);
    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;

    remove(notif);


    await Services.updateNotifDel(notif.nid).then((response) {

      if (response == "success" || response == "Does not exist") {
        _notification.removeWhere((test) => test.nid == notif.nid);
        uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mynotif', uniqueNotif);
        myNotif = uniqueNotif;


        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Notification removed"),
              width: 500,
              showCloseIcon: true,
            ),
          );
        }
      }
    });

    return false;
  }

  Future<bool> editEntity(BuildContext context, Function reload, EntityModel updatedEntity, File? image, String oldImage)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    EntityModel newEntity = updatedEntity;
    newEntity.checked = updatedEntity.checked.contains("EDIT")
        ? updatedEntity.checked
        : "${updatedEntity.checked},EDIT";

    _entity.firstWhere((element) => element.eid == updatedEntity.eid).title = updatedEntity.title;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).category = updatedEntity.category;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).image = updatedEntity.image;
    _entity.firstWhere((element) => element.eid == updatedEntity.eid).checked = newEntity.checked;

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload(newEntity);

    final response = await Services.updateEntity(
        updatedEntity.eid,
        updatedEntity.title.toString(),
        updatedEntity.category.toString(),
        image,
        oldImage,
        updatedEntity.due.toString(),
        updatedEntity.late.toString(),
    );
    final String responseString = await response.stream.bytesToString();
    if(responseString.contains("success")){
      updatedEntity.checked = "true";
      newEntity.checked = "true";
      _entity.firstWhere((element) => element.eid == updatedEntity.eid).checked = "true";
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      reload(newEntity);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated Successfully"),
            showCloseIcon: true,
          )
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Entity updated. Awaiting internet connection."),
            showCloseIcon: true,
          )
      );
    }
    return false;
  }
  Future<bool> editUnit(BuildContext context, Function reload, UnitModel updatedUnit)async{
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    UnitModel newUnit = updatedUnit;
    newUnit.checked = newUnit.checked.toString().contains("EDIT")? newUnit.checked : "${newUnit.checked},EDIT";

    _unit.firstWhere((test) => test.id == newUnit.id).title = newUnit.title;
    _unit.firstWhere((test) => test.id == newUnit.id).room = newUnit.room;
    _unit.firstWhere((test) => test.id == newUnit.id).price = newUnit.price;
    _unit.firstWhere((test) => test.id == newUnit.id).deposit = newUnit.deposit;
    _unit.firstWhere((test) => test.id == newUnit.id).checked = newUnit.checked;

    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
    reload();

    await Services.updateUnit(newUnit).then((response)async{
      if(response=="success"){
        _unit.firstWhere((test) => test.id == newUnit.id).checked = "true";
        uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myunit', uniqueUnit);
        myUnits = uniqueUnit;
      } else if(response == "Does not exist"){
        await Services.addUnits(newUnit).then((value){
          if(value=="Success"){
            _unit.firstWhere((test) => test.id == newUnit.id).checked = "true";
            uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
            sharedPreferences.setStringList('myunit', uniqueUnit);
            myUnits = uniqueUnit;
          }
        });
      } else if(response=="error"){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text("Unit was not updated. Please try again"),
                showCloseIcon: true,
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failed),
              showCloseIcon: true,
            )
        );
      }
    });
    reload();
    return false;
  }

  Future<void> restoreUnit(BuildContext context, UnitModel unit, String action, Function reload)async{
    List<UnitModel> _unit = [];
    List<String> uniqueUnit = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();

    List<String> checks = [];
    UnitModel unitModel = _unit.firstWhere((test) => test.id == unit.id, orElse: ()=>UnitModel(id: ""));
    checks = unitModel.checked.toString().split(",");
    checks.remove(action);

    _unit.firstWhere((test)=> test.id == unit.id).checked = checks.join(",");

    uniqueUnit = _unit.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myunit', uniqueUnit);
    myUnits = uniqueUnit;
    reload();
  }

  Future<void> updateSeen(NotifModel notif)async{
    List<NotifModel> _notification = [];
    List<String> uniqueNotif = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _notification = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();

    if(!notif.seen.toString().contains(currentUser.uid)){
      List<String> seens = [];
      List<String> _checks = [];
      seens = notif.seen.toString().split(",");
      _checks = notif.checked.toString().split(",");
      seens.remove("");
      if(!seens.contains(currentUser.uid)){
        seens.add(currentUser.uid);
      }
      if(!_checks.contains("SEEN")){
        _checks.add("SEEN");
      }
      _notification.firstWhere((test) => test.nid == notif.nid).seen = seens.join(",");
      _notification.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
      if(socketManager.notifications.any((test) => test.nid == notif.nid)){
        socketManager.notifications.firstWhere((test) => test.nid == notif.nid).seen = seens.join(",");
        socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
      }
    }

    uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('mynotif', uniqueNotif);
    myNotif = uniqueNotif;

    await Services.updateNotifSeen(notif.nid).then((response){
      if(response=="success"){
        List<String> _checks = [];
        _checks = notif.checked.toString().split(",");
        if(_checks.contains("SEEN")){
          _checks.remove("SEEN");
        }

        _notification.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
        if(socketManager.notifications.any((test) => test.nid == notif.nid)){
          socketManager.notifications.firstWhere((test) => test.nid == notif.nid).checked = _checks.join(",");
        }
        uniqueNotif = _notification.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('mynotif', uniqueNotif);
        myNotif = uniqueNotif;
      }
    });
  }

  Future<bool> exitEntity(BuildContext context, EntityModel entity, Function reload)async{
    List<EntityModel> _entity = [];
    List<UnitModel> _units = [];
    List<NotifModel> _notif = [];
    List<PaymentsModel> _payments = [];

    List<String> uniqueEntities = [];
    List<String> uniqueUnit = [];
    List<String> uniqueNotif = [];
    List<String> uniquePayments = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _notif = myNotif.map((jsonString) => NotifModel.fromJson(json.decode(jsonString))).toList();
    _payments = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    
    await Services.removeAdmin(entity.eid, currentUser.uid).then((response){print("Response $response");});
    await Services.removePid(entity.eid, currentUser.uid).then((value){
      print("Value ${value}");
      if(value=="success"||value=="Does not exist"){
        _entity.removeWhere((element) => element.eid == entity.eid);
        _units.removeWhere((element) => element.eid == entity.eid);
        _payments.removeWhere((element) => element.eid == entity.eid);
        _notif.removeWhere((element) => element.eid == entity.eid);
        socketManager.notifications.removeWhere((element) => element.eid == entity.eid);

        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        uniqueUnit = _units.map((model) => jsonEncode(model.toJson())).toList();
        uniqueNotif = _notif.map((model) => jsonEncode(model.toJson())).toList();
        uniquePayments  = _payments.map((model) => jsonEncode(model.toJson())).toList();

        sharedPreferences.setStringList('myentity', uniqueEntities);
        sharedPreferences.setStringList("myunit", uniqueUnit);
        sharedPreferences.setStringList("mynotif", uniqueNotif);
        sharedPreferences.setStringList('mypay', uniquePayments);


        myEntity = uniqueEntities;
        myUnits = uniqueUnit;
        myNotif = uniqueNotif;
        myPayment = uniquePayments;
        reload();
      }
    });

    return false;
  }

  Future<bool> makeAdmin(BuildContext context, EntityModel entity, UserModel user, Function reload)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> _admins = [];
    List<String> _checks = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    EntityModel entityModel = _entity.firstWhere((test) => test.eid == entity.eid);


    _admins = entityModel.admin.toString().split(",");
    _checks = entityModel.checked.toString().split(",");
    _admins.remove("");
    if(!_admins.contains(user.uid)){
      _admins.add(user.uid);
    }
    if(!_checks.contains("EDIT")){
      _checks.add("EDIT");
    }

    _entity.firstWhere((test) => test.eid == entity.eid).admin = _admins.join(",");
    _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload(user,"Add");

    await Services.updateAdmin(entity.eid, user.uid).then((response){
      if(response=="success"){
        _checks.remove("EDIT");
        _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        reload(user,"Add");
      }
    });
    return false;
  }
  Future<bool> removeAdmin(BuildContext context, EntityModel entity, UserModel user, Function reload)async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> _admins = [];
    List<String> _checks = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    EntityModel entityModel = _entity.firstWhere((test) => test.eid == entity.eid);


    _admins = entityModel.admin.toString().split(",");
    _checks = entityModel.checked.toString().split(",");
    _admins.remove("");
    if(!_admins.contains(user.uid)){
      _admins.remove(user.uid);
    }
    if(!_checks.contains("EDIT")){
      _checks.add("EDIT");
    }

    _entity.firstWhere((test) => test.eid == entity.eid).admin = _admins.join(",");
    _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    reload(user,"Remove");

    await Services.removeAdmin(entity.eid, user.uid).then((response){

      if(response=="success"){
        _checks.remove("EDIT");
        _entity.firstWhere((test) => test.eid == entity.eid).checked = _checks.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        reload(user,"Remove");
      }
    });
    return false;
  }
}