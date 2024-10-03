import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/actions/notifications.dart';
import 'package:Zelli/home/tabs/explore.dart';
import 'package:Zelli/home/tabs/tenants.dart';
import 'package:Zelli/models/units.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';

import '../../create/create_property.dart';
import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
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
  List<EntityModel> _entity = [];
  List<UnitModel> _unit = [];
  late TabController _tabController;
  final socketManager = Get.find<SocketManager>();

  bool isFilled = false;

  int countNotif = 0;
  int countMess = 0;

  int entityCount = 0;
  int leaseCount = 0;
  int unitCount = 0;
  int tenantCount = 0;

  double amount = 0.0;

  _getDetails()async{
    _getData();
    await Data().checkAndUploadEntity(_entity, _getData);
    SocketManager().getDetails();
    _getData();
  }

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).toList();
    entityCount = _entity.length;
    unitCount = _unit.length;
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
    final style = TextStyle(color: reverse, fontSize: 13);
    final secondary = TextStyle(color: secondaryColor, fontSize: 13);
    List filteredList = [];
    if (_search.text.isNotEmpty) {
      _entity.forEach((item) {
        if (item.title.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _entity;
    }
    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: normal,
                pinned: true,
                surfaceTintColor: Colors.transparent,
                expandedHeight: 320,
                automaticallyImplyLeading: false,
                foregroundColor: reverse,
                toolbarHeight: 30,
                actions: [
                  SizedBox(width: 5,),
                  Image.asset(
                      'assets/logo/logo-blue-48px.png',
                      height: 20
                  ),
                  SizedBox(width: 5,),
                  Text('Z E L L I', style: TextStyle(fontWeight: FontWeight.w100, fontSize: 18),),
                  Expanded(child: SizedBox()),
                  SizedBox(width: 10,),
                  IconButton(
                      onPressed: (){
                        Get.to(()=>Explore(from: "home",),transition: Transition.rightToLeft);
                      },
                      icon: Icon(CupertinoIcons.compass)
                  ),
                  SizedBox(width: 10,),
                  IconButton(
                      onPressed: (){
                        Get.to(()=>Notifications(reload: _getData, updateCount: _updateCount, eid: '',), transition: Transition.rightToLeft);
                      },
                      icon: Obx(() {
                        List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && !not.seen.toString().contains(currentUser.uid) ).toList();
                        countNotif = _countNotif.length;
                        return badges.Badge(
                          badgeStyle: badges.BadgeStyle(
                              shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                              borderRadius: BorderRadius.circular(30),
                              padding: EdgeInsets.all(5)
                          ),
                          badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10),),
                          showBadge:countNotif ==0?false:true,
                          position: badges.BadgePosition.topEnd(end: -5, top: -4),
                          child: LineIcon.bell(),
                        );
                      })
                  ),
                  SizedBox(width: 10,),
                  IconButton(
                      onPressed: (){
                        Get.to(() => ChatScreen(updateCount: _updateCount,), transition: Transition.rightToLeft);
                      },
                      icon: Obx((){
                        List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                        countMess = _count.length;
                        return badges.Badge(
                          badgeStyle: badges.BadgeStyle(
                              shape:countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                              borderRadius: BorderRadius.circular(30),
                              padding: EdgeInsets.all(5)
                          ),
                          badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10),),
                          showBadge:countMess==0?false:true,
                          position: badges.BadgePosition.topEnd(end: -5, top: -4),
                          child: Icon(CupertinoIcons.ellipses_bubble),
                        );
                      })
                  ),
                  SizedBox(width: 10,),
                  IconButton(
                      onPressed: (){
                        Get.to(() => Options(reload: (){setState(() {});},), transition: Transition.rightToLeft);
                      },
                      icon: Icon(CupertinoIcons.gear)
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Column(
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
                                  Text(tenantCount.toString(),style: TextStyle(fontSize: 18)),
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
                  child:Container(
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
                      tabs: const [
                        Text('Properties',),
                        Text('Tenants'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
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
                                        int noTenant = 0;
                                        _unitList = _unit.where((test) => test.eid == entity.eid).toList();
                                        noTenant = _unitList.where((test) => test.tid.toString() != "").toList().length;
                                        available = _unitList.where((test) => test.tid.toString() == "").toList().length;
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
                                                                      text:  " Tnts:${noTenant} ",
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
                                                        entity.pid!.contains(currentUser.uid)? RichText(
                                                            text: TextSpan(
                                                                children: [
                                                                  TextSpan(
                                                                      text: '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)} ',
                                                                      style: style
                                                                  ),
                                                                  TextSpan(
                                                                      text: "last month revenue",
                                                                      style: secondary
                                                                  )
                                                                ]
                                                            )
                                                        ) : Text("Leasing"),
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
                        Tenants(entity: EntityModel(eid: ""),)
                      ],
                  ),
                ),
              )
            ],
          )
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
