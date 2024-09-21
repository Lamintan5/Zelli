import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:flutter/material.dart';

class UnitProfilePage extends StatefulWidget {
  final UnitModel unit;
  final EntityModel entity;
  const UnitProfilePage({super.key, required this.unit, required this.entity});

  @override
  State<UnitProfilePage> createState() => _UnitProfilePageState();
}

class _UnitProfilePageState extends State<UnitProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
