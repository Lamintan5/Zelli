import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/tabs/payments.dart';
import 'package:Zelli/home/tabs/tenants.dart';
import 'package:Zelli/models/duties.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/views/property/activities/edit_property.dart';
import 'package:Zelli/views/property/activities/leases.dart';
import 'package:Zelli/views/property/activities/utilities.dart';
import 'package:Zelli/views/property/activities/managers.dart';
import 'package:Zelli/views/property/tabs/prop_unit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../create/create_units.dart';
import '../../home/actions/notifications.dart';
import '../../home/tabs/report.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../../widgets/buttons/call_actions/double_call_action.dart';
import '../../widgets/cards/card_button.dart';
import '../../widgets/cards/row_button.dart';
import '../../widgets/dialogs/dialog_title.dart';
import '../../widgets/logo/prop_logo.dart';
import '../../widgets/profile_images/user_profile.dart';
import '../../widgets/star_items/drop_star.dart';
import '../unit/unit_profile.dart';
import 'activities/reviews.dart';

class PropertyView extends StatefulWidget {
  final Function removeEntity;
  final EntityModel entity;
  final Function reload;
  const PropertyView({super.key,  required this.entity, required this.removeEntity, required this.reload});

  @override
  State<PropertyView> createState() => _PropertyViewState();
}

class _PropertyViewState extends State<PropertyView>  with TickerProviderStateMixin{
  TextEditingController _search = TextEditingController();
  late TabController _tabController;
  List<UnitModel> _unitList = [];
  List<UnitModel> _units = [];
  List<UserModel> _users = [];
  List<EntityModel> _entity = [];

  List<UserModel> _managers = [];

  List<String> _pidList = [];
  List<String> _duties = [];

  DutiesModel duty = DutiesModel(did: "");
  EntityModel entity = EntityModel(eid: "");

  List<String> admin = [];

  bool _loading = false;
  bool _loadingAction = false;
  bool isFilled = false;
  bool isMember = false;
  bool isTenant = false;

  int highestId = 0;
  int available = 0;
  int tenants = 0;

  double width = 0;

  double _position1 = 20.0;
  double _position2 = 20.0;
  double _position3 = 20.0;
  double _position4 = 20.0;

  String image1 = '';
  String image2 = '';
  String image3 = '';

  bool _rating = false;


  Future<void> _getDetails() async {
    _getData();
    if(!isMember && !isTenant){
      _entity = await Services().getAllEntity();
      _units = await Services().getEntityUnit(widget.entity.eid);
    }
    _pidList.forEach((pid)async{
      if(!_managers.any((test) => test.uid == pid)){
        List<UserModel>  _new = await Services().getCrntUsr(pid);
        UserModel user = _new.first;
        await Data().addUser(user);
      }
    });
    _getData();
    if(!isMember && !isTenant){
      _units.where((test) => test.tid.toString() == "").toList().forEach((unt){
        if(!_unitList.any((u) => u.id.toString().contains(unt.id.toString()))){
          _unitList.add(unt);
        }
      });
    }
  }

  void _getData() {
    _unitList = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).where((element) => element.eid == widget.entity.eid).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    isMember = widget.entity.pid.toString().split(",").contains(currentUser.uid);
    isTenant = _unitList.any((test) => test.tid.toString().contains(currentUser.uid));

    entity = isMember || isTenant ?  myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList().firstWhere((element) => element.eid == widget.entity.eid,
        orElse: () => EntityModel(eid: "", image: "", title: "N/A", time: ""))
        : ! isMember && !isTenant
        ? _entity.firstWhere((element) => element.eid == widget.entity.eid,orElse: () => EntityModel(eid: "", image: "", title: "N/A", time: ""))
        : EntityModel(eid: "", image: "", title: "N/A", time: "");
    duty = myDuties.map((jsonString) => DutiesModel.fromJson(json.decode(jsonString))).firstWhere((test) =>
      test.pid.toString() == currentUser.uid, orElse: ()=>DutiesModel(did: "", duties: ""));
    _users.add(currentUser);

    available = _unitList.where((test) => test.tid.toString() == "").toList().length;
    tenants = _unitList.where((test) => test.tid.toString() != "").toList().length;

    highestId = _unitList.fold(0, (maxId, unit) => int.parse(unit.floor.toString()).compareTo(maxId) > 0 ? int.parse(unit.floor.toString()) : maxId);
    _pidList = widget.entity.pid.toString().split(",");
    admin = entity.admin.toString().split(",");
    _pidList.forEach((uid){
      var userModel = _users.firstWhere((element) => element.uid == uid, orElse: ()=> UserModel(uid: "", image: ""));
      if(_managers.any((test) => test.uid == uid)){

      } else {
        _managers.add(userModel);
      }
    });




    if (_managers.isNotEmpty) {
      image1 = _managers.length > 0 ? _managers[0].image.toString() : '';
      image2 = _managers.length > 1 ? _managers[1].image.toString() : '';
      image3 = _managers.length > 2 ? _managers[2].image.toString() : '';
    }


    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _position1 = _managers.length == 2 ? 18 : _managers.length == 3 || _managers.length > 3 ? 10 : 20.0;
        _position2 = _managers.length == 2 ? 18 : _managers.length == 3 || _managers.length > 3 ? 20 : 20.0;
        _position3 = _managers.length == 0 ? 20 : _managers.length == 1 ? 20 : _managers.length == 2 || _managers.length == 3 || _managers.length > 3 ? 30 : 20.0;
        _position4 = _managers.length == 0 ? 20 : _managers.length == 1 ? 30 : _managers.length == 2 || _managers.length == 3 || _managers.length > 3 ? 40 : 20.0;
      });
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getDetails();
    print(duty.toJson());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _unitList.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _unitList;
    }
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body:CustomScrollView(
          slivers:[
            SliverAppBar(
              surfaceTintColor: Colors.transparent,
              backgroundColor: normal,
              pinned: true,
              expandedHeight: 350,
              foregroundColor: reverse,
              toolbarHeight: 40,
              actions: [
                _loading ? SizedBox(width: 20,height: 20, child: CircularProgressIndicator(color: reverse,strokeWidth: 2,)) : SizedBox(),
                SizedBox(width: 10,),
                admin.contains(currentUser.uid) || isMember || isTenant
                    ? Tooltip(
                      message: "Community",
                      child: InkWell(
                          onTap: (){

                          },
                          hoverColor: color1,
                          borderRadius: BorderRadius.circular(5),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(CupertinoIcons.ellipses_bubble, size: 22,),
                          )
                      ),
                    )
                    : SizedBox(),
                SizedBox(width: 5,),
                admin.contains(currentUser.uid) || isMember || isTenant
                    ? buildButton() : SizedBox(),
              ],
              flexibleSpace: entity.eid.isEmpty
                  ? Center(child: CircularProgressIndicator(color: reverse,strokeWidth: 3,))
                  : FlexibleSpaceBar(
                background: SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 0,top: 0, right: 0,left: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20,),
                            Hero(
                                tag: widget.entity,
                                child: PropLogo(entity: entity, radius: 40,)),
                            SizedBox(height: 10,),
                            Text(entity.title.toString(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),),
                            DropStar(entity: entity),
                            SizedBox(height: 5,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.location, size: 15,color: secondaryColor,),
                                SizedBox(width: 5),
                                Text("San Fransisco, CA", style: TextStyle(color: secondaryColor)),
                                SizedBox(width: !isMember ?0:10,),
                                !isMember ?SizedBox() : Icon(CupertinoIcons.calendar, size: 15,color: secondaryColor),
                                SizedBox(width: !isMember ?0:5),
                                !isMember ? SizedBox() : Text("Created on ${DateFormat.yMMMd().format(DateTime.parse(entity.time!))}", style: TextStyle(color: secondaryColor),),
                              ],
                            ),
                            SizedBox(height: 5,),
                            entity.checked.contains("REMOVE")
                                ? SizedBox()
                                : CardButton(
                                    text: "REVIEWS",
                                    backcolor: reverse,
                                    forecolor: normal,
                                    icon: Icon(CupertinoIcons.star_fill, color: normal, size: 18,),
                                    onTap: (){
                                      Get.to(()=>Reviews(entity: entity), transition: Transition.rightToLeft);
                                    }
                                ),
                            SizedBox(height: 20,),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 90,
                        right: 8,
                        child: Column(
                          children: [
                            entity.checked.contains("REMOVE")
                                ? SizedBox()
                                :  InkWell(
                          onTap: (){
                            Get.to(()=>Managers(entity: entity, reload: _getDetails),transition: Transition.rightToLeft);
                          },
                          borderRadius: BorderRadius.circular(5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Tooltip(
                                message: 'Click here to see all handlers',
                                child: Container(
                                  width: 60,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        left: _position1,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                        child:  UserProfile(image: image3,radius: 10, shadow: Colors.black54,),
                                      ),
                                      AnimatedPositioned(
                                        left: _position2,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                        child: UserProfile(image: image2,radius: 10, shadow: Colors.black54,),
                                      ),
                                      AnimatedPositioned(
                                        left: _position3,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                        child: UserProfile(image: image1,radius: 10, shadow: Colors.black54,),
                                      ),
                                      !admin.contains(currentUser.uid) ? SizedBox() : AnimatedPositioned(
                                        left: _position4,
                                        duration: Duration(seconds: 1),
                                        curve: Curves.easeInOut,
                                        child: CircleAvatar(
                                          radius: 10,
                                          backgroundColor: reverse,
                                          child: Center(
                                            child: Icon(
                                              Icons.add,
                                              size: 15,
                                              color: normal,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text('Managers', overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 10),)
                            ],
                          ),
                        ),
                            isMember || isTenant
                                ? entity.checked.contains("false") || entity.checked.contains("EDIT") || entity.checked.contains("DELETE") || entity.checked.contains("REMOVED")
                                ? Card(
                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10, top: 3, bottom: 3, right: 5),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          entity.checked == "false" || entity.checked == "false, EDIT"
                                              ? _upload()
                                              :  entity.checked.toString().contains("REMOVED")
                                              ? dialogRemoveEntity(context, 'Delete')
                                              :_updateEntity();
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Row(
                                          children: [
                                            _loadingAction
                                                ?SizedBox(width: 12, height: 12,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,))
                                                :Icon(
                                              entity.checked == "false"
                                                  ? Icons.cloud_upload
                                                  : entity.checked.contains("REMOVE") || entity.checked.contains("DELETE")
                                                  ? CupertinoIcons.delete
                                                  : entity.checked.contains("EDIT")
                                                  ? Icons.edit
                                                  : Icons.more_vert,
                                              size: 15,
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              _loadingAction
                                                  ?"Loading..."
                                                  :entity.checked.split(",").last == "false"
                                                  ? "UPLOAD"
                                                  : entity.checked.split(",").last == "DELETE"
                                                  ? "DELETE"
                                                  : entity.checked.split(",").last == "EDIT"
                                                  ? "EDIT"
                                                  : entity.checked.split(",").last == "REMOVED"
                                                  ? "REMOVE"
                                                  : entity.checked,
                                              style: TextStyle(color: Colors.white, fontSize: 13),),
                                            SizedBox(width: 5,),
                                          ],
                                        ),
                                      ),
                                      entity.checked.contains("REMOVE") || !entity.pid.toString().contains(currentUser.uid)
                                          ? SizedBox()
                                          :Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: VerticalDivider(
                                          width: 1,color: Colors.white,
                                        ),
                                      ),
                                      entity.checked.contains("REMOVE") || !entity.pid.toString().contains(currentUser.uid)
                                          ? SizedBox(height: 20,)
                                          : PopupMenuButton(
                                          child: Icon(Icons.keyboard_arrow_down),
                                          itemBuilder: (BuildContext context){
                                            return [
                                              if (entity.checked == "false" || entity.checked == "false, EDIT"
                                                  || entity.checked.toString().contains("REMOVED"))
                                                PopupMenuItem(
                                                  value: 'upload',
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.cloud_upload, color: Colors.red,),
                                                      SizedBox(width: 5,),
                                                      Text(
                                                        'Upload', style: TextStyle(
                                                        color:Colors.red,),
                                                      ),
                                                    ],
                                                  ),
                                                  onTap: (){
                                                    _upload();
                                                  },
                                                ),
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(CupertinoIcons.delete, color:reverse),
                                                    SizedBox(width: 5,),
                                                    Text('Delete',style: TextStyle(
                                                      color:  reverse,
                                                    ),),
                                                  ],
                                                ),
                                                onTap: (){
                                                  dialogRemoveEntity(context, 'Delete');
                                                },
                                              ),
                                              PopupMenuItem(
                                                value: entity.checked.toString().contains("DELETE")
                                                    ? 'Restore'
                                                    : 'Edit',
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(entity.checked.toString().contains("DELETE") ?Icons.restore :Icons.edit,
                                                      color: reverse,
                                                    ),
                                                    SizedBox(width: 5,),
                                                    Text(entity.checked.toString().contains("DELETE") ?'Restore' :'Edit', style: TextStyle(
                                                        color:reverse),
                                                    ),
                                                  ],
                                                ),
                                                onTap: (){
                                                  entity.checked.toString().contains("DELETE")
                                                      ? _restore()
                                                      : Get.to(() => EditProperty(entity: entity, reload: _updateEntityProfile,), transition: Transition.rightToLeft);
                                                },
                                              )
                                            ];
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                            )
                                : SizedBox() : SizedBox()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom:  PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: entity.checked.contains("REMOVE")
                    ? SizedBox(height: 20,)
                    : isMember
                    ? Container(
                  width: 220,
                  height: 30,
                  margin: EdgeInsets.only(left: 10, bottom: 20),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                    unselectedLabelStyle: const TextStyle(fontSize: 15),
                    labelPadding: const EdgeInsets.only(bottom: 0),
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 10,),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    splashBorderRadius: const BorderRadius.all(Radius.circular(30)),
                    tabs: const [
                      Tab(text: 'Units',),
                      Tab(text: 'Tenants'),
                      Tab(text: 'Payments'),
                    ],
                  ),
                )
                    : SizedBox(),
              ),
            ),
            SliverToBoxAdapter(
              child:entity.eid.isEmpty? SizedBox() : entity.checked.contains("REMOVE")
                  ? Column(
                      children: [
                        Row(),
                        SizedBox(height: 100,),
                        Image.asset(
                          "assets/add/removed.png",
                        ),
                        SizedBox(height: 10,),
                        Text("Manager Removed", style: TextStyle(color: reverse, fontSize: 18, fontWeight: FontWeight.w600),),
                        Container(
                            width: 450,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text("You have been removed from ${entity.title} and no longer have access to modify its data. If you believe this is an error or would like to regain access, please contact the entity administrator for assistance.",
                              style: TextStyle(color: secondaryColor),
                              textAlign: TextAlign.center,
                            )
                        ),
                      ],
                    )
                  : isMember
                  ? Container(
                    width: double.maxFinite,
                    height: MediaQuery.of(context).size.height - 35,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        PropUnit(title: entity.title.toString(), entity: entity, max: highestId+1,),
                        Tenants(entity: entity),
                        Payments(entity: entity, unit: UnitModel(id: ""), tid: "", lid: "", from: '',),
                      ],
                    ),
                  )
                  : Container(
                    height: MediaQuery.of(context).size.height - 35,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                        children: [
                          Container(
                            width: 800,
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Units", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,)),
                                InkWell(
                                  onTap: (){},
                                  borderRadius: BorderRadius.circular(5),
                                  hoverColor: color1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Icon(Icons.filter_list),
                                  ),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: 800,
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
                              child: Container(
                                width: 800,
                                child: GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 120,
                                        childAspectRatio: 3 / 2,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1
                                    ),
                                    itemCount: filteredList.length,
                                    itemBuilder: (context, index){
                                      UnitModel unit = filteredList[index];
                                      double _accrdAmount = 0;
                                      double _prdAmount = 0;
                                      final currentMonth = DateTime.now().month;
                                      UserModel user = UserModel(uid: "");
                                      user = _users.firstWhere((test) => test.uid == unit.tid!.split(",").first, orElse: ()=> UserModel(uid: ""));
                                      void _removeTenant(){
                                        unit.tid ="";
                                        setState(() {
                                        });
                                      }
                                      return InkWell(
                                        onTap: (){
                                          Get.to(()=> ShowCaseWidget(
                                            builder: (_) => UnitProfile(unit: unit, reload: _getData, removeTenant: _removeTenant, removeFromList: _removeFromList, user: UserModel(uid: ""), leasid: '', entity: widget.entity,),
                                          ), transition: Transition.rightToLeft);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        splashColor: CupertinoColors.activeBlue,
                                        child: Stack (
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: color1,
                                                    width: 1
                                                ),
                                                color: unit.tid == ''
                                                    ? CupertinoColors.activeBlue
                                                    : _accrdAmount > 0.0
                                                    ?Colors.red
                                                    : _prdAmount > 0.0
                                                    ? Colors.green
                                                    : color1,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                  child: Text(unit.title.toString(),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14,
                                                    ),
                                                  )
                                              ),
                                            ),
                                            unit.tid == ""
                                                ? SizedBox()
                                                :Positioned(
                                                right: 5,
                                                bottom: 5,
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                                        ? Icon(CupertinoIcons.delete, color: Colors.red,size: 20,)
                                                        : unit.checked.toString().contains("EDIT")
                                                        ? Icon(Icons.edit, color: Colors.red,size: 20,)
                                                        : unit.checked == "false"
                                                        ? Icon(Icons.cloud_upload, color: Colors.red,size: 20,)
                                                        : SizedBox(),
                                                    SizedBox(width: 3,),
                                                    user.uid==""
                                                        ? SizedBox()
                                                        : UserProfile(image: user.image.toString(), radius: 10,)
                                                  ],
                                                )
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              )
                          ),
                        ],
                      ),
                  ),
            ),
          ],
        ),
        endDrawer: Drawer(
          child: Scaffold(
            body: SafeArea (
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Options',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(height: 20,),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [

                            // Managers
                            admin.contains(currentUser.uid) || entity.pid.toString().contains(currentUser.uid) || _unitList.any((test) => test.tid.toString().contains(currentUser.uid))
                                ? RowButton(
                                onTap: (){
                                  Navigator.pop(context);
                                  Get.to(()=> Managers(entity: entity, reload: _getDetails), transition: Transition.rightToLeft);
                                },
                                icon : Icon(CupertinoIcons.person_crop_circle), title: "Managers",subtitle: ""
                            )
                                : SizedBox(),

                            // Edit Property
                            !admin.contains(currentUser.uid)
                                ? SizedBox()
                                : RowButton(
                                    onTap:() {
                                      Navigator.pop(context);
                                      Get.to(()=>EditProperty(entity: entity, reload: _updateEntityProfile,), transition: Transition.rightToLeftWithFade);
                                    },
                                    icon :  Icon(CupertinoIcons.pen, ), title: "Edit Property",subtitle: ""
                                  ),

                            // Exit or Delete
                            admin.first != currentUser.uid
                                ? entity.pid.toString().contains(currentUser.uid)
                                ? RowButton(
                                    onTap: () {
                                      Navigator.pop(context);
                                      dialogRemoveEntity(context, 'Exit');
                                    },
                                    icon : Icon(CupertinoIcons.minus_circle,), title:"Exit Property", subtitle:""
                                  )
                                : SizedBox()
                                : RowButton(
                                    onTap: () {
                                      Navigator.pop(context);
                                      dialogRemoveEntity(context, 'Delete');
                                    },
                                    icon : Icon(CupertinoIcons.delete,), title:"Remove Property", subtitle:""
                                  ),

                            // Leases
                            !admin.contains(currentUser.uid)
                                ? SizedBox()
                                : RowButton(
                                    onTap:() {
                                      Get.to(() => Leases(entity: entity, unit: UnitModel(id: ""), lease: LeaseModel(lid: ""),), transition: Transition.rightToLeft);
                                    },
                                    icon : Icon(CupertinoIcons.doc_text,), title:"Leases", subtitle:""
                                  ),

                            // Add Floor
                            !admin.contains(currentUser.uid)
                                ? SizedBox()
                                : RowButton(
                                    onTap:() {
                                      Get.to(()=>CreateUnits(
                                        getUnits: _getDetails,
                                        floor:  highestId+1,
                                        entity: entity,
                                        addToUnitList: _addToUnitList,
                                        removeFromList: _removeFromList,
                                        updateUnit: _updateUnit,
                                        updateUnitData: _updateUnitData,
                                      ), transition: Transition.rightToLeftWithFade);
                                  }, icon : Icon(CupertinoIcons.add), title:"Add Floor", subtitle:""
                                ),


                            // NOTIFICATIONS
                            entity.checked.contains("REMOVE") || !entity.pid.toString().contains(currentUser.uid) ? SizedBox() : RowButton(onTap:() {
                              Get.to(()=> Notifications(reload: _getDetails, updateCount: _updateCount, eid: entity.eid,), transition: Transition.rightToLeft);
                            },icon :  LineIcon.bell(), title:"Notifications",subtitle: ""),

                            // UTILITIES
                            duty.duties.toString().contains("UTILITIES") || admin.contains(currentUser.uid)
                                ?  RowButton(
                                    onTap:() {
                                        Get.to(()=>Utilities(entity: entity, reload: (){
                                          _getData();
                                          widget.reload();
                                        },), transition: Transition.rightToLeft);
                                      },  icon :Icon(CupertinoIcons.lightbulb), title:"Utilities", subtitle:"")
                                      : SizedBox(),

                            // Requests
                            admin.contains(currentUser.uid) || entity.pid.toString().contains(currentUser.uid) || _unitList.any((test) => test.tid.toString().contains(currentUser.uid))
                                ? RowButton(
                                      onTap:() {

                                      },
                                      icon :Icon(CupertinoIcons.arrowshape_turn_up_right), title:"Request", subtitle:""
                                  )
                                : SizedBox(),

                            // Payments
                            admin.contains(currentUser.uid) || duty.duties.toString().contains("PAYMENTS") || _unitList.any((test) => test.tid.toString().contains(currentUser.uid))
                                ?  RowButton(
                                      onTap:() {
                                        Get.to(() =>Payments(entity: entity,unit: UnitModel(id: ""),tid: _unitList.any((test) => test.tid.toString().contains(currentUser.uid))?currentUser.uid:'', lid: '', from: 'Prop',),transition: Transition.rightToLeft);
                                      },
                                    icon :LineIcon.wallet(), title:"Payments", subtitle:""
                                  )
                                : SizedBox(),



                            !admin.contains(currentUser.uid) ? SizedBox() :RowButton(onTap:() {
                              Get.to(()=>Report(entity: widget.entity, unitid: '', tid: '', lid: '',), transition: Transition.rightToLeft);
                            },  icon :Icon(CupertinoIcons.chart_bar_alt_fill,), title:"Reports & Analytics", subtitle:"Beta"),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      child: Column(
                        children: [
                          Text("Z E L L I", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10),),
                          Text("S T U D I O 5 I V E", style: TextStyle( color: secondaryColor, fontSize: 9),),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void dialogRemoveEntity(BuildContext context, String action){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final style = TextStyle(color: secondaryColor, fontSize: 13);
    final bold = TextStyle(color: reverse, fontSize: 13);
    showDialog(context: context, builder: (context){
      return Dialog(
        backgroundColor: dilogbg,
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child: SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: action=="Delete"? 'R E M O V E': 'E X I T'),
                RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                            text:  action=="Delete"? 'Please confirm that you want to delete ' : 'Please confirm that you want to exit ',
                            style: style,
                          ),
                          TextSpan(
                            text: '${entity.title}. ',
                            style: bold
                          ),
                          TextSpan(
                            text: action=="Delete"? 'All the data related to this entity will be lost if you proceed.'
                                : 'You will no longer have access to any of its data.',
                            style: style,
                          ),
                        ]
                    )
                ),
                DoubleCallAction(
                  action: ()async{
                    if(action=="Delete"){
                      Navigator.pop(context);
                      Navigator.pop(context);
                      if(admin.first.toString()==currentUser.uid){
                        await Data().removeEntity(entity, widget.reload, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("You do not have permission to delete ${entity.title}"),
                              width: 500,
                              showCloseIcon: true,
                          )
                        );
                      }
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      setState(() {
                        _loading = true;
                      });
                      await Data().exitEntity(context, entity, widget.reload).then((value){
                        if(value==false){
                          setState(() {
                            _loading = value;
                          });

                        }
                      });
                    }
                  },
                  title: "Remove",titleColor: Colors.red,
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  void _upload (){}
  void _restore()async{
    List<EntityModel> _entity = [];
    List<String> uniqueEntities = [];
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    EntityModel initial = _entity.firstWhere((element) =>element.eid == entity.eid);

    _entity.firstWhere((element) => element.eid == entity.eid).checked = initial.checked.split(",").first;
    entity.checked = initial.checked.split(",").first;

    uniqueEntities = _entity.map((model) => jsonEncode(model.toJson())).toList();
    sharedPreferences.setStringList('myentity', uniqueEntities);
    myEntity = uniqueEntities;
    _getData();
    widget.reload();
  }
  void _updateEntity ()async{
    setState(() {
      _loadingAction = true;
    });
    await Data().editEntity(context, _updateEntityProfile, entity, File(entity.image!), entity.image.toString()).then((value){
      setState(() {
        _loadingAction = value;
      });
    });

  }
  void _updateEntityProfile(EntityModel entity){
    print(entity.toJson());
    widget.entity.title = entity.title;
    widget.entity.category = entity.category;
    widget.entity.due = entity.due;
    widget.entity.late = entity.late;
    widget.entity.image = entity.image;
    widget.entity.checked = entity.checked;
    widget.reload();
    setState(() {

    });
  }
  void _addToUnitList(UnitModel unitModel){
    _unitList.add(unitModel);
    setState(() {
    });
  }
  void _updateUnit(String id){
    _unitList.firstWhere((unit) => unit.id == id).checked = "true";
    setState(() {
    });
  }
  void _removeFromList(String id){
    _unitList.removeWhere((unit) => unit.id == id);
    setState(() {
    });
  }
  void _updateUnitData(UnitModel unitModel){
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).title = unitModel.title;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).room = unitModel.room;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).price = unitModel.price;
    _unitList.firstWhere((unit) => unit.id == unitModel.id.toString()).deposit = unitModel.deposit;
    setState(() {

    });
  }
  void _updateCount(){

  }
}
class buildButton extends StatelessWidget {
  const buildButton({super.key});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Tooltip(
      message: "More options",
      child: InkWell(
          onTap: (){
            Scaffold.of(context).openEndDrawer();
          },
          hoverColor: color1,
          borderRadius: BorderRadius.circular(5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.menu),
          )),
    );
  }
}
