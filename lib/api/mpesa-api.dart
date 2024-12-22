import 'dart:convert';
import 'package:Zelli/api/config.dart';
import 'package:http/http.dart' as http;

class MpesaApiService {
  static String _baseUrl = 'http://${Config.apiURL}/api';

  Future<Map<String, dynamic>> getAccessToken() async {
    try {
      final response = await http.get(Uri.parse('${_baseUrl}/access_token'));
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (responseBody['access_token'] != null) {
          print("Access Token: ${responseBody['access_token']}");
          return {
            "success": true,
            "data": responseBody,
          };
        } else {
          print("Failed to fetch token: ${responseBody['message']}");
          return {
            "success": false,
            "error": responseBody['message'] ?? "Unknown error",
          };
        }
      } else {
        print("Error fetching token: ${responseBody['message']}");
        return {
          "success": false,
          "error": responseBody['message'] ?? "Error occurred",
        };
      }
    } catch (e) {
      print("Exception: $e");
      return {
        "success": false,
        "error": "An error occurred while fetching the access token: $e",
      };
    }
  }

  Future<Map<String, dynamic>> registerUrl(String accessToken, String shortCode) async {
    try {
      // Prepare the request body
      final body = jsonEncode({
        'accessToken': accessToken,
        'ShortCode': shortCode,
      });

      // Make a POST request
      final response = await http.post(
        Uri.parse("${_baseUrl}/registerurl"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // Parse the response body
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          print("Register URL Success: ${responseBody['data']}");
          return {
            "success": true,
            "data": responseBody['data'],
          };
        } else {
          print("Register URL Failed: ${responseBody['message']}");
          return {
            "success": false,
            "error": responseBody['message'],
          };
        }
      } else {
        print("Error in registerUrl API: ${responseBody['message']}");
        return {
          "success": false,
          "error": responseBody['message'] ?? "Unknown error",
        };
      }
    } catch (e) {
      print("Exception in registerUrl API: $e");
      return {
        "success": false,
        "error": "An error occurred: $e",
      };
    }
  }

  Future<Map<String, dynamic>> stkPush({
    required String accessToken,
    required String businessShortCode,
    required String amount,
    required String phoneNumber,
    required String accountReference,
    required Map<String, dynamic> paymodel,
  }) async {
    try {
      final body = jsonEncode({
        'accessToken': accessToken,
        'BusinessShortCode': businessShortCode,
        'Amount': amount,
        'PhoneNumber': phoneNumber,
        'AccountReference': accountReference,
        'paymodel':paymodel
      });

      // Make a POST request
      final response = await http.post(
        Uri.parse("${_baseUrl}/stkpush"),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      // Parse the response body
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['success'] == true) {
          print("STK Push Success: ${responseBody['data']}");
          return {
            "success": true,
            "data": responseBody['data'],
          };
        } else {
          print("STK Push Failed: ${responseBody['message']}");
          return {
            "success": false,
            "error": responseBody['message'],
            "details":responseBody['details'],
          };
        }
      } else {
        print("Error in STK Push API: ${responseBody['message']}");
        return {
          "success": false,
          "error": responseBody['message'] ?? "Unknown error",
          "details":responseBody['details'],
        };
      }
    } catch (e) {
      print("Exception in STK Push API: $e");
      return {
        "success": false,
        "error": "An error occurred: $e",

      };
    }
  }

}
