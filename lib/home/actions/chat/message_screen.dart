import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/chats.dart';
import '../../../models/data.dart';
import '../../../models/messages.dart';
import '../../../models/users.dart';
import '../../../resources/socket.dart';
import '../../../utils/colors.dart';
import '../../../widgets/buttons/options_button.dart';
import '../../../widgets/items/mess_items/own_file_card.dart';
import '../../../widgets/items/mess_items/own_mess_card.dart';
import '../../../widgets/items/mess_items/target_file_card.dart';
import '../../../widgets/items/mess_items/target_mes_card.dart';
import '../../../widgets/profile_images/user_profile.dart';

class MessageScreen extends StatefulWidget {
  final Function changeMess;
  final Function updateCount;
  final UserModel receiver;
  const MessageScreen({super.key, required this.changeMess, required this.updateCount, required this.receiver});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController messageController = TextEditingController();

  late ScrollController _scrollcontroller;
  late GlobalKey<AnimatedListState> _key;

  bool isShowEmojiContainer = false;
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
  final socketManager = Get.find<SocketManager>();

  void sendMessage(String mid,String message, String sourceId, String targetId,String path, String type,String time){
    setMessage(mid, gidList.join(','), sourceId, targetId, message,path, type, time);
    SocketManager().socket.emit("message", {
      "mid": mid,
      "gid": gidList.join(','),
      "sourceId":sourceId,
      "targetId":targetId,
      "message":message,
      "path":path,
      "time":time,
      "type":type,
      "title": currentUser.username,
      "token": widget.receiver.token.toString().split(","),
      "profile": currentUser.image,
    });
  }
  void setMessage(String mid, String gid,String sourceId, String targetId, String message, String path, String type,String time){
    MessModel messageModel = MessModel(
      mid: mid,
      gid: gid,
      targetId: targetId,
      sourceId: sourceId,
      message: message,
      time: time,
      path: path,
      type: type,
      deleted: "",
      seen: "",
      delivered: "",
      checked: "false",
    );
    messages.add(messageModel);
    Data().addOrUpdateMessagesList(messages);
    // widget.changeMess(messageModel);
    List<String> _cidList = [sourceId,targetId];
    _cidList.sort();
    ChatsModel chatsModel = ChatsModel(
      cid: _cidList.join(","),
      title: "",
      time: time,
      type: type,
    );
    final socketManager = Get.find<SocketManager>();
    List<ChatsModel> _chats = socketManager.chats;
    if(_chats.contains(chatsModel)){
      _chats.firstWhere((element) => element.cid == chatsModel.cid).time = chatsModel.time;
      _chats.firstWhere((element) => element.cid == chatsModel.cid).type = chatsModel.type;
    } else {
      _chats.add(chatsModel);
    }
    Data().addOrUpdateChats(_chats);

    if (mounted && _key.currentState != null) {
      _key.currentState!.insertItem(messages.length - 1, duration: Duration(milliseconds: 800));
    }
  }
  void connect() {
    SocketManager().socket.on("message", (msg) {
      setMessage(
        msg['mid'],
        msg['gid'],
        msg['sourceId'],
        msg['targetId'],
        msg['message'],
        msg["path"],
        msg["type"],
        msg['time'],
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connect();
    chatType = 'individual';
    _scrollcontroller = ScrollController();
    _key = GlobalKey();
    gidList = [widget.receiver.uid, currentUser.uid];
    gidList.sort();
    mess = myMess.map((jsonString) => MessModel.fromJson(json.decode(jsonString))).toList();
    messages = mess.where((element) => "${element.sourceId},${element.targetId}".contains(currentUser.uid) && "${element.sourceId},${element.targetId}".contains(widget.receiver.uid) && element.type.toString()== "individual").toList();
    _uidList.add(widget.receiver.uid.toString());
    _uidList.add(currentUser.uid);
    if(messages.isNotEmpty){
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollcontroller.jumpTo(_scrollcontroller.position.extentTotal);
      });
    }
    _updateSeen();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    return Scaffold(
      backgroundColor: normal,
      body: WillPopScope(
        onWillPop: ()async{
          if(isShowEmojiContainer || more){
            setState(() {
              isShowEmojiContainer = false;
              more = false;
            });
            return false;
          } else {
            Navigator.pop(context);
            return true;
          }
        },
        child: Stack(
          children: [
            Theme.of(context).brightness == Brightness.dark
                ? Container(
              width: size.width,
              height: size.height,
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
                SafeArea(
                  child: Container(
                    padding: const EdgeInsets.only(right: 5, left: 5, top: 5),
                    child: Row(
                      children: [
                        UserProfile(image: widget.receiver.image!),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(widget.receiver.username.toString(), style: TextStyle(color: reverse)),
                              Text("${widget.receiver.firstname.toString()} ${widget.receiver.lastname.toString()}", style: TextStyle(color: secondaryColor,fontSize: 12),),
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
                            SizedBox(width: 5,),
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: color1,
                              child: IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon(Icons.close), color: reverse,),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: Stack(
                      children: [
                        Container(
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
                                  }
                                  else {
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
                                  }
                                  else {
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
                          borderRadius: BorderRadius.circular(40),
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
                                    hintText: "Message @${widget.receiver.username}",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                sendMessage(
                                  mid,
                                  messageController.text.toString(),
                                  currentUser.uid,
                                  widget.receiver.uid,
                                  "",
                                  "individual",
                                  time,
                                );
                                socketManager.messages.add(
                                    MessModel(
                                      mid: mid,
                                      message: messageController.text.toString(),
                                      gid: "${currentUser.uid},${widget.receiver.uid}",
                                      sourceId: currentUser.uid,
                                      targetId: widget.receiver.uid,
                                      path: "", type: "individual", deleted: "", seen: "",checked: "",delivered: "",
                                      time: time,
                                    )
                                );
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
  _updateSeen(){
    if(messages.isNotEmpty){
      SocketManager().socket.emit('cancel-notification', {'mid': messages.last.mid});
    }
  }
}
