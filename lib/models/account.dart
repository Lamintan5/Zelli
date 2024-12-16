class AccountModel {
  String bid;
  String uid;
  String accountno;
  String account;

  AccountModel({required this.bid, required this.uid, required this.accountno, required this.account});

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      bid: json['bid'] as String,
      uid: json['uid'] as String,
      accountno: json['accountno'] as String,
      account: json['account'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'bid': bid,
      'uid': uid,
      'accountno': accountno,
      'account': account,
    };
  }
}