import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../main.dart';
import '../../models/entities.dart';
import '../../resources/services.dart';

class PropLogo extends StatelessWidget {
  final EntityModel entity;
  final double radius;
  final double stroke;
  final String from;
  const PropLogo({super.key, required this.entity, this.radius = 20.0, this.stroke = 2.0, this.from = ""});

  @override
  Widget build(BuildContext context) {
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          width: stroke, color: Colors.white38
        )
      ),
      child: entity.image.toString().contains("/") || entity.image.toString().contains("\\")
          ? CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        backgroundImage: FileImage(File(entity.image!)),
      )
          : entity.image.toString() != ""
          ? CachedNetworkImage(
        cacheManager: customCacheManager,
        imageUrl:  Services.HOST + 'logos/${entity.image.toString()}' ,
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
          : CircleAvatar(
        radius: radius,
        backgroundColor: color1,
        child: Text('${entity.title.toString().toUpperCase()[0]}', style: TextStyle(fontWeight: FontWeight.w500, color: revers, fontSize: radius/2 +5),),
      ),
    );
  }
}
