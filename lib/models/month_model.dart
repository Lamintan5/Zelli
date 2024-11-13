class MonthModel {
  int year;
  int month;
  String monthName;
  double amount;
  double balance;

  MonthModel({required this.year, required this.monthName, required this.month, required this.amount, required this.balance});

  // Copy constructor
  MonthModel.copy(MonthModel original)
      : year = original.year,
        month = original.month,
        monthName = original.monthName,
        amount = original.amount,
        balance = original.balance;
}