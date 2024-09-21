class DutiesModel {
  String did;
  String? eid;
  String? pid;
  String? duties;
  String? checked;

  DutiesModel({required this.did, this.eid, this.pid, this.duties, this.checked});

  factory DutiesModel.fromJson(Map<String, dynamic> json) {
    return DutiesModel(
      did: json['did'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      duties: json['duties'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'did': did,
      'eid': eid,
      'pid': pid,
      'duties': duties,
      'checked': checked,
    };
  }
}