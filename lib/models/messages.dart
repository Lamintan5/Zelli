class MessModel {
  String mid;
  String? gid;
  String? sourceId;
  String? targetId;
  String? message;
  String? path;
  String? type;
  String? deleted;
  String? seen;
  String? delivered;
  String? checked;
  String? time;

  MessModel({required this.mid, this.gid, this.sourceId, this.targetId, this.message, this.path,this.type, this.deleted,this.seen,this.delivered,this.checked, this.time});

  factory MessModel.fromJson(Map<String, dynamic> json) {
    return MessModel(
      mid: json['mid'] as String,
      gid: json['gid'] as String,
      sourceId: json['sourceId'] as String,
      targetId: json['targetId'] as String,
      message: json['message'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      deleted: json['deleted'] as String,
      seen: json['seen'] as String,
      delivered: json['delivered'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'mid': mid,
      'gid': gid,
      'sourceId': sourceId,
      'targetId': targetId,
      'message': message,
      'path': path,
      'type': type,
      'deleted': deleted,
      'seen': seen,
      'delivered': delivered,
      'checked': checked,
      'time': time,
    };
  }
}