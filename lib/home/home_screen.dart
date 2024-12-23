import 'package:Zelli/api/google_signin_api.dart';
import 'package:Zelli/widgets/profile_images/current_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login.dart';
import '../main.dart';
import '../models/users.dart';
import '../resources/services.dart';
import '../resources/socket.dart';
import '../utils/colors.dart';
import '../utils/global_variables.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late PageController pageController;
  bool _requireConsent = false;


  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void onPageChanged(int page) {
    setState(() {
      _selectedIndex = page;
    });
  }
  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    SocketManager().connect();
    SocketManager().getDetails();
    SocketManager().setData();
  }

  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    return Scaffold(
      body: SizedBox(
        child: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: pageController,
          onPageChanged: onPageChanged,
          children: homeScreenItems,
        ),
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: normal,
        onTap: navigationTapped,
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: LineIcon.home(
              color: (_selectedIndex == 0) ? reverse : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: LineIcon.box(
              color: (_selectedIndex == 1) ? reverse : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: LineIcon.wallet(
              color: (_selectedIndex == 2) ? reverse : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.chart_bar_alt_fill,
              color: (_selectedIndex == 3) ? reverse : secondaryColor,
            ),
            label: '',
            backgroundColor: primaryColor,
          ),
        ],
      ),
    );
  }
}
