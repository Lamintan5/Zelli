import 'dart:io';

import 'package:Zelli/main.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/reviews.dart';
import 'package:Zelli/resources/services.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/stars.dart';
import '../utils/colors.dart';

class CreateReview extends StatefulWidget {
  final EntityModel entity;
  final Function addReview;
  const CreateReview({super.key, required this.entity, required this.addReview});

  @override
  State<CreateReview> createState() => _CreateReviewState();
}

class _CreateReviewState extends State<CreateReview> {
  TextEditingController _controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  File? _image;
  final picker = ImagePicker();
  double star = 0.0;
  bool isRated = false;
  bool _loading = false;
  String rid = "";

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
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
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1)
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Write your Review'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Center(
          child: Container(
            width: 500,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _image == null
                            ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" Add Photo (Optional)", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              DottedBorder(
                                  borderType: BorderType.RRect,
                                  color: reverse,
                                  radius: Radius.circular(12),
                                  dashPattern: [5,5],
                                  child: InkWell(
                                    onTap: (){
                                      choiceImage();
                                    },
                                    child: Container(
                                      width: 450,
                                      height: 100,
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.cloud_upload),
                                            Text("Click Here to upload")
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                              )
                            ],
                          ),
                        )
                            : SizedBox(
                          child: Stack(
                            children: [
                              InkWell(
                                onTap: (){
                                  choiceImage();
                                },
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: 400,
                                      maxHeight: MediaQuery.of(context).size.height * 1/2
                                    ),
                                    child: Center(
                                      child: Image.file(
                                        _image!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                ),
                              ),
                              Align(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: (){
                                            choiceImage();
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.black54,
                                              borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: Icon(CupertinoIcons.arrow_2_circlepath),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        InkWell(
                                          onTap: (){
                                            setState(() {
                                              _image = null;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                                color: Colors.black54,
                                                borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: Icon(Icons.close),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" Add Rating", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: color1,
                                    border: Border.all(
                                        width: 1, color:isRated? Colors.red : color1
                                    )
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RatingBar.builder(
                                        initialRating: 0.0,
                                        minRating: 0.5,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        itemSize: 30.0,
                                        unratedColor: color2,
                                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                                        itemBuilder: (context, _) => Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rate) {
                                          setState(() {
                                            star = rate;
                                            isRated = false;
                                          });
                                        }),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Please provide your feedback by indicating your experience-based rating for this property. Your input is valuable and will contribute to the overall assessment of the property\'s quality.',
                                        style: TextStyle(color: secondaryColor, fontSize: 11),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(" Write your Review", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                              SizedBox(height: 5,),
                              TextFormField(
                                enableInteractiveSelection: true,
                                controller: _controller,
                                maxLines: 7,
                                minLines: 4,
                                maxLength: 400,
                                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                style: TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: "Would you wish to write a review about this property",
                                  hintStyle: TextStyle(color: secondaryColor, fontSize: 13),
                                  border: inputBorder,
                                  focusedBorder: inputBorder,
                                  enabledBorder: inputBorder,
                                  filled: true,
                                  fillColor: color1,
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                                validator: (value){
                                  if( value == null || value.isEmpty){
                                    return 'Please enter your review';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: (){
                      final form = formKey.currentState!;
                      if(form.validate()){
                        if(star == 0.0){
                          setState(() {
                            isRated = true;
                          });
                        } else {
                          setState(() {
                            isRated = false;
                          });
                          _review();
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 450,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: CupertinoColors.activeBlue,
                      ),
                      child: Center(child: _loading
                          ? SizedBox(
                              width: 15,height: 15,
                              child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                          )
                          :Text("Submit Review", style: TextStyle(color: Colors.black),)),
                    ),
                  ),
                ),
                SizedBox(height: 10,)
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future choiceImage() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedImage!.path);
    });
  }
  _review()async{
    final dgcolor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    Uuid uuid  = Uuid();
    rid = uuid.v1();
    ReviewModel review = ReviewModel(
        rid: rid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        uid: currentUser.uid,
        sid: rid,
        message: _controller.text.trim(),
        star: star.toString(),
        image: _image == null? "" : _image!.path,
        time: DateTime.now().toString()
    );
    StarModel starmodel = StarModel(
        sid: rid,
        rid: rid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        uid: currentUser.uid,
        rate: star.toString(),
        type: "REVIEW"
    );
    setState(() {
      _loading = true;
    });
    Services.addReview(review, _image).then((response)async{
      final String responseString = await response.stream.bytesToString();
      print(responseString);
      if (responseString.contains('Success')) {
        Services.addStar(starmodel).then((value) => print(value));
        Navigator.pop(context);
        widget.addReview(review);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dgcolor,
                content: Text("Review successfully added", style: TextStyle(color: reverse),)
            )
        );
      } else if(responseString.contains('Failed')){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dgcolor,
              content: Text("Review was not added", style: TextStyle(color: reverse),),
              action: SnackBarAction(
                label: 'Try again',
                onPressed: (){
                  _review();
                },
              ),
            )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dgcolor,
              content: Text("mhmm🤔 something went.", style: TextStyle(color: reverse),),
              action: SnackBarAction(
                label: 'Try again',
                onPressed: (){
                  _review();
                },
              ),
            )
        );
      }
    });
    setState(() {
      _loading = false;
    });
  }
}
