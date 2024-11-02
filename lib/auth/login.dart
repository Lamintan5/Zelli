import 'dart:io';

import 'package:Zelli/auth/reset.dart';
import 'package:Zelli/auth/sign_up.dart';
import 'package:Zelli/resources/socket.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/google_signin_api.dart';
import '../home/home_screen.dart';
import '../home/web_home.dart';
import '../main.dart';
import '../models/data.dart';
import '../models/users.dart';
import '../resources/services.dart';
import '../utils/colors.dart';
import '../widgets/dialogs/dialog_ipaddress.dart';
import '../widgets/logo/row_logo.dart';
import '../widgets/text/emailTextFormWidget.dart';
import '../widgets/text/text_filed_input.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<UserModel> _user = [];
  late UserModel userModel;
  List<UserModel> fltUsrs = [];
  bool obsecure = true;
  bool select = false;
  bool checked = true;
  String id = '';
  bool _isLoading = false;
  String email = '';

  String token = '';
  List<String> tokens = [];


  _getUser()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      _isLoading = true;
    });
    _user = await Services().getUser(email==""?_emailController.text.trim().toString():email);
    userModel = _user.first;
    token = Platform.isAndroid || Platform.isIOS ? deviceModel.id! : "";
    tokens = userModel.token.toString().split(",");
    tokens.add(token);
    tokens.remove("");
    await Services.updateToken(userModel.uid, tokens.join(",")).then((value){
      print("Token : $token, ${value}");
    });
    await Services.updateToken(userModel.uid, token);
    sharedPreferences.setString('uid', userModel.uid.toString());
    sharedPreferences.setString('username', userModel.username.toString());
    sharedPreferences.setString('first', userModel.firstname.toString());
    sharedPreferences.setString('last', userModel.lastname.toString());
    sharedPreferences.setString('image', userModel.image.toString());
    sharedPreferences.setString('email', userModel.email.toString());
    sharedPreferences.setString('phone', userModel.phone.toString());
    sharedPreferences.setString('status', userModel.status.toString());
    sharedPreferences.setString('token', token);
    sharedPreferences.setString('password', userModel.password.toString());
    sharedPreferences.setString('country', userModel.country.toString());
    currentUser = UserModel(
      uid: userModel.uid.toString(),
      firstname: userModel.firstname,
      lastname: userModel.lastname,
      username: userModel.username,
      email: userModel.email.toString(),
      phone: userModel.phone.toString(),
      image: userModel.image.toString(),
      password: userModel.password.toString(),
      status: userModel.status,
      token:  token,
      country: userModel.country
    );
    await SocketManager().getDetails();
    Get.snackbar(
        'Authentication',
        'User account logged in successfully',
        shouldIconPulse: true,
        icon: Icon(Icons.check, color: Colors.green),
        maxWidth: 500
    );
    Get.offAll(()=>Platform.isAndroid || Platform.isIOS
        ? HomeScreen()
        : WebHome(), transition: Transition.fadeIn);      _isLoading = false;
  }
  _loginUser()async{

    setState(() {
      _isLoading = true;
    });
    var response;
    if (email == "") {
      response = await Services.loginUsers(_emailController.text.trim().toString(), _passwordController.text.trim().toString());
    } else {
      response = await Services.loginUserWithEmail(email);
    }
    print("Response $response");
    if(response.contains('Success')){
      _getUser();
    }
    else if(response.contains('Error')){
      Get.snackbar(
          'Authentication',
          'Invalid credentials. Please check you email or password',
          shouldIconPulse: true,
          icon: Icon(Icons.close, color: Colors.red),
          maxWidth: 500
      );
      setState(() {
        _isLoading = false;
      });
    }
    else {
      Get.snackbar(
        'Authentication',
        'mmhmm, 🤔 seems like something went wrong. Please try again.',
        shouldIconPulse: true,
        maxWidth: 500,
        icon: Icon(Icons.close, color: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }
  void checkid() {
    email = "";
    if(_emailController.text.isEmpty) {
      Get.snackbar(
          "Error",
          "Please Enter your Email Address!",
          icon: Icon(Icons.error),
          maxWidth: 500,
          shouldIconPulse:true
      );
    } else if(_passwordController.text.isEmpty) {
      Get.snackbar(
          "Error",
          "Please enter your password!",
          icon: Icon(Icons.error),
          maxWidth: 500,
          shouldIconPulse:true
      );
    } else {
      setState((){
        _loginUser();
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(deviceModel.id==null){
      SocketManager().initPlatform().then((value){
        setState(() {

        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final boldBtn = TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RowLogo(text: 'Login Account',),
                      IconButton(
                          onPressed: (){dialogIpAddress(context);},
                          icon: Icon((Icons.settings))
                      )
                    ],
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 450,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text('Hello',style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Login or '),
                                  InkWell(
                                      onTap: (){
                                        Get.to(() => SignUp(), transition: Transition.rightToLeft);
                                      },
                                      child: Text("Create Account", style: boldBtn,))
                                ],
                              ),
                              SizedBox(height: 30,),
                              EmailTextFormWidget(
                                controller: _emailController,
                              ),
                              SizedBox(height: 20,),
                              TextFieldInput(
                                textEditingController: _passwordController,
                                labelText: "Password",
                                textInputType: TextInputType.text,
                                isPass: obsecure,
                                srfIcon: IconButton(
                                    onPressed: (){
                                      setState(() {
                                        obsecure = !obsecure;
                                      });
                                    },
                                    icon: Icon(obsecure?CupertinoIcons.eye: CupertinoIcons.eye_slash)
                                ),
                                prxIcon:Icon(Icons.lock_outline),
                              ),
                              SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                      onTap: (){
                                        Get.to(() => Reset(), transition: Transition.rightToLeft);
                                      },
                                      borderRadius: BorderRadius.circular(5),
                                      child: Text("Forgot your password?", style: TextStyle(fontWeight: FontWeight.w500, color: CupertinoColors.systemBlue),)
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              MaterialButton(
                                onPressed: checkid,
                                splashColor: CupertinoColors.systemBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                padding: EdgeInsets.symmetric(vertical: 18),
                                color: CupertinoColors.activeBlue,
                                minWidth: 400,
                                child: _isLoading
                                    ? SizedBox(width: 15, height: 15,child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,),)
                                    : Text("Continue"),
                              ),
                              SizedBox(height: 30,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                                  Text('  or  '),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: "Login with Facebook",
                                    child: InkWell(
                                      onTap:(){},
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        width: 65, height: 65,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: CupertinoColors.activeBlue,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2, color: Colors.blue
                                            )
                                        ),
                                        child: Image.asset(
                                          'assets/add/fb.png',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Tooltip(
                                    message: "Login with Google",
                                    child: InkWell(
                                      onTap:signIn,
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        width: 65, height: 65,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: color2,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2, color: color1
                                            )
                                        ),
                                        child: Image.asset(
                                          'assets/add/google_2.png',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Tooltip(
                                    message: "Login with Apple",
                                    child: InkWell(
                                      onTap: (){},
                                      borderRadius: BorderRadius.circular(15),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        width: 65, height: 65,
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: color2,
                                            borderRadius: BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2, color: color1
                                            )
                                        ),
                                        child: Image.asset(
                                          Theme.of(context).brightness == Brightness.dark?'assets/add/apple_2.png' : 'assets/add/apple.png',
                                          height: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    Data().message,
                    style: TextStyle(color: secondaryColor, fontSize: 11),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  void dialogIpAddress(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        builder: (context) => Dialog(
          backgroundColor: dilogbg,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
          ),
          child: SizedBox(width: 400,
            child: DialogIpaddress(),
          ),
        ), context: context
    );
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }
  Future signIn()async{
    final user = await GoogleSignInApi.login();
    if(user==null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login unsuccessful'),
            showCloseIcon: true,
          )
      );
    } else {
      email = user.email;
      _loginUser();
      await GoogleSignInApi.logout();
    }
  }
}
