import 'dart:convert';

import 'package:Zelli/home/options/verify_otp.dart';
import 'package:Zelli/main.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';

import '../../api/api_service.dart';
import '../../utils/colors.dart';
import '../../widgets/text/emailTextFormWidget.dart';
import '../../widgets/text/text_filed_input.dart';


class ChangeEmail extends StatefulWidget {
  final Function changeData;
  const ChangeEmail({super.key, required this.changeData});

  @override
  State<ChangeEmail> createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool obsecure = true;
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: color2,
        title: Text("E-mail", style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20,),
              Row(),
              Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(width: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mail, size: 25,),
                              SizedBox(width: 10,),
                              Text("Change E-mail Address",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                            ],
                          ),
                          Text(
                            'In order to change your current email address, please enter your new email and ensure that you have entered your current password. An OTP code will be sent to your new email to verify your email address',
                            style: TextStyle(fontSize: 12, color: secondaryColor),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: 20,),
                          EmailTextFormWidget(controller: _email),
                          SizedBox(height: 20,),
                          TextFieldInput(
                            textEditingController: _password,
                            labelText: "Password",
                            textInputType: TextInputType.text,
                            isPass: obsecure,
                            srfIcon: IconButton(
                                onPressed: (){
                                  setState(() {
                                    obsecure =! obsecure;
                                  });
                                },
                                icon: Icon(obsecure?Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                            validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password.';
                              }
                              if (md5.convert(utf8.encode(value!)).toString()!= currentUser.password) {
                                return 'Please Enter the correct password';
                              }

                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              InkWell(
                onTap: (){
                  final form = formKey.currentState!;
                  if(form.validate()) {
                    _verifyEmail();
                  }
                },
                child: Container(
                  width: 400,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        width: 1,color: color2
                    ),
                  ),
                  child: Center(child: _isLoading
                      ? SizedBox(width: 15, height: 15,child: CircularProgressIndicator(color: color2, strokeWidth: 2,))
                      : Text("Change Email")),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
  _verifyEmail()async{
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _isLoading = true;
    });
    APIService.otpLogin(_email.text.trim()).then((response)async{
      print(response.data);
      setState(() {
        _isLoading = false;
      });
      if(response.data != null){
        Get.to(()=>VerifyOTP(email: _email.text.trim(), otpHash: response.data!, changeData: widget.changeData,), transition: Transition.rightToLeft);
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
}
