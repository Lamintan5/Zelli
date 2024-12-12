import 'package:Zelli/test/stripe_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TestUnit extends StatefulWidget {
  const TestUnit({super.key});

  @override
  State<TestUnit> createState() => _TestUnitState();
}

class _TestUnitState extends State<TestUnit> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MaterialButton(
          onPressed: (){
            StripeService.instance.makePayment();
          },
          color: CupertinoColors.activeBlue,
          child: Text("Pay"),
        ),
      ),
    );
  }
}
