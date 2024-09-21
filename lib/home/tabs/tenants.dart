import 'dart:convert';

import 'package:Zelli/models/entities.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../widgets/items/item_tenant.dart';

class Tenants extends StatefulWidget {
  const Tenants({super.key});

  @override
  State<Tenants> createState() => _TenantsState();
}

class _TenantsState extends State<Tenants> {
  TextEditingController _search = TextEditingController();
  List<UserModel> _user = [];
  List<UnitModel> _units = [];
  List<String> _tntList = [];

  _getData(){
    _user = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _units = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((unt) =>unt.tid !="").toList();
    _tntList = _units.map((unt) => unt.tid.toString()).toList();
    _user = _user.where((usr) => _tntList.any((tnt) => usr.uid == tnt)).toList();
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
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _user.forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()) )
          filteredList.add(item);
      });
    } else {
      filteredList = _user;
    }
    final size = 800.0;
    return Scaffold(
      body: SafeArea(
          child:Column(
            children: [
              Row(
                children: [
                  Text('  ${_user.length.toString()} Tenants', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
                ],
              ),
              SizedBox(height: 10,),
              SizedBox(width: 500,
                child: TextFormField(
                  controller: _search,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "🔎  Search for Tenants...",
                    fillColor: color1,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                          Radius.circular(5)
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  onChanged:  (value) => setState((){}),
                ),
              ),
              SizedBox(height: 10,),
              Expanded(
                child: SizedBox(width: size,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context,index){
                        UserModel user = filteredList[index];
                        return ItemTenant(user: user, entity : EntityModel(eid: ""));
                      }),
                ),
              ),
            ],
          )
      ),
    );
  }
}
