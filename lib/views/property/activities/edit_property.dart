import 'dart:convert';
import 'dart:io';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/text/text_filed_input.dart';
import '../../../widgets/text/text_format.dart';

class EditProperty extends StatefulWidget {
  final EntityModel entity;
  final Function reload;
  const EditProperty({super.key, required this.entity, required this.reload});

  @override
  State<EditProperty> createState() => _EditPropertyState();
}

class _EditPropertyState extends State<EditProperty> {
  List<String> cats = ['Cat One', 'Cat Two', 'Cat Three', 'Cat Four' , 'Cat Five'];

  late TextEditingController _title;
  late TextEditingController _pass;
  late TextEditingController _location;

  File? _image; String? category;
  final picker = ImagePicker();
  final _formkey = GlobalKey<FormState>();
  final _key = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _loading = false;
  bool ismore = false;

  String unitsString = '1';String oldImage = "";
  String eid = '';
  int due = 1;
  int late = 5;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title= TextEditingController();
    _pass= TextEditingController();
    _location= TextEditingController();
    oldImage = widget.entity.image.toString();
    _title.text = widget.entity.title.toString();
    _location.text = widget.entity.location.toString();
    category = widget.entity.category.toString();
    due = int.parse(widget.entity.due.toString());
    late = int.parse(widget.entity.late.toString());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _title.dispose();
    _location.dispose();
    _pass.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    double width = 450;
    return Scaffold(
      appBar: AppBar(
        title: Text('  Edit Property', style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body:  Form(
        key: _formkey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(width: width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(' Property Information', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _image != null
                                ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70, height: 70,
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: secondaryColor,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                              _image!
                                          )
                                      )
                                  ),
                                ),
                                Positioned(
                                    bottom: 0, right: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          choiceImage();
                                        },
                                        icon: Icon(Icons.change_circle))),
                                Positioned(
                                    top: 0, left: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            _image = null;
                                            oldImage = "";
                                          });
                                        },
                                        icon: Icon(Icons.cancel))),
                                _loading ? SizedBox(
                                    width: 40,height: 40,
                                    child: CircularProgressIndicator(strokeWidth: 1 ,color: Colors.white,))
                                    : SizedBox(),
                              ],
                            )
                                : oldImage.toString().contains("/") || oldImage.toString().contains("\\")
                                    ?  Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70, height: 70,
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: secondaryColor,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: FileImage(
                                              File(oldImage)
                                          )
                                      )
                                  ),
                                ),
                                Positioned(
                                    bottom: 0, right: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          choiceImage();
                                        },
                                        icon: Icon(Icons.change_circle))),
                                Positioned(
                                    top: 0, left: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            _image = null;
                                            oldImage = "";
                                          });
                                        },
                                        icon: Icon(Icons.cancel))),
                                _loading ? SizedBox(
                                    width: 40,height: 40,
                                    child: CircularProgressIndicator(strokeWidth: 1 ,color: Colors.white,))
                                    : SizedBox(),
                              ],
                            )
                                : oldImage != ""
                                ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 70, height: 70,
                                  margin: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: secondaryColor,
                                        width: 2,
                                      ),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: NetworkImage(
                                              '${Services.HOST}logos/'+oldImage
                                          )
                                      )
                                  ),
                                ),
                                Positioned(
                                    bottom: 0, right: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          choiceImage();
                                        },
                                        icon: Icon(Icons.change_circle))),
                                Positioned(
                                    top: 0, left: 0,
                                    child: IconButton(
                                        onPressed: (){
                                          setState(() {
                                            oldImage = "";
                                          });
                                        },
                                        icon: Icon(Icons.cancel))),
                                _loading ? SizedBox(
                                    width: 40,height: 40,
                                    child: CircularProgressIndicator(strokeWidth: 1 ,color: Colors.white,))
                                    : SizedBox(),
                              ],
                            )
                                : InkWell(
                                onTap: (){
                                  choiceImage();
                                },
                                borderRadius: BorderRadius.circular(5),
                                child: Image.asset("assets/add/add-image.png", width: 80, height: 80,)
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 15,),
                                  Text('Business Logo',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                                  ),
                                  Text('Add a logo to this Business. This action is optional', style: TextStyle(color: secondaryColor, fontSize: 11),),
                                  SizedBox(height: 5,),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 20,),
                        TextFieldInput(
                          textEditingController: _title,
                          labelText: 'Business Title',
                          textInputType: TextInputType.text,
                          validator: (value){
                            if(value == null || value == ""){
                              return 'Please enter your property title';
                            }
                          },
                        ),
                        SizedBox(height: 10,),
                        TextFieldInput(
                          textEditingController: _location,
                          labelText: 'Location',
                          textInputType: TextInputType.text,
                          srfIcon: IconButton(icon: Icon(Icons.location_on_outlined), onPressed: (){},),
                          validator: (value){
                            if(value == null || value == ""){
                              return 'Please enter your property location';
                            }
                          },
                        ),
                        SizedBox(height: 10,),
                        // Text(' Category :  ', style: TextStyle(color: secondaryColor),),
                        // SizedBox(height: 10,),
                        // Container(
                        //   padding: EdgeInsets.symmetric(horizontal: 12,),
                        //   decoration: BoxDecoration(
                        //       color: color1,
                        //       borderRadius: BorderRadius.circular(5),
                        //       border: Border.all(
                        //           width: 1,
                        //           color: color1
                        //       )
                        //   ),
                        //   child: DropdownButtonHideUnderline(
                        //     child: DropdownButton<String>(
                        //       value: category,
                        //       icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                        //       isExpanded: true,
                        //       items: cats.map(buildMenuItem).toList(),
                        //       dropdownColor: bgColor,
                        //       onChanged: (value) => setState(() => this.category = value),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 20,),
                        Text('Payment Terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: [
                                  Text('Rent is due on the'),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 1, color: ismore ? Colors.red : color1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 20,),
                                        Text('${due}${due==1||due==21?"st":due==2||due==22?"nd":due==3||due==23?"rd":"th"}'),
                                        Expanded(child: SizedBox()),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                setState(() {
                                                  if(due<27){
                                                    due++;
                                                    if(due > late){
                                                      ismore = true;
                                                    } else {
                                                      ismore = false;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: ismore ? Colors.red : color1,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(10)
                                                    )
                                                ),
                                                child: Icon(Icons.keyboard_arrow_up),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                setState(() {
                                                  if (due > 1) {
                                                    due--;
                                                    if(due > late){
                                                      ismore = true;
                                                    } else {
                                                      ismore = false;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: ismore ? Colors.red :color1,
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight: Radius.circular(10)
                                                    )
                                                ),
                                                child: Icon(Icons.keyboard_arrow_down),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment : CrossAxisAlignment.start,
                                children: [
                                  Text('Rent is late on the'),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: color1,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        width: 1, color: color1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 20,),
                                        Text('${late}${late==1||late==21?"st":late==2||late==22?"nd":late==3||late==23?"rd":"th"}'),
                                        Expanded(child: SizedBox()),
                                        Column(
                                          children: [
                                            InkWell(
                                              onTap: (){
                                                setState(() {
                                                  if(late<27){
                                                    late++;
                                                    if(due > late){
                                                      ismore = true;
                                                    } else {
                                                      ismore = false;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: color1,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(10)
                                                    )
                                                ),
                                                child: Icon(Icons.keyboard_arrow_up),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: (){
                                                setState(() {
                                                  if (late > 1) {
                                                    late--;
                                                    if(due > late){
                                                      ismore = true;
                                                    } else {
                                                      ismore = false;
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: color1,
                                                    borderRadius: BorderRadius.only(
                                                        bottomRight: Radius.circular(10)
                                                    )
                                                ),
                                                child: Icon(Icons.keyboard_arrow_down),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Row(mainAxisSize: MainAxisSize.max,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: InkWell(
                  onTap: (){
                    if(due > late){
                    } else {
                      final form = _formkey.currentState!;
                      if(form.validate()) {
                        dialogPassword(context);
                      }
                    }
                  },
                  child: Container(
                    width: 400,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: CupertinoColors.systemBlue,
                    ),
                    child: Center(child: _isLoading
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                        : Text('UPDATE', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
                    TextFieldInput(
                      textEditingController: _pass,
                      labelText: "Password",
                      isPass: true,
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return "Please enter your password";
                        }
                        if(TFormat().encryptText(value, currentUser.uid) != currentUser.password){
                          return "Please enter the correct password";
                        }
                      },
                    ),
                    DoubleCallAction(
                        action: (){
                      final form = _key.currentState!;
                      if(form.validate()) {
                        Navigator.pop(context);
                        _update();
                      }
                    })
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }

  _update()async{
    setState(() {
      _isLoading = true;
    });
    EntityModel entity = widget.entity;
    entity.title = _title.text;
    entity.category = category;
    entity.location = _location.text;
    entity.due = due.toString();
    entity.late = late.toString();
    entity.image = _image==null?oldImage:_image!.path;

    await Data().editEntity(context, widget.reload, entity, _image, oldImage).then((value){
      setState(() {
        _isLoading = value;
      });
      if(value==false){
        Navigator.pop(context);
      }
    });

  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
  Future choiceImage() async {
    setState(() {
      _loading = true;
    });
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
      _loading = false;
    });
  }
}
