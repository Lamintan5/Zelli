import 'package:Zelli/models/chats.dart';
import 'package:flutter/material.dart';

class ItemChat extends StatefulWidget {
  final ChatsModel chatsModel;
  final String from;
  const ItemChat({super.key, required this.chatsModel, required this.from});

  @override
  State<ItemChat> createState() => _ItemChatState();
}

class _ItemChatState extends State<ItemChat> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
