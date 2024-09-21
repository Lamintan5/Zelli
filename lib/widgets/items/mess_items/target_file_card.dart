import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../models/messages.dart';

class TargetFileCard extends StatelessWidget {
  final MessModel messModel;
  const TargetFileCard({super.key, required this.messModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      // Get.to(()=>MediaScreen(message: messModel));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomLeft:  Radius.circular(10),
                        bottomRight:  Radius.circular(10),
                      ),
                      child: Hero(
                        tag: messModel,
                        child: CachedNetworkImage(
                          cacheManager: customCacheManager,
                          imageUrl: 'http://192.168.0.105:5000/uploads/${messModel.path}',
                          key: UniqueKey(),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 200,
                            width: 500,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "STUDIO5IVE",
                                style: TextStyle(fontWeight: FontWeight.w100, color: Colors.white),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 200,
                            width: 200,
                            child: Center(
                              child: Icon(Icons.error_outline_rounded, size: 50),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  messModel.message == ""? SizedBox():Text(
                    messModel.message!,
                    textAlign: TextAlign.start,
                  ),
                  Text(DateFormat('hh:mm a').format(DateTime.parse(messModel.time!)), style: TextStyle(fontSize: 11),),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  static final customCacheManager = CacheManager(
      Config(
        'customCacheManager',
        maxNrOfCacheObjects: 1,
      )
  );
}
