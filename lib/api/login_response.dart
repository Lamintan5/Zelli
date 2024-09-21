import 'dart:convert';

LogInResponseModel logInResponseModel(String str) => LogInResponseModel.fromJson(json.decode(str));

class LogInResponseModel {
  LogInResponseModel({
    required this.message,
    this.data,
  });
  late final String message;
  late final String? data;

  LogInResponseModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data["message"] = message;
    data["data"] = data;

    return data;
  }
}