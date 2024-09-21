import 'package:flutter/cupertino.dart';

class DutyModel {
  String text;
  String message;
  Widget icon;
  bool isChecked;

  DutyModel({required this.text, required this.message, required this.icon, this.isChecked = false});
}