import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../../widgets/items/mess_items/item_chat.dart';
import '../../../widgets/items/mess_items/item_chat_group.dart';

class ChatScreen extends StatefulWidget {
  final Function updateCount;
  const ChatScreen({super.key, required this.updateCount});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _search;

  bool isFilled = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.updateCount();
    _search = TextEditingController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final socketManager = Get.find<SocketManager>();
    List<ChatsModel> mychats = socketManager.chats;
    mychats.sort((a, b) => b.time!.compareTo(a.time.toString()));

    List<ChatsModel> chats = [];

    if (_search.text.isNotEmpty) {
      chats = mychats.where((item) =>
          item.title.toString().toLowerCase().contains(_search.text.toLowerCase()))
          .toList();
    } else {
      chats = mychats;
    }

    return  Scaffold(
      backgroundColor: normal,
      appBar: AppBar(
        backgroundColor: normal,
        title: Obx(() => Text("${mychats.length} C H A T S", style: TextStyle(fontWeight: FontWeight.w100),)),
        actions: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 1, horizontal: 8),
            decoration: BoxDecoration(
                color: CupertinoColors.activeBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                    color: CupertinoColors.activeBlue,
                    width: 0.5
                )
            ),
            child: Text("Beta", style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.bold),),
          ),
          IconButton(
            onPressed: (){
            },
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 8.0),
          child: Column(
            children: [
              Container(
                width: 500,
                child: TextFormField(
                  controller: _search,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "Search",
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                    prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
                    prefixIconConstraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 30
                    ),
                    suffixIcon: isFilled?InkWell(
                        onTap: (){
                          _search.clear();
                          setState(() {
                            isFilled = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(100),
                        child: Icon(Icons.cancel, size: 20,color: secondaryColor)
                    ) :SizedBox(),
                    suffixIconConstraints: BoxConstraints(
                        minWidth: 40,
                        minHeight: 30
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 1, horizontal: 20),
                    filled: true,
                    isDense: true,
                  ),
                  onChanged:  (value) => setState((){
                    if(value.isNotEmpty){
                      isFilled = true;
                    } else {
                      isFilled = false;
                    }
                  }),
                ),
              ),
              Expanded(
                child: Obx(
                        ()=> ListView.builder(
                        physics: BouncingScrollPhysics(),
                        itemCount:chats.length,
                        itemBuilder: (context, index){
                          ChatsModel chat = chats[index];
                          return chat.cid.split(",").length == 1
                              ? ItemChatGroup(chatsModel: chat, from: 'Group',)
                              : ItemChat(chatsModel: chat, from: 'Individual');
                        })
                ),
              ),
              Text(
                Data().message,
                style: TextStyle(color: secondaryColor, fontSize: 11),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
