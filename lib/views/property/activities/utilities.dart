import 'dart:convert';

import 'package:Zelli/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/util.dart';
import '../../../models/utils.dart';
import '../../../resources/services.dart';
import '../../../widgets/items/item_util.dart';

class Utilities extends StatefulWidget {
  final EntityModel entity;
  final Function reload;
  const Utilities({super.key, required this.entity, required this.reload,});

  @override
  State<Utilities> createState() => _UtilitiesState();
}

class _UtilitiesState extends State<Utilities> {
  List<UtilsModel> _utilities = [];
  List<UtilsModel> _oldUtils = [];
  List<String> _utilString = [];
  bool _loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _utilString = widget.entity.utilities.toString().split("&");
    _utilities = _utilString.map((jsonString) {
      if (jsonString.isNotEmpty) {
        return UtilsModel.fromJson(json.decode(jsonString));
      } else {
        // Handle empty jsonString (if needed)
        return UtilsModel(text: '', period: '', amount: "", checked: "");
      }
    }).toList();
    _oldUtils = _utilString.map((jsonString) {
      if (jsonString.isNotEmpty) {
        return UtilsModel.fromJson(json.decode(jsonString));
      } else {
        // Handle empty jsonString (if needed)
        return UtilsModel(text: '', period: '', amount: "", checked: "");
      }
    }).toList();
    areUtilsEqual(_oldUtils, _utilities);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Utilities"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          children: [
            Row(),
            SizedBox(height: 10,),
            Expanded(
              child: SizedBox(width: 800,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: Data().utilList.length,
                    itemBuilder: (context, index){
                      UtilModel util = Data().utilList[index];
                      return ItemUtil(
                        util: util,
                        addUtil: addUtil,
                        removeUtil: removeUtil, utils: _utilities,
                      );
                    }),
              ),
            ),
            areUtilsEqual(_oldUtils, _utilities)
                ? SizedBox()
                : Container(
              width: 500,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              child: InkWell(
                onTap: (){
                  _updateUtils();
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: CupertinoColors.activeBlue,
                  ),
                  child: Center(child: _loading
                      ? SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                      : Text("UPDATE", style: TextStyle(color: Colors.black),)),
                ),
              ),
            ),
            Text(
              Data().message,
              style: TextStyle(fontSize: 12, color: secondaryColor),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
  void removeUtil(String text) {
    print("Util removing");
    if (_utilities.isNotEmpty) {
      _utilities.removeWhere((element) => element.text == text) ;
      setState(() {});
    }
  }
  void addUtil(UtilsModel util) {
    print("Util adding");
    bool containsText = _utilities.any((element) => element.text == util.text);
    if(containsText){
      _utilities.firstWhere((element) => element.text == util.text).amount = util.amount.toString();
      _utilities.firstWhere((element) => element.text == util.text).period = util.period.toString();
    } else {
      _utilities.add(util);
    }
    areUtilsEqual(_oldUtils, _utilities);

    setState(() {});
  }

  void _updateUtils() async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    List<String> checks = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();


    _utilities.forEach((element) {
      element.checked = "true";
    });
    _utilString = _utilities.map((model) => jsonEncode(model.toJson())).toList();

    checks = widget.entity.checked.toString().split(",");

    if(!widget.entity.checked.toString().contains("EDIT")){
      checks.add("EDIT");
    }

    _entity.firstWhere((test) => test.eid == widget.entity.eid).checked = checks.join(",");
    _entity.firstWhere((test) => test.eid == widget.entity.eid).utilities = _utilString.join('&');

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    widget.reload();

    Services.updateEntityUtil(widget.entity.eid, _utilString).then((response) {
      if (response == "success" || response == "Does not exist")  {
        checks.remove("EDIT");
        _entity.firstWhere((test) => test.eid == widget.entity.eid).checked = checks.join(",");
        uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
        sharedPreferences.setStringList('myentity', uniqueEntities);
        myEntity = uniqueEntities;
        widget.reload();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Utilities Updated Successfully"),
            showCloseIcon: true,
          ),
        );
      } else if (response == "error") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Utilities was not Updated"),
            showCloseIcon: true,
            action: SnackBarAction(
              label: "Try Again",
              onPressed: _updateUtils,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Data().failed),
            showCloseIcon: true,
            action: SnackBarAction(
              label: "Try Again",
              onPressed: _updateUtils,
            ),
          ),
        );
      }
    });
  }

  bool areUtilsEqual(List<UtilsModel> utils, List<UtilsModel> newUtils) {
    // Check if lengths are the same
    if (utils.length != newUtils.length) {
      return false;
    }

    // Check if attributes are equal for each element
    for (int i = 0; i < utils.length; i++) {
      if (utils[i].text != newUtils[i].text ||
          utils[i].period != newUtils[i].period ||
          utils[i].amount != newUtils[i].amount ||
          utils[i].checked != newUtils[i].checked) {
        return false;
      }
    }
    // If all checks pass, the lists are equal
    return true;
  }
}
