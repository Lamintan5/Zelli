import 'package:Zelli/models/util.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/utils.dart';
import '../../../widgets/text/text_filed_input.dart';

class UtilScreen extends StatefulWidget {
  final UtilModel util;
  final UtilsModel utils;
  final Function addUtil;

  const UtilScreen({super.key, required this.util, required this.addUtil, required this.utils});

  @override
  State<UtilScreen> createState() => _UtilScreenState();
}

class _UtilScreenState extends State<UtilScreen> {
  TextEditingController _pay = TextEditingController();

  List<String> costs = ['Variable', 'Fixed'];
  List<String> items = ['Once', 'Annually', 'Monthly'];

  final formKey = GlobalKey<FormState>();


  String period = "";
  String? item;
  String? cost;

  _getData(){
    cost = widget.utils.cost.isEmpty? 'Fixed' : widget.utils.cost;
    item = widget.utils.period.isEmpty? 'Monthly' : widget.utils.period;
    _pay.text = widget.utils.amount;
    setState(() {

    });
  }

  _setDate(String newPeriod, String newCost, String newAmount){
    UtilsModel utilsModel = UtilsModel(
      text: widget.util.text,
      period: newPeriod,
      amount: newAmount.isEmpty || cost == 'Variable'? '0.0' : newAmount,
      checked: 'false',
      cost: newCost,
    );
    // amount = newAmount.isEmpty || cost == 'Variable'? 0 :  double.parse(newAmount);
    period = newPeriod;
    widget.addUtil(utilsModel);
    setState(() {

    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30,),
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: CupertinoColors.activeBlue.withOpacity(0.2)
                          ),
                          child: Icon(widget.util.icon, size: 40,color: CupertinoColors.activeBlue,),
                        ),
                        Text(
                          widget.util.text, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Text(
                            widget.util.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: secondaryColor),
                        ),
                        SizedBox(height: 20,),
                        Row(
                          children: [
                            Text("  Select cost type", style: TextStyle(fontSize: 13, color: secondaryColor),),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12,),
                          decoration: BoxDecoration(
                              color: color1,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: cost == null? Colors.red: color1
                              )
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: cost,
                              dropdownColor: bgColor,
                              icon: Icon(Icons.arrow_drop_down, color:cost == null? Colors.red: reverse),
                              isExpanded: true,
                              items: costs.map(buildMenuItem).toList(),
                              onChanged: (value) => setState(() => this.cost = value),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          children: [
                            Text("  Payment Interval", style: TextStyle(fontSize: 13, color: secondaryColor),),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12,),
                          decoration: BoxDecoration(
                              color: color1,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1,
                                  color: item == null? Colors.red: color1
                              )
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: item,
                              dropdownColor: bgColor,
                              icon: Icon(Icons.arrow_drop_down, color:item == null? Colors.red: reverse),
                              isExpanded: true,
                              items: items.map(buildMenuItem).toList(),
                              onChanged: (value) => setState(() => this.item = value),
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        cost == "Variable"
                            ? SizedBox()
                            : TextFieldInput(
                          textEditingController: _pay,
                          textInputType: TextInputType.number,
                          labelText: 'Amount',
                          validator: (value){
                            if (value == null || value.isEmpty) {
                              return 'Please enter the correct amount';
                            }
                            if (RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(value)) {
                              return null;
                            } else {
                              return 'Please enter a valid number with up to two decimal places.';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: (){
                  _setDate(item.toString(), cost.toString(), _pay.text.toString());
                  Navigator.pop(context);

                },
                child: Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(child: Text("Continue", style: TextStyle(color: Colors.black),)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
    ),
  );
}
