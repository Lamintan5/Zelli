import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../models/messages.dart';


class OwnFileCard extends StatelessWidget {
  final MessModel messModel;
  const OwnFileCard({super.key, required this.messModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: 300,
              ),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      // Get.to(()=>MediaScreen(message: messModel));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: messModel.path.toString().split('\\').length == 1 && messModel.path.toString().split('/').length == 1
                          ? Hero(
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
                          )
                          : Hero(
                            tag: messModel,
                            child: Image.file(
                              File(messModel.path!),
                                fit: BoxFit.contain,
                              ),
                          ),
                    ),
                  ),
                  messModel.message == ""? SizedBox() :Text(
                    messModel.message!,
                    style: TextStyle(color: Colors.white),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(DateFormat('hh:mm a').format(DateTime.parse(messModel.time!)), style: TextStyle(fontSize: 11),),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 4,),
            Text("Read... ", style: TextStyle(fontSize: 12,  color: Colors.grey),),
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
