import 'package:flutter/material.dart';

import '../../../models/chats.dart';

class ItemChatGroup extends StatefulWidget {
  final ChatsModel chatsModel;
  final String from;
  const ItemChatGroup({super.key, required this.chatsModel, required this.from});

  @override
  State<ItemChatGroup> createState() => _ItemChatGroupState();
}

class _ItemChatGroupState extends State<ItemChatGroup> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
