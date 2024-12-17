import 'dart:convert';

import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/util.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../models/account.dart';
import '../../../models/billing.dart';
import '../../../models/entities.dart';
import '../../../models/gateway.dart';
import '../../../models/utils.dart';
import '../../../widgets/text/text_filed_input.dart';

class UtilScreen extends StatefulWidget {
  final UtilModel util;
  final UtilsModel utils;
  final EntityModel entity;
  final Function addUtil;
  final Function reload;

  const UtilScreen({super.key, required this.util, required this.addUtil, required this.utils, required this.entity, required this.reload});

  @override
  State<UtilScreen> createState() => _UtilScreenState();
}

class _UtilScreenState extends State<UtilScreen> {
  TextEditingController _pay = TextEditingController();

  List<String> costs = ['Variable', 'Fixed'];
  List<String> items = ['Once', 'Annually', 'Monthly'];

  final formKey = GlobalKey<FormState>();

  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];

  bool _loading = false;
  bool _isEqual = true;

  String period = "";
  String? item;
  String? cost;

  _getData(){
    cost = widget.utils.cost.isEmpty? 'Fixed' : widget.utils.cost;
    item = widget.utils.period.isEmpty? 'Monthly' : widget.utils.period;
    _pay.text = widget.utils.amount;
    _isEqualData();

  }

  void _isEqualData(){
    if(cost == widget.utils.cost  && item == widget.utils.period && _pay.text == widget.utils.amount){
      _isEqual = true;
    } else {
      _isEqual = false;
    }
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
                            Text("  Select cost type", style: TextStyle(fontSize: 14),),
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
                              onChanged: (value) => setState(() {
                                this.cost = value;
                                _isEqualData();
                              }),
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        cost == "Variable"
                            ? SizedBox()
                            : Row(
                              children: [
                                Text("  Payment Interval", style: TextStyle(fontSize: 14),),
                              ],
                            ),
                        SizedBox(height: 5,),
                        cost == "Variable"
                            ? SizedBox()
                            : Container(
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
                              onChanged: (value) => setState((){
                                this.item = value;
                                _isEqualData();
                              }),
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
                          onChanged: (value){
                            _isEqualData();
                          },
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
                  if(_isEqual == false){
                    _addUtil(item.toString(), cost.toString(), _pay.text.toString());
                  }
                },
                splashColor: CupertinoColors.activeBlue,
                child: Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: _isEqual? CupertinoColors.activeBlue.withOpacity(0.3) : CupertinoColors.activeBlue,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                      child: _loading
                          ?SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                          : Text(
                            "Continue",
                            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
                          )
                  ),
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

  _addUtil(String newPeriod, String newCost, String newAmount)async{
    List<EntityModel> _entity = [];
    List<UtilsModel> _utils = [];
    List<String> uniqueEntities = [];
    List<String> _utilString = [];

    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();

    setState(() {
      _loading = true;
    });

    UtilsModel utilsModel = UtilsModel(
      text: widget.util.text,
      period: newPeriod,
      amount: newAmount.isEmpty || cost == 'Variable'? '0.0' : newAmount,
      checked: 'false',
      cost: newCost,
    );
    _utils.add(utilsModel);
    _utilString = _utils.map((e) => jsonEncode(e.toJson())).toList();

    EntityModel entityModel = _entity.firstWhere((element) => element.eid == widget.entity.eid);

    List<String> _oldUtils = entityModel.utilities.toString().split('&');
    List<String> _finalUtils = [];

    _finalUtils = [..._oldUtils, ..._utilString];


    _entity.firstWhere((element) => element.eid == widget.entity.eid).utilities = _finalUtils.join('&');

    await Services.addUtil(widget.entity.eid, _utilString.first).then((response){
      print(response);
      _finalUtils.forEach((e){
        print(e.toString());
      });
      if(response=="success"){
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        setState(() {
          _loading = false;
        });
        widget.reload();
        Navigator.pop(context);
      } else if(response.contains('failed')){
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Utility Added Successfully.'),
                showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Data().failed),
              showCloseIcon: true,
            )
        );
        setState(() {
          _loading = false;
        });
      }
    });
  }

}
