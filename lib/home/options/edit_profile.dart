import 'dart:convert';
import 'dart:io';

import 'package:Zelli/main.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/profile_images/current_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/camera.dart';
import '../../models/avatars.dart';
import '../../models/data.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../../widgets/dialogs/dialog_title.dart';
import '../../widgets/text/text_filed_input.dart';
import '../../widgets/text/text_format.dart';

class EditProfile extends StatefulWidget {
  final Function reload;
  const EditProfile({super.key, required this.reload});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _username = TextEditingController();
  TextEditingController _first = TextEditingController();
  TextEditingController _last = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _pass = TextEditingController();

  bool _loading = false;
  bool _addimage = false;
  final picker = ImagePicker();
  var pickedImage;
  String imageUrl = '';
  File? _image;
  String type = "";
  final _key = GlobalKey<FormState>();
  final _formkey = GlobalKey<FormState>();
  String firstImage = "";
  String firstType = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _username.text = currentUser.username!;
    _first.text = currentUser.firstname!;
    _last.text = currentUser.lastname!;
    _email.text = currentUser.email!;
    _phone.text = currentUser.phone!;
    firstImage = currentUser.image!;
  }


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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: _formkey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 500,
                    child: Column(
                      children: [
                        Text("Change User Profile Details",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                        Text(
                          'To change your user profile by selecting the fields you want to modify and enter the new information. You can update your name, email, password and photo. Tap on update to confirm your edits. Your profile will be updated immediately.',
                          style: TextStyle(fontSize: 12, color: secondaryColor),

                        ),
                        Expanded(child: SizedBox()),
                        SizedBox(width: 100,height: 100,
                          child: Stack(
                            children: [
                              _image==null && imageUrl == ""
                                  ?CurrentImage(radius: 50,)
                                  : Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  _image != null
                                      ? CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: FileImage(_image!),
                                  )
                                      : imageUrl == ''
                                      ? CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage("assets/add/default_profile.png"),
                                  )
                                      : CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(imageUrl),
                                  ),
                                  _addimage
                                      ? CircularProgressIndicator()
                                      : SizedBox(),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: MaterialButton(
                                  onPressed: (){dialogPickProfile(context);},
                                  color: CupertinoColors.activeBlue,
                                  minWidth: 5,
                                  elevation: 8,
                                  shape: CircleBorder(),
                                  splashColor: CupertinoColors.systemBlue,
                                  child: Icon(Icons.edit, size: 16,color: normal,),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        TextFieldInput(
                          textEditingController: _username,
                          labelText: "Username",
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter your Username';
                            }
                          },
                        ),
                        SizedBox(height: 10,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFieldInput(
                                textEditingController: _first,
                                labelText: "First Name",
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your First Name';
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: TextFieldInput(
                                textEditingController: _last,
                                labelText: "Last Name",
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your Second Name';
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Expanded(child: SizedBox()),
                        InkWell(
                          onTap: (){
                            final form = _formkey.currentState!;
                            if(form.validate()) {
                              dialogPassword(context);
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
                            child: Center(child: _loading? CircularProgressIndicator(color: reverse, strokeWidth: 2,) : Text("Change Profile", style: TextStyle(color: reverse),)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Text(Data().message,
                style: TextStyle(color: secondaryColor, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future choiceImage() async {
    setState(() {
      _addimage = true;
    });
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageUrl = '';
      _image = File(pickedImage!.path);
      _addimage = false;
    });
  }
  void dialogPickProfile(BuildContext context){
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
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(title: "S E L E C T  P R O F I L E"),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      choiceImage();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(Icons.photo_sharp),
                          SizedBox(width: 10,),
                          Text("Gallery")
                        ],
                      ),
                    ),
                  ),
                  Platform.isWindows || Platform.isLinux || Platform.isMacOS? SizedBox() :  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      Get.to(()=>CameraScreen(setPicture: _setPicture,), transition: Transition.downToUp);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          LineIcon.camera(),
                          SizedBox(width: 10,),
                          Text("Camera")
                        ],
                      ),
                    ),
                  ),
                  _image != null || imageUrl != ""
                      ? InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      setState(() {
                        _image = null;
                        imageUrl = "";
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(Icons.remove),
                          SizedBox(width: 10,),
                          Text("Remove Photo")
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ), context: context
    );
  }
  _setPicture(File? image){
    setState(() {
      _image = image;
    });
  }
  void dialogPassword(BuildContext context, ){
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
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
          child: Form(
            key: _key,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SizedBox(
              width: 450,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: "P A S S W O R D"),
                    Text('Please enter your current password to update',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryColor, ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: TextFieldInput(
                        textEditingController: _pass,
                        labelText: "Password",
                        isPass: true,
                        validator: (value){
                          if(value!.isNotEmpty){
                            if(TFormat().encryptText(value, currentUser.uid) != currentUser.password){
                              return "Please enter the correct password";
                            }
                          }
                        },
                      ),
                    ),
                    DoubleCallAction(
                        action: (){
                          final form = _key.currentState!;
                          if(form.validate()) {
                            Navigator.pop(context);
                            _update();
                          }
                        }
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
  Future _update()async{
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
    Services.updateProfile(currentUser.uid, _username.text.trim(), _first.text.trim(), _last.text.trim(), imageUrl, _image).then((response)async {
      final String responseString = await response.stream.bytesToString();
      if(responseString.contains("success")){
        setState(() {
          sharedPreferences.setString('username', _username.text.trim());
          sharedPreferences.setString('first', _first.text.trim());
          sharedPreferences.setString('last', _last.text.trim());
          sharedPreferences.setString('image', _image != null? _image!.path : firstImage);
          sharedPreferences.setString('url', imageUrl.toString());
          currentUser.username = _username.text.trim();
          currentUser.firstname = _first.text.trim();
          currentUser.lastname = _last.text.trim();
          currentUser.image = _image != null? _image!.path : firstImage;
        });
        _pass.text = "";
        widget.reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile update", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            )
        );
      } else if(responseString.contains("error")){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Profile was not update", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: "Try again",
                onPressed: _update,
              ),
            )
        );
      } else if(responseString.contains("Exists")){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Username already exists. Please try out another username", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            )
        );
      }  else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("mhmm🤔 seems like something went wrong please try again", style: TextStyle(color: revers),),
              backgroundColor: dilogbg,
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
            )
        );
      }
    });
    setState(() {
      _loading = false;
    });

  }
}
