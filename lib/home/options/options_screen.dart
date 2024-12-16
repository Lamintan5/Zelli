import 'package:Zelli/models/messages.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/login.dart';
import '../../main.dart';
import '../../models/users.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../../widgets/dialogs/dialog_ipaddress.dart';
import 'change_email.dart';
import 'change_pass.dart';
import 'change_phone.dart';
import 'edit_profile.dart';

class Options extends StatefulWidget {
  final Function reload;
  const Options({super.key, required this.reload});

  @override
  State<Options> createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  final socketManager = Get.find<SocketManager>();
  bool tenant = false;
  bool pay = false;
  bool accrued = false;
  bool removed = false;

  bool _loading = false;
  bool upload = false;
  bool power = false;


  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final double height = 5;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: revers,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30,),
                      const Text("Settings", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),),
                      const SizedBox(height: 20,),
                      const Row(
                        children: [
                          LineIcon.user(size: 20,),
                          SizedBox(width: 5,),
                          Text("Account", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Divider(
                        color: revers,
                        height: 2,
                      ),
                      const SizedBox(height: 2,),
                      const Text('Update your information to keep your account ', style: TextStyle(color: secondaryColor),),
                      const SizedBox(height: 20,),
                      Card(
                        color: normal,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              OptionButtons(
                                txt: "Edit Profile",
                                icon: LineIcon.edit(),
                                onTap: (){
                                  Get.to(()=> EditProfile(reload: widget.reload,),transition: Transition.rightToLeft);
                                },
                              ),
                              OptionButtons(
                                txt: "Change Password",
                                icon: Icon(Icons.password),
                                onTap: (){
                                  Get.to(()=> ChangePass(),transition: Transition.rightToLeft);
                                },
                              ),
                              OptionButtons(
                                txt: "Change Email",
                                mssg : currentUser.email.toString() ==""||currentUser.email == null? "" :  currentUser.email.toString().replaceRange(4, currentUser.email.toString().length - 4, "**********"),
                                icon: const Icon(Icons.mail),
                                onTap: (){
                                  Get.to(()=>ChangeEmail(changeData: widget.reload,),transition: Transition.rightToLeft);
                                },
                              ),
                              OptionButtons(
                                txt: "Change Phone Number",
                                mssg: currentUser.phone.toString() =="" || currentUser.phone == null? "":currentUser.phone.toString().replaceRange(5, currentUser.phone.toString().length - 3, "*****"),
                                icon: const Icon(Icons.phone_android),
                                onTap: (){
                                  Get.to(()=>const ChangePhone(),transition: Transition.rightToLeft);
                                },
                              ),
                              OptionButtons(txt: "Language", icon: LineIcon.language(),onTap: (){},),
                              OptionButtons(txt: "Location", icon: Icon(Icons.pin_drop),onTap: (){},),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40,),
                      const Row(
                        children: [
                          LineIcon.lock(size: 20,),
                          SizedBox(width: 5,),
                          Text("Privacy", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                        ],
                      ),
                      const SizedBox(height: 8,),
                      Divider(
                        color: revers,
                        height: 2,
                      ),
                      const SizedBox(height: 2,),
                      const Text('Customize your privacy to make experience better', style: TextStyle(color: secondaryColor),),
                      const SizedBox(height: 20,),
                      Card(
                        color: normal,
                        elevation: 10,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              OptionButtons(txt: "Security", icon: LineIcon.lock(),onTap: (){}),
                              OptionButtons(txt: "Login Details", icon: Icon(Icons.login),onTap: (){}),
                              OptionButtons(txt: "Privacy", icon: Icon(Icons.remove_red_eye), onTap: (){},),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20,),
                      Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 5,),
                          Text("More Options", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),),
                        ],
                      ),
                      SizedBox(height: 8,),
                      Divider(
                        color: revers,
                        height: 2,
                      ),
                      SizedBox(height: 2,),
                      Text('Update your information to keep your account ', style: TextStyle(color: secondaryColor),),
                      SizedBox(height: 20,),
                      Card(
                        color: normal,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            children: [
                              OptionButtons(
                                txt: "Currency",
                                icon: LineIcon.globe(),
                                mssg: "Ksh", onTap: () {  },
                              ),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(txt: "Domain",
                                mssg: domain,
                                icon: Icon(Icons.cable), onTap: () { dialogIpAddress(context); },),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(
                                txt: "Auto Upload",
                                icon: Icon(Icons.cloud_upload),
                                action : Switch(
                                    value: upload,
                                    onChanged: (value){
                                      setState(() {
                                        upload = value;
                                      });
                                    }
                                ), onTap: () {  },
                              ),
                              SizedBox(height: height),
                              Divider(color: color1, thickness: 1, height: 1,),
                              SizedBox(height: height),
                              OptionButtons(
                                txt: "Power Saving",
                                icon: Icon(Icons.energy_savings_leaf_outlined),
                                action : Switch(
                                    value: power,
                                    onChanged: (value){
                                      setState(() {
                                        power = value;
                                      });
                                    }
                                ), onTap: () {  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 40,),
                    ],
                  ),
                ),
              ),
            ),
            const Row(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                onTap: (){
                  dialogLogOut(context);
                },
                child: Container(
                  width: 400,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 1,
                        color: revers,
                      )
                  ),
                  child: Center(child: _loading
                      ? SizedBox(
                        width: 15, height: 15,
                        child: CircularProgressIndicator(color: revers,strokeWidth: 2,))
                      :Text("SIGN OUT",style: TextStyle(color: revers),)),
                ),
              ),
            ),
            const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }

  Future logoutUser()async{
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    setState(() {
      _loading = true;
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await Services.updateToken(currentUser.uid, "").then((response){
      if(response=="success"){
        setState(() {
          _loading = false;
        });
        preferences.remove('uid');
        preferences.remove('username');
        preferences.remove('first');
        preferences.remove('last');
        preferences.remove('image');
        preferences.remove('email');
        preferences.remove('phone');
        preferences.remove('status');
        preferences.remove('token');
        preferences.remove('password');
        preferences.remove('country');
        // preferences.remove('unit_profile_showcase');
        preferences.remove('myentity');
        preferences.remove('notmyentity');
        preferences.remove('myunit');
        preferences.remove('myusers');
        preferences.remove('mylease');
        preferences.remove('mymess');
        preferences.remove('mypay');
        preferences.remove('mynotif');
        preferences.remove('mychats');
        preferences.remove('mythird');
        preferences.remove('mystars');
        preferences.remove('myduties');
        preferences.remove('mybills');
        currentUser = UserModel(uid: "", email: "", phone: "", username: "", image: "", token: "", status: "", firstname: "", lastname: "", password: "", time: "", country: "");
        myEntity = [];
        notMyEntity = [];
        myUnits = [];
        myThird = [];
        myUsers = [];
        myLease = [];
        myMess = [];
        myPayment = [];
        myNotif = [];
        myChats = [];
        myThird = [];
        myStars = [];
        myDuties = [];
        myBills = [];
        socketManager.chats.clear();
        socketManager.messages.clear();
        socketManager.notifications.clear();
        socketManager.signout();
        socketManager.disconnect();
        Get.snackbar(
          "User Account",
          "User logged out successfully",
          icon: Icon(Icons.logout),
          maxWidth: 500,
        );
        Get.offAll(()=>LogIn(), transition: Transition.leftToRight);
      }
      else if(response=="error"){
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: dilogbg,
            content: Text("Login out failed", style: TextStyle(color: reverse),),
            action: SnackBarAction(
              label: "Try again",
              onPressed: (){
                logoutUser();
              },
            ),
          )
        );
      }
      else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dilogbg,
              content: Text("mhmm 🤔 something went wrong", style: TextStyle(color: reverse),),
              action: SnackBarAction(
                label: "Try again",
                onPressed: (){
                  logoutUser();
                },
              ),
            )
        );
      }
    });
  }
  void dialogLogOut(BuildContext context, ){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color7 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          backgroundColor: dilogbg,
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
                  DialogTitle(title: "A C C O U N T"),
                  const Text('Are you sure you wish to log out from this account',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryColor, ),
                  ),
                  DoubleCallAction(
                      title: "Sign Out",
                      action: (){
                        Navigator.pop(context);
                        logoutUser();
                  })
                ],
              ),
            ),
          ),
        )
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
              borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(width: 450,
            child: DialogIpaddress(),
          ),
        ), context: context
    );
  }
}
class OptionButtons extends StatelessWidget {
  final String txt;
  final String mssg;
  final Widget icon;
  final Widget action;
  final void Function() onTap;
  const OptionButtons({super.key, required this.onTap, required this.txt, required this.icon, this.mssg = '', this.action = const Icon(Icons.arrow_forward_ios,size: 15,),
  });

  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Row(
          children: [
            icon,
            SizedBox(width: 10,),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(txt,style: TextStyle(fontSize: 15),),
                mssg==''?SizedBox():Text(mssg.toString(), style: TextStyle(color: secondaryColor, fontSize: 11),),
              ],
            ),
            Expanded(child: SizedBox()),
            action
          ],
        ),
      ),
    );
  }
}



