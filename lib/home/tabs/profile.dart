import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/actions/notifications.dart';
import 'package:Zelli/home/tabs/explore.dart';
import 'package:Zelli/home/tabs/tenants.dart';
import 'package:Zelli/models/cards.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/views/unit/unit_profile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../create/create_property.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/lease.dart';
import '../../models/messages.dart';
import '../../models/notifications.dart';
import '../../resources/services.dart';
import '../../resources/socket.dart';
import '../../utils/colors.dart';
import '../../views/property/prop_view.dart';
import '../../widgets/frosted_glass.dart';
import '../../widgets/logo/prop_logo.dart';
import '../../widgets/profile_images/current_profile.dart';
import '../../widgets/star_items/small_star.dart';
import '../../widgets/text/text_format.dart';
import '../actions/chat/chat_screen.dart';
import '../options/edit_profile.dart';
import '../options/options_screen.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late TextEditingController _search;
  late TabController _tabController;
  final controller = CarouselSliderController();
  int activeIndex = 0;

  final socketManager = Get.find<SocketManager>();

  List<EntityModel> _entity = [];
  List<UnitModel> _unit = [];
  List<LeaseModel> _lease = [];
  List<PaymentsModel> _pay = [];
  List<UserModel> _users =[];

  bool isFilled = false;
  bool isExpnd = false;
  bool isManager = false;
  bool isTenant = false;

  int countNotif = 0;
  int countMess = 0;

  int entityCount = 0;
  int leaseCount = 0;
  int unitCount = 0;
  int tenantCount = 0;

  _getDetails()async{
    _getData();
    await Data().checkAndUploadEntity(_entity, _getData);
    SocketManager().getDetails();
    _getData();
  }

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    _lease = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    isManager = _entity.any((test) => test.pid.toString().contains(currentUser.uid));
    isTenant = _lease.any((test) => test.tid.toString().contains(currentUser.uid)
        || test.ctid.toString().contains(currentUser.uid) && test.end.toString().isEmpty);
    entityCount = _entity.length;
    unitCount = _unit.length;
    leaseCount = _lease.where((test) => test.tid == currentUser.uid || test.ctid.toString().contains(currentUser.uid)).toList().length;
    List<String> _tenants = [];
    _lease.where((test) => test.end.toString().isEmpty).toList().forEach((leas){
      _tenants.add(leas.tid.toString());
    });
    _tenants.remove("");
    _tenants.remove(currentUser.uid);
    _tenants = _tenants.toSet().toList();
    tenantCount = _tenants.length;
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    _getDetails();
    Future.delayed(Duration(seconds: 1)).then((value){
      setState(() {
        isExpnd = true;
      });
    });
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
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final size = MediaQuery.of(context).size;
    final style = TextStyle(color: reverse, fontSize: 12);
    final secondary = TextStyle(color: secondaryColor, fontSize: 12);
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _entity.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _entity;
    }
    return Obx((){
      List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
      List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && !not.seen.toString().contains(currentUser.uid) ).toList();
      countNotif = _countNotif.length;
      countMess = _count.length;

      return Scaffold(
        body: SafeArea(
            child:  CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: normal,
                  pinned: true,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: !isManager && !isTenant
                      ? 20
                      : 320,
                  automaticallyImplyLeading: false,
                  foregroundColor: reverse,
                  toolbarHeight: 35,
                  actions: [
                    SizedBox(width: 5,),
                    Image.asset(
                        'assets/logo/logo-blue-48px.png',
                        height: 20
                    ),
                    SizedBox(width: 5,),
                    Text('Z E L L I', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 18),),
                    Expanded(child: SizedBox()),
                    IconButton(
                      onPressed: (){
                        Get.to(()=>Explore(from: "home",),transition: Transition.rightToLeft);
                      },
                      icon: Icon(CupertinoIcons.compass),
                    ),
                    SizedBox(width: 5,),
                    IconButton(
                        onPressed: (){
                          Get.to(()=>Notifications(reload: _getData, updateCount: _updateCount, eid: '',), transition: Transition.rightToLeft);
                        },
                        icon: badges.Badge(
                          badgeStyle: badges.BadgeStyle(
                              shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                              borderRadius: BorderRadius.circular(30),
                              padding: EdgeInsets.all(5)
                          ),
                          badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10, color: Colors.black),),
                          showBadge:countNotif ==0?false:true,
                          position: badges.BadgePosition.topEnd(end: -5, top: -4),
                          child: LineIcon.bell(),
                        )
                    ),
                    SizedBox(width: 5,),
                    IconButton(
                        onPressed: (){
                          Get.to(() => ChatScreen(updateCount: _updateCount,), transition: Transition.rightToLeft);
                        },
                        icon: badges.Badge(
                          badgeStyle: badges.BadgeStyle(
                              shape:countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                              borderRadius: BorderRadius.circular(30),
                              padding: EdgeInsets.all(5)
                          ),
                          badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10, color: Colors.black),),
                          showBadge:countMess==0?false:true,
                          position: badges.BadgePosition.topEnd(end: -5, top: -4),
                          child: Icon(CupertinoIcons.ellipses_bubble),
                        )
                    ),
                    SizedBox(width: 5,),
                    IconButton(
                        onPressed: (){
                          Get.to(() => Options(reload: (){setState(() {});},), transition: Transition.rightToLeft);
                        },
                        icon: Icon(CupertinoIcons.gear)
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: !isManager && !isTenant
                        ? SizedBox()
                        : Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(width: 100,height: 100,
                              child: Stack(
                                children: [
                                  Center(child: CurrentImage(radius: 50,)),
                                  Positioned(
                                    right: -5,
                                    bottom: -5,
                                    child:  MaterialButton(
                                      onPressed: (){
                                        Get.to(()=>EditProfile(reload: (){setState(() {});}), transition: Transition.rightToLeft);
                                      },
                                      color: CupertinoColors.activeBlue,
                                      minWidth: 5,
                                      elevation: 8,
                                      padding: EdgeInsets.all(6),
                                      shape: CircleBorder(),
                                      splashColor: CupertinoColors.systemBlue,
                                      child: Icon(Icons.edit, size: 16,color: normal,),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5,),
                        Text(currentUser.username!.toUpperCase().trim(), style: TextStyle(fontSize: 18),),
                        Text('${currentUser.firstname} ${currentUser.lastname}', style: TextStyle(color: secondaryColor),),
                        // RichText(
                        //     text: TextSpan(
                        //       children: [
                        //         TextSpan(
                        //           text: currentUser.phone==""?"":"${currentUser.phone!.replaceRange(3, currentUser.phone!.length - 2, "******")} ",
                        //           style: style,
                        //         ),
                        //         TextSpan(
                        //           text:currentUser.phone==""?"":"● ",
                        //           style: style,
                        //         ),
                        //         TextSpan(
                        //           text:"${currentUser.email!.replaceRange(4, currentUser.email!.length - 5, "*******")} ",
                        //           style: style,
                        //         ),
                        //       ]
                        //     )
                        // ),
                        SizedBox(height: 10,),
                        SizedBox(width: 400,
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                SizedBox(width: 20,),
                                Column(
                                  children: [
                                    Text(entityCount.toString(),style: TextStyle( fontSize: 18)),
                                    Text('Properties', style: TextStyle(color: secondaryColor),),
                                  ],
                                ),
                                Expanded(child: SizedBox()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
                                  child: VerticalDivider(
                                    color: color5,
                                    thickness: 2,
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Column(
                                  children: [
                                    Text(unitCount.toString(),style: TextStyle(fontSize: 18)),
                                    Text('Units', style: TextStyle(color: secondaryColor),),
                                  ],
                                ),
                                isTenant && !isManager
                                    ?  SizedBox() :Expanded(child: SizedBox()),
                                isTenant && !isManager
                                    ?  SizedBox() : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
                                  child: VerticalDivider(
                                    color: color5,
                                    thickness: 2,
                                  ),
                                ),
                                isTenant && !isManager
                                    ?  SizedBox() : Expanded(child: SizedBox()),
                                isTenant && !isManager
                                    ?  SizedBox() : Column(
                                  children: [
                                    Text(tenantCount.toString(), style: TextStyle(fontSize: 18)),
                                    Text('Tenants', style: TextStyle(  color: secondaryColor),),
                                  ],
                                ),
                                leaseCount == 0? SizedBox() :Expanded(child: SizedBox()),
                                leaseCount == 0? SizedBox() :Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 3),
                                  child: VerticalDivider(
                                    color: color5,
                                    thickness: 2,
                                  ),
                                ),
                                leaseCount == 0? SizedBox() :Expanded(child: SizedBox()),
                                leaseCount == 0? SizedBox() : Column(
                                  children: [
                                    Text(leaseCount.toString(),style: TextStyle(fontSize: 18)),
                                    Text('Lease', style: TextStyle(  color: secondaryColor),),
                                  ],
                                ),
                                SizedBox(width: 20,),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(20),
                    child:!isManager && !isTenant
                        ? SizedBox()
                        : Container(
                      width: 200,
                      height: 30,
                      margin: EdgeInsets.only(left: 10, bottom: 20),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        indicatorWeight: 1,
                        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        unselectedLabelStyle: const TextStyle(fontSize: 15),
                        labelPadding: const EdgeInsets.only(bottom: 0),
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorPadding: const EdgeInsets.symmetric(horizontal: 5,),
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        splashBorderRadius: const BorderRadius.all(Radius.circular(30)),
                        tabs: [
                          Text('Properties',),
                          Text(
                              isTenant && !isManager
                                  ? 'Leases'
                                  : 'Tenants'
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: !isManager && !isTenant
                      ? Carousel()
                      : Container(
                    height: MediaQuery.of(context).size.height - 80,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            TextFormField(
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
                              onChanged:  (value) => setState((){
                                if(value.isNotEmpty){
                                  isFilled = true;
                                } else {
                                  isFilled = false;
                                }
                              }),
                            ),
                            SizedBox(height: 20,),
                            Expanded(
                                child: GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: filteredList.length+1,
                                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: 250,
                                    ),
                                    itemBuilder: (context, index){
                                      if(index==filteredList.length){
                                        return InkWell(
                                          onTap: (){
                                            Get.to(()=> CreateProperty(getData: _getData,), transition: Transition.rightToLeft);
                                          },
                                          splashColor: CupertinoColors.activeBlue,
                                          borderRadius: BorderRadius.circular(10),
                                          hoverColor: color1,
                                          child: DottedBorder(
                                              borderType: BorderType.RRect,
                                              color: reverse,
                                              radius: Radius.circular(12),
                                              dashPattern: [5,5],
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Center(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.add, color: Colors.tealAccent,size: 50,),
                                                      Text(
                                                        "Click here to create new entity",
                                                        style: TextStyle(color: secondaryColor),
                                                        textAlign: TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                          ),
                                        );
                                      } else {
                                        EntityModel entity = filteredList[index];
                                        String image = entity.image!;
                                        List<String> _managers = entity.pid!.split(",");
                                        List<UnitModel> _unitList = [];
                                        int available = 0;
                                        List<String> tnts = [];
                                        _unitList = _unit.where((test) => test.eid == entity.eid).toList();
                                        available = _unitList.where((test) => test.tid.toString() == "").toList().length;
                                        _unitList.where((test) => test.tid.toString() != "").toList().forEach((tnt){
                                          if(!tnts.any((element) => element == tnt.tid.toString().split(",").first)){
                                            tnts.add(tnt.tid.toString().split(",").first);
                                          }
                                        });
                                        return InkWell(
                                          onTap: (){
                                            Get.to(()=>PropertyView(entity: entity,removeEntity: _removeEntity, reload: _getData,), transition: Transition.rightToLeftWithFade);
                                          },
                                          borderRadius: BorderRadius.circular(10),
                                          splashColor: CupertinoColors.activeBlue,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                SizedBox(
                                                  width: double.infinity, height: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: entity.image == ""
                                                        ? Opacity(
                                                      opacity: 0.5,
                                                      child: Image.asset(
                                                        "assets/logo/logo-blue-144px.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                        : entity.checked == "false"
                                                        ? Opacity(opacity: 0.05,
                                                      child: Image.file(
                                                        File(entity.image!),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    )
                                                        : Opacity(
                                                      opacity: 0.05,
                                                      child: CachedNetworkImage(
                                                        cacheManager: customCacheManager,
                                                        imageUrl: Services.HOST + '/logos/${image}',
                                                        key: UniqueKey(),
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) =>
                                                            Container(
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                        errorWidget: (context, url, error) => Container(
                                                          height: 40,
                                                          width: 40,
                                                          child: Center(child: Icon(Icons.error_outline_rounded, size: 25,),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                    child: FrostedGlass(width: double.infinity, height: double.infinity)
                                                ),
                                                Align(
                                                    alignment: Alignment.topCenter,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(top: 20.0),
                                                      child: Hero(
                                                          tag: entity,
                                                          child: PropLogo(entity: entity, radius: 40,from: 'GRID',)
                                                      ),
                                                    )),
                                                Positioned(
                                                    top: 5,right: 10,
                                                    child:entity.checked.contains("DELETE") || entity.checked.contains("REMOVED")
                                                        ? Icon(CupertinoIcons.delete, color: Colors.red,)
                                                        : entity.checked.contains("EDIT")
                                                        ? Icon(Icons.edit, color: Colors.red,)
                                                        : entity.checked == "false"
                                                        ? Icon(Icons.cloud_upload, color: Colors.red,)
                                                        : SizedBox()
                                                ),
                                                Align(
                                                  alignment: Alignment.bottomCenter,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                    margin: EdgeInsets.all(1),
                                                    width: double.infinity,
                                                    height: 110,
                                                    decoration: BoxDecoration(
                                                        color: normal,
                                                        borderRadius: BorderRadius.only(
                                                            bottomLeft: Radius.circular(10),
                                                            bottomRight: Radius.circular(10)
                                                        )
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          entity.title.toString().toUpperCase(),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600
                                                          ),
                                                        ),
                                                        RichText(
                                                            text: TextSpan(
                                                                children: [
                                                                  WidgetSpan(
                                                                    child: LineIcon.box(size: 14, color: color5,),
                                                                  ),
                                                                  TextSpan(
                                                                      text:  " Unts:${_unitList.length} ",
                                                                      style: TextStyle(color: color5, fontSize: 12)
                                                                  ),
                                                                  WidgetSpan(
                                                                    child: Icon(Icons.people, size: 14, color: color5,),
                                                                  ),
                                                                  TextSpan(
                                                                      text:  " Tnts:${tnts.length} ",
                                                                      style: TextStyle(color: color5, fontSize: 12)
                                                                  ),
                                                                  WidgetSpan(
                                                                    child: Icon(Icons.crop_free_outlined, size: 13, color: color5,),
                                                                  ),
                                                                  TextSpan(
                                                                      text:  " Avl:${available} ",
                                                                      style: TextStyle(color: color5, fontSize: 12)
                                                                  ),
                                                                ]
                                                            )
                                                        ),
                                                        entity.location.toString()==""?SizedBox()
                                                            : Container(
                                                          margin: EdgeInsets.only(bottom: 2),
                                                          child: RichText(
                                                              textAlign: TextAlign.center,
                                                              text: TextSpan(
                                                                  children: [
                                                                    WidgetSpan(
                                                                      child: Icon(CupertinoIcons.location, size: 12,color: secondaryColor,),
                                                                    ),
                                                                    TextSpan(
                                                                        text:  " ${entity.location}",
                                                                        style: secondary
                                                                    ),
                                                                  ]
                                                              )
                                                          ),
                                                        ),
                                                        SmallStar(entity: entity, type: "ENTITY", rid: "", size: 20,),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                )
                            )
                          ],
                        ),
                        isTenant && !isManager
                            ?Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Leases",
                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  itemCount: _lease.length,
                                  itemBuilder: (context, index){
                                    LeaseModel lease = _lease[index];
                                    UnitModel unit = _unit.firstWhere((u) => u.id.toString() == lease.uid.toString().split(",").first,
                                      orElse: ()=>UnitModel(
                                        id: lease.uid.toString().split(",").first,
                                        title: lease.uid.toString().split(",").last,
                                        tid: "", tenant: "",eid: "",lid: '', price: '0.0',
                                        room: '0', floor: '0', deposit: '0.0',),
                                    );
                                    double amount = _pay.where((pay) => pay.lid == lease.lid && pay.type == "RENT").toList()
                                        .fold(0.0, (previous, payment) => previous + double.parse(payment.amount.toString()));
                                    UserModel user = _users.firstWhere((test) => test.uid == lease.tid, orElse: ()=>UserModel(uid: ""));
                                    void _removeTenant(){
                                      setState(() {
                                      });
                                    }
                                    void _removeFromList(String id){
                                      setState(() {
                                      });
                                    }
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                      child: InkWell(
                                        onTap: (){
                                          Get.to(() => ShowCaseWidget(builder: (_) => UnitProfile(
                                              unit: unit,
                                              reload: _getData,
                                              removeTenant: _removeTenant,
                                              removeFromList: _removeFromList,
                                              user: user,
                                              leasid: lease.lid,
                                              entity: EntityModel(eid: '', title: '', due: "1", late: "1")
                                          ))
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        hoverColor: color1,
                                        splashColor: CupertinoColors.activeBlue,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(5),
                                              color: color1
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.doc_text, color: reverse,),
                                              SizedBox(width: 10,),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "${lease.lid.split("-").first}, ${unit.title}",
                                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                                        ),
                                                        Expanded(child: SizedBox()),
                                                        Text(
                                                          "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}",
                                                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: CupertinoColors.systemBlue),)
                                                      ],
                                                    ),
                                                    Wrap(
                                                      runSpacing: 4,
                                                      spacing: 8,
                                                      children: [
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(CupertinoIcons.person_2, size: 13,),
                                                            SizedBox(width: 3,),
                                                            Text("${lease.ctid.toString().split(",").length} Co-Tenants")
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(CupertinoIcons.play, size: 13,),
                                                            SizedBox(width: 3,),
                                                            Text(DateFormat.yMMMEd().format(DateTime.parse(lease.start.toString())))
                                                          ],
                                                        ),
                                                        lease.end.toString().isEmpty
                                                            ? SizedBox()
                                                            : Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(CupertinoIcons.stop, size: 13,),
                                                            SizedBox(width: 3,),
                                                            Text(DateFormat.yMMMEd().format(DateTime.parse(lease.end.toString())))
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                        )
                            :Tenants(entity: EntityModel(eid: ""),)
                      ],
                    ),
                  ),
                )
              ],
            )
        ),
      );
    });
  }
  Widget Carousel() {
    final size = MediaQuery.of(context).size;
    return Column(
        children: [
          Container(
            height: size.height*3/4,
            constraints: BoxConstraints(
              minWidth: 400,
              maxWidth: 450,
            ),
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: CarouselSlider.builder(
              carouselController: controller,
              itemCount: Data().cards.length,
              options: CarouselOptions(
                  initialPage: 0,
                  height: size.height,
                  enlargeFactor: 0.5,
                  autoPlay: true,
                  viewportFraction: 1,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  enlargeStrategy: CenterPageEnlargeStrategy.height,
                  autoPlayAnimationDuration: Duration(seconds: 2),
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  }),
              itemBuilder: (context, index, realIndex) {
                CardModel card = Data().cards[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          width: 1,
                          color: secondaryColor
                        )
                      ),
                      child: card.image,
                    ),
                    SizedBox(height: 10),
                    Text(
                      card.title,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      card.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryColor),
                    ),
                    SizedBox(height: 10,),
                    InkWell(
                      onTap: (){
                        index == 0 || index == 2
                            ? Get.to(() => Explore(from: "home"), transition: Transition.rightToLeft)
                            : Get.to(() => CreateProperty(getData: _getData), transition: Transition.rightToLeft);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal:10, vertical: 6),
                        decoration: BoxDecoration(
                          color: CupertinoColors.activeBlue,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                index == 0
                                    ? CupertinoIcons.compass
                                    : index == 1
                                    ? CupertinoIcons.add_circled
                                    : CupertinoIcons.person,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 5,),
                            Text(
                                index == 0
                                ? "Explore"
                                : index == 1
                                ? "Create"
                                : "Get Started",
                              style: TextStyle(color: Colors.black)
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          buildIndicator()
        ],
    );
  }
  Widget buildIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: Data().cards.length,
      effect: WormEffect(
        activeDotColor: CupertinoColors.activeBlue,
        dotColor: Colors.white38,
        dotHeight: 6,
        dotWidth: 6,
      ),
    );
  }
  void _removeEntity(EntityModel entityModel){
    print("Removing Property");
    _entity.remove(entityModel);
    // widget.removeEntity(entityModel);
    setState(() {
    });
  }
  void _updateCount(){

  }

}
