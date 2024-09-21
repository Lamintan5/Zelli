import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/messages.dart';


class TargetMessCard extends StatelessWidget {
  final MessModel messModel;
  const TargetMessCard({super.key, required this.messModel});

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
                  Text(
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
}
