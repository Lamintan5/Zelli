import 'dart:io';

import 'package:Zelli/models/entities.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/views/property/prop_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';

import '../../main.dart';
import '../../models/units.dart';
import '../../utils/colors.dart';
import '../../widgets/frosted_glass.dart';
import '../../widgets/logo/prop_logo.dart';
import '../../widgets/star_items/small_star.dart';


class Explore extends StatefulWidget {
  final String from;
  const Explore({super.key, this.from = ""});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  late TextEditingController _search;

  List<EntityModel> _entity = [];
  List<UnitModel> _units = [];

  bool isFilled = false;
  bool _loading = false;

  _getEntity()async{
    setState(() {
      _loading = true;
    });
    _entity = await Services().getAllEntity();
    _units = await Services().getAllUnit();
    setState(() {
       _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = TextEditingController();
    _getEntity();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _search.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final style = TextStyle(color: reverse, fontSize: 13);
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Row(
                children: [
                  widget.from.isNotEmpty? Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: (){Navigator.pop(context);},
                      borderRadius: BorderRadius.circular(5),
                      hoverColor: color1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                  ) : SizedBox(),
                  Text("Explore", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  Expanded(child: SizedBox()),
                  InkWell(
                    onTap: (){},
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.filter_list_rounded),
                    ),
                  )
                ],
              ),
              Container(
                width: 500,
                margin: EdgeInsets.symmetric(vertical: 10),
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
              _loading
                  ? Expanded(child: Center(child: SizedBox(child: CircularProgressIndicator(color: reverse, strokeWidth: 3,))))
                  : Expanded(
                      child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredList.length,
                          gridDelegate:  SliverGridDelegateWithMaxCrossAxisExtent(
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            mainAxisExtent: 250,
                            maxCrossAxisExtent: 200,
                          ),
                          itemBuilder: (context, index){
                            EntityModel entity = filteredList[index];
                            String image = entity.image!;
                            List<UnitModel> _unitList = [];
                            int available = 0;
                            _unitList = _units.where((test) => test.eid == entity.eid).toList();
                            available = _unitList.where((test) => test.tid.toString() == "").toList().length;
                            return InkWell(
                              onTap: (){
                                Get.to(()=>PropertyView(entity: entity,removeEntity: _removeEntity, reload: _getEntity,), transition: Transition.rightToLeftWithFade);
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

                                            // entity.pid!.contains(currentUser.uid)? RichText(
                                            //     text: TextSpan(
                                            //         children: [
                                            //           TextSpan(
                                            //               text: '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)} ',
                                            //               style: style
                                            //           ),
                                            //           TextSpan(
                                            //               text: "last month revenue",
                                            //               style: secondary
                                            //           )
                                            //         ]
                                            //     )
                                            // ) : Text("Leasing"),
                                            SmallStar(entity: entity, type: "ENTITY", rid: "", size: 20,),
                                            SizedBox(height: 1,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(CupertinoIcons.location, size: 13,color: secondaryColor,),
                                                SizedBox(width: 5),
                                                Text("San Fransisco, CA", style: TextStyle(color: secondaryColor, fontSize: 12),),
                                              ],
                                            ),
                                            SizedBox(height: 1,),
                                            RichText(
                                                text: TextSpan(
                                                    children: [
                                                      WidgetSpan(
                                                        child: Icon(Icons.crop_free_outlined, size: 13, color: color5,),
                                                      ),
                                                      TextSpan(
                                                          text:  " ${available} Available units",
                                                          style: TextStyle(color: color5, fontSize: 12)
                                                      ),
                                                    ]
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  ),
            ],
          ),
        ),
      ),
    );
  }
  void _removeEntity(EntityModel entityModel){
    print("Removing Property");
    _entity.remove(entityModel);
    setState(() {
    });
  }
}
