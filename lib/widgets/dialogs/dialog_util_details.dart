import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../text/text_filed_input.dart';

class DialogUtilDetail extends StatefulWidget {
  final Function setData;
  final String period;
  final double amount;
  const DialogUtilDetail({super.key, required this.setData, required this.period, required this.amount});

  @override
  State<DialogUtilDetail> createState() => _DialogUtilDetailState();
}

class _DialogUtilDetailState extends State<DialogUtilDetail> {
  List<String> items = ['Once', 'Annually', 'Monthly'];
  TextEditingController _pay = TextEditingController();
  String? item;
  final formKey = GlobalKey<FormState>();

  _setData(){
    widget.setData(item, double.parse(_pay.text));
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.period != ""){
      _pay.text = widget.amount.toString();
      item = widget.period;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
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
          SizedBox(height: 5,),
          TextFieldInput(
            textEditingController: _pay,
            textInputType: TextInputType.number,
            labelText: 'Amount Paid',
            validator: (value){
              if (value == null || value.isEmpty) {
                return 'Please enter the correct amount';
              } else  if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                return null;
              } else {
                return 'Please enter a valid number.';
              }
            },
          ),
          SizedBox(height: 5,),
          DoubleCallAction(action: (){
            final form = formKey.currentState!;
            if(form.validate()) {
              _setData();
            }
          })
        ],
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
