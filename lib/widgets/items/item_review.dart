import 'package:Zelli/models/messages.dart';
import 'package:Zelli/models/reviews.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:Zelli/widgets/shimmer_widget.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/users.dart';

class ItemReview extends StatefulWidget {
  final ReviewModel review;
  const ItemReview({super.key, required this.review});

  @override
  State<ItemReview> createState() => _ItemReviewState();
}

class _ItemReviewState extends State<ItemReview> {
  List<UserModel> _users = [];
  UserModel user = UserModel(uid: "", image: "", username: "");
  bool _loading = false;
  double star = 0.0;
  MessModel message = MessModel(mid: "", message: "", path: "", time: DateTime.now().toString());

  _getUser()async{
    star = widget.review.star == ""? 0.0 : double.parse(widget.review.star.toString());
    setState(() {
      _loading = true;
    });
    _users = await Services().getCrntUsr(widget.review.uid.toString());
    user = _users.first;
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUser();
  }

  @override
  Widget build(BuildContext context) {
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _loading
                  ?ShimmerWidget.circular(width: 40, height: 40)
                  :UserProfile(image: user.image.toString()),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _loading
                            ?ShimmerWidget.rectangular(width: 100, height: 10)
                            :Text(
                          user.username.toString(),
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 10,),
                        RatingBar.builder(
                            initialRating:star,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemCount: 5,
                            itemSize: 15.0,
                            unratedColor: color2,
                            itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              CupertinoIcons.star_fill,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {

                            }),
                        SizedBox(
                          width: 10,
                        ),
                        Text(star.toString()),
                        Expanded(child: SizedBox()),
                        Text(timeago.format(DateTime.parse(widget.review.time.toString())), style: TextStyle(
                            fontSize: 11))
                      ],
                    ),
                    SizedBox(height: 2,),
                    Text(widget.review.message.toString()),
                    widget.review.image == ""
                        ? SizedBox()
                        : Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                          InkWell(
                            onTap: (){
                              message = MessModel(
                                mid: "",
                                path: widget.review.image,
                                message: widget.review.message,
                                time: widget.review.time,
                              );
                              // Get.to(()=>MediaScreen(message: message));
                            },
                            child: Hero(
                              tag: message,
                              child: Container(
                                constraints: BoxConstraints(
                                    maxHeight: 100, minHeight: 50,
                                    maxWidth: 100, minWidth: 50
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(width: 2, color: color2),
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: NetworkImage('${Services.HOST}Uploads/${widget.review.image}')
                                  ),
                                ),
                              ),
                            ),
                          ),
                                                ],
                                              ),
                        ),
                    Row(
                      children: [
                        Text("Like",style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),),
                        SizedBox(width: 20),
                        Text("Reply",style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w700),),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
