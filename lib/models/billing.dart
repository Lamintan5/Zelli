
class BillingModel {
  String bid;
  String eid;
  String pid;
  String bill;
  String businessno;
  String accountno;
  String access;
  String type;
  String account;
  String time;
  String checked;

  BillingModel({required this.bid, required this.eid, required this.pid, required this.bill, required this.businessno,
    required this.type, required this.account,  required this.accountno, required this.access, required this.time, required this.checked});

  factory BillingModel.fromJson(Map<String, dynamic> json) {
    return BillingModel(
      bid: json['bid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      bill: json['bill'] as String,
      businessno: json['businessno'] as String,
      accountno: json['accountno'] as String,
      access: json['access'] as String,
      type: json['type'] as String,
      account: json['account'] as String,
      checked: json['checked'] as String,
      time: json['time'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bid': bid,
      'eid': eid,
      'pid': pid,
      'bill': bill,
      'businessno': businessno,
      'accountno': accountno,
      'access': access,
      'type': type,
      'account': account,
      'checked': checked,
      'time': time,
    };
  }
}