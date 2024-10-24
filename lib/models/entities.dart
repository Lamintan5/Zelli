import 'dart:io';

class EntityModel {
  String eid;
  String? pid;
  String? admin;
  String? title;
  String? category;
  String? image;
  String? due;
  String? late;
  String? utilities;
  String? location;
  String? time;
  String checked;

  EntityModel({required this.eid, this.pid, this.admin, this.title, this.category,this.image,this.location, this.due,this.late, this.utilities,this.time, this.checked = "false"});

  factory EntityModel.fromJson(Map<String, dynamic> json) {
    return EntityModel(
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      admin: json['admin'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      image: json['image'] as String,
      due: json['due'] as String,
      late: json['late'] as String,
      utilities: json['utilities'] as String,
      location: json['location'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'eid': eid,
      'pid': pid,
      'admin': admin,
      'title': title,
      'category': category,
      'image': image,
      'due': due,
      'late': late,
      'location': location,
      'utilities': utilities,
      'checked': checked,
      'time': time,

    };
  }
}