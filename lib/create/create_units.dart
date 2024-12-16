import 'dart:convert';

import 'package:Zelli/widgets/dialogs/dialog_add_unit.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/data.dart';
import '../models/entities.dart';
import '../models/units.dart';
import '../utils/colors.dart';
import '../views/unit/activities/add_unit.dart';
import '../widgets/buttons/call_actions/double_call_action.dart';
import '../widgets/cards/card_button.dart';
import '../widgets/dialogs/dialog_edit_unit.dart';
import '../widgets/dialogs/dialog_title.dart';

class CreateUnits extends StatefulWidget {
  final Function getUnits;
  final Function addToUnitList;
  final Function removeFromList;
  final Function updateUnit;
  final Function updateUnitData;
  final int floor;
  final EntityModel entity;
  const CreateUnits({super.key, required this.getUnits, required this.addToUnitList, required this.removeFromList, required this.updateUnit, required this.updateUnitData, required this.floor, required this.entity});

  @override
  State<CreateUnits> createState() => _CreateUnitsState();
}

class _CreateUnitsState extends State<CreateUnits> {
  List<UnitModel> _unitList = [];
  bool _layout = true;
  bool _loading = false;
  String _titleProgress = '';
  List<String> title = ['Total Units'];

  final _formkey = GlobalKey<FormState>();

  _getUnits()async {
    setState(() {
      _showProgress('Loading Units...');
      _loading = true;
    });
    _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid && element.floor == widget.floor.toString()).toList();
    widget.getUnits();
    setState(() {
      _showProgress(_titleProgress = widget.floor == 0 ? 'Create units under Ground Floor' : 'Create units under Floor ${widget.floor}');
      _loading = false;
    });
  }

  _showProgress(String message) {
    setState(() {
      _titleProgress = message;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUnits();
  }


  @override
  Widget build(BuildContext context) {
    final normal =  Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleProgress),
      ),
      body: SafeArea(
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formkey,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 3 / 2,
                        crossAxisSpacing: 1,
                        mainAxisSpacing: 1
                    ),
                    itemCount: title.length,
                    itemBuilder: (context, index){
                      return Card(
                        margin: EdgeInsets.all(5),
                        elevation: 3,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(title[index], style: TextStyle(fontWeight: FontWeight.w300,color: Colors.black),),
                            SizedBox(height: 10,),
                            Text(_unitList.length.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black
                              ),
                            ),

                          ],
                        ),
                      );
                    }),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _loading? SizedBox(width: 15, height: 15,child: CircularProgressIndicator(color: reverse,strokeWidth: 2,)) : SizedBox(),
                    Expanded(child: SizedBox()),
                    CardButton(
                      text: 'ADD',
                      backcolor: Colors.white,
                      icon: Icon(Icons.add, color: screenBackgroundColor,size: 19,),
                      forecolor: screenBackgroundColor,
                      onTap: () {
                        Get.to(() => AddUnit(entity: widget.entity, reload: _getUnits, floor: widget.floor),transition: Transition.rightToLeft);
                      },
                    ),
                    CardButton(
                      text: _layout?'LIST':'TABLE',
                      backcolor: Colors.white,
                      icon: Icon(_layout?Icons.list:Icons.table_chart_sharp, color: screenBackgroundColor,size: 19,),
                      forecolor: screenBackgroundColor,
                      onTap: () {
                        setState(() {
                          _layout=!_layout;
                        });
                      },
                    ),
                    CardButton(
                      text:'RELOAD',
                      backcolor: screenBackgroundColor,
                      icon: Icon(Icons.refresh, size: 19, color: Colors.white,), forecolor: Colors.white,
                      onTap: () {
                        _getUnits();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: BouncingScrollPhysics(),
                      child: DataTable(
                        headingRowHeight: 40,
                        headingTextStyle: TextStyle(color: normal),
                        dividerThickness: 0.5,
                        headingRowColor: MaterialStateColor.resolveWith((states) {
                          return reverse;
                        }),
                        columns: const [
                          DataColumn(
                              label: Text("Unit",),
                              numeric: false,
                              tooltip: "This is the unit title"),
                          DataColumn(
                              label: Text(
                                  "Bedroom"
                              ),
                              numeric: false,
                              tooltip: "This is the number of bedrooms"),
                          DataColumn(
                              label: Text("Rent"),
                              numeric: false,
                              tooltip: "This is the rent price"),
                          DataColumn(
                              label: Text("Deposit"),
                              numeric: false,
                              tooltip: "This is the deposit amount"),
                          DataColumn(
                              label: Text("Edit"),
                              numeric: false,
                              tooltip: "This is action to edit"),
                          DataColumn(
                              label: Text("Delete"  ),
                              numeric: false,
                              tooltip: "This is delete action"),

                        ],
                        rows: _unitList.map((unit) => DataRow(
                            cells: [
                              DataCell(
                                  Text(
                                    unit.title.toString(),
                                    style: TextStyle(
                                        color: unit.checked == "false"
                                            ? Colors.red
                                            : reverse
                                    ),
                                  ),
                                  onTap: (){

                                  }
                              ),
                              DataCell(
                                  Text(unit.room.toString() == "0"? "Studio" : unit.room.toString()),
                                  onTap: (){

                                  }
                              ),
                              DataCell(
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(unit.price.toString()))}' ),
                                  onTap: (){

                                  }
                              ),
                              DataCell(
                                  Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(unit.deposit.toString()))}'),
                                  onTap: (){

                                  }
                              ),
                              DataCell(
                                  IconButton(
                                      onPressed: (){
                                        dialogEditUnit(context, unit);
                                      },
                                      icon: Icon(Icons.edit))
                              ),
                              DataCell(
                                  IconButton(
                                      onPressed: (){
                                        dialogRemoveUnit(context, unit);
                                      },
                                      icon: Icon(Icons.delete))

                              ),
                            ]
                        )
                        ).toList(),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(Data().message,
                        style: TextStyle(color: secondaryColor, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  void dialogAddUnit(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "A D D  U N I T"),
                Text(
                  'Please provide the unit details in the fields below to add a new unit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor),
                ),
                DialogAddUnit(reload: _getUnits, entity: widget.entity, floor: widget.floor)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogEditUnit(BuildContext context, UnitModel unitModel){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "E D I T  U N I T"),
                Text(
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, ),
                ),
                DialogEditUnit(unit: unitModel, reload: _getUnits,)
              ],
            ),
          ),
        ),
      );
    });
  }
  void dialogRemoveUnit(BuildContext context, UnitModel unitModel){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "R E M O V E  U N I T"),
                Text(
                  'Are you sure you wish to remove ${unitModel.title} from your entity completely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, ),
                ),
                DoubleCallAction(
                    action: ()async{
                      await Data().removeUnit(unitModel, _getUnits, context).then((value){
                        Navigator.pop(context);
                      });
                    })
              ],
            ),
          ),
        ),
      );
    });
  }


  void _removeFromList(String id){
    _unitList.removeWhere((unit) => unit.id == id);
    widget.removeFromList(id);
    setState(() {
    });
  }


}


