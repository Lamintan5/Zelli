class NotifModel {
  String nid;
  String? sid;
  String? rid;
  String? eid;
  String? pid;
  String? text;
  String? message;
  String? actions;
  String? seen;
  String? type;
  String? time;
  String? image;
  String? deleted;
  String? checked;

  NotifModel({required this.nid, this.sid, this.rid, this.eid, this.pid, this.text, this.message,
    this.actions, this.type, this.seen, this.image, this.time, this.deleted, this.checked});

  factory NotifModel.fromJson(Map<String, dynamic> json) {
    return NotifModel(
      nid: json['nid'] as String,
      sid: json['sid'] as String,
      rid: json['rid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      text: json['text'] as String,
      message: json['message'] as String,
      actions: json['actions'] as String,
      image: json['image'] as String,
      type: json['type'] as String,
      seen: json['seen'] as String,
      deleted: json['deleted'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nid': nid,
      'sid': sid,
      'rid': rid,
      'eid': eid,
      'pid': pid,
      'text': text,
      'message': message,
      'actions': actions,
      'image': image,
      'type': type,
      'seen': seen,
      'deleted': deleted,
      'checked': checked,
      'time': time,
    };
  }
}