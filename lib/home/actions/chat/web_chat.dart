import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import '../../../main.dart';
import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/users.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../../widgets/buttons/options_button.dart';
import '../../../widgets/items/mess_items/item_chat.dart';
import '../../../widgets/items/mess_items/item_chat_group.dart';
import '../../../widgets/items/mess_items/own_file_card.dart';
import '../../../widgets/items/mess_items/own_mess_card.dart';
import '../../../widgets/items/mess_items/target_file_card.dart';
import '../../../widgets/items/mess_items/target_mes_card.dart';
import '../../../widgets/profile_images/user_profile.dart';

class WebChat extends StatefulWidget {
  final UserModel selected;
  const WebChat({super.key, required this.selected});

  @override
  State<WebChat> createState() => _WebChatState();
}

class _WebChatState extends State<WebChat> {
  TextEditingController _serchController = TextEditingController();
  UserModel selectedUser = UserModel(uid: "");
  final TextEditingController messageController = TextEditingController();

  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;

  bool isShowEmojiContainer = false;
  bool isFilled = false;

  final isDialOpen =ValueNotifier(false);
  FocusNode focusNode = FocusNode();
  bool isShowSendButton = false;
  FocusNode _focusNode = FocusNode();
  bool more = false;
  String mid = '';
  String imageUrl = '';
  String chatType = '';
  List<String> _uidList = [];
  final picker = ImagePicker();
  File? _image;
  List<String> gidList = [];
  List<MessModel> mess = [];
  List<MessModel> messages = [];
  List<UserModel> _users = [];
  List<UserModel> _newUsers = [];
  final socketManager = Get.find<SocketManager>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedUser = widget.selected;
    chatType = 'individual';
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final image =  Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_72.png"
        : "assets/logo/5logo_72_black.png";
    final socketManager = Get.find<SocketManager>();
    List<ChatsModel> mychats = socketManager.chats;
    mychats.sort((a, b) => b.time!.compareTo(a.time.toString()));

    List<ChatsModel> chats = [];

    if (_serchController.text.isNotEmpty) {
      chats = mychats.where((item) =>
          item.title.toString().toLowerCase().contains(_serchController.text.toLowerCase()))
          .toList();
    } else {
      chats = mychats;
    }
    return  Scaffold(
      backgroundColor: normal,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                      onTap: (){Navigator.pop(context);},
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: color1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.arrow_left),
                      )
                  ),
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
                  )
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Column(
                      children: [

                        Expanded(child: SizedBox()),
                        Image.asset(
                            height: 30,
                            image
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: 450,
                        minWidth: 300
                    ),
                    decoration: BoxDecoration(
                        color: color1,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)
                        )
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Obx(() => Text("${mychats.length} C H A T S", style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20))),
                            Expanded(child: SizedBox()),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: LineIcon.editAlt(),
                                )
                            ),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.filter_list),
                                )
                            ),
                            SizedBox(width: 5,),
                            InkWell(
                                onTap: (){},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1  ,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(Icons.more_vert),
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        TextFormField(
                          controller: _serchController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Search",
                            fillColor: color1,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            isDense: true,
                            hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
                            prefixIcon: Icon(CupertinoIcons.search, size: 20,color: secondaryColor),
                            prefixIconConstraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 30
                            ),
                            suffixIcon: isFilled?InkWell(
                                onTap: (){
                                  _serchController.clear();
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
                          ),
                          onChanged: (value) {
                            setState(() {
                              if(value.isNotEmpty){
                                isFilled = true;
                              } else {
                                isFilled = false;
                              }
                            });
                          },
                        ),
                        SizedBox(height: 10,),
                        Expanded(
                          child: Obx(
                                  ()=> ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount:chats.length,
                                  itemBuilder: (context, index){
                                    ChatsModel chat = chats[index];
                                    late UserModel usr;
                                    var eids = [];
                                    if(chat.type=="individual"){
                                      eids = chat.cid.split(',');
                                      eids.remove(currentUser.uid);
                                      usr = _users.firstWhere((test) => test.uid == eids.first, orElse: () => UserModel(uid: ""));
                                    }
                                    return chat.type != "individual"
                                        ? InkWell(
                                            onTap: (){
                                            },
                                            child: ItemChatGroup(chatsModel: chat,from: "WEB",)
                                        )
                                        : InkWell(
                                        onTap: (){
                                          setState(() {
                                            selectedUser = usr;
                                            messages = mess.where((element) => "${element.sourceId},${element.targetId}".contains(currentUser.uid) && "${element.sourceId},${element.targetId}".contains(selectedUser.uid) && element.type.toString()== "individual").toList();
                                          });
                                        },
                                        child: Column(
                                          children: [
                                            ItemChat(chatsModel: chat, from: "WEB",),
                                            Text("Type : ${chat.type}")
                                          ],
                                        ))
                                    ;
                                  })
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 1,),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                          color: color1,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                          )
                      ),
                      margin: EdgeInsets.only(right: 10),
                      child:selectedUser.uid==""
                          ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset("assets/add/box.png"),
                          Text("Studio5ive Messaging", style: TextStyle(fontSize: 18),),
                          Text("Please select any user to start a conversation", style: TextStyle(color: secondaryColor),)
                        ],
                      )
                          : Stack(
                        children: [
                          Theme.of(context).brightness == Brightness.dark
                              ? Container(
                            width:double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  opacity: 0.6,
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/wallpaper/damascus.jpg'),
                                )
                            ),
                          )
                              : SizedBox(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                                child: Row(
                                  children: [
                                    UserProfile(image: selectedUser.image!),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(selectedUser.username.toString(), style: TextStyle(color: reverse)),
                                          Text("${selectedUser.firstname.toString()} ${selectedUser.lastname.toString()}", style: TextStyle(color: secondaryColor,fontSize: 12),),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: color1,
                                          child: IconButton(onPressed: (){}, icon: Icon(Icons.video_call), color: Colors.blue,),
                                        ),
                                        SizedBox(width: 5,),
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: color1,
                                          child: IconButton(onPressed: (){}, icon: Icon(Icons.call), color: Colors.blue,),
                                        ),

                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          constraints: BoxConstraints(
                                              maxWidth: 950,
                                              minWidth: 500
                                          ),
                                          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                          child: AnimatedList(
                                              physics: BouncingScrollPhysics(),
                                              key: _key,
                                              controller: _scrollcontroller,
                                              initialItemCount: messages.length,
                                              itemBuilder: (((context, index, animation){
                                                MessModel mess = messages[index];
                                                if(mess.sourceId==currentUser.uid){
                                                  if(mess.path==""){
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: OwnMessCard(messModel: mess,),
                                                      ),
                                                    );
                                                  } else {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: OwnFileCard(messModel: mess,),
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  if(mess.path==""){
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: TargetMessCard(messModel: mess,),
                                                      ),
                                                    );
                                                  } else {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SizeTransition(
                                                        key: UniqueKey(),
                                                        sizeFactor: animation,
                                                        child: TargetFileCard(messModel: mess,),
                                                      ),
                                                    );
                                                  }
                                                }
                                              }))
                                          ),
                                        ),
                                      ),
                                      const Positioned(
                                        top: 10,
                                        left: 0,right: 0,
                                        child:
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock, size: 10, color: CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text("end-to-end-encryption", style: TextStyle(color: CupertinoColors.systemBlue,fontSize: 11),),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: (){
                                        FocusScope.of(context).requestFocus(FocusNode());
                                        if (more == false){
                                          hideEmojiContainer();
                                        }
                                        setState(() {
                                          more = !more;
                                        });
                                      },
                                      icon: Icon(more ? Icons.add_circle : Icons.add_circle_outline_outlined)),
                                  IconButton(onPressed: (){}, icon: Icon(CupertinoIcons.photo_on_rectangle)),
                                  Expanded(
                                    child: Container(
                                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: color1,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: TextFormField(
                                                focusNode: _focusNode,
                                                onChanged: (val) {
                                                  if(val.isNotEmpty) {
                                                    setState((){
                                                      isShowSendButton = true;
                                                    });
                                                  } else {
                                                    setState((){
                                                      isShowSendButton = false;
                                                    });
                                                  }
                                                },
                                                controller: messageController,
                                                keyboardType: TextInputType.multiline,
                                                minLines: 1,
                                                maxLines: 7,
                                                decoration: InputDecoration(
                                                  hintText: "Message @${selectedUser.username}",
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  filled: false,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                onTap: (){
                                                  more = false;
                                                },
                                              )
                                          ),
                                          InkWell(onTap: (){
                                            setState(() {
                                              more = false;
                                            });
                                            toggleEmojiContainer();
                                          },child: Icon(isShowEmojiContainer? Icons.emoji_emotions  : Icons.emoji_emotions_outlined)),
                                          SizedBox(width: 10,),
                                          isShowSendButton
                                              ? InkWell(
                                            onTap: (){
                                              Uuid uuid = Uuid();
                                              mid = uuid.v1();
                                              String time = DateTime.now().toString();
                                              // sendMessage(
                                              //   mid,
                                              //   messageController.text.toString(),
                                              //   currentUser.uid,
                                              //   selectedUser.uid,
                                              //   "",
                                              //   "individual",
                                              //   time,
                                              // );
                                              _scrollcontroller.animateTo(_scrollcontroller.position.maxScrollExtent, duration: Duration(milliseconds: 800), curve: Curves.easeInOut);
                                              messageController.clear();
                                            },
                                            child: Icon(CupertinoIcons.location_fill),
                                          )
                                              : Icon(CupertinoIcons.mic),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              isShowEmojiContainer
                                  ? SizedBox()
                                  : AnimatedContainer(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                height: more ? 310 : 0,
                                duration: const Duration(milliseconds:500),
                                child: Wrap(
                                  spacing: 40,
                                  runSpacing: 20,
                                  children: [
                                    InkWell(onTap: choiceImage,child: OptionsButton( icon: LineIcon.photoVideo(color: reverse,), text: 'Gallery')),
                                    OptionsButton( icon: Icon(Icons.gif, color: reverse,), text: 'GIFs'),
                                    OptionsButton( icon: LineIcon.stickyNote(color: reverse,), text: 'Sticker'),
                                    OptionsButton( icon: Icon(Icons.attach_file, color: reverse,), text: 'Files'),
                                    OptionsButton( icon: Icon(Icons.location_on, color: reverse,), text: 'Location'),
                                    OptionsButton( icon: LineIcon.user(color: reverse,), text: 'Contacts'),
                                    OptionsButton( icon: LineIcon.clock(color: reverse,), text: 'Schedule'),
                                  ],
                                ),
                              ),
                              isShowEmojiContainer
                                  ? SizedBox(
                                height: 310,
                                child: EmojiPicker(
                                    config: Config(
                                      emojiViewConfig: EmojiViewConfig(
                                        columns: 10,
                                        emojiSizeMax: 20,
                                        backgroundColor: Colors.transparent,
                                        noRecents: Text(
                                          'No Recents',
                                          style: TextStyle(fontSize: 20, color: reverse),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      categoryViewConfig: CategoryViewConfig(
                                          indicatorColor: reverse,
                                          iconColorSelected: reverse,
                                          backgroundColor: Colors.transparent
                                      ),
                                      bottomActionBarConfig: BottomActionBarConfig(
                                          backgroundColor: Colors.transparent,
                                          buttonColor: normal
                                      ),
                                      searchViewConfig: SearchViewConfig(
                                        backgroundColor: Colors.transparent,
                                        buttonIconColor: reverse,
                                      ),
                                    ),
                                    onEmojiSelected: (category, emoji) {
                                      final currentPosition = messageController.selection.baseOffset;
                                      final newText = messageController.text.replaceRange(
                                        currentPosition,
                                        currentPosition,
                                        emoji.emoji,
                                      );
                                      setState(() {
                                        messageController.value = messageController.value.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                            offset: currentPosition + emoji.emoji.length,
                                          ),
                                        );
                                      });
                                    },
                                    onBackspacePressed: (){
                                      final currentPosition = messageController.selection.baseOffset;
                                      final currentText = messageController.text;

                                      if (currentPosition > 0) {
                                        final newText = currentText.substring(0, currentPosition - 1) +
                                            currentText.substring(currentPosition);

                                        setState(() {
                                          messageController.value = messageController.value.copyWith(
                                            text: newText,
                                            selection: TextSelection.collapsed(
                                              offset: currentPosition - 1,
                                            ),
                                          );
                                        });
                                      }
                                    }
                                ),
                              )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ),

                    ),
                  ),
                ],
              ),
            ),
            Text(
              Data().message,
              style: TextStyle(fontSize: 12, color: secondaryColor),
            )
          ],
        ),
      ),
    );
  }
  Future choiceImage() async {
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageUrl = '';
      _image = File(pickedImage!.path);
      // Get.to(()=>MediaView(path: _image!.path, onImageSend: onImageSend));
    });
  }
  void _clearValues() {
    messageController.text = '';
  }
  void hideEmojiContainer(){
    setState((){
      more = false;
      isShowEmojiContainer = false;
    });
  }
  void showEmojiContainer(){
    setState((){
      more = false;
      isShowEmojiContainer = true;
    });
  }
  void showKeyBoard() => focusNode.requestFocus();
  void hideKeyBoard() => focusNode.unfocus();
  void toggleEmojiContainer(){
    if(isShowEmojiContainer){
      showKeyBoard();
      hideEmojiContainer();
    } else {
      hideKeyBoard();
      showEmojiContainer();
    }
  }
}
