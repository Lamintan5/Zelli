class UtilsModel {
  String text;
  String period;
  String amount;
  String checked;

  UtilsModel({required this.text, required this.period, required this.amount, this.checked = "false"});

  factory UtilsModel.fromJson(Map<String, dynamic> json) {
    return UtilsModel(
      text: json['text'] as String,
      period: json['period'] as String,
      amount: json['amount'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'period': period,
      'amount': amount,
      'checked': checked,
    };
  }
}