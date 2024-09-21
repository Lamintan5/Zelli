class ThirdModel {
  String eid;
  String? uid;
  String? type;


  ThirdModel({required this.eid, this.uid, this.type});

  factory ThirdModel.fromJson(Map<String, dynamic> json) {
    return ThirdModel(
      eid: json['eid'] as String,
      uid: json['uid'] as String,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "uid" : uid,
      "eid" : eid,
      "type":type,
    };
  }
}