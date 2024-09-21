import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/messages.dart';


class OwnMessCard extends StatelessWidget {
  final MessModel messModel;
  const OwnMessCard({super.key, required this.messModel});

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
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.teal,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
}
