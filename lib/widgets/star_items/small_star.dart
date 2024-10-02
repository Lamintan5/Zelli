import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:uuid/uuid.dart';

import '../../main.dart';
import '../../models/stars.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';

class SmallStar extends StatefulWidget {
  final EntityModel entity;
  final String from;
  final String type;
  final String rid;
  final double size;
  const SmallStar({super.key, required this.entity, required this.type, required this.rid, this.size = 15.0, this.from = "" });

  @override
  State<SmallStar> createState() => _SmallStarState();
}

class _SmallStarState extends State<SmallStar> {
  OverlayEntry? entry;
  final layerLink = LayerLink();
  bool isOpened = false;
  List<StarModel> starList = [];
  List<StarModel> newStars = [];
  List<StarModel> crrntStars = [];
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
  bool rating = false;
  String sid = '';

  _getStars()async{
    // _getStar();
    // newStars = await Services().getMyStars(currentUser.uid);
    // await Data().addOrUpdateStarList(newStars);
    // _getStar();
  }

  _getCurrentStar()async{
    // setState(() {
    //   rating = true;
    // });
    // crrntStars= await Services().getCrrntStars(widget.entity.eid);
    // starList = crrntStars;
    // _getData();
    // setState(() {
    //   rating = false;
    // });
  }

  _getStar(){
    starList = myStars.map((jsonString) => StarModel.fromJson(json.decode(jsonString)))
        .where((star) => star.eid == widget.entity.eid).toList();
    _getData();
  }

  _getData(){
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
    setState(() {
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.from=="SEARCH"){
      _getCurrentStar();
    } else {
      _getStars();
    }
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
      child:  Row(
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
              itemSize: widget.size,
              unratedColor: color2,
              itemPadding: EdgeInsets.symmetric(horizontal: 0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                _rate(rating);
              }),
          SizedBox(width: 5,),
          rating?SizedBox(width: 10,):SizedBox(),
          rating?SizedBox(height: 10, width: 10,
            child: CircularProgressIndicator(
              color: Colors.amber,
              strokeWidth: 2,
            ),
          ):SizedBox()
        ],
      ),
    );
  }
  void _rate(double rate){
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
        rid: widget.rid,
        eid: widget.entity.eid,
        pid: widget.entity.pid,
        uid: currentUser.uid,
        rate: rate.toString(),
        type: widget.type
    );
    // Services.addEntityStar(star).then((response){
    //   print(response);
    //   if(response=="Exists"){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //             backgroundColor: dgcolor,
    //             content: Text("Rating already exists", style: TextStyle(color: reverse),)
    //         )
    //     );
    //   } else if(response=="Success"){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //             backgroundColor: dgcolor,
    //             content: Text("Successfully rated ${rate} stars.", style: TextStyle(color: reverse),)
    //         )
    //     );
    //   }else if(response=="Failed"){
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           backgroundColor: dgcolor,
    //           content: Text("Rating failed.", style: TextStyle(color: reverse),),
    //           action: SnackBarAction(
    //             label: "Try again",
    //             onPressed: (){
    //               _rate(rate);
    //             },
    //           ),
    //         )
    //     );
    //   }else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           backgroundColor: dgcolor,
    //           content: Text("mhmm 🤔 seems like something went wrong.", style: TextStyle(color: reverse),),
    //           action: SnackBarAction(
    //             label: "Try again",
    //             onPressed: (){
    //               _rate(rate);
    //             },
    //           ),
    //         )
    //     );
    //   }
    //   setState(() {
    //     rating = false;
    //   });
    // });

  }
  Widget buildOverlay() {
    final color =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
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
                Text('${average.toString()} out of 5', style: TextStyle(fontWeight: FontWeight.w600),),
                Expanded(child: SizedBox()),
                IconButton(onPressed: (){hideOverlay();}, icon: Icon(Icons.cancel))
              ],
            ),
            Text('${starList.length.toString()} Global Ratings', style: TextStyle(fontSize: 11),),
            SizedBox(height:10),
            Row(
              children: [
                Text('5 star'),
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 20,
                    animationDuration: 600,
                    percent: (five/totalStars),
                    progressColor: Colors.amber,
                    backgroundColor: color2,
                    barRadius: Radius.circular(5),
                  ),
                ),
                SizedBox(width: 40,
                    child: Text('${(five/totalStars * 100).toStringAsFixed(0)}%')),
              ],
            ),
            SizedBox(height:5),
            Row(
              children: [
                Text('4 star'),
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 20,
                    animationDuration: 700,
                    percent: (four/totalStars),
                    backgroundColor: color2,
                    progressColor: Colors.amber,
                    barRadius: Radius.circular(5),
                  ),
                ),
                SizedBox(width: 40,child: Text('${(four/totalStars * 100).toStringAsFixed(0)}%')),
              ],
            ),
            SizedBox(height:5),
            Row(
              children: [
                Text('3 star'),
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 20,
                    animationDuration: 800,
                    percent: (three/totalStars),
                    progressColor: Colors.amber,
                    backgroundColor: color2,
                    barRadius: Radius.circular(5),
                  ),
                ),
                SizedBox(width:40,
                    child: Text('${(three/totalStars * 100).toStringAsFixed(0)}%')),
              ],
            ),
            SizedBox(height:5),
            Row(
              children: [
                Text('2 star'),
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 20,
                    animationDuration: 900,
                    percent: (two/totalStars),
                    progressColor: Colors.amber,
                    backgroundColor: color2,
                    barRadius: Radius.circular(5),
                  ),
                ),
                SizedBox(width: 40,
                    child: Text('${(two/totalStars * 100).toStringAsFixed(0)}%')),
              ],
            ),
            SizedBox(height:5),
            Row(
              children: [
                Text('1 star'),
                Expanded(
                  child: LinearPercentIndicator(
                    animation: true,
                    lineHeight: 20,
                    animationDuration: 1000,
                    percent: (one/totalStars),
                    progressColor: Colors.amber,
                    backgroundColor: color2,
                    barRadius: Radius.circular(5),
                  ),
                ),
                SizedBox(width: 40,
                    child: Text('${(one/totalStars * 100).toStringAsFixed(0)}%')),
              ],
            ),
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
                      //Get.to(()=>Review(entityId: widget.goods.eid,), transition: Transition.rightToLeft);
                    },
                    child: Text("See all Ratings")),
              ],
            )
          ],
        ),
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
