import 'dart:convert';

import 'package:http/http.dart' as http;

import '../main.dart';
import '../models/device.dart';
import 'config.dart';
import 'login_response.dart';

class APIService {
  static var client  = http.Client();
  static String HOST = "zelli.studio5ive.org";

  static Future<LogInResponseModel> otpLogin (String email) async {
    var url = Uri.https(HOST, "/api/otp-login");
    var response = await client.post(
        url,
        headers: {'Content-type':"application/json"},
        body: jsonEncode({
          "email":email
        })
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> verifyOTP (String email, String otpHash, String otpCode) async {
    var url = Uri.https(HOST, "/api/otp-verify");
    var response = await client.post(
        url,
        headers: {'Content-type':"application/json"},
        body: jsonEncode({
          "email":email,
          "otp": otpCode,
          "hash": otpHash
        })
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> otpSmsLogin(String mobileNo) async{
    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json'
    };
    var url = Uri.https(HOST, Config.otpLoginAPI);
    var response = await client.post(url, headers: requestHeaders,
      body: jsonEncode(
        {
          "phone":mobileNo
        },
      ),
    );
    return logInResponseModel(response.body);
  }

  static Future<LogInResponseModel> verifySmsLogin(String mobileNo, String otpHash, String otpCode) async{
    Map<String, String> requestHeaders = {
      'Content-Type' : 'application/json'
    };
    var url = Uri.https(HOST, Config.otpVerifyAPI);
    var response = await client.post(url, headers: requestHeaders,
      body: jsonEncode(
        {
          "phone":mobileNo,
          "otp": otpCode,
          "hash": otpHash
        },
      ),
    );
    return logInResponseModel(response.body);
  }

  Future<void> getUserData(String onesignalId) async {
    print("Started");
    String url = 'https://api.onesignal.com/apps/41db0b95-b70f-44a5-a5bf-ad849c74352e/users/by/onesignal_id/$onesignalId';
    Map<String, String> headers = {
      'Authorization': 'Basic 41db0b95-b70f-44a5-a5bf-ad849c74352e',
      'Content-Type': 'application/json'
    };
    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        deviceModel = DeviceModel(
          onesignalId: data['identity']?['onesignal_id'],

          id: data['subscriptions']?[0]?['id'],
          type: data['subscriptions']?[0]?['type'],
          token: data['subscriptions']?[0]?['token'],
          enabled: data['subscriptions']?[0]?['enabled'],
          notification_types: data['subscriptions']?[0]?['notification_types'],
          session_time: data['subscriptions']?[0]?['session_time'],
          session_count: data['subscriptions']?[0]?['session_count'],
          sdk: data['subscriptions']?[0]?['sdk'],
          device_model: data['subscriptions']?[0]?['device_model'],
          device_os: data['subscriptions']?[0]?['device_os'],
          app_version: data['subscriptions']?[0]?['app_version'],
          net_type: data['subscriptions']?[0]?['net_type'],
          carrier: data['subscriptions']?[0]?['carrier'],

          language: data['properties']?['language'],
          timezone_id: data['properties']?['timezone_id'],
          country: data['properties']?['country'],
          first_active: data['properties']?['first_active'],
          last_active: data['properties']?['last_active'],
          ip: data['properties']?['ip'],
        );

      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}