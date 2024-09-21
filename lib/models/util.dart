import 'package:flutter/cupertino.dart';

class UtilModel {
  String text;
  String message;
  Widget icon;
  bool isChecked;

  UtilModel({required this.text, required this.message, required this.icon, this.isChecked = false});
}