import 'package:flutter/material.dart';

class RequestModel {
  String id;
  String text;
  String message;
  IconData? icon;
  List<String>? types;

  RequestModel({required this.id, required this.text, required this.message, this.icon, this.types});
}