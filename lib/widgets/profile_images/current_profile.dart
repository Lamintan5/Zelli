import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../main.dart';
import '../../resources/services.dart';


class CurrentImage extends StatelessWidget {
  final double radius;
  const CurrentImage({super.key,this.radius = 20.0});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return   currentUser.image.toString() != ""
        ? CachedNetworkImage(
      cacheManager: customCacheManager,
      imageUrl: currentUser.image.toString().contains("https://")
          ?  currentUser.image.toString()
          :  currentUser.image.toString().contains("/")
          ? Services.HOST + 'profile/${currentUser.image.toString().split("/").last}'
          : currentUser.image.toString().contains("\\")
          ? Services.HOST + 'profile/${currentUser.image.toString().split("\\").last}'
          : Services.HOST + 'profile/${currentUser.image.toString()}' ,
      key: UniqueKey(),
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) =>
          Container(
            height: radius*2,
            width: radius*2,
          ),
      errorWidget: (context, url, error) => Container(
        height: radius*2,
        width: radius*2,
        child: Center(child: Icon(Icons.error_outline_rounded, size: radius*2),
        ),
      ),
    )
        : currentUser.image.toString().contains("/") || currentUser.image.toString().contains("\\")
        ? CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      backgroundImage: FileImage(File(currentUser.image!)),
    )
        : CircleAvatar(
      radius: radius,
      backgroundColor: color5,
      child: Icon(CupertinoIcons.person_fill,),
    );
  }
}
