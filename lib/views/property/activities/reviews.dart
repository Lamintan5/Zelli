import 'package:Zelli/models/entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../create/create_review.dart';
import '../../../models/reviews.dart';
import '../../../resources/services.dart';
import '../../../utils/colors.dart';
import '../../../widgets/items/item_review.dart';

class Reviews extends StatefulWidget {
  final EntityModel entity;
  const Reviews({super.key, required this.entity});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  List<ReviewModel> _review = [];
  List<double> _stars = [];
  bool _loading = false;

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

  _getReviews()async{
    setState(() {
      _loading = true;
    });
    _review = await Services().getCrntReview(widget.entity.eid.toString());
    _stars = _review.map((e) => double.parse(e.star.toString())).toList();
    fivestars = _stars.where((element) => element > 4.1).toList();
    fourstars = _stars.where((element) => element > 3.0 && element <4.1).toList();
    threestars = _stars.where((element) => element > 2.0 && element <3.1).toList();
    twostars = _stars.where((element) => element > 1.0 && element <2.1).toList();
    onestars = _stars.where((element) => element > 0.0 && element <1.1).toList();
    five = fivestars.isEmpty? 0.0 : fivestars.fold(0, (sum, stars) => sum + stars);
    four = fourstars.isEmpty? 0.0 : fourstars.fold(0, (sum, stars) => sum + stars);
    three = threestars.isEmpty? 0.0 : threestars.fold(0, (sum, stars) => sum + stars);
    two = twostars.isEmpty? 0.0 : twostars.fold(0, (sum, stars) => sum + stars);
    one = onestars.isEmpty? 0.0 : onestars.fold(0, (sum, stars) => sum + stars);
    totalStars = _stars.isEmpty? 0.0 : _stars.fold(0, (sum, stars) => sum + stars);
    average = _stars.isEmpty? 0.0 : totalStars / _stars.length;
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getReviews();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            surfaceTintColor: Colors.transparent,
            backgroundColor: normal,
            pinned: true,
            expandedHeight: 400,
            foregroundColor: reverse,
            toolbarHeight: 30,
            title: Text("Review"),
            centerTitle: true,
            actions: [IconButton(onPressed: () {}, icon: Icon(Icons.help))],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      average.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 60,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RatingBar.builder(
                        initialRating: average,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        ignoreGestures: true,
                        itemCount: 5,
                        itemSize: 30.0,
                        unratedColor: color2,
                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          //rate(rating.toString()).then((value) => getStars());
                        }),
                    Text(
                      "based on ${_stars.length} reviews",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: 450,
                      child: Column(
                        children: [
                          bar("Excellent", five/totalStars, Colors.green),
                          bar("Good", four/totalStars, Colors.lightGreen),
                          bar("Average", three/totalStars, Colors.yellow),
                          bar("Below Average", two/totalStars, Colors.orange),
                          bar("Poor", one/totalStars, Colors.red),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 30),
                      child: _loading
                          ? LinearProgressIndicator(color: reverse,minHeight: 2,)
                          : Divider(
                        thickness: 2,
                        height: 1,
                        color: color2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _loading? SizedBox() : ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _review.length,
                    itemBuilder: (context, index) {
                      ReviewModel review = _review[index];
                      return ItemReview(review: review);
                    }),
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.to(() => CreateReview(entity: widget.entity,addReview: _addReview), transition: Transition.rightToLeft);
        },
        autofocus: true,
        tooltip: "Write your Review",
        child: Icon(Icons.add),

      ),
    );
  }
  Widget bar(String title, double percent, Color color) {
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
            width: 90,
            child: Text(
              title,
              style: TextStyle(fontSize: 13, color: secondaryColor),
            )),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: LinearPercentIndicator(
            animation: true,
            lineHeight: 8,
            animationDuration: 700,
            percent: percent.isNaN ? 0.0 : percent,
            backgroundColor: color2,
            progressColor: color,
            barRadius: Radius.circular(2),
          ),
        ),
      ],
    );
  }
  void _addReview(ReviewModel review){
    _review.add(review);
    setState(() {

    });
  }
}
