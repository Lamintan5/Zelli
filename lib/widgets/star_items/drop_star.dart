import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/stars.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../../views/property/activities/reviews.dart';

class DropStar extends StatefulWidget {
  final EntityModel entity;
  const DropStar({super.key, required this.entity,});

  @override
  State<DropStar> createState() => _DropStarState();
}

class _DropStarState extends State<DropStar> {
  OverlayEntry? entry;
  final layerLink = LayerLink();
  bool isOpened = false;
  List<StarModel> starList = [];
  List<StarModel> crrntStars = [];
  List<StarModel> newStars = [];
  List fivestars = [];
  List fourstars = [];
  List threestars = [];
  List twostars = [];
  List onestars = [];
  double five = 0.0;
  double four = 0.0;
  double three = 0.0;
  double two = 0.0;
  double one = 0.0;
  double totalStars = 0.0;
  double average = 0.0;
  int totalRate = 0;
  bool rating = false;
  String sid = '';

  void getStars()async{
    // getData();
    // newStars = await Services().getMyStars(currentUser.uid);
    // await Data().addOrUpdateStarList(newStars);
    // getData();
  }
  _getCurrentStar()async{
    // setState(() {
    //   rating = true;
    // });
    // crrntStars= await Services().getCrrntStars(widget.entity.eid);
    // setState(() {
    //   rating = false;
    // });
  }

  void getData(){
    rating = false;
    starList = myStars.map((jsonString) => StarModel.fromJson(json.decode(jsonString)))
        .where((star) => star.eid == widget.entity.eid).toList();
    fivestars = starList.where((element) => double.parse(element.rate.toString()) > 4.1).toList();
    fourstars = starList.where((element) => double.parse(element.rate.toString()) > 3.0 && double.parse(element.rate.toString()) <4.1).toList();
    threestars = starList.where((element) => double.parse(element.rate.toString()) > 2.0 && double.parse(element.rate.toString()) <3.1).toList();
    twostars = starList.where((element) => double.parse(element.rate.toString()) > 1.0 && double.parse(element.rate.toString()) <2.1).toList();
    onestars = starList.where((element) => double.parse(element.rate.toString()) > 0.0 && double.parse(element.rate.toString()) <1.1).toList();
    five = fivestars.isEmpty? 0.0 : fivestars.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    four = fourstars.isEmpty? 0.0 : fourstars.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    three = threestars.isEmpty? 0.0 : threestars.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    two = twostars.isEmpty? 0.0 : twostars.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    one = onestars.isEmpty? 0.0 : onestars.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    totalStars = starList.isEmpty? 0.0 : starList.fold(0, (sum, stars) => sum + double.parse(stars.rate.toString()));
    average = starList.isEmpty? 0.0 : totalStars / starList.length;
    totalRate = starList.length;
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentStar();
    getData();
    starList = [];
  }

  @override
  Widget build(BuildContext context) {
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final style = TextStyle(color: secondaryColor);
    final bold = TextStyle( fontWeight: FontWeight.w600);
    return CompositedTransformTarget(
      link: layerLink,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                  initialRating: average,
                  minRating: 0.5,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  glowColor: Colors.amber,
                  itemSize: 25.0,
                  unratedColor: color2,
                  itemPadding:
                  EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    rate(rating).then((value) => getStars());
                  }),
              SizedBox(width: 5,),
              rating?SizedBox(width: 10,):SizedBox(),
              rating?SizedBox(height: 20, width: 20,
                child: CircularProgressIndicator(
                  color: Colors.amber,
                  strokeWidth: 2,
                ),
              ):SizedBox()
            ],
          ),
          widget.entity.pid!.contains(currentUser.uid)
              ?RichText(
            textAlign: TextAlign.center,
              text: TextSpan(
              children: [
                TextSpan(
                 text: '${average.toStringAsFixed(1)} ',
                  style: bold
                ),
                TextSpan(
                    text: 'ratings out of ',
                    style: style
                ),
                TextSpan(
                    text: '${totalRate.toString()} ',
                    style: bold
                ),
                TextSpan(
                    text: 'Ratings',
                    style: style
                ),
                WidgetSpan(
                    child: InkWell(
                      onTap: (){
                        isOpened ? hideOverlay() : showOverlay();
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                      ),
                    )
                )
              ]
            )
          )
              :SizedBox()
        ],
      ),
    );
  }
  Future<void> rate(double rate)async {
    final dgcolor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    String sid = "";
    setState(() {
      Uuid uuid = Uuid();
      sid = uuid.v1();
      rating = true;
    });
    StarModel star = StarModel(
        sid: sid,
        rid: "",
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        uid: currentUser.uid,
        rate: rate.toString(),
        type: "ENTITY"
    );
    Services.addStar(star).then((response)async{
      print(response);
      if(response=="Exists"){
        setState(() {
          rating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dgcolor,
                content: Text("Rating already exists", style: TextStyle(color: reverse),)
            )
        );
      } else if(response=="Success"){
        setState(() {
          rating = false;
        });
        await Data().addStar(star);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                backgroundColor: dgcolor,
                content: Text("Successfully rated ${rate} stars.", style: TextStyle(color: reverse),)
            )
        );
      }else if(response=="Failed"){
        setState(() {
          rating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dgcolor,
              content: Text("Rating failed. Please try again", style: TextStyle(color: reverse),),

            )
        );
      }else {
        setState(() {
          rating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: dgcolor,
              content: Text("mhmm 🤔 seems like something went wrong. Please try again", style: TextStyle(color: reverse),),
            )
        );
      }

    });

  }
  Widget buildOverlay() {
    final color2 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final bgColor =  Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    return Material(
      borderRadius: BorderRadius.circular(5),
      elevation: 10,
      color: bgColor,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RatingBar.builder(
                    initialRating: average,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20.0,
                    unratedColor: color2,
                    itemPadding:
                    EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      //rate(rating.toString()).then((value) => getStars());
                    }),
                Text('${average.toStringAsFixed(1)} out of 5', style: TextStyle(fontWeight: FontWeight.w600),),
                Expanded(child: SizedBox()),
                IconButton(onPressed: (){hideOverlay();}, icon: Icon(Icons.cancel))
              ],
            ),
            Text('${starList.length.toString()} Global Ratings', style: TextStyle(fontSize: 11),),
            SizedBox(height:10),
            bar("5", (five/totalStars) ),
            bar("4", (four/totalStars) ),
            bar("3", (three/totalStars) ),
            bar("2", (two/totalStars) ),
            bar("1", (one/totalStars) ),
            SizedBox(height:20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Divider(
                color: color2,
                height: 1,
                thickness: 1,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: (){
                      hideOverlay();
                      Get.to(()=>Reviews(entity: widget.entity), transition: Transition.rightToLeft);
                    },
                    child: Text("See all Reviews")),
              ],
            )
          ],
        ),
      ),
    );
  }
  Widget bar(String title, double percent){
    final color2 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text('${title} star'),
          Expanded(
            child: LinearPercentIndicator(
              animation: true,
              lineHeight: 20,
              animationDuration: 600,
              percent: percent.isNaN? 0.0 : percent,
              progressColor: Colors.amber,
              backgroundColor: color2,
              barRadius: Radius.circular(5),
            ),
          ),
          SizedBox(width: 40,
              child: Text(percent.isNaN? '0.0' : '${percent.toStringAsFixed(0)}%')),
        ],
      ),
    );
  }
  void showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    setState(() {
      isOpened = true;
    });
    entry = OverlayEntry(
      builder: (context) => Positioned(
          width: 300,
          child: CompositedTransformFollower(
            link: layerLink,
            showWhenUnlinked: false,
            offset: Offset(0,  size.height - 40),
            child: buildOverlay(),
          )),
    );
    overlay.insert(entry!);
  }
  void hideOverlay() {
    entry?.remove();
    entry = null;
    setState(() {
      isOpened = false;
    });
  }
}
