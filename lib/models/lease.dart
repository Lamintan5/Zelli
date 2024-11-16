class LeaseModel {
  String lid;
  String? tid;
  String? ctid;
  String? eid;
  String? pid;
  String? uid;
  String? rent;
  String? deposit;
  String? deduct;
  String? refund;
  String? balance;
  String? start;
  String? end;
  String? checked;

  LeaseModel({required this.lid, this.tid,this.ctid, this.eid,this.pid,this.uid, this.rent, this.deposit,
    this.deduct, this.refund, this.balance, this.start, this.end, this.checked});
  factory LeaseModel.fromJson(Map<String, dynamic> json) {
    return LeaseModel(
      lid: json['lid'] as String,
      tid: json['tid'] as String,
      ctid: json['ctid'] as String,
      eid: json['eid'] as String,
      pid: json['pid'] as String,
      uid: json['uid'] as String,
      rent: json['rent'] as String,
      deposit: json['deposit'] as String,
      deduct: json['deduct'] as String,
      refund: json['refund'] as String,
      balance: json['balance'] as String,
      start: json['start'] as String,
      end: json['end'] as String,
      checked: json['checked'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lid': lid,
      'tid': tid,
      'ctid': ctid,
      'eid': eid,
      'pid': pid,
      'uid': uid,
      'rent': rent,
      'deposit': deposit,
      'deduct': deduct,
      'refund': refund,
      'balance': balance,
      'start': start,
      'end': end,
      'checked': checked,
    };
  }
}