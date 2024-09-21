import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final Function updateCount;
  const ChatScreen({super.key, required this.updateCount});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
