import 'dart:io';

import 'package:Zelli/auth/camera.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../models/avatars.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../text/text_filed_input.dart';

class DialogUserInfo extends StatefulWidget {
  final UserModel user;
  final Function change;
  const DialogUserInfo({super.key, required this.user, required this.change});

  @override
  State<DialogUserInfo> createState() => _DialogUserInfoState();
}

class _DialogUserInfoState extends State<DialogUserInfo> {
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _secondName = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  Country _country = CountryParser.parseCountryCode('US');
  File? _image;

  UserModel userModel = UserModel(uid: "");
  final formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _add = false;
  var pickedImage;
  final picker = ImagePicker();
  String imageUrl = '';



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userModel = widget.user;
    _usernameController.text = userModel.username.toString();
    _firstName.text = userModel.firstname.toString();
    _secondName.text = userModel.lastname.toString();
    imageUrl =userModel.image == null? "" : userModel.image.toString();
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Stack(
            alignment: AlignmentDirectional.center,
            children: [
              _image != null
                  ? ClipOval(
                child: Image.file(_image!, width: 70, height: 70, fit: BoxFit.cover,),
              )
                  : imageUrl == ''? ClipOval(
                child: Image.asset("assets/add/default_profile.png", width: 70, height: 70,),
              ) : !imageUrl.contains("https://") && imageUrl.contains("/") || imageUrl.contains("\\")
                  ? CircleAvatar(
                radius: 35,
                backgroundColor: Colors.transparent,
                backgroundImage: FileImage(File(imageUrl)),
              ): ClipOval(
                child: Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover,),
              ),
              _add
                  ? SizedBox(width: 30, height: 30, child: CircularProgressIndicator())
                  : SizedBox(),
              Positioned(
                right: -10,
                bottom: -10,
                child: MaterialButton(
                  onPressed: (){dialogPickProfile(context);},
                  color: CupertinoColors.activeBlue,
                  minWidth: 5,
                  elevation: 8,
                  shape: CircleBorder(),
                  splashColor: CupertinoColors.systemBlue,
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.edit, size: 16,color: normal,),
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFieldInput(
                  textEditingController: _firstName,
                  labelText: 'First Name',
                  textInputType: TextInputType.text,
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
                  textEditingController: _secondName,
                  labelText: 'Second Name',
                  textInputType: TextInputType.text,
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
          TextFieldInput(
            textEditingController: _usernameController,
            labelText: 'Username',
            textInputType: TextInputType.text,
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
              InkWell(
                onTap: _showPicker,
                child: Container(
                  width: 60, height: 48,
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        width: 1, color: color1
                    ),
                  ),
                  child: Center(
                      child: Text("+${_country.phoneCode}")
                  ),
                ),
              ),
              SizedBox(width: 5,),
              Expanded(
                child: TextFieldInput(
                  textEditingController: _phoneController,
                  labelText: "Phone",
                  maxLength: 9,
                  textInputType: TextInputType.phone,
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number.';
                    }
                    if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                      return null; // Valid input (contains only digits)
                    } else {
                      return 'Please enter a valid phone number';
                    }
                  },
                ),
              )
            ],
          ),
          DoubleCallAction(
              action: (){
              final form = formKey.currentState!;
              if(form.validate()) {
                userModel.username = _usernameController.text;
                userModel.firstname = _firstName.text;
                userModel.lastname = _secondName.text;
                userModel.phone = "+"+ _country.phoneCode+_phoneController.text.trim().toString();
                userModel.image = _image != null? pickedImage!.path : imageUrl;
                userModel.country = _country.countryCode;
                widget.change(userModel);
                Navigator.pop(context);
              }
          })
        ],
      ),
    );
  }
  Future choiceImage() async {
    setState(() {
      _add = true;
    });
    pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageUrl = '';
      _image = File(pickedImage!.path);
      _add = false;
    });
  }
  void dialogPickProfile(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    showDialog(
        builder: (context) => Dialog(
          backgroundColor: dilogbg,
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
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
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.photo),
                          SizedBox(width: 10,),
                          Text("Gallery")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      dialogAvatar(context);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_emotions_outlined),
                          SizedBox(width: 10,),
                          Text("Avatar")
                        ],
                      ),
                    ),
                  ),
                  Platform.isAndroid || Platform.isIOS
                      ? InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      Get.to(()=>CameraScreen(setPicture: _setPicture,), transition: Transition.downToUp);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.camera),
                          SizedBox(width: 10,),
                          Text("Camera")
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
                  _image != null || imageUrl != ""
                      ? InkWell(
                    onTap: (){
                      Navigator.pop(context);
                      setState(() {
                        _image = null;
                        imageUrl = "";
                        _add = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
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
  void dialogAvatar(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size =MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height/2,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DialogTitle(title: "C H O O S E  A V A T A R"),
                SizedBox(height: 5,),
                Text('${avatars.length.toString()} avatars'),
                SizedBox(height: 5,),
                Expanded(
                  child: GridView.builder(
                    itemCount: avatars.length,
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1),
                    itemBuilder: (context, index){
                      return InkWell(
                        onTap: (){
                          setState(() {
                            imageUrl =avatars[index].toString();
                            _image = null;
                            _add = false;
                          });
                          Navigator.pop(context);
                        },
                        child: CachedNetworkImage(
                          cacheManager: customCacheManager,
                          imageUrl: avatars[index].toString(),
                          key: UniqueKey(),
                          fit: BoxFit.cover,
                          imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(avatars[index].toString()),
                                )
                            ),
                          ),
                          placeholder: (context, url) => SizedBox(),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.error_outline_rounded,),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }
    );
  }
  _setPicture(File? image){
    setState(() {
      _image = image;
      _add = false;
    });
  }
  void _showPicker(){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1,)
    );
    showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
            textStyle: TextStyle(fontWeight: FontWeight.w400),
            bottomSheetHeight: MediaQuery.of(context).size.height / 2,
            backgroundColor: dilogbg,
            borderRadius: BorderRadius.circular(10),
            inputDecoration:  InputDecoration(
              hintText: "🔎 Search for your country here",
              hintStyle: TextStyle(color: secondaryColor),
              border: inputBorder,
              isDense: true,
              fillColor: color1,
              contentPadding: const EdgeInsets.all(10),

            )
        ),
        onSelect: (country){
          setState(() {
            this._country = country;
          });
        });
  }
}
