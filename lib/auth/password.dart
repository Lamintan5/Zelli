import 'dart:io';

import 'package:Zelli/api/google_signin_api.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:line_icons/line_icon.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home/home_screen.dart';
import '../home/web_home.dart';
import '../main.dart';
import '../resources/services.dart';
import '../utils/colors.dart';
import '../widgets/dialogs/dialog_user_info.dart';
import '../widgets/text/text_filed_input.dart';

class PasswordScreen extends StatefulWidget {
  final GoogleSignInAccount user;
  const PasswordScreen({super.key, required this.user});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController _newpass = TextEditingController();
  TextEditingController _repass = TextEditingController();
  Country _country = CountryParser.parseCountryCode('US');
  final formKey = GlobalKey<FormState>();
  bool _loading = false;

  late UserModel user;

  _registerUsers()async{
    setState(() {
      _loading = true;
    });
    Services.registerUsers(
        user.uid,
        user.username!,
        user.firstname!,
        user.lastname!,
        user.email!,
        user.phone!,
        _repass.text.toString(),
        user.image =="" || user.image!.contains("https://")? null : File(user.image!),
        user.image.toString(),
        "",user.token!,user.country.toString()).then((response) async{
      final String responseString = await response.stream.bytesToString();
        print(responseString);
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
      else if (responseString.contains('Success'))
      {
        final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        sharedPreferences.setString('uid', user.uid);
        sharedPreferences.setString('first', user.firstname.toString());
        sharedPreferences.setString('last', user.lastname.toString());
        sharedPreferences.setString('username', user.username.toString());
        sharedPreferences.setString('email', user.email.toString());
        sharedPreferences.setString('image', user.image.toString());
        sharedPreferences.setString('phone', user.phone.toString());
        sharedPreferences.setString('token', user.token.toString());
        sharedPreferences.setString('password', _repass.text.toString());
        sharedPreferences.setString('country', user.country.toString());
        currentUser = UserModel(
          uid: user.uid.toString(),
          firstname: user.firstname,
          lastname: user.lastname,
          username: user.username,
          email: user.email.toString(),
          phone: user.phone.toString(),
          image: user.image.toString(),
          token: user.token.toString(),
          password: _repass.text,
          status: user.status,
          country: user.country
        );
        if(Platform.isAndroid || Platform.isIOS){
          Get.offAll(()=>HomeScreen(), transition: Transition.fadeIn);
        } else {
          Get.offAll(()=>WebHome(), transition: Transition.fadeIn);
        }
        await GoogleSignInApi.logout();
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
      } else {
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
    user = UserModel(
        uid: widget.user.id,
        username: widget.user.displayName.toString().split(" ").first,
        firstname: widget.user.displayName.toString().split(" ").first,
        lastname: widget.user.displayName.toString().split(" ").last,
        email: widget.user.email,
        phone: "",
        password: "",
        image: widget.user.photoUrl,
        token: "",
        status: "",
        country: "",
        time: DateTime.now().toString()
    );
    if(Platform.isAndroid || Platform.isIOS){
      initPlatform();
    }
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
    final style = TextStyle(fontSize: 11, color: reverse);
    final bold = TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: reverse);
    return WillPopScope(
      onWillPop: ()async {
        await GoogleSignInApi.logout();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Password", style: TextStyle(fontWeight: FontWeight.normal),),
          actions: [
          ],
        ),
        body: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              SizedBox(height: 10,),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              user.image == null
                                  ?  ClipOval(
                                child: Image.asset("assets/add/default_profile.png", width: 40, height: 40,),
                              )
                                  : !user.image.toString().contains("https://") && user.image.toString().contains("/") || user.image.toString().contains("\\")
                                  ? CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.transparent,
                                backgroundImage: FileImage(File(user.image!)),
                              )
                                  : UserProfile(image: user.image.toString(), radius: 20,),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Image.asset(
                                  'assets/add/google_2.png',
                                  height: 15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "Username : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: user.username,
                                              style: bold
                                          )
                                        ]
                                    )
                                ),
                                RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "First Name : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: "${user.firstname}, ",
                                              style: bold
                                          ),
                                          TextSpan(
                                              text: "Last Name : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: user.lastname,
                                              style: bold
                                          ),
                                        ]
                                    )
                                ),
                                RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "Email Address : ",
                                              style: style
                                          ),
                                          TextSpan(
                                              text: user.email.toString(),
                                              style: bold
                                          )
                                        ]
                                    )
                                ),
                              ],
                            ),
                          ),
                          IconButton(onPressed: (){dialogUserInfo(context);}, icon: Icon(Icons.edit))
                        ],
                      ),
                      user.phone.toString()==""
                          ? Text(
                            "Please enter your phone number by clicking the edit button",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          )
                          : RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Phone number set to ",
                                    style: style
                                  ),
                                  TextSpan(
                                    text: "${user.phone}, ",
                                    style: bold
                                  ),
                                  TextSpan(
                                    text: "billing set to",
                                    style: style
                                  ),
                                  TextSpan(
                                    text: _country.countryCode,
                                  )
                                ]
                              ),
                            )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Row(),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: 500,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            LineIcon.lock(),
                            SizedBox(width: 5),
                            Text("Enter Your Password",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text('In order to protect your account, make sure your password:'),
                        SizedBox(height: 10,),
                        Text('●   Is longer than 7 characters',style: TextStyle(color: secondaryColor),),
                        Text('●   Does not match or significantly contain your username, e.g. do not use \'username123\'.',style: TextStyle(color: secondaryColor)),
                        Text('●   Make sure your new pass word is not the same as the current password',style: TextStyle(color: secondaryColor)),
                        SizedBox(height: 20,),
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
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long.';
                            }
                            if (!value.contains(RegExp(r'[A-Z]'))) {
                              return 'Password must contain at least one uppercase letter.';
                            }
                            if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 3) {
                              return 'Password must contain at least three digits.';
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
                    if(user.phone.toString()==""){
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please enter you phone number by clicking on the edit button"),
                            showCloseIcon: true,
                          )
                      );
                    } else {
                      _registerUsers();
                    }
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
                  child: Center(child: _loading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: reverse, strokeWidth: 2,))
                      : Text("Finish", style: TextStyle(color: reverse),)),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
  void dialogUserInfo(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
      barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: dilogbg,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(
            width: 450,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DialogTitle(title: "P R O F I L E"),
                  DialogUserInfo(user: user, change: _change,),
                ],
              ),
            ),
          ),
        ), context: context
    );
  }
  Future<void> initPlatform() async {
    await OneSignal.shared.setAppId("41db0b95-b70f-44a5-a5bf-ad849c74352e");
    await OneSignal.shared.getDeviceState().then((value) {
      print(value!.userId);
      user.token = value.userId!;
      setState(() {

      });
    });
  }
  void _change(UserModel userModel){
    user = userModel;
    _country = CountryParser.parseCountryCode(user.country.toString());
    setState(() {

    });
  }
}
