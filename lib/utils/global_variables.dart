import 'package:Zelli/models/entities.dart';
import 'package:flutter/cupertino.dart';

import '../home/tabs/payments.dart';
import '../home/tabs/profile.dart';
import '../home/tabs/report.dart';
import '../home/tabs/units.dart';

List<Widget> homeScreenItems = [
  Profile(),
  Units(),
  Payments(eid: '',unitid: '',tid: '', lid: '',),
  Report(entity: EntityModel(eid: ""), unitid: '', tid: ''),
];