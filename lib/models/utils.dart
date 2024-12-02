class UtilsModel {
  String text;
  String period;
  String cost;
  String amount;
  String checked;

  UtilsModel({required this.text, required this.period, required this.amount, this.checked = "false", required this.cost});

  factory UtilsModel.fromJson(Map<String, dynamic> json) {
    return UtilsModel(
      text: json['text'] as String,
      period: json['period'] as String,
      cost: json['cost'] as String,
      amount: json['amount'] as String,
      checked: json['checked'] as String,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'period': period,
      'amount': amount,
      'cost': cost,
      'checked': checked,
    };
  }
}