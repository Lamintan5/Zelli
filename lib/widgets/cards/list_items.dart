import 'package:Zelli/widgets/profile_images/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../models/users.dart';
import '../../utils/colors.dart';


class ListItemWidget extends StatefulWidget {
  final UserModel user;
  final Animation<double> animation;
  final Function? onPressed;


  const ListItemWidget({super.key, required this.user, required this.animation, this.onPressed, });

  @override
  State<ListItemWidget> createState() => _ListItemWidgetState();
}

class _ListItemWidgetState extends State<ListItemWidget> {


  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;

    return SizeTransition(
      sizeFactor: widget.animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0,),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                backgroundColor: color1,
                borderRadius: BorderRadius.circular(10),
                foregroundColor: color2,
                icon: Icons.chat_bubble,
                label: 'Message',
                onPressed: (context) {},
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: VerticalDivider(
                  color: color2,
                  thickness: 1,
                ),
              ),
              SlidableAction(
                foregroundColor: color2,
                backgroundColor: color1,
                borderRadius: BorderRadius.circular(10),
                icon: Icons.remove,
                label: 'Remove',
                onPressed: (context){
                  widget.onPressed?.call();
                },
              ),
            ],
          ),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              children: [
                UserProfile(image: widget.user.image!),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.user.username.toString()),
                      Text('${widget.user.firstname} ${widget.user.lastname}', style: TextStyle(color: secondaryColor, fontSize: 12),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
