import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'login_response.dart';

class APIService {
  static var client  = http.Client();

  static Future<LogInResponseModel> otpLogin (String email) async {
    var url = Uri.http(Config.apiURL, "/api/otp-login");
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
    var url = Uri.http(Config.apiURL, "/api/otp-verify");
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
    var url = Uri.http(Config.apiURL, Config.otpLoginAPI);
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
    var url = Uri.http(Config.apiURL, Config.otpVerifyAPI);
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
}