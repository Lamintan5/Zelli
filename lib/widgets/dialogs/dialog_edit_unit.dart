import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../buttons/call_actions/double_call_action.dart';

class DialogEditUnit extends StatefulWidget {
  final UnitModel unit;
  final Function reload;
  const DialogEditUnit({super.key, required this.unit, required this.reload});

  @override
  State<DialogEditUnit> createState() => _DialogEditUnitState();
}

class _DialogEditUnitState extends State<DialogEditUnit> {
  TextEditingController _title = TextEditingController();
  TextEditingController _rent = TextEditingController();
  TextEditingController _deposit = TextEditingController();
  bool _loading = false;
  int roomNo = 0;
  final formKey = GlobalKey<FormState>();
  late UnitModel unit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    unit = widget.unit;
    _title.text = unit.title.toString();
    roomNo = int.parse(unit.room.toString());
    _rent.text = unit.price.toString();
    _deposit.text = unit.deposit.toString();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _title,
            keyboardType: TextInputType.text,
            maxLines: 1,
            minLines: 1,
            decoration: InputDecoration(
              label: Text("Unit Title"),
              fillColor: color1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(5)
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            ),
            onChanged:  (value) => setState((){}),
            validator: (value){
              if(value!.isEmpty || value==""){
                return "Please enter unit title";

              }
            },
          ),
          SizedBox(height: 10,),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              color: color1,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                Text(roomNo == 0 ? "  Studio" : " ${roomNo} Bedroom"),
                Expanded(child: SizedBox()),
                InkWell(
                  onTap: (){
                    setState(() {
                      if(roomNo >0){
                        roomNo--;
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Icon(Icons.remove_circle),
                ),
                SizedBox(width: 5,),
                InkWell(
                    onTap: (){
                      setState(() {
                        roomNo++;
                      });
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Icon(Icons.add_circle)
                ),
              ],
            ),
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  controller: _rent,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Rent"),
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  onChanged:  (value) => setState((){}),
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }

                    if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return null; // Valid input (contains only digits and at most one dot)
                    } else {
                      return 'Please enter a valid number with only one decimal point.';
                    }

                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: TextFormField(
                  controller: _deposit,
                  maxLines: 1,
                  minLines: 1,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text("Deposit"),
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  ),
                  onChanged:  (value) => setState((){}),
                  validator: (value){
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value.';
                    }

                    if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                      return null;
                    } else {
                      return 'Please enter a valid number with only one decimal point.';
                    }
                  },
                ),
              ),
            ],
          ),
          Divider(
            thickness: 0.1,
            color: reverse,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                      onTap: (){Navigator.pop(context);},
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(height: 40,
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                            textAlign: TextAlign.center,),
                        ),
                      ),
                    )
                ),
                VerticalDivider(
                  thickness: 0.1,
                  color: reverse,
                ),
                Expanded(
                    child: InkWell(
                      onTap: ()async{
                        UnitModel newUnit = unit;
                        setState(() {
                          newUnit = unit;
                          newUnit.title = _title.text.toString();
                          newUnit.room = roomNo.toString();
                          newUnit.price = _rent.text.toString();
                          newUnit.deposit = _deposit.text.toString();
                          _loading = true;
                        });

                        await Data().editUnit(context, widget.reload, newUnit).then((value){
                          _loading = value;
                          if(value==false){Navigator.pop(context);}
                        });
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: SizedBox(height: 40,
                        child: Center(
                          child: _loading
                              ? SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(
                                  "Continue",
                                  style: TextStyle(color: CupertinoColors.systemBlue, fontWeight: FontWeight.w700, fontSize: 15),
                                  textAlign: TextAlign.center
                                ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
