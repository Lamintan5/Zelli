
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../utils/colors.dart';
import '../buttons/call_actions/double_call_action.dart';
import '../text/text_filed_input.dart';
import 'dialog_title.dart';

class DialogIpaddress extends StatefulWidget {
  const DialogIpaddress({super.key});

  @override
  State<DialogIpaddress> createState() => _DialogIpaddressState();
}

class _DialogIpaddressState extends State<DialogIpaddress> {
  final TextEditingController _ipController = TextEditingController();
  bool _loading = false;

  _setDomain()async{
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('domain', _ipController.text.toString());
    domain = _ipController.text.toString();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Address Added Successfully ✅",),
        )
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ipController.text = domain.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DialogTitle(title: "D O M A I N"),
          Text(
            "Please enter your servers domain here.",
            textAlign: TextAlign.center,
            style: TextStyle(color: secondaryColor),
          ),
          SizedBox(height: 10,),
          TextFieldInput(
            textEditingController: _ipController,
            labelText: "Domain",
            textInputType: TextInputType.text,
            validator: (value){
              if (value == null || value.isEmpty) {
                return 'Please enter an ipp address.';
              }
            },
          ),
          DoubleCallAction(action: (){_setDomain();}),
        ],
      ),
    );
  }
}
