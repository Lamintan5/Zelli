class StarModel {
  String sid;
  String? pid;
  String? rid;
  String? eid;
  String? uid;
  String? rate;
  String? type;
  String? time;

  StarModel({required this.sid, this.pid, this.rid, this.eid,this.uid, this.rate, this.type, this.time});


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
    );
  }

  Map<String, dynamic> toJsonAdd() {
    return {
      "sid" : sid,
      "pid" : pid,
      "rid" : rid,
      "eid" : eid,
      "uid" : uid,
      "rate" : rate,
      "type" : type,
      "time":time,
    };
  }

}