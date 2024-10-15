import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../api/api_service.dart';
import '../home/home_screen.dart';
import '../home/web_home.dart';
import '../main.dart';
import '../models/users.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import '../utils/colors.dart';
import '../widgets/time_counter.dart';

class VerifyEmail extends StatefulWidget {
  final UserModel userModel;
  final String otpHash;
  const VerifyEmail(
      {super.key, required this.otpHash, required this.userModel});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  String _otpCode = "";
  bool isMatch = true;
  final int _otpCodeLength = 6;
  bool _loading = false;
  String _hashCode = "";
  late UserModel user;
  String token = '';
  int targetTimestamp = 0;

  _resend() {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    APIService.otpLogin(widget.userModel.email!).then((response) async {
      if (response.data != null) {
        _hashCode = response.data!;
        targetTimestamp = int.parse(response.data!.split(".").last.toString());
        _otpCode = "";
        Get.snackbar(
            "Resend OTP",
            "New OTP has been sent to ${widget.userModel.email} please verify your email address with the new OTP",
            maxWidth: 500,
            icon: Icon(Icons.password));
        setState(() {
          _loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "mhmm🤔 seems like something went wrong please try again",
            style: TextStyle(color: revers),
          ),
          backgroundColor: dilogbg,
          behavior: SnackBarBehavior.floating,
        ));
        setState(() {
          _loading = false;
        });
      }
    });
  }

  _verifyOTP() {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    APIService.verifyOTP(widget.userModel.email!, _hashCode, _otpCode)
        .then((response) async {
      if (response.data == "Success") {
        _registerUsers();
      } else {
        setState(() {
          _otpCode = "";
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Email Verification : ${response.data}",
            style: TextStyle(color: revers),
          ),
          backgroundColor: dilogbg,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });
  }

  _registerUsers()async{
    Services.registerUsers(
        user.uid,
        user.username!,
        user.firstname!,
        user.lastname!,
        user.email!,
        user.phone!,
        user.password!,
        user.image =="" || user.image.toString().contains("https://")? null :  File(user.image!),
        user.image.toString(),
        "",token,user.country.toString()).then((response) async{
          print(response);
      final String responseString = await response.stream.bytesToString();

      if (responseString.contains('Exists')) {
        setState(() {
          _loading = false;
        });
        Get.snackbar(
          'Authentication',
          'Username already exists. Please try a different username.',
          maxWidth: 500,
          shouldIconPulse: true,
          icon: Icon(Icons.error, color: Colors.red),
        );
        //  Navigator.pop(context);
      }
      else if (responseString.contains('Error')) {
        setState(() {
          _loading = false;
        });
        Get.snackbar(
          'Authentication',
          'Email already registered. Please try a different email address.',
          maxWidth: 500,
          shouldIconPulse: true,
          icon: Icon(Icons.error, color: Colors.red),
        );
      }
      else if (responseString.contains('Success')) {
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('uid', user.uid);
        sharedPreferences.setString('first', user.firstname.toString());
        sharedPreferences.setString('last', user.lastname.toString());
        sharedPreferences.setString('username', user.username.toString());
        sharedPreferences.setString('email', user.email.toString());
        sharedPreferences.setString('image', user.image.toString());
        sharedPreferences.setString('phone', user.phone.toString());
        sharedPreferences.setString('token', token);
        sharedPreferences.setString('password', md5.convert(utf8.encode(user.password.toString())).toString());
        sharedPreferences.setString('country', user.country.toString());
        currentUser = UserModel(
          uid: user.uid.toString(),
          firstname: user.firstname,
          lastname: user.lastname,
          username: user.username,
          email: user.email.toString(),
          phone: user.phone.toString(),
          image: user.image.toString(),
          token: token,
          password: user.password,
          status: user.status,
          country: user.country,
        );
        if(Platform.isAndroid || Platform.isIOS){
          Get.offAll(()=>HomeScreen(), transition: Transition.fadeIn);
        } else {
          Get.offAll(()=>WebHome(), transition: Transition.fadeIn);
        }
        Get.snackbar(
          'Authentication',
          'User account created successfully.',
          maxWidth: 500,
          shouldIconPulse: true,
          icon: Icon(Icons.check, color: Colors.green),
        );
        setState(() {
          _loading = false;
        });
      }
      else {
        Get.snackbar(
          'Authentication',
          'An error occurred. please try again',
          maxWidth: 500,
          shouldIconPulse: true,
          icon: Icon(Icons.error, color: Colors.red),
        );
        setState(() {
          _loading = false;
        });
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(deviceModel.id==null){
      SocketManager().initPlatform();
    }
    _hashCode = widget.otpHash;
    targetTimestamp = int.parse(widget.otpHash.split(".").last);
    _hashCode = widget.otpHash;
    user = widget.userModel;
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final inputBorder =
    OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back_ios),
                    iconSize: 20,
                  ),
                  Expanded(child: SizedBox()),
                  TimeCounter(time: targetTimestamp,)
                ],
              ),
              Expanded(
                  child: SizedBox(width: 450,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Verify Email",
                              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "We have sent an OTP to ${widget.userModel.email!.replaceRange(4, widget.userModel.email!.length - 5, "*******")}. Please enter the code below to verify your email address",
                              style: TextStyle(color: secondaryColor),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: 450,
                          child: PinFieldAutoFill(
                            autoFocus: true,
                            decoration: BoxLooseDecoration(
                              textStyle: TextStyle(color: isMatch ? revers : Colors.red),
                              gapSpace: 5,
                              strokeWidth: 1.5,
                              radius: Radius.circular(5),
                              strokeColorBuilder:
                              FixedColorBuilder(isMatch ? color5 : Colors.red),
                            ),
                            currentCode: _otpCode,
                            codeLength: _otpCodeLength,
                            onCodeChanged: (code) {
                              if (code!.length == _otpCodeLength) {
                                _otpCode = code;
                              }
                            },
                            onCodeSubmitted: (value) {
                              print("Submitted");
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextButton(onPressed: (){
                          if(_loading){

                          } else{
                           _resend();
                          }
                        }, child: _loading
                            ? Text("Loading...")
                            : Text("Resend")),
                        Expanded(child: SizedBox()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: MaterialButton(
                            onPressed: (){
                              if(_loading){

                              } else {
                                _verifyOTP();
                              }
                            },
                            child: _loading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)) : Text("Continue"),
                            minWidth: 500,
                            color: CupertinoColors.activeBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}
