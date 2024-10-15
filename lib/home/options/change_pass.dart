import 'dart:convert';
import 'dart:developer';

import 'package:Zelli/main.dart';
import 'package:Zelli/resources/services.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/colors.dart';
import '../../widgets/text/text_filed_input.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({super.key});

  @override
  State<ChangePass> createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  TextEditingController _current = TextEditingController();
  TextEditingController _newpass = TextEditingController();
  TextEditingController _repass = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

  _update()async{
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Services.updatePassword(currentUser.uid, _repass.text.trim()).then((response){
      if(response=="success"){
        Navigator.pop(context);
        sharedPreferences.setString('password', _repass.text.trim().toString());
        currentUser.password = _repass.text.trim().toString();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Password update", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            )
        );

      } else if(response=="error"){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Password was not update.", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: "Try Again",
                onPressed: _update,
              ),
            )
        );
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("mhmm🤔 seems like something went wrong please try again", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            )
        );
      }
      setState(() {
        _loading = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26; 
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: reverse,
        title: Text("Password", style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 20,),
              Row(),
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(width: 500,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LineIcon.lock(),
                            SizedBox(width: 5,),
                            Text("Change Password",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text('In order to protect your account, make sure your password:'),
                        SizedBox(height: 10,),
                        Text('●   Is longer than 7 characters',style: TextStyle(color: secondaryColor),),
                        Text('●   Does not match or significantly contain your username, e.g. do not use \'username123\'.',style: TextStyle(color: secondaryColor)),
                        Text('●   Make sure your new pass word is not the same as the current password',style: TextStyle(color: secondaryColor)),
                        SizedBox(height: 20,),
                        Text("Current password"),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _current,
                          hintText: "Current Password",
                          isPass: true,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter current password.';
                            }
                            if (md5.convert(utf8.encode(value)).toString()!= currentUser.password) {
                              return 'Please enter the correct password.';
                            }
                          },
                        ),
                        SizedBox(height: 10,),
                        Text("New password"),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _newpass,
                          hintText: "New Password",
                          isPass: true,
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password.';
                            }
                            if (value == currentUser.password) {
                              return 'New password must different from current password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long.';
                            }
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                              return 'Password must contain at least one uppercase letter.';
                            }
                            if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 4) {
                              return 'Password must contain at least four digits.';
                            }
                            if (!value.contains(RegExp(r'[!@#\$%^&*()_+{}\[\]:;<>,.?~\\-]'))) {
                              return 'Password must contain at least one special character.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10,),
                        Text("Re-enter Your New password"),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _repass,
                          hintText: "Re-enter Password",
                          isPass: true,
                          validator: (value){
                            if(value != _newpass.text.trim()){
                              return 'Passwords don\'t match. Please check your new password';
                            }
                          },
                        ),
                        SizedBox(height: 40,)
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  final form = formKey.currentState!;
                  if(form.validate()) {
                    _update();
                  }
                },
                child: Container(
                  width: 400,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        width: 1,color: reverse
                    ),
                  ),
                  child: Center(child: _loading? CircularProgressIndicator(color: reverse, strokeWidth: 2,) : Text("Change Password", style: TextStyle(color: reverse),)),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
