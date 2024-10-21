class StarModel {
  String sid;
  String? pid;
  String? rid;
  String? eid;
  String? uid;
  String? rate;
  String? type;
  String? time;
  String? checked;

  StarModel({required this.sid, this.pid, this.rid, this.eid,this.uid, this.rate, this.type, this.time, this.checked});


  factory StarModel.fromJson(Map<String, dynamic> json) {
    return StarModel(
      sid: json['sid'] as String,
      pid: json['pid'] as String,
      rid: json['rid'] as String,
      eid: json['eid'] as String,
      uid: json['uid'] as String,
      rate: json['rate'] as String,
      type: json['type'] as String,
      time: json['time'] as String,
      checked: json['checked'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sid" : sid,
      "pid" : pid,
      "rid" : rid,
      "eid" : eid,
      "uid" : uid,
      "rate" : rate,
      "type" : type,
      "checked":checked,
      "time":time,
    };
  }

}