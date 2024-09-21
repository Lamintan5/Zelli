class PaymentsModel {
  String payid;
  String? pid;
  String? admin;
  String? tid;
  String? lid;
  String? eid;
  String? uid;
  String? payerid;
  String? amount;
  String? balance;
  String? method;
  String? type;
  String? time;
  String? current;
  String? checked;

  PaymentsModel({required this.payid, this.pid, this.admin, this.tid, this.lid, this.eid,this.uid, this.payerid, this.amount, this.balance, this.method, this.type, this.time, this.current, this.checked});
  DateTime get dateTime => DateTime.parse(current.toString());

  factory PaymentsModel.fromJson(Map<String, dynamic> json) {
    return PaymentsModel(
      payid: json['payid'] as String,
      pid: json['pid'] as String,
      admin: json['admin'] as String,
      tid: json['tid'] as String,
      lid: json['lid'] as String,
      eid: json['eid'] as String,
      uid: json['uid'] as String,
      payerid: json['payerid'] as String,
      amount: json['amount'] as String,
      balance: json['balance'] as String,
      method: json['method'] as String,
      type: json['type'] as String,
      time: json['time'] as String,
      current: json['current'] as String,
      checked: json['checked'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "payid" : payid,
      "pid" : pid,
      "admin" : admin,
      "tid" : tid,
      "lid" : lid,
      "eid" : eid,
      "uid" : uid,
      "payerid" : payerid,
      "amount" : amount,
      "balance" : balance,
      "method" : method,
      "type":type,
      "time":time,
      "current":current,
      "checked":checked,
    };
  }

}