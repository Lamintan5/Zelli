class ManagerModel {
  String mid;
  String? eid;
  String? pid;
  String? duties;
  String? time;
  bool isChecked;

  ManagerModel({required this.mid, this.eid, this.pid, this.duties,this.time, this.isChecked = false});

  factory ManagerModel.fromJson(Map<String, dynamic> json) {
    return ManagerModel(
      mid: json['mid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      duties: json['duties'] as String,
      time: json['time'] as String,
    );
  }
}