import 'package:Zelli/main.dart';
import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../widgets/text/text_filed_input.dart';


class ChangePhone extends StatefulWidget {
  const ChangePhone({super.key});

  @override
  State<ChangePhone> createState() => _ChangePhoneState();
}

class _ChangePhoneState extends State<ChangePhone> {
  TextEditingController _phone = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool obsecure = true;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black87;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: normal,
        foregroundColor: color2,
        title: Text("Phone", style: TextStyle(fontWeight: FontWeight.normal),),
      ),
      body: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(height: 20,),
              Row(),
              Expanded(
                  child: SingleChildScrollView(
                    child: SizedBox(width: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.phone_android, size: 25,),
                              SizedBox(width: 10,),
                              Text("Change Phone Number",style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),),
                            ],
                          ),
                          Text(
                            'In order to change your current phone number, please enter your new phone number and ensure that you have entered your current password. An OTP code will be sent to your new phone number to verify your contact',
                            style: TextStyle(fontSize: 12, color: secondaryColor),
                          ),
                          SizedBox(height: 20,),
                          TextFieldInput(
                            textEditingController: _phone,
                            labelText: "Phone",
                            textInputType: TextInputType.phone,
                            validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number.';
                              }
                              if (value.length < 12) {
                                return 'phone number must be at least 12 characters long.';
                              }
                              if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                                return null; // Valid input (contains only digits)
                              } else {
                                return 'Please enter a valid phone number';
                              }
                            },
                          ),
                          SizedBox(height: 20,),
                          TextFieldInput(
                            textEditingController: _password,
                            labelText: "Password",
                            textInputType: TextInputType.text,
                            isPass: obsecure,
                            srfIcon: IconButton(
                                onPressed: (){
                                  setState(() {
                                    obsecure =! obsecure;
                                  });
                                },
                                icon: Icon(obsecure?Icons.remove_red_eye_outlined : Icons.remove_red_eye)),
                            validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password.';
                              }
                              if (value != currentUser.password) {
                                return 'Please Enter the correct password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  )
              ),
              InkWell(
                onTap: (){
                  final form = formKey.currentState!;
                  if(form.validate()) {

                  }
                },
                child: Container(
                  width: 400,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        width: 1,color: color2
                    ),
                  ),
                  child: Center(child: Text("Change Phone")),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        ),
      ),
    );
  }
}
