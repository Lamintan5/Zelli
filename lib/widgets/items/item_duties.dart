import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/duties.dart';
import '../../models/duty.dart';
import '../../utils/colors.dart';

class ItemDuties extends StatefulWidget {
  final DutyModel duty;
  final DutiesModel dutiesModel;
  final Function removeDuty;
  final Function addDuty;
  const ItemDuties({super.key, required this.duty, required this.dutiesModel,  required this.removeDuty, required this.addDuty});

  @override
  State<ItemDuties> createState() => _ItemDutiesState();
}

class _ItemDutiesState extends State<ItemDuties> {
  String _dutiesString = "";
  List<String> _dutiesList = [];
  bool _isChecked = false;

  _setDuties(){
    _dutiesString = widget.dutiesModel.duties.toString();
    _dutiesList = _dutiesString.split(",");
    if(_dutiesList.contains(widget.duty.text.toUpperCase())){
      setState(() {
        _isChecked = true;
      });
    } else {
      setState(() {
        _isChecked = false;
      });
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setDuties();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Container(
      decoration: BoxDecoration(
        color: color1,
        borderRadius: BorderRadius.circular(5)
      ),
      margin: EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        children: [
          widget.duty.icon,
          SizedBox(width: 20,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.duty.text),
                Text(widget.duty.message,
                  style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isChecked,
            onChanged: (value){
              setState(() {
                _isChecked = value;
                if(value==true){
                  widget.addDuty(widget.duty.text.toUpperCase());
                } else {
                  widget.removeDuty(widget.duty.text.toUpperCase());
                }
              });
            },
          )
        ],
      ),
    );
  }
}
