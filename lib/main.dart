import 'dart:io';

import 'package:Zelli/auth/login.dart';
import 'package:Zelli/resources/socket.dart';
import 'package:Zelli/test/consts.dart';
import 'package:Zelli/test/test_unit.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/fetching_data.dart';
import 'home/home_screen.dart';
import 'home/web_home.dart';
import 'models/device.dart';
import 'models/users.dart';

late List<CameraDescription> cameras;
DateTime today = DateTime.now();
DateTime justToday = DateTime(today.year, today.month, today.day);
UserModel currentUser = UserModel(uid: "");
DeviceModel deviceModel = DeviceModel();
String domain = "192.168.1.186";
List<String> myEntity = [];
List<String> notMyEntity = [];
List<String> myUnits = [];
List<String> myThird = [];
List<String> myUsers = [];
List<String> myLease = [];
List<String> myPayment = [];
List<String> myNotif = [];
List<String> myChats = [];
List<String> myMess = [];
List<String> myStars = [];
List<String> myDuties = [];
List<String> myBills = [];
Map<String, dynamic> myRates = {};

final customCacheManager = CacheManager(
    Config(
      'customCacheManager',
      maxNrOfCacheObjects: 200,
    )
);

Future<void> main()async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
  if(Platform.isMacOS || Platform.isWindows || Platform.isLinux){

  } else {
    cameras = await availableCameras();
  }
  Get.put(SocketManager());
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = false;

  Future getValidations() async{
    setState(() {
      _loading = true;
    });
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var obtainId = sharedPreferences.getString('uid');
    var obtainUsername = sharedPreferences.getString('username');
    var obtainFirst = sharedPreferences.getString('first');
    var obtainLast= sharedPreferences.getString('last');
    var obtainImage = sharedPreferences.getString('image');
    var obtainPhone = sharedPreferences.getString('phone');
    var obtainEmail = sharedPreferences.getString('email');;
    var obtainStatus = sharedPreferences.getString('status');
    var obtainToken = sharedPreferences.getString('token');
    var obtainPass = sharedPreferences.getString('password');
    var obtainCountry = sharedPreferences.getString('country');

    var obtainMyEntity = sharedPreferences.getStringList('myentity');
    var obtainNotMyEntity = sharedPreferences.getStringList('notmyentity');
    var obtainMyUnit = sharedPreferences.getStringList('myunit');
    var obtainMyThird= sharedPreferences.getStringList('mythird');
    var obtainMyUsers= sharedPreferences.getStringList('myusers');
    var obtainMyLease= sharedPreferences.getStringList('mylease');
    var obtainMyPayment= sharedPreferences.getStringList('mypay');
    var obtainMyNotif= sharedPreferences.getStringList('mynotif');
    var obtainMyChats= sharedPreferences.getStringList('mychats');
    var obtainMyMess= sharedPreferences.getStringList('mymess');
    var obtainMyStars= sharedPreferences.getStringList('mystars');
    var obtainMyDuties= sharedPreferences.getStringList('myduties');
    var obtainMyBills= sharedPreferences.getStringList('mybills');


    var obtainRates= sharedPreferences.getStringList('rates');

    var obtainDomain = sharedPreferences.getString('domain');
    setState(() {
      currentUser = UserModel(
          uid: obtainId == null || obtainId == ""? "": obtainId,
          firstname: obtainFirst == null || obtainFirst == ""? "":obtainFirst,
          lastname: obtainLast == null || obtainLast == ""? "":obtainLast,
          username: obtainUsername == null || obtainUsername == ""? "":obtainUsername,
          email: obtainEmail == null || obtainEmail == ""? "":obtainEmail,
          phone: obtainPhone == null || obtainPhone == ""? "":obtainPhone,
          image: obtainImage == null || obtainImage == ""? "":obtainImage,
          password: obtainPass == null || obtainPass == ""? "":obtainPass,
          status: obtainStatus == null || obtainStatus == ""? "":obtainStatus,
          token: obtainToken == null || obtainToken == ""? "":obtainToken,
          country: obtainCountry == null || obtainCountry == ""? "":obtainCountry
      );
      domain = obtainDomain == null || obtainDomain == "" ? "192.168.0.103" : obtainDomain;
      myEntity = obtainMyEntity == null ? [] :  obtainMyEntity;
      notMyEntity = obtainNotMyEntity == null ? [] :  obtainNotMyEntity;
      myUnits = obtainMyUnit == null ? [] : obtainMyUnit;
      myThird = obtainMyThird == null ? [] :obtainMyThird;
      myUsers = obtainMyUsers== null ? [] :obtainMyUsers;
      myLease = obtainMyLease== null ? [] :obtainMyLease;
      myPayment = obtainMyPayment== null ? [] :obtainMyPayment;
      myNotif = obtainMyNotif== null ? [] :obtainMyNotif;
      myChats = obtainMyChats== null ? [] :obtainMyChats;
      myMess = obtainMyMess== null ? [] :obtainMyMess;
      myStars = obtainMyStars== null ? [] :obtainMyStars;
      myDuties = obtainMyDuties== null ? [] :obtainMyDuties;
      myBills = obtainMyBills== null ? [] :obtainMyBills;
      // for (var item in (obtainRates ?? [])) {
      //   List<String> splitItem = item.split(': ');
      //   if (splitItem.length == 2) {
      //     String key = splitItem[0].trim();
      //     String value = splitItem[1].trim();
      //     myRates[key] = value;
      //   }
      // }
      _loading = false;
    });
   //await CurrencyService().fetchExchangeRates("USD");
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getValidations();
    SocketManager().initPlatform();
  }
  @override
  Widget build(BuildContext context) {
    final dialogBgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.grey[900];
    final size = MediaQuery.of(context).size;
    return GetMaterialApp(
      title: 'Zelli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(useMaterial3: true,).copyWith(
        dialogBackgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
          popupMenuTheme: PopupMenuThemeData(surfaceTintColor: Colors.transparent, color: Colors.white,),
          colorScheme: ColorScheme.highContrastLight(primary: CupertinoColors.activeBlue),
          dialogTheme: DialogTheme(surfaceTintColor: Colors.transparent,),
          bottomSheetTheme: BottomSheetThemeData(surfaceTintColor: Colors.transparent,),
          cardTheme: CardTheme(surfaceTintColor: Colors.transparent),
          appBarTheme: AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return CupertinoColors.activeBlue.withOpacity(0.9); // Color when the scrollbar is hovered
              }
              if (states.contains(MaterialState.focused)) {
                return CupertinoColors.activeBlue; // Color when the scrollbar is focused
              }
              return CupertinoColors.activeBlue.withOpacity(0.5); // Default color
            },
          ),
          thickness: MaterialStateProperty.resolveWith<double?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return 7.0; // Thickness when the scrollbar is hovered
              }
              if (states.contains(MaterialState.dragged)) {
                return 7.0; // Thickness when the scrollbar is being dragged
              }
              return 5; // Default thickness
            },
          ),
        ),
        tabBarTheme: TabBarTheme( dividerColor: Colors.transparent,)
      ),
      darkTheme: ThemeData.light(useMaterial3: true,).copyWith(
          dialogBackgroundColor: Colors.grey[900],
          scaffoldBackgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white),
          colorScheme: ColorScheme.highContrastDark(primary: CupertinoColors.activeBlue),
          popupMenuTheme: PopupMenuThemeData(surfaceTintColor: Colors.transparent, color: dialogBgColor),
          hintColor: secondaryColor,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white,),
            bodyMedium: TextStyle(color: Colors.white,),
          ),
          tabBarTheme: TabBarTheme(dividerColor: Colors.transparent),
          dialogTheme: DialogTheme(surfaceTintColor: Colors.transparent,),
          bottomSheetTheme: BottomSheetThemeData(surfaceTintColor: Colors.transparent,),
          cardTheme: CardTheme(surfaceTintColor: Colors.transparent),
          appBarTheme: AppBarTheme(backgroundColor: Colors.black),
          snackBarTheme: SnackBarThemeData(
              width: size.width > 450 ? 500: null,
              actionTextColor: CupertinoColors.activeBlue,
              backgroundColor: Colors.grey[900],
              elevation: 10,
              behavior: SnackBarBehavior.floating,
              contentTextStyle: TextStyle(color: Colors.white),
              closeIconColor: CupertinoColors.systemBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))
          ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return CupertinoColors.activeBlue.withOpacity(0.9); // Color when the scrollbar is hovered
              }
              if (states.contains(MaterialState.focused)) {
                return CupertinoColors.activeBlue; // Color when the scrollbar is focused
              }
              return CupertinoColors.activeBlue.withOpacity(0.5); // Default color
            },
          ),
          thickness: MaterialStateProperty.resolveWith<double?>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return 7.0; // Thickness when the scrollbar is hovered
              }
              if (states.contains(MaterialState.dragged)) {
                return 7.0; // Thickness when the scrollbar is being dragged
              }
              return 5; // Default thickness
            },
          ),
        ),
      ),
      home: _loading
          ?FetchingData()
          :currentUser.uid.isEmpty || currentUser.uid=="" || currentUser.uid==null
          ? LogIn()
          : Platform.isAndroid || Platform.isIOS
          ? HomeScreen()
          : WebHome(),
    );
  }
}

