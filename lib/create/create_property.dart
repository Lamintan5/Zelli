import 'dart:convert';
import 'dart:io';

import 'package:Zelli/main.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/data.dart';
import '../models/entities.dart';
import '../utils/colors.dart';
import '../widgets/text/text_filed_input.dart';

class CreateProperty extends StatefulWidget {
  final Function getData;
  const CreateProperty({super.key, required this.getData});

  @override
  State<CreateProperty> createState() => _CreatePropertyState();
}

class _CreatePropertyState extends State<CreateProperty> {
  TextEditingController _title = TextEditingController();
  TextEditingController _location = TextEditingController();
  List<String> cats = ['Cat One', 'Cat Two', 'Cat Three', 'Cat Four' , 'Cat Five'];
  List<EntityModel> _entity = [];
  File? _image; String? category;
  bool _loading = false;
  final picker = ImagePicker();
  bool _isLoading = false;
  String eid = '';
  int due = 1;
  int late = 5;
  String unitsString = '1';
  bool ismore = false;
  final formKey = GlobalKey<FormState>();
  List<String> _utilities = [];

  Future<void> publish() async {

    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    Uuid uuid = Uuid();
    eid = uuid.v1();

    EntityModel entityModel = EntityModel(
      eid: eid,
      pid: currentUser.uid,
      admin: currentUser.uid,
      title: _title.text.trim().toString(),
      category: category.toString(),
      image: _image == null? "" : _image!.path,
      due: due.toString(),
      late: late.toString(),
      utilities: _utilities.join(','),
      checked: "false",
      location: _location.text.toString(),
      time: DateTime.now().toString(),
    );

    _entity.add(entityModel);
    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    widget.getData();
    Navigator.pop(context);

    final response = await Services.addEntity(eid,currentUser.uid,currentUser.uid,
      _title.text.trim().toString(),category.toString(),_image,due.toString(),late.toString(),_utilities, _location.text.trim());
    final String responseString = await response.stream.bytesToString();
    if(responseString.contains("Success")){
      _entity.firstWhere((test) => test.eid == eid).checked = "true";
      _entity.firstWhere((test) => test.eid == eid).image = entityModel.image.toString().contains("\\")
          ? entityModel.image.toString().split("\\").last
          : entityModel.image.toString().split("/").last;
      uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
      sharedPreferences.setStringList('myentity', uniqueEntities);
      myEntity = uniqueEntities;
      widget.getData();
    }
  }

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

  void removeUtil(String util) {
    if (_utilities.isNotEmpty) {
      _utilities.remove(util);
      setState(() {});
    }
  }

  void addUtil(String util) {
    _utilities.add(util);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final bgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    double width = 450;
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Property"),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
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
                          SizedBox(height: 20,),
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
                          // SizedBox(height: 5,),
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
                          //       dropdownColor: bgColor,
                          //       isExpanded: true,
                          //       items: cats.map(buildMenuItem).toList(),
                          //       onChanged: (value) => setState(() => this.category = value),
                          //     ),
                          //   ),
                          // ),
                          //SizedBox(height: 20,),
                          Text('Payment Terms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          SizedBox(height: 5,),
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
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
                Row(children: [],),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: InkWell(
                    onTap: (){
                      if(due > late){
                      } else {
                        final form = formKey.currentState!;
                        if(form.validate()) {
                          publish();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 450,
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
                          : Text('Publish', style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600, color: Colors.black),)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item){
    return DropdownMenuItem(
      value: item,
      child: Text(
        item,
      ),
    );
  }
}
