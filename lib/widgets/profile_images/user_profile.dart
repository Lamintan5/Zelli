import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../resources/services.dart';

class UserProfile extends StatelessWidget {
  final String image;
  final double radius;
  final Color shadow;
  const UserProfile({super.key, required this.image, this.radius = 20, this.shadow = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return image == ""
        ? Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Makes the container circular
            boxShadow: [
              BoxShadow(
                color: shadow,
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(-2, 0),
              ),
            ],
          ),
          child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage('assets/add/default_profile.png',)
          ),
        )
        : CachedNetworkImage(
          cacheManager: customCacheManager,
          imageUrl: image.contains("https://")? image :  '${Services.HOST}profile/${image}',
          key: UniqueKey(),
          fit: BoxFit.cover,
          imageBuilder: (context, imageProvider) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: shadow,
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.transparent,
              backgroundImage: imageProvider,
            ),
          ),
          placeholder: (context, url) =>
              Container(
                height: radius*2,
                width: radius*2,
              ),
          errorWidget: (context, url, error) => Container(
            height: radius*2,
            width: radius*2,
            child: Center(child: Icon(Icons.error_outline_rounded, size: 20,),
            ),
          ),
        );
  }
}
