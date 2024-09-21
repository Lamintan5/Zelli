import 'package:flutter/material.dart';

import '../../../models/users.dart';

class MessageScreen extends StatefulWidget {
  final Function changeMess;
  final Function updateCount;
  final UserModel receiver;
  const MessageScreen({super.key, required this.changeMess, required this.updateCount, required this.receiver});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
