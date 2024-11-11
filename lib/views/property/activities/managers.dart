import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/users.dart';
import '../../../utils/colors.dart';
import '../../../widgets/dialogs/dialog_add_managers.dart';
import '../../../widgets/dialogs/dialog_title.dart';
import '../../../widgets/items/item_managers.dart';

class Managers extends StatefulWidget {
  final EntityModel entity;
  final Function reload;
  const Managers({super.key, required this.entity, required this.reload});

  @override
  State<Managers> createState() => _ManagersState();
}

class _ManagersState extends State<Managers> {
  TextEditingController _search = TextEditingController();
  List<String> _pidList = [];
  List<UserModel> _user = [];
  List<UserModel> _newUser = [];
  UserModel user = UserModel(uid: "", image: "");
  String duty = '';
  List<String> admin = [];
  bool _loading = false;
  bool isFilled = false;


  _getData(){
    _pidList = widget.entity.pid.toString().split(",").toSet().toList();
    _user =  myUsers.isEmpty ? [] : myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    if(_user.any((test) => test.uid == currentUser.uid)){

    } else {
      _user.add(currentUser);
    }
    _user = _user.where((usr) => _pidList.any((pids) => pids == usr.uid)).toList();
    admin = widget.entity.admin.toString().split(",");
    widget.reload();
    // print("PID : ${_pidList.length}");
    // print("Users : ${_user.length}");
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    final normal = Theme.of(context).brightness == Brightness.dark
        ? screenBackgroundColor
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _user.forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    }
    else {
      filteredList = _user;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Managers", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,)),
        actions: [
          !admin.contains(currentUser.uid) ? SizedBox() : IconButton(
              onPressed: (){
                dialogGetManagers(context);
              },
              tooltip: 'Add a new manager',
              icon: Icon(Icons.add_circle))
        ],
      ),
      body: Column(
        children: [
          Row(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: SizedBox(
                width: 800,
                child: Column(
                  children: [
                    SizedBox(width: 500,
                      child: TextFormField(
                        controller: _search,
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
                        ),
                        onChanged: (value) => setState(() {
                          if(value.isNotEmpty){
                            isFilled = true;
                          } else {
                            isFilled = false;
                          }
                        }),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: filteredList.length,
                          itemBuilder: (context, index){
                            UserModel users = filteredList[index];
                            return ItemManagers(
                              user: users,
                              entity: widget.entity,
                              reload: _getData,
                              remove: _remove,
                            );
                          }),
                    ),

                  ],
                ),
              ),
            ),
          ),
          Text(Data().message,
            style: TextStyle(color: secondaryColor, fontSize: 11),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
  void dialogGetManagers(BuildContext context) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        backgroundColor: dilogbg,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height-100,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            children: [
              DialogTitle(title: 'M A N A G E R S'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Text( 'Tap on any manager send request',
                  style: TextStyle(color: secondaryColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                  child: DialogAddManagers(entity: widget.entity)
              )
            ],
          );
        });
  }

  _remove(UserModel user){
    print("Removing ${user.username}");
    _user.removeWhere((test) => test.uid == user.uid);
    widget.reload();
    setState(() {

    });
  }
}
