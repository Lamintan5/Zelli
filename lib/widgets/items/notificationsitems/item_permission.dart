import 'package:flutter/material.dart';

import '../../../models/notifications.dart';

class ItemPermission extends StatefulWidget {
  final NotifModel notif;
  final Function getEntity;
  final String from;
  const ItemPermission({super.key, required this.notif, required this.getEntity, required this.from});

  @override
  State<ItemPermission> createState() => _ItemPermissionState();
}

class _ItemPermissionState extends State<ItemPermission> {
  @override
  Widget build(BuildContext context) {
    return SizedBox();
  }
}
