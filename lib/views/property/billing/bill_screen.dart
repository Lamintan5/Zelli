import 'dart:convert';

import 'package:Zelli/models/billing.dart';
import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/utils.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/gateway.dart';
import '../../../widgets/buttons/call_actions/double_call_action.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/text/text_filed_input.dart';

class BillScreen extends StatefulWidget {
  final EntityModel entity;
  final GateWayModel card;
  final BillingModel bill;
  final Function reload;
  final Function removeBill;
  const BillScreen({super.key, required this.card, required this.bill, required this.reload, required this.removeBill, required this.entity});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<String> _paybilloptions = ['One account for all units', 'Different accounts for different units'];

  final key = GlobalKey<FormState>();

  List<UtilsModel> _utils = [];
  List<String> _utilString = [];

  late TextEditingController _accno;
  late TextEditingController _busno;

  late GateWayModel card;
  late BillingModel bill;

  String? _selectedOption;

  bool _edit = false;
  bool _editing = false;
  bool _deleting = false;

  _getData(){
    _busno = TextEditingController();
    _accno = TextEditingController();
    card = widget.card;
    bill = widget.bill;
    _busno.text = bill.businessno;
    _accno.text = bill.type=="Different"? '' : bill.accountno;
    _selectedOption = bill.type == 'Same'? 'One account for all units':'Different accounts for different units';
    _utilString = widget.entity.utilities.toString().split("&");
    _utils.add(UtilsModel(text: "Rent", period: 'Monthly', amount: '', cost: '',  checked: 'false'));
    _utils.addAll(_utilString.map((jsonString) {
      if (jsonString.isNotEmpty) {
        return UtilsModel.fromJson(json.decode(jsonString));
      } else {
        return UtilsModel(text: '', period: '', amount: "", checked: "", cost: '');
      }
    }).toList());
    _utils.removeWhere((test) =>test.text.isEmpty);
    _utils.forEach((util){
      if(bill.account.toLowerCase().contains(util.text.toLowerCase())){
        util.checked = 'true';
      } else {
        util.checked = 'false';
      }
    });
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _busno.dispose();
    _accno.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(width: 20, height: 20, card.logo),
            SizedBox(width: 10,),
            Text(card.title)
          ],
        ),
        actions: [
          _deleting
              ? Container(
                  width: 20,
                  height: 20 ,
                  margin: EdgeInsets.only(right: 10),
                  child: CircularProgressIndicator(color: reverse,strokeWidth: 3,)
              )
              : PopupMenuButton(
              itemBuilder: (BuildContext context){
                return [
                  if(!_edit)
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.pen),
                          SizedBox(width: 5,),
                          Text('Edit'),
                        ],
                      ),
                      onTap: (){
                        setState(() {
                          _edit = true;
                        });
                      },
                    ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.delete),
                        SizedBox(width: 5,),
                        Text('Delete'),
                      ],
                    ),
                    onTap: (){
                      dialogRemove(context);
                    },
                  ),
                ];
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _edit
            ? Form(
              key: key,
              autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      SizedBox(height: 30,),
                      Text(
                        "Update Pay Bill Detail",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10,),
                      TextFieldInput(
                        textEditingController: _busno,
                        labelText: "Business Number",
                        textInputType: TextInputType.number,
                        validator: (value){
                          if (value == null || value.isEmpty) {
                            return 'Please enter business number.';
                          }
                          if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                            return null; // Valid input (contains only digits)
                          } else {
                            return 'Please enter a valid business number';
                          }
                        },
                      ),
                      SizedBox(height: 5,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("  Account types"),
                        ],
                      ),
                      SizedBox(height: 5,),
                      ..._paybilloptions.map((option){
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: RadioListTile(
                              contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              dense: true,
                              value: option,
                              groupValue: _selectedOption,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              title: Text(option, style: TextStyle(fontSize: 15, color: secondaryColor)),
                              tileColor: color1,
                              subtitle: option == 'One account for all units' && _selectedOption == 'One account for all units'
                                  ? TextFormField(
                                controller: _accno,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  label: Text("Account Number"),
                                  fillColor: color1,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(5)
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  filled: true,
                                  isDense: true,
                                ),
                                validator: (value){
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter account number.';
                                  }
                                  if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                                    return null; // Valid input (contains only digits)
                                  } else {
                                    return 'Please enter a valid account number';
                                  }
                                },
                              ) : null,
                              onChanged: (value){
                                setState(() {
                                  _selectedOption = value;
                                });
                              }
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 10,),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: color1
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('<<Click on any item to select>>', style: TextStyle(color: secondaryColor),),
                              ],
                            ),
                            SizedBox(height: 5,),
                            Wrap(
                              spacing: 5,runSpacing: 5,
                              children: _utils.map((account){
                                return InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                  splashColor: CupertinoColors.activeBlue,
                                  onTap: (){
                                      setState(() {
                                        if(account.checked=='true'){
                                          account.checked = 'false';
                                        } else {
                                          account.checked = 'true';
                                        }
                                      });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                                    decoration: BoxDecoration(
                                        color: account.checked == 'true'? CupertinoColors.activeBlue.withOpacity(0.2) : color1,
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          account.checked == 'true'? CupertinoIcons.check_mark_circled : CupertinoIcons.circle,
                                          size: 15,
                                          color: account.checked == 'true'? CupertinoColors.activeBlue : secondaryColor,
                                        ),
                                        SizedBox(width: 2,),
                                        Text(account.text,
                                            style: TextStyle(
                                                color: account.checked == 'true'? CupertinoColors.activeBlue : secondaryColor)
                                        ),
                                        SizedBox(width: 2,),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      InkWell(
                        onTap: (){
                          final form = key.currentState!;
                          if(form.validate()) {
                            _update();
                          }
                        },
                        child: Container(
                          width: 450,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: CupertinoColors.activeBlue
                          ),
                          child: Center(
                              child: _editing
                                  ? SizedBox(
                                      width: 15, height: 15,
                                      child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,)
                                    )
                                  : Text(
                                      "Update", style: TextStyle(
                                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                                      ),
                                    )
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: (){
                            setState(() {
                              _edit = false;
                              _busno.text = bill.businessno;
                              _accno.text = bill.accountno;
                              _selectedOption = bill.type;
                            });
                          },
                          child: Text("Cancel")
                      )
                    ],
                  ),
                )
            : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: color1
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Business No",
                            style: TextStyle(color: secondaryColor),
                          ),
                          Text(bill.businessno),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: color1
                      ),
                      child:bill.type == "Different"
                          ? Text(
                            "Different accounts for different units",
                            style: TextStyle(color: secondaryColor),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Account no",
                                style: TextStyle(color: secondaryColor),
                              ),
                              Text(bill.accountno),
                            ],
                          ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: color1
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Created on",
                            style: TextStyle(color: secondaryColor),
                          ),
                          Text(DateFormat.yMMMEd().format(DateTime.parse(bill.time))),
                        ],
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text("  Account types"),
                    SizedBox(height: 5,),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: color1
                      ),
                      child: _utils.where((test) => test.checked == 'true').toList().isEmpty
                          ?  Text('No account type added', style: TextStyle(color: secondaryColor),)
                          :  Wrap(
                        spacing: 5,runSpacing: 5,
                        children: _utils.where((test) => test.checked == 'true').map((account){
                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                            decoration: BoxDecoration(
                              color: color1,
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Text(account.text, style: TextStyle(color: secondaryColor)),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: CupertinoColors.activeGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.checkmark_shield_fill, color: CupertinoColors.activeGreen,size: 50,),
                          SizedBox(width: 10,),
                          Expanded(
                              child: Text('We adhere entirely to the data security standards of the payment card industry.')
                          ),
                          SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ],
            ),
      ),
    );
  }
  void _update()async{
    setState(() {
      _editing = true;
    });
    List<String> _account = [];
    _account = _utils.where((test) => test.checked == 'true').map((element) => element.text).toList();
    await Services.updateBill(
        widget.bill.bid,
        _busno.text,
        _selectedOption == 'Different accounts for different units'? '' : _accno.text,
        _selectedOption == 'One account for all units'? 'Same' : 'Different',
        _account.join(',')
    ).then((value)async{
      if(value=="success"){
        setState(() {
          bill.businessno = _busno.text;
          bill.accountno = _accno.text;
          bill.type = _selectedOption == 'One account for all units'? 'Same' : 'Different';
          bill.account = _account.join(',');
          _editing = false;
          _edit = false;
        });
        await Data().editBill(bill);
        widget.reload();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Account was updated successfully"),
              showCloseIcon: true,
            )
        );
      } else if(value=="failed"){
        setState(() {
          _editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Account was not updated please try again"),
              showCloseIcon: true,
          )
        );
      }
    });
  }
  void dialogRemove(BuildContext context){
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "R E M O V E"),
              Text(
                 "Are you certain you want to proceed with removing this account?",
                style: TextStyle(color: secondaryColor),
              ),
              DoubleCallAction(
                  titleColor: Colors.red,
                  title: "Remove",
                  action: ()async{
                    setState(() {
                      _deleting = true;
                    });
                    await Services.deleteBill(bill.bid).then((value){
                      if(value=="success"){
                        setState(() {
                          _deleting = false;
                        });
                        Data().removeAccount(bill);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        widget.removeBill(bill);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Account removed successfully"),
                              showCloseIcon: true,
                          )
                        );
                      } else if(value=="failed"){
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Account was not removed. Please try again"),
                              showCloseIcon: true,
                            )
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(Data().failed),
                              showCloseIcon: true,
                            )
                        );
                      }
                    });
                  })
            ],
          ),
        ),
      );
    });
  }
}
