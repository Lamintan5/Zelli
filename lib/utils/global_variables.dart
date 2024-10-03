import 'package:Zelli/models/entities.dart';
import 'package:flutter/cupertino.dart';

import '../home/tabs/payments.dart';
import '../home/tabs/profile.dart';
import '../home/tabs/report.dart';
import '../home/tabs/units.dart';
import '../models/units.dart';

List<Widget> homeScreenItems = [
  Profile(),
  Units(),
  Payments(entity: EntityModel(eid: ""),unit: UnitModel(id: ""),tid: '', lid: '', from: '',),
  Report(entity: EntityModel(eid: ""), unitid: '', tid: '', lid: '',),
];