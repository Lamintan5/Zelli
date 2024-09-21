import 'package:Zelli/main.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../api/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/counter.dart';

class VerifyOTP extends StatefulWidget {
  final String email;
  final String otpHash;
  final Function changeData;
  const VerifyOTP({super.key, required this.email, required this.otpHash, required this.changeData});

  @override
  State<VerifyOTP> createState() => _VerifyOTPState();
}

class _VerifyOTPState extends State<VerifyOTP> {
  String _otpCode = "";
  bool isMatch = true;
  final int _otpCodeLength = 6;
  bool _loading = false;
  String _hashCode = "";

  _resend(){
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    APIService.otpLogin(widget.email).then((response)async{
      print(response.data);
      setState(() {
        _loading = false;
      });
      if(response.data != null){
        setState(() {
          _hashCode = response.data!;
        });
        Get.snackbar(
            "Resend OTP",
            "New OTP has been sent to ${widget.email} please verify your email address with the new OTP",
            icon: Icon(Icons.password)
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("mhmm🤔 seems like something went wrong please try again", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    });
  }
  _verifyOTP(){
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    APIService.verifyOTP(widget.email, widget.otpHash, _otpCode).then((response)async{
      if(response.data != null){
        if(response.data=="Success"){
          _updateEmail();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Email Verification : ${response.data}", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
            )
        );
      }
    });
  }

  _updateEmail(){
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    // Services.updateEmail(currentUser.uid, widget.email).then((response) {
    //     if(response=="success"){
    //       widget.changeData();
    //       currentUser.email = widget.email;
    //       Navigator.pop(context);
    //       Navigator.pop(context);
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text("Email updated", style: TextStyle(color: revers),),
    //             backgroundColor: dilogbg,
    //             behavior: SnackBarBehavior.floating,
    //           )
    //       );
    //     } else if(response=="Exists"){
    //       Navigator.pop(context);
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text("Email already exists. Please try another email address", style: TextStyle(color: revers),),
    //             backgroundColor: dilogbg,
    //             behavior: SnackBarBehavior.floating,
    //           )
    //       );
    //     } else if(response=="error"){
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text("Email was not updated", style: TextStyle(color: revers),),
    //             backgroundColor: dilogbg,
    //             behavior: SnackBarBehavior.floating,
    //           )
    //       );
    //     } else {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(
    //             content: Text("mhmm:🤔 seems like something went wrong please try again", style: TextStyle(color: revers),),
    //             backgroundColor: dilogbg,
    //             behavior: SnackBarBehavior.floating,
    //           )
    //       );
    //     }
    // });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _hashCode = widget.otpHash;
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
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context)
    );
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.arrow_back_ios), iconSize: 20,),
                Expanded(child: SizedBox()),
                TimeCounter()
              ],
            ),
            SizedBox(height: 20,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Verify Email",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                Text(
                  "We have sent an OTP to ${widget.email!.replaceRange(4, widget.email!.length - 5, "*******")}. Please enter the code below to verify your email address",
                  style: TextStyle(color: secondaryColor),
                ),
              ],
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: 450,
              child: PinFieldAutoFill(
                autoFocus: true,
                decoration: BoxLooseDecoration(
                  textStyle: TextStyle(color: isMatch?revers:Colors.red),
                  gapSpace: 5,
                  strokeWidth: 1.5,
                  strokeColorBuilder: FixedColorBuilder(isMatch?color5:Colors.red),
                ),
                currentCode: _otpCode,
                codeLength:_otpCodeLength,
                onCodeChanged: (code){
                  if(code!.length == _otpCodeLength){
                    _otpCode = code;
                  }
                },
                onCodeSubmitted: (value){
                  print("Submitted");
                },
              ),
            ),
            SizedBox(height: 20,),
            TextButton(onPressed: _resend, child: Text("Resend")),
            Expanded(child: SizedBox()),
            InkWell(
              onTap: (){
                _verifyOTP();
              },
              child: Container(
                width: 400,
                padding: EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(child: _loading
                    ? SizedBox(width: 15, height: 15,child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black,))
                    : Text("CONTINUE", style: TextStyle(color: Colors.black),)),
              ),
            ),
            SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}
