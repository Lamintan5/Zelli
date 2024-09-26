import 'dart:convert';
import 'dart:io';

import 'package:Zelli/create/create_property.dart';
import 'package:Zelli/home/options/options_screen.dart';
import 'package:Zelli/home/tabs/payments.dart';
import 'package:Zelli/home/tabs/report.dart';
import 'package:Zelli/home/tabs/tenants.dart';
import 'package:Zelli/home/tabs/units.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/widgets/credits.dart';
import 'package:Zelli/widgets/logo/row_logo_single.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:badges/badges.dart' as badges;

import '../api/crypto.dart';
import '../api/currency_service.dart';
import '../main.dart';
import '../models/data.dart';
import '../models/messages.dart';
import '../models/notifications.dart';
import '../models/units.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import '../utils/colors.dart';
import '../views/property/prop_page.dart';
import '../views/property/prop_view.dart';
import '../widgets/frosted_glass.dart';
import '../widgets/logo/prop_logo.dart';
import '../widgets/profile_images/current_profile.dart';
import '../widgets/star_items/small_star.dart';
import '../widgets/text/text_format.dart';
import 'actions/notifications.dart';
import 'options/edit_profile.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  var encryptionHelper;
  TextEditingController _search = TextEditingController();

  List<EntityModel> _entity = [];

  EntityModel enty = EntityModel(eid: "", title: "N/A");

  final socketManager = Get.find<SocketManager>();
  bool _expand = true;
  bool _loading = false;
  String encryptedText = "";
  List<LeaseModel> _tenants = [];



  int nav = 0;
  int countMess = 0;
  int countNotif = 0;
  double amount = 0;
  double convert = 0;

  _getDetails()async{
    _getData();
    await Data().checkAndUploadEntity(_entity, _getData);
    SocketManager().getDetails();
    _getData();
  }

  _getData(){
    _entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList();
    _tenants = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).toList();
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDetails();
    SocketManager().connect();
    SocketManager().setData();
    // convert = CurrencyService().convertCurrency(toCurrency: TFormat().getCurrencyCode().toString(), amount: 1000);
  }







  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final style = TextStyle(color: revers, fontSize: 13);
    final secondary = TextStyle(color: secondaryColor, fontSize: 13);
    final image =  Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_72.png"
        : "assets/logo/5logo_72_black.png";
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
      body: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            constraints: BoxConstraints(
                maxWidth: _expand
                    ?250
                    :50
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _expand
                            ?Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RowLogoSingle(height: 30,),
                            )
                            :Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/logo/logo-48px.png',
                            height: 30,
                          ),
                        ),
                        SizedBox(height: 40,),
                        Container(
                          margin: EdgeInsets.only( bottom: 20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            onTap: (){
                              setState(() {
                                _expand =! _expand;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(Icons.menu),
                            ),
                          ),
                        ),
                        navButton(Icon(CupertinoIcons.chart_bar_alt_fill), "Analytics", (){setState(() {nav=0;});}, 0),
                        SizedBox(height: 5,),
                        navButton(LineIcon.box(), "Units", (){setState(() {nav=1;});}, 1),
                        SizedBox(height: 5,),
                        navButton(LineIcon.user(), "Tenants", (){setState(() {nav=2;});}, 2),
                        SizedBox(height: 5,),
                        navButton(Icon(CupertinoIcons.cube_box), "Leasing", (){setState(() {nav=3;});}, 3),
                        SizedBox(height: 5,),
                        navButton(LineIcon.wallet(), "Payments", (){setState(() {nav=4;});}, 4),
                        SizedBox(height: 5,),
                        navButton(Icon(CupertinoIcons.compass), "Explore", (){setState(() {nav=5;});}, 5),
                        SizedBox(height: 5,),
                        InkWell(
                          onTap: (){
                            // Get.to(()=>WebChat(selected: UserModel(uid: "")), transition: Transition.rightToLeft);
                          },
                          hoverColor: color1,
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(width: 5,),
                                _expand
                                    ? Icon(CupertinoIcons.ellipses_bubble)
                                    : Obx((){
                                  List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                                  countMess = _count.length;
                                  return badges.Badge(
                                    badgeStyle: badges.BadgeStyle(
                                        shape: countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                        borderRadius: BorderRadius.circular(30),
                                        padding: EdgeInsets.all(5)
                                    ),
                                    badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10),),
                                    showBadge: countMess==0?false:true,
                                    position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                    child: Icon(CupertinoIcons.ellipses_bubble),
                                  );
                                }),
                                _expand?SizedBox(width: 20,):SizedBox(),
                                _expand?Expanded(
                                    child:
                                    Text(
                                      "Message",
                                      style: TextStyle(color: reverse,),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    )
                                )
                                    :SizedBox(),
                                _expand
                                    ? Obx((){
                                  List<MessModel> _count = socketManager.messages.where((msg) => msg.sourceId != currentUser.uid && msg.seen =="").toList();
                                  countMess = _count.length;
                                  return badges.Badge(
                                    badgeStyle: badges.BadgeStyle(
                                        shape: countMess > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                        borderRadius: BorderRadius.circular(30),
                                        padding: EdgeInsets.all(5)
                                    ),
                                    badgeContent: Text(NumberFormat.compact().format(countMess), style: TextStyle(fontSize: 10),),
                                    showBadge: countMess==0?false:true,
                                    position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                  );
                                })
                                    : SizedBox()

                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        InkWell(
                          onTap: (){
                            Get.to(()=> Notifications(reload: _getDetails, updateCount: _updateCount, eid: '',), transition: Transition.rightToLeft);
                          },
                          hoverColor: color1,
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
                            decoration: BoxDecoration(

                                borderRadius: BorderRadius.circular(5)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(width: 5,),
                                _expand
                                    ? LineIcon.bell()
                                    : Obx((){
                                  List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && not.seen == "" ).toList();
                                  countNotif = _countNotif.length;
                                  return badges.Badge(
                                    badgeStyle: badges.BadgeStyle(
                                        shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                        borderRadius: BorderRadius.circular(30),
                                        padding: EdgeInsets.all(5)
                                    ),
                                    badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10),),
                                    showBadge: countNotif==0?false:true,
                                    position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                    child: LineIcon.bell(),
                                  );
                                }),
                                _expand?SizedBox(width: 20,):SizedBox(),
                                _expand?Expanded(
                                    child:
                                    Text(
                                      "Notifications",
                                      style: TextStyle(color: reverse,),
                                      maxLines: 1,
                                      overflow: TextOverflow.fade,
                                    )
                                )
                                    :SizedBox(),
                                _expand
                                    ? Obx((){
                                  List<NotifModel> _countNotif = socketManager.notifications.where((not) => not.sid != currentUser.uid && !not.seen.toString().contains(currentUser.uid)).toList();
                                  countNotif = _countNotif.length;
                                  return badges.Badge(
                                    badgeStyle: badges.BadgeStyle(
                                        shape: countNotif > 99? badges.BadgeShape.square : badges.BadgeShape.circle,
                                        borderRadius: BorderRadius.circular(30),
                                        padding: EdgeInsets.all(5)
                                    ),
                                    badgeContent: Text(NumberFormat.compact().format(countNotif), style: TextStyle(fontSize: 10),),
                                    showBadge: countNotif==0?false:true,
                                    position: badges.BadgePosition.topEnd(end: -5, top: -4),
                                  );
                                })
                                    : SizedBox()
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5,),
                        navButton(Icon(CupertinoIcons.gear), "Settings", (){
                          Get.to(() => Options(reload: (){setState(() {});},), transition: Transition.rightToLeft);},6),
                        SizedBox(height: 5,),
                        navButton(Icon(Icons.add_box_outlined), "Create", (){Get.to(()=> CreateProperty(getData: _getData), transition: Transition.rightToLeft);},7),
                      ],
                    ),
                  ),
                ),
                Image.asset(
                    height: 30,
                    image
                ),
                SizedBox(width: 5,),
                _expand?Text(
                  "S T U D I O 5 I V E",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w100),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ):SizedBox(),
                SizedBox(height: 20,)
              ],
            ),
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  nav==0? Expanded(child: Report(entity: EntityModel(eid: ""), unitid: '', tid: '', lid: '',))
                      : nav == 1
                      ? Expanded(child: Units())
                      : nav==2
                      ? Expanded(child: Tenants(entity: EntityModel(eid: "")))
                      : nav==3
                      ? SizedBox()
                      : nav==4
                      ? Expanded(child: Payments(eid: '',unitid: '',tid: '', lid: '',))
                      :SizedBox()
                ],
              )
          ),
          SizedBox(width: 10,),
          Container(
            padding: EdgeInsets.all(8),
            constraints: BoxConstraints(
                minWidth: 250,
                maxWidth:400
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: color1,
                      borderRadius: BorderRadius.circular(5)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CurrentImage(radius: 20,),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('@${currentUser.username}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                                Text('${currentUser.firstname} ${currentUser.lastname}', style: TextStyle()),
                              ],
                            ),
                          ),
                          IconButton(
                              tooltip: "Edit Profile",
                              onPressed: (){
                                Get.to(()=>EditProfile(reload: (){setState(() {});},), transition: Transition.rightToLeft);
                              },
                              icon: Icon(Icons.arrow_forward_ios, size: 20, color: secondaryColor,)
                          ),

                        ],
                      ),
                      SizedBox(height: 5,),
                      RichText(
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              style: TextStyle(fontSize: 13, color: secondaryColor),
                              children: [
                                WidgetSpan(child: Icon(Icons.mail_outline,size: 15,color: secondaryColor)),
                                WidgetSpan(child: SizedBox(width: 5)),
                                TextSpan(text: currentUser.email),
                                WidgetSpan(child: SizedBox(width: 10)),
                                WidgetSpan(child: LineIcon.phone(size: 15,color: secondaryColor)),
                                WidgetSpan(child: SizedBox(width: 5)),
                                TextSpan(text: currentUser.phone),
                              ]
                          )
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Credit(title: "Properties", subtitle: "12"),
                    Credit(title: "Units", subtitle: "23"),
                    Credit(title: "Tenants", subtitle: "45"),
                    Credit(title: "Leasing", subtitle: "5"),
                  ],
                ),
                SizedBox(height: 10,),
                Text('Entities',
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w900
                  ),
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _search,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "🔎  Search for your Entities...",
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
                            return InkWell(
                              onTap: (){
                                entity.pid!.contains(currentUser.uid)
                                    ?  Get.to(()=>PropertyView(entity: entity,removeEntity: _removeEntity, reload: _getData,), transition: Transition.rightToLeftWithFade)
                                    :  Get.to(()=>PropertyPage(entity: entity, units: _unitList,), transition: Transition.rightToLeft);
                              },
                              borderRadius: BorderRadius.circular(10),
                              splashColor: CupertinoColors.activeBlue,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Stack(
                                  children: [
                                    SizedBox(width: double.infinity, height: double.infinity,
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
          ),
        ],
      ),
    );
  }
  Widget navButton(Widget icon, String title, void Function() ontap, int index){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final revers = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    return InkWell(
      onTap: ontap,
      hoverColor: color1,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
        decoration: BoxDecoration(
            color: nav==index?color1:null,
            borderRadius: BorderRadius.circular(5)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            nav==index
                ?Container(
              width: 3,height: 15,
              margin: EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                  color:CupertinoColors.activeBlue,
                  borderRadius: BorderRadius.circular(10)
              ),
            )
                :SizedBox(width: 5,),
            icon,
            _expand?SizedBox(width: 20,):SizedBox(),
            _expand?Expanded(
                child:
                Text(
                  title,
                  style: TextStyle(color: revers,),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                )
            )
                :SizedBox(),
          ],
        ),
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
  void _addEntity(EntityModel entityModel){
    _entity.add(entityModel);
    setState(() {
    });
  }
  void _updateEntity(String eid){
    _entity.firstWhere((element) => element.eid == eid).checked = 'true';
    setState(() {
    });
  }
  void _updateCount(){

  }

// var uuid = '12345678912345678912345678912345';
// encryptionHelper = EncryptionHelper(uuid);
// final encryptedData = encryptionHelper.encryptField("HELLO World");
// print('Encrypted Data: $encryptedData');
// final decryptedData = encryptionHelper.decryptField (encryptedData);
// print('Decrypted Data: $decryptedData');
}
