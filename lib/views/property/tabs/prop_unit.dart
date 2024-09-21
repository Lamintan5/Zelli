import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../create/create_units.dart';
import '../../../models/entities.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/expanded_floor.dart';
import '../../../widgets/map_key.dart';

class PropUnit extends StatefulWidget {
  final String title;
  final EntityModel entity;
  final int max;
  const PropUnit({super.key, required this.title, required this.entity, required this.max});

  @override
  State<PropUnit> createState() => _PropUnitState();
}

class _PropUnitState extends State<PropUnit> {
  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Column(
      children: [
        SizedBox(height: 10,),
        SizedBox(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MapKeys(color: color1, text: 'Occupied'),
              MapKeys(color: CupertinoColors.activeOrange, text: 'Incomplete'),
              MapKeys(color: CupertinoColors.systemBlue, text: 'Available'),
              MapKeys(color: Colors.green, text: 'Prepaid'),
              MapKeys(color: Colors.red, text: 'Accrual'),
            ],
          ),
        ),
        SizedBox(height: 10,),
        Expanded(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 1000,
              minWidth: 450
            ),
            child: ListView.builder(
                itemCount: widget.max,
                itemBuilder: (context, index){
                  return ExpandFloor(floor: index, title: widget.title, entity: widget.entity,);
                }),
          ),
        ),
      ],
    );
  }
}


