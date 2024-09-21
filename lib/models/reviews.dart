class ReviewModel {
  String rid;
  String? eid;
  String? pid;
  String? uid;
  String? sid;
  String? message;
  String? image;
  String? star;
  String? time;

  ReviewModel({required this.rid, this.eid, this.pid, this.uid, this.sid, this.message,this.image, this.star, this.time});

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rid: json['rid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      uid: json['uid'] as String,
      sid: json['sid'] as String,
      message: json['message'] as String,
      image: json['image'] as String,
      star: json['star'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'rid': rid,
      'eid': eid,
      'pid': pid,
      'uid': uid,
      'sid': sid,
      'message': message,
      'image': image,
      'star': star,
      'time': time,
    };
  }
}