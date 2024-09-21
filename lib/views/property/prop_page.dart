import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/units.dart';
import 'package:flutter/material.dart';

class PropertyPage extends StatefulWidget {
  final EntityModel entity;
  final List<UnitModel> units;
  const PropertyPage({super.key, required this.entity, required this.units});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

class _PropertyPageState extends State<PropertyPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
