import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/tabs/payments.dart';
import 'package:Zelli/main.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/views/property/activities/leases.dart';
import 'package:Zelli/views/unit/activities/co_tenants.dart';
import 'package:Zelli/views/unit/activities/create_request.dart';
import 'package:Zelli/views/unit/activities/lease.dart';
import 'package:Zelli/widgets/dialogs/unit_dialogs/dialog_pay.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../home/actions/chat/message_screen.dart';
import '../../home/actions/chat/web_chat.dart';
import '../../home/tabs/report.dart';
import '../../models/charge.dart';
import '../../models/data.dart';
import '../../models/messages.dart';
import '../../models/month_model.dart';
import '../../models/lease.dart';
import '../../models/units.dart';
import '../../models/util.dart';
import '../../models/utils.dart';
import '../../resources/services.dart';
import '../../utils/colors.dart';
import '../../widgets/buttons/bottom_call_buttons.dart';
import '../../widgets/buttons/call_actions/double_call_action.dart';
import '../../widgets/cards/card_button.dart';
import '../../widgets/cards/row_button.dart';
import '../../widgets/dialogs/dialog_add_tenant.dart';
import '../../widgets/dialogs/dialog_edit_unit.dart';
import '../../widgets/dialogs/dialog_title.dart';
import '../../widgets/dialogs/unit_dialogs/dialog_terminate.dart';
import '../../widgets/dialogs/unit_dialogs/dialog_tnt_rq.dart';
import '../../widgets/items/item_pay.dart';
import '../../widgets/items/item_utils_period.dart';
import '../../widgets/profile_images/user_profile.dart';

class UnitProfile extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final UserModel user;
  final Function reload;
  final Function removeTenant;
  final Function removeFromList;
  final String leasid;
  const UnitProfile({super.key, required this.unit, required this.reload, required this.removeTenant, required this.removeFromList, required this.user, required this.leasid, required this.entity});

  @override
  State<UnitProfile> createState() => _UnitProfileState();
}

class _UnitProfileState extends State<UnitProfile> with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _search;

  EntityModel entity = EntityModel(eid: "");
  UnitModel unit = UnitModel(id: "");
  UserModel currentTenant = UserModel(uid: "");
  LeaseModel currentLease = LeaseModel(lid: "");
  MonthModel lastPaid = MonthModel(year: 2000, monthName: "Jan", month: 1, amount: 0, balance: 0);

  List<UserModel> _users = [];
  List<UserModel> _tenants = [];
  List<PaymentsModel> _pay = [];
  List<PaymentsModel> _filtPay = [];
  List<PaymentsModel> _current = [];
  List<PaymentsModel> _rent = [];
  List<PaymentsModel> _deposit = [];
  List<MonthModel> _accrue = [];
  List<MonthModel> monthsList = [];
  List<LeaseModel> _leases = [];
  List<String> _admin = [];
  List<String> _pids = [];
  List<String> _tids = [];

  final _keyOne = GlobalKey();
  final _keyTwo = GlobalKey();
  final _keyThree = GlobalKey();

  int floor = 0;
  int room = 0;

  double deposit = 0;
  double rent = 0;
  double paidDeposit = 0;
  double depoBalance = 0;
  double accrued = 0;

  late DateTime startDate;
  late DateTime endDate;

  String start = "";
  String end = "";
  String expanded = "";
  String lid = "";

  bool _loading = false;
  bool isFilled = false;
  bool isMember = false;
  bool isTenant = false;

  double _position1 = 20.0;
  double _position2 = 20.0;
  double _position3 = 20.0;
  double _position4 = 20.0;

  String image1 = '';
  String image2 = '';
  String image3 = '';

  _getDetails()async{
    _getData();
    if(currentLease.ctid.toString().split(",").length > 1){
      currentLease.ctid.toString().split(",").forEach((tid)async{
        if(!_tenants.any((test) => test.uid == tid)){
          List<UserModel>  _new = await Services().getCrntUsr(tid);
          UserModel user = _new.first;
          await Data().addUser(user);
        }
      });
    }
    _getData();
  }

  _getData(){
    lid = widget.leasid.isEmpty? widget.unit.lid.toString() : widget.leasid;
    _getUnit();
    _getEntity();
    _getUser();
    _getPayments();
    _listMonth();
    _accrue = monthsList.where((test)=>test.balance!=0.0).toList();
    accrued=_accrue.fold(0.0, (previous, element) => previous + element.balance);
    lastPaid = monthsList.lastWhere((test) => double.parse(test.amount.toString()) != 0, orElse: ()=>MonthModel(year: DateTime.now().year, monthName: "Jan", month: DateTime.now().month, amount: 0, balance: 0));
    monthsList.forEach((mnth){
      print("${mnth.monthName}, Amount : ${mnth.amount}, Bal : ${mnth.balance}");
    });
    setState(() {
    });
  }

  _getEntity(){
    entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList().firstWhere((test)=> test.eid == unit.eid, orElse: ()=> widget.entity);
    _admin = entity.admin.toString().split(",");
    _pids = entity.pid.toString().split(",");
    isMember = entity.pid.toString().split(",").contains(currentUser.uid);
    isTenant = unit.tid.toString().contains(currentUser.uid);
  }

  _getUser(){
    _users = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).toList();
    _leases = myLease.map((jsonString) => LeaseModel.fromJson(json.decode(jsonString))).where((test){
      bool matchLid = lid.isEmpty || test.lid == lid;
      bool matchTid = currentTenant.uid.isEmpty || test.tid == currentTenant.uid;
      bool matchUid = unit.id.toString().isEmpty || test.uid.toString().split(",").first == unit.id.toString();
      return matchLid && matchUid && matchTid;
    }).toList();
    currentTenant =  widget.user.uid.isNotEmpty
        ? widget.user
        :  _users.firstWhere((test) => test.uid == unit.tid.toString().split(",").first, orElse: () => UserModel(uid: ""));

    currentLease = _leases.firstWhere((test) => test.lid == lid, orElse: ()=>LeaseModel(lid: "", tid: "", start: "", end: "") );
    start = currentLease.start.toString();
    end = currentLease.end.toString();
    // _leases.forEach((e){
    //   print(e.toJson());
    // });
    _tids.add(currentLease.tid.toString());
    currentLease.ctid.toString().split(",").forEach((e){
      if(!_tids.contains(e)){
        _tids.add(e);
      }
    });
    _tids.remove("");
    _tenants = _users.where((usr)=>_tids.any((tnt) => usr.uid==tnt)).toList();
    if (_tenants.isNotEmpty) {
      image1 = _tenants.length > 0 ? _tenants[0].image.toString() : '';
      image2 = _tenants.length > 1 ? _tenants[1].image.toString() : '';
      image3 = _tenants.length > 2 ? _tenants[2].image.toString() : '';
    }


    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _position1 = _tenants.length == 2 ? 18 : _tenants.length == 3 || _tenants.length > 3 ? 10 : 20.0;
        _position2 = _tenants.length == 2 ? 18 : _tenants.length == 3 || _tenants.length > 3 ? 20 : 20.0;
        _position3 = _tenants.length == 0 ? 20 : _tenants.length == 1 ? 20 : _tenants.length == 2 || _tenants.length == 3 || _tenants.length > 3 ? 30 : 20.0;
        _position4 = _tenants.length == 0 ? 20 : _tenants.length == 1 ? 30 : _tenants.length == 2 || _tenants.length == 3 || _tenants.length > 3 ? 40 : 20.0;
      });
    });
  }

  _getUnit(){
    unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).firstWhere((test) => test.id==widget.unit.id, orElse: ()=>widget.unit);
    floor = int.parse(unit.floor.toString());
    room = int.parse(unit.room.toString());
    deposit = double.parse(unit.deposit.toString());
    rent = double.parse(unit.price.toString());
  }

  _getPayments(){
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).toList();
    _pay = _pay.where((test) => test.uid == unit.id).toList();
    _current = currentLease.lid==""? [] : _pay.where((test) => test.lid == currentLease.lid).toList();
    _deposit = currentLease.lid==""? [] : _pay.where((test) => test.lid == currentLease.lid && test.type == "DEPOSIT").toList();
    _rent = currentLease.lid==""? [] : _pay.where((test) => test.lid == currentLease.lid && test.type ==  "RENT").toList();
    paidDeposit = _deposit.fold(0.0, (previous, element) => previous + double.parse(element.amount.toString()));
    depoBalance = deposit - paidDeposit;
  }

  _listMonth(){
    DateTime currentMonth = DateTime.now();
    DateTime firstRentDate =  _rent.isEmpty
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString()))
        : DateTime.parse(_rent.first.time.toString());
    DateTime lastRentDate =  _rent.isEmpty
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString()))
        : DateTime.parse(_rent.last.time.toString());
    startDate = DateTime(firstRentDate.year, firstRentDate.month, int.parse(entity.due.toString()));
    endDate = lastRentDate.month < currentMonth.month
        ?  DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString()))
        : DateTime(lastRentDate.year, lastRentDate.month, int.parse(entity.due.toString()));
    monthsList = generateMonthsList(startDate, endDate);
  }

  // List<MonthModel> generateMonthsLiasst(DateTime startDate, DateTime endDate) {
  //   List<MonthModel> monthsList = [];
  //
  //   for (DateTime date = startDate;
  //   date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
  //   date = DateTime(date.year, date.month + 1, date.day)) {
  //
  //     double totalAmountPaid = 0;
  //     double balance = 0;
  //     print(DateFormat('MMM').format(date));
  //     // Filter rent payments for the current month
  //     var currentMonthRentPayments = _rent.where((test) {
  //       DateTime paymentDate = DateTime.parse(test.time!.split(",").first);
  //       return test.type == "RENT" &&
  //           paymentDate.year == date.year &&
  //           paymentDate.month == date.month;
  //     }).toList();
  //
  //     // Calculate total amount paid for the current month
  //     totalAmountPaid = currentMonthRentPayments.fold(
  //       0.0,
  //           (previous, test) => previous + double.parse(test.amount.toString()),
  //     );
  //
  //     // Handle overpayment and balance calculation
  //     while (totalAmountPaid > 0) {
  //       double paymentForThisMonth = rent;
  //       balance = 0;
  //
  //       if (totalAmountPaid < rent) {
  //         paymentForThisMonth = totalAmountPaid;
  //         balance = rent - totalAmountPaid;
  //       }
  //
  //       String monthName = DateFormat('MMM').format(date);
  //       print('Month $monthName: Paid \$${paymentForThisMonth.toStringAsFixed(2)}, Remaining balance: \$${balance.toStringAsFixed(2)}');
  //       monthsList.add(MonthModel(
  //         year: date.year,
  //         monthName: monthName,
  //         month: date.month,
  //         amount: paymentForThisMonth,
  //         balance: balance,
  //       ));
  //
  //       totalAmountPaid -= paymentForThisMonth;
  //
  //       if (balance > 0) {
  //         // If there's a balance, break the while loop, and continue with the same month in the for loop
  //         break;
  //       } else {
  //         // If no balance, move to the next month within the while loop
  //         date = DateTime(date.year, date.month + 1, date.day);
  //       }
  //     }
  //
  //     if (balance > 0) {
  //       // If there's a balance, reset date to the current month to repeat in the next for loop iteration
  //       date = DateTime(date.year, date.month - 1, date.day);
  //     }
  //     // If no balance, the for loop will naturally continue to the next month
  //   }
  //
  //   return monthsList;
  // }

  List<MonthModel> generateMonthsList(DateTime startDate, DateTime endDate) {
    List<MonthModel> monthList = [];
    double remainingBalance = 0.0;

    for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = DateTime(date.year, date.month + 1, 1)) {
      double totalAmountPaid = 0.0;
      double monthlyBalance = rent;

      // Find payments for the current month
      var currentMonthPayments = _rent.where((payment) {
        List<String> times = payment.time!.split(',');
        DateTime paymentStart = DateTime.parse(times.first);
        DateTime paymentEnd = times.length > 1 ? DateTime.parse(times.last) : paymentStart;

        return (paymentStart.year == date.year && paymentStart.month == date.month) ||
            (paymentEnd.year == date.year && paymentEnd.month == date.month) ||
            (paymentStart.isBefore(date) && paymentEnd.isAfter(date));
      }).toList();

      // Accumulate payments for the month
      for (var payment in currentMonthPayments) {
        double paymentAmount = double.parse(payment.amount!);

        if (date.month == DateTime.parse(payment.time!.split(',').first).month &&
            date.year == DateTime.parse(payment.time!.split(',').first).year) {
          // Add previous balance to the first payment in the period
          paymentAmount += remainingBalance;
          remainingBalance = 0;  // Reset the remaining balance after it's used
          // print("Remain Balance $remainingBalance");
        }

        // Distribute the payment amount across months, if necessary
        if (paymentAmount > monthlyBalance) {
          remainingBalance = paymentAmount - monthlyBalance;
          totalAmountPaid += monthlyBalance;
          // print("Remain Balance $remainingBalance");
          break;  // Stop accumulating payments once the rent is covered
        } else {
          totalAmountPaid += paymentAmount;
          monthlyBalance -= paymentAmount;
          print("Monthly Balance $monthlyBalance");
        }
      }

      // Create MonthModel for the current month
      monthList.add(MonthModel(
        year: date.year,
        month: date.month,
        monthName: DateFormat('MMM').format(date),
        amount: totalAmountPaid,
        balance:monthlyBalance,
      ));
    }

    return monthList;
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _search = TextEditingController();
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
    final size = MediaQuery.of(context).size;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final dgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.withOpacity(.4)
        : Colors.white;
    final width = 800.0;
    final style = TextStyle(fontSize: 13, color: secondaryColor);
    final bold = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: reverse);
    final activeBlue = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue);
    final activeRed = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.red);
    List filteredTenants = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _users.where((test) => _leases.any((element) => element.tid == test.uid)).toList().forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredTenants.add(item);
      });
    } else {
      filteredTenants = _users.where((test) => _leases.any((element) => element.tid == test.uid)).toList();
    }

    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                surfaceTintColor: Colors.transparent,
                backgroundColor: normal,
                pinned: true,
                expandedHeight: currentTenant.uid==""? 220 :240,
                toolbarHeight: 40,
                title: Text(entity.title.toString()),
                actions: [
                  currentTenant.uid==currentUser.uid || currentTenant.uid==""
                      ? SizedBox()
                      : IconButton(
                      onPressed: (){
                        Platform.isAndroid || Platform.isIOS
                            ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: currentTenant), transition: Transition.rightToLeft)
                            : Get.to(() => WebChat(selected: currentTenant), transition: Transition.rightToLeft);
                      },
                      icon: Icon(CupertinoIcons.ellipses_bubble)
                  ),
                  currentTenant.uid==""
                      ? SizedBox()
                      : IconButton(
                          onPressed: (){
                            Get.to(() => Lease(entity: entity, unit: unit, lease: currentLease, tenant: currentTenant), transition: Transition.rightToLeft);
                          },
                          icon: Icon(CupertinoIcons.doc_text)
                        ),
                  isMember || isTenant
                      ? Showcase(
                    key: _keyThree,
                    description: 'Get more options',
                    child: buildButton(),
                    tooltipBackgroundColor: dgColor,
                    textColor: reverse,
                    tooltipPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 5 ),
                    tooltipBorderRadius: BorderRadius.circular(5),
                    descTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  )
                      : SizedBox()
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 40),
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: unit.tid==""&&currentTenant.uid==""?CupertinoColors.activeBlue:color1,
                                          width: 1
                                      ),
                                      color: unit.tid==""&&currentTenant.uid==""
                                          ?CupertinoColors.activeBlue
                                          : paidDeposit!=deposit
                                          ? color1
                                          : accrued > 0
                                          ? Colors.red
                                          : color1,
                                  ),
                                  child: Center(child: Text(unit.title.toString(), style: TextStyle(fontWeight: FontWeight.w600),)),
                                ),
                                Positioned(
                                    right: 5,
                                    bottom: 8,
                                    child: Container(
                                        padding: EdgeInsets.all(1.3),
                                      decoration: BoxDecoration(
                                        color: normal,
                                        borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(width: unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                              ||unit.checked.toString().contains("EDIT") || unit.checked.toString().contains("false")?2:0,),

                                          unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                              ? Icon(CupertinoIcons.delete, color: Colors.red,size: 20,)
                                              : unit.checked.toString().contains("EDIT")
                                              ? Icon(Icons.edit, color: Colors.red,size: 20,)
                                              : unit.checked == "false"
                                              ? Icon(Icons.cloud_upload, color: Colors.red,size: 20,)
                                              : SizedBox(),

                                          SizedBox(width: unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                              ||unit.checked.toString().contains("EDIT") || unit.checked.toString().contains("false")?3:0,),
                                          currentTenant.uid==""
                                              ? SizedBox()
                                              : UserProfile(image: currentTenant.image.toString(), radius: 10,)
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  unit.tid==""
                                      ? Text(
                                          entity.title!.toUpperCase(),
                                            style: TextStyle(fontWeight: FontWeight.w700)
                                        )
                                      : Text(currentTenant.username.toString().toUpperCase(),
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                  Text(
                                      floor == 0
                                        ? "GROUND FLOOR"
                                        : "${TFormat().getOrdinal(floor)} FLOOR"
                                  ),
                                  Text(
                                      room == 0
                                          ? "STUDIO"
                                          : "${room} BEDROOM"
                                  ),
                                  Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(rent)}"),
                                  // currentTenant.uid==""
                                  //     ? SizedBox()
                                  //     : Wrap(
                                  //   runSpacing: 5,
                                  //   spacing: 5,
                                  //   children: [
                                  //     Container(
                                  //       padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                  //       decoration: BoxDecoration(
                                  //           borderRadius: BorderRadius.circular(5),
                                  //           color: color1
                                  //       ),
                                  //       child: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         crossAxisAlignment: CrossAxisAlignment.end,
                                  //         children: [
                                  //           Icon(CupertinoIcons.mail, color: color5,size: 13,),
                                  //           SizedBox(width: 2,),
                                  //           Text(
                                  //             currentTenant.email.toString(),
                                  //             style: TextStyle(color: color5,fontSize: 12),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     ),
                                  //     currentTenant.phone.toString() == "" ? SizedBox() : Container(
                                  //       padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                                  //       decoration: BoxDecoration(
                                  //           borderRadius: BorderRadius.circular(5),
                                  //           color: color1
                                  //       ),
                                  //       child: Row(
                                  //         mainAxisSize: MainAxisSize.min,
                                  //         children: [
                                  //           Icon(CupertinoIcons.phone, color: color5,size:  13),
                                  //           SizedBox(width: 2,),
                                  //           Text(
                                  //             currentTenant.phone.toString(),
                                  //             style: TextStyle(color: color5,fontSize: 12),
                                  //           )
                                  //         ],
                                  //       ),
                                  //     )
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                            lid == ""
                                ? SizedBox()
                                : InkWell(
                              onTap: (){
                                Get.to(()=>CoTenants(unit: unit, lease: currentLease, entity: entity, reload: _getData,),transition: Transition.rightToLeft);
                              },
                              borderRadius: BorderRadius.circular(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Tooltip(
                                    message: 'Click here to see all co-tenants',
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
                                          !_admin.contains(currentUser.uid) || currentLease.lid != unit.lid? SizedBox() : AnimatedPositioned(
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
                                  SizedBox(height: 5,),
                                  Text('Co-Tenants', overflow: TextOverflow.ellipsis, style: TextStyle(color: secondaryColor, fontSize: 10),)
                                ],
                              ),
                            ),
                          ],
                        ),
                        currentTenant.uid==""
                            ? SizedBox()
                            : Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: color1
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.doc_text , color: color5,size: 12,),
                                  SizedBox(width: 2,),
                                  Text(
                                    currentLease.lid.split("-").first.toUpperCase(),
                                    style: TextStyle(color: color5,fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                            start.isEmpty? SizedBox() : Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: color1
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.play_arrow , color: color5,size: 12,),
                                  SizedBox(width: 2,),
                                  Text(
                                    "Begin : ${DateFormat.yMMMEd().format(DateTime.parse(start))}",
                                    style: TextStyle(color: color5,fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                            end.isEmpty? SizedBox() :  Container(
                              padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: color1
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(CupertinoIcons.stop , color: color5,size: 12,),
                                  SizedBox(width: 2,),
                                  Text(
                                    "End : ${DateFormat.yMMMEd().format(DateTime.parse(end))}",
                                    style: TextStyle(color: color5,fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Center(
                          child: currentTenant.uid!=unit.tid.toString().split(",").first
                              ?RichText(
                              text: TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "This lease was terminated on ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: end.isEmpty? "" : DateFormat.yMMMEd().format(DateTime.parse(end)),
                                        style: bold
                                    )
                                  ]
                              )
                          )
                              :unit.tid == ""
                              ? RichText(
                              textAlign: TextAlign.center,
                              text:TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "This unit is currently available for lease. Wish to ",
                                        style: style
                                    ),

                                    WidgetSpan(
                                        child: InkWell(
                                            onTap: (){
                                              isMember
                                                  ? dialogAddTenant(context)
                                                  : dialogRequestLease(context);
                                            },
                                            child: Text(
                                              isMember
                                                  ?"Add Tenant"
                                                  :"Start Leasing",
                                              style: activeBlue,
                                            )
                                        )
                                    ),
                                  ]
                              )
                          )
                              : RichText(
                              textAlign: TextAlign.center,
                              text: paidDeposit < deposit
                                  ? TextSpan(
                                  children: [
                                    TextSpan(
                                        text: depoBalance < deposit? "Record " : "The anticipated ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: "security deposit ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: depoBalance < deposit? "balance of " : "amount is ",
                                        style: style
                                    ),
                                    WidgetSpan(
                                        child: InkWell(
                                          onTap: (){ dialogRecordPayments(context, "DEPOSIT",depoBalance);},
                                          child: Text(
                                              "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(depoBalance)}",
                                              style: activeBlue
                                          ),
                                        )
                                    ),
                                  ]
                              )
                                  : TextSpan(
                                  children: [
                                    TextSpan(
                                        text: "The rent has accrued by ",
                                        style: style
                                    ),
                                    WidgetSpan(
                                        child: InkWell(
                                          onTap: (){},
                                          child: Text(
                                            "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(accrued)} ",
                                            style: activeRed,
                                          ),
                                        )
                                    ),
                                    TextSpan(
                                        text: _accrue.length < 2? "" : " over the past ",
                                        style: style
                                    ),
                                    TextSpan(
                                        text: _accrue.length < 2? "" :"${_accrue.length} ",
                                        style: bold
                                    ),
                                    TextSpan(
                                        text: _accrue.length < 2? "" : "months",
                                        style: style
                                    ),
                                  ]
                              )
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(40),
                  child: currentTenant.uid==""
                      ? Row(
                        children: [
                          SizedBox(width: 10,),
                          Icon(CupertinoIcons.doc_text, size: 20,),
                          Text(
                            '  Leases' ,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      )
                      : Container(
                    width: 500,
                    height: 30,
                    margin: EdgeInsets.only(left: 10, bottom: 0),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      unselectedLabelStyle: const TextStyle(fontSize: 15),
                      labelPadding:  EdgeInsets.zero,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 10,),
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      splashBorderRadius: const BorderRadius.all(Radius.circular(10)),
                      tabs: const [
                        Tab(text: 'Rent',),
                        Tab(text: 'Periods',),
                        Tab(text: 'Payments'),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: currentTenant.uid==""
                    ? Container(
                      height: MediaQuery.of(context).size.height - 35,
                      child: Column(
                        children: [
                          SizedBox(height: 10),
                          Container(
                            width: 500,
                            padding: EdgeInsets.symmetric(horizontal: 8),
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
                            child: SizedBox(width: 1000,
                              child: ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  itemCount: filteredTenants.length,
                                  itemBuilder: (context, index){
                                    UserModel user = filteredTenants[index];

                                    List<LeaseModel> _lease = _leases.where((e) => e.tid == user.uid).toList();
                                    _filtPay = _pay.where((p) => p.tid == user.uid).toList();
                                    var amount = _filtPay.fold(0.0, (previous, element) => previous + double.parse(element.amount.toString()));

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0,),
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                if(expanded.contains(user.uid)){
                                                  expanded = "";
                                                } else {
                                                  expanded = user.uid;
                                                }
                                              });
                                            },
                                            hoverColor: color1,
                                            borderRadius: BorderRadius.circular(5),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                                              child: Row(
                                                children: [
                                                  UserProfile(image: user.image.toString()),
                                                  SizedBox(width: 10,),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(user.username.toString()),
                                                        Text(
                                                          '${user.firstname} ${user.lastname}',
                                                          style: TextStyle(color: secondaryColor, fontSize: 12),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        _admin.contains(user.uid)? "admin" : "",
                                                        style: TextStyle(fontSize: 12, color: Colors.green),
                                                      ),
                                                      Wrap(
                                                        runSpacing: 5,
                                                        spacing: 5,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                                            decoration: BoxDecoration(
                                                                color: color1,
                                                                borderRadius: BorderRadius.circular(5)
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                LineIcon.wallet(size: 12,color: secondaryColor,),
                                                                SizedBox(width: 5,),
                                                                Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}', style: TextStyle(fontSize: 11, color: secondaryColor),)
                                                              ],
                                                            ),
                                                          ),

                                                          _lease.length < 2? SizedBox() :Container(
                                                            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                                            decoration: BoxDecoration(
                                                                color: color1,
                                                                borderRadius: BorderRadius.circular(5)
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(CupertinoIcons.doc_text ,size: 12,color: secondaryColor,),
                                                                SizedBox(width: 5,),
                                                                Text('${_lease.length} leases', style: TextStyle(fontSize: 11, color: secondaryColor),)
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  SizedBox(width: 10,),
                                                  _loading
                                                      ? Container(
                                                      margin: EdgeInsets.only(right: 10),
                                                      width: 20, height: 20,
                                                      child: CircularProgressIndicator(color: reverse, strokeWidth: 3)
                                                  )
                                                      : SizedBox(),
                                                  AnimatedRotation(
                                                    duration: Duration(milliseconds: 500),
                                                    turns: expanded == user.uid ? 0.5 : 0.0,
                                                    child: Icon(Icons.keyboard_arrow_down, color: secondaryColor,),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          AnimatedSize(
                                            duration: Duration(milliseconds: 500),
                                            alignment: Alignment.topCenter,
                                            curve: Curves.easeInOut,
                                            child: expanded ==user.uid
                                                ? Column(
                                              children: [
                                                SizedBox(height: 5,),
                                                IntrinsicHeight(
                                                  child: Row(
                                                    children: [
                                                      BottomCallButtons(
                                                          onTap: () {
                                                            dialogLeases(context, user, _lease);
                                                          },
                                                          icon: Icon(CupertinoIcons.doc_text ,
                                                              color: secondaryColor),
                                                          actionColor: secondaryColor,
                                                          backColor: Colors.transparent,
                                                          title: "Leases"
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                        child: VerticalDivider(
                                                          thickness: 1,
                                                          width: 15,
                                                          color: secondaryColor,
                                                        ),
                                                      ),
                                                      BottomCallButtons(
                                                          onTap: () {
                                                            Get.to(()=>Payments(entity: entity, unit: unit,
                                                              tid: user.uid, lid: "", from: 'unit',),transition: Transition.rightToLeft);
                                                          },
                                                          icon: LineIcon.wallet(color: secondaryColor,),
                                                          actionColor: secondaryColor,
                                                          backColor: Colors.transparent,
                                                          title: "Payments"),

                                                      Platform.isAndroid || Platform.isIOS
                                                          ?  user.uid == currentUser.uid? SizedBox() : Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                        child: VerticalDivider(
                                                          thickness: 1,
                                                          width: 15,
                                                          color: secondaryColor,
                                                        ),
                                                      )
                                                          : SizedBox(),
                                                      Platform.isAndroid || Platform.isIOS? user.uid == currentUser.uid? SizedBox() : BottomCallButtons(
                                                          onTap: () {
                                                            if(user.phone.toString()==""){
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(Data().noPhone),
                                                                    width: 500,
                                                                    showCloseIcon: true,
                                                                  )
                                                              );
                                                            } else {
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text("Feature not available."),
                                                                    showCloseIcon: true,
                                                                  )
                                                              );
                                                            }
                                                          },
                                                          icon: Icon(
                                                            CupertinoIcons.phone,
                                                            color: secondaryColor,
                                                          ),
                                                          actionColor: secondaryColor,
                                                          backColor: Colors.transparent,
                                                          title: "Call") : SizedBox(),
                                                      user.uid == currentUser.uid? SizedBox() :Padding(
                                                        padding: EdgeInsets.symmetric(vertical: 10),
                                                        child: VerticalDivider(
                                                          thickness: 1,
                                                          width: 15,
                                                          color: secondaryColor,
                                                        ),
                                                      ),

                                                      user.uid == currentUser.uid? SizedBox() : BottomCallButtons(
                                                          onTap: () {
                                                            Platform.isAndroid || Platform.isIOS
                                                                ? Get.to(() => MessageScreen(changeMess: _changeMess, updateCount: _updateCount, receiver: user), transition: Transition.rightToLeft)
                                                                : Get.to(() => WebChat(selected: user), transition: Transition.rightToLeft);
                                                          },
                                                          icon: Icon(
                                                            CupertinoIcons.ellipses_bubble,
                                                            color: secondaryColor,
                                                          ),
                                                          actionColor: secondaryColor,
                                                          backColor: Colors.transparent,
                                                          title: "Message"
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                                : SizedBox(),
                                          ),
                                        ],
                                      ),
                                    );

                                  }),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Container(
                  height: MediaQuery.of(context).size.height - 35,
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: SizedBox(width: width,
                                child: GroupedListView(
                                  physics: BouncingScrollPhysics(),
                                  order: GroupedListOrder.DESC,
                                  elements: monthsList,
                                  groupBy: (months) => DateTime(
                                      months.year
                                  ),
                                  groupHeaderBuilder: (MonthModel months) {
                                    final year = months.year.toString();
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.5,
                                              height: 0.5,
                                              color: reverse,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: color2,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              year,
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.5,
                                              height: 0.5,
                                              color: reverse,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  indexedItemBuilder : (BuildContext context, MonthModel month, int index) {
                                    var amount = double.parse(month.amount.toString());
                                    var balance = double.parse(month.amount.toString());
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 5.0,),
                                      child: InkWell(
                                        onTap: (){
                                          Get.to(() => Payments(entity: entity, unit: unit, tid: "", lid: lid, month: month.month.toString(),year: month.year.toString(), type: "RENT", from: 'unit',), transition: Transition.rightToLeft);
                                        },
                                        borderRadius: BorderRadius.circular(5),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: color1,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                amount == 0
                                                    ? CupertinoIcons.circle
                                                    : amount < double.parse(widget.unit.price!)
                                                    ? CupertinoIcons.circle_lefthalf_fill
                                                    :CupertinoIcons.check_mark_circled,
                                                size: 20,
                                                color: amount == double.parse(widget.unit.price!)? Colors.green :secondaryColor,
                                              ),
                                              SizedBox(width: 10,),
                                              Text(
                                                TFormat().toCamelCase(DateFormat.MMMM().format(DateTime(month.year, month.month))),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,fontSize: 15,
                                                  color: amount < double.parse(widget.unit.price!) ? secondaryColor : reverse
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '${amount<=0?"":"+"}${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w700,
                                                        color: amount<=0?secondaryColor:CupertinoColors.activeBlue
                                                    ),
                                                  ),
                                                  amount < double.parse(widget.unit.price!) && double.parse(widget.unit.price!) - amount != rent
                                                      ? Text("Balance : ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.unit.price!) - amount)}",
                                                        style: TextStyle(color: secondaryColor),)
                                                      : SizedBox()
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },

                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              width: 800,
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:  const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 120,
                                      childAspectRatio: 3 / 2,
                                      crossAxisSpacing: 1,
                                      mainAxisSpacing: 1
                                  ),
                                  itemCount: monthsList.length,
                                  itemBuilder: (context, index){
                                    MonthModel monthModel = monthsList[index];
                                    var percent = (monthModel.amount/rent);
                                    return InkWell(
                                      onTap: (){
                                        dialogActivities(context, monthModel, index);
                                      },
                                      borderRadius: BorderRadius.circular(10),
                                      splashColor: CupertinoColors.activeBlue,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: color1,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child:Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              monthModel.monthName.toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(monthModel.year.toString(),
                                              style: TextStyle(color: secondaryColor),
                                            ),
                                            SizedBox(height: 2,),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                              child: LinearPercentIndicator(
                                                animation: true,
                                                lineHeight: 5.0,
                                                animationDuration: 2000,
                                                percent: percent,
                                                barRadius: Radius.circular(50),
                                                linearStrokeCap: LinearStrokeCap.roundAll,
                                                progressColor: CupertinoColors.activeBlue,
                                                backgroundColor: color1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Payments", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                InkWell(
                                    onTap: (){},
                                    borderRadius: BorderRadius.circular(5),
                                    hoverColor: color1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(Icons.filter_list),
                                    )
                                )
                              ],
                            ),
                            Expanded(
                              child: SizedBox(width: 500,
                                child: GroupedListView(
                                  physics: BouncingScrollPhysics(),
                                  order: GroupedListOrder.DESC,
                                  elements: _current,
                                  groupBy: (_filterpay) => DateTime(
                                    DateTime.parse(_filterpay.current.toString()).year,
                                    DateTime.parse(_filterpay.current.toString()).month,
                                    DateTime.parse(_filterpay.current.toString()).day,
                                  ),
                                  groupHeaderBuilder: (PaymentsModel payment) {
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);
                                    final yesterday = today.subtract(Duration(days: 1));
                                    final time = DateTime.parse(payment.current.toString());
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.5,
                                              height: 0.5,
                                              color: reverse,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: color2,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(
                                              time.year == now.year && time.month == now.month && time.day == now.day
                                                  ? 'Today'
                                                  : time.year == yesterday.year && time.month == yesterday.month && time.day == yesterday.day
                                                  ? 'Yesterday'
                                                  : DateFormat.yMMMd().format(time),
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              thickness: 0.5,
                                              height: 0.5,
                                              color: reverse,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  indexedItemBuilder : (BuildContext context, PaymentsModel payment, int index) {
                                    return ItemPay(payments: payment, removePay: _removePay, from: 'Unit', entity: entity,unit:unit ,);
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      ]
                  ),
                ),
              )
            ],
          )
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
                  _admin.contains(currentUser.uid)?
                  RowButton(
                      onTap: (){
                        Navigator.pop(context);
                        dialogEditUnit(context, widget.unit);
                      },
                      icon : Icon(CupertinoIcons.pen), title: "Edit Unit",subtitle: ""
                  ):SizedBox(),

                  _admin.contains(currentUser.uid)?
                  unit.checked.toString().contains("DELETE")
                      ? RowButton(
                          onTap: ()async{
                            Navigator.pop(context);
                            await Data().restoreUnit(context, unit, "DELETE", (){
                              setState(() {});
                              _getData();
                              widget.reload();
                            });
                          },
                          icon : Icon(CupertinoIcons.restart), title: "Undo",subtitle: ""
                      )
                      : RowButton(
                        onTap: (){
                          Navigator.pop(context);
                          dialogRemoveUnit(context, widget.unit);
                        },
                            icon : Icon(CupertinoIcons.delete), title: "Remove Unit",subtitle: ""
                        )
                      : SizedBox(),

                  widget.unit.tid.toString() == ''|| unit.lid!=lid
                      ? SizedBox()
                      : _admin.contains(currentUser.uid) || unit.tid.toString().split(",").first == currentUser.uid
                      ? RowButton(
                          onTap: (){
                            // dialogRemoveTenant(context, widget.unit, "${crrntTenant.firstname} ${crrntTenant.lastname}", crrntTenant.uid);
                            Navigator.pop(context);
                            dialogTerminateLease(context);
                          },
                          icon : Icon(CupertinoIcons.clear_circled), title: "Terminate Lease",subtitle: ""
                      )
                      : SizedBox(),

                  lid == ''
                      ? SizedBox()
                      : currentLease.ctid.toString().contains(currentUser.uid) || _admin.contains(currentUser.uid) || _pids.contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                          Get.to(()=>CoTenants(unit: unit, lease: currentLease, entity: entity, reload: _getData,),transition: Transition.rightToLeft);},
                          icon : Icon(CupertinoIcons.person_2), title: "Co-Tenants",subtitle: ""
                        )
                      : SizedBox(),

                  // _admin.contains(currentUser.uid) || unit.tid.toString().contains(currentUser.uid) || _pids.contains(currentUser.uid)
                  //     ? RowButton(
                  //     onTap: (){
                  //       dialogChargers(context);
                  //     },
                  //     icon : Icon(CupertinoIcons.money_dollar_circle), title: "Cost",subtitle: ""
                  // )
                  //     : SizedBox(),

                  _admin.contains(currentUser.uid) || unit.tid.toString().contains(currentUser.uid) || _pids.contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            // Navigator.pop(context);
                            // dialogRequest(context);
                          },
                          icon : Icon(CupertinoIcons.arrowshape_turn_up_right), title: "Request",subtitle: "", isBeta: true,
                        )
                      : SizedBox(),

                  _admin.contains(currentUser.uid) && unit.lid == currentLease.lid
                      ? RowButton(
                          onTap: (){
                            Get.to(()=>Leases(entity: entity, unit: unit, lease: currentLease,), transition: Transition.rightToLeft);
                          },
                          icon : Icon(CupertinoIcons.doc_text), title: "Leases",subtitle: ""
                      )
                      : SizedBox(),

                  _pids.contains(currentUser.uid) || unit.tid.toString().contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            Get.to(()=>Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid, from: 'unit',), transition: Transition.rightToLeft);
                          },
                          icon : LineIcon.wallet(), title: "Payments",subtitle: ""
                      )
                      : SizedBox(),

                  _pids.contains(currentUser.uid) || unit.tid.toString().contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            Get.to(()=>Report(entity: entity, unitid: widget.unit.id.toString(), tid: currentTenant.uid.toString(), lid: lid,), transition: Transition.rightToLeft);
                          },
                          icon : Icon(CupertinoIcons.graph_square), title: "Reports & Analytics",subtitle: "Beta"
                        )
                      : SizedBox(),
                  Expanded(child: SizedBox()),
                  Container(
                    child: Column(
                      children: [
                        Text("Z E L L I", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10),),
                        SizedBox(height: 5,),
                        Text("S T U D I O 5 I V E", style: TextStyle( color: secondaryColor, fontSize: 10),),
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
      floatingActionButton: currentTenant.uid=="" || currentLease.lid != unit.lid
          ? SizedBox()
          : SpeedDial(
            backgroundColor: CupertinoColors.activeBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            icon: CupertinoIcons.money_dollar,
            overlayOpacity: 0.5,
            animationDuration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            tooltip: "Payments",
            children: [
              if(paidDeposit < deposit)
                SpeedDialChild(
                    child: Icon(CupertinoIcons.lock, size: 20,),
                    shape: CircleBorder(),
                    label: "Deposit"
                ),
              SpeedDialChild(
                  child: Icon(CupertinoIcons.home, size: 20,),
                  shape: CircleBorder(),
                  label: "Rent"
              ),
              SpeedDialChild(
                child: Icon(CupertinoIcons.lightbulb, size: 20,),
                  shape: CircleBorder(),
                label: "Utilities"
              ),
            ],
          ),
    );
  }
  void dialogAddTenant(BuildContext context){
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            )
        ),
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height/2,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return DialogAddTenant(
            unit: widget.unit,
            getUnits: _getData,
            onUpdateTid: (newTid) {
              setState(() {
                widget.unit.tid = newTid;
              });
            }, entity: entity,
          );
        });
  }
  void dialogEditUnit(BuildContext context, UnitModel unitModel){
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width:450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "E D I T"),
              Text(
                '',
                textAlign: TextAlign.center,
                style: TextStyle(color: secondaryColor, ),
              ),
              DialogEditUnit(unit: unitModel, reload: _getData,)
            ],
          ),
        ),
      );
    });
  }
  void dialogRemoveUnit(BuildContext context, UnitModel unitModel){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "R E M O V E"),
              RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Are you sure you wish to remove ",
                          style: TextStyle(color: secondaryColor, ),
                        ),
                        TextSpan(
                          text: "${unitModel.title} ",
                        ),
                        TextSpan(
                          text: "from your entity completely?",
                          style: TextStyle(color: secondaryColor, ),
                        ),
                      ]
                  )
              ),
              DoubleCallAction(
                  titleColor: Colors.red,
                  title: "Remove",
                  action: ()async{
                    await Data().removeUnit(unitModel, widget.reload, context).then((value){
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  })
            ],
          ),
        ),
      );
    });
  }
  void dialogTerminateLease(BuildContext context){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    showDialog(context: context, builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        backgroundColor: dilogbg,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
        ),
        child:  Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "T E R M I N A T E"),
              DialogTerminate(
                unit: unit, lease: currentLease, reload: (){
                widget.reload();
                _getData();
              }, tenant: currentTenant, entity: entity,),
            ],
          ),
        ),
      );
    });
  }
  void dialogLeases(BuildContext context, UserModel user, List<LeaseModel> leases) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    showDialog(context: context, builder: (context){
      return Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5)
        ),
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "L E A S E S"),
              Text(
                'Select a lease item to view detailed information.',
                style: TextStyle( color: secondaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5,),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: leases.length,
                  itemBuilder: (context, index){
                    LeaseModel lease = leases[index];
                    UserModel user = _users.firstWhere((test) => test.uid == lease.tid, orElse: ()=>UserModel(uid: ""));
                    return Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: InkWell(
                        onTap: (){
                          Navigator.push(context, (MaterialPageRoute(builder: (context) => ShowCaseWidget(
                            builder:  (_) => UnitProfile(unit: unit, reload: (){}, removeTenant: (){}, removeFromList: (){}, user: user, leasid: lease.lid, entity: widget.entity,),
                          ))));
                        },
                        splashColor: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5),
                        hoverColor: color1,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: color1,
                                child: Icon(CupertinoIcons.doc_text, color: reverse,),
                              ),
                              SizedBox(width: 10,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${lease.lid.split("-").first.toUpperCase()}"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                          decoration: BoxDecoration(
                                              color: color1,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Text("Start : ${DateFormat.yMMMEd().format(DateTime.parse(lease.start.toString()))}" , style: TextStyle(fontSize: 11, color: secondaryColor),),
                                        ),
                                        lease.end.toString().isEmpty? SizedBox() : Container(
                                          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
                                          decoration: BoxDecoration(
                                              color: color1,
                                              borderRadius: BorderRadius.circular(5)
                                          ),
                                          child: Text("End : ${DateFormat.yMMMEd().format(DateTime.parse(lease.end.toString()))}" , style: TextStyle(fontSize: 11, color: secondaryColor),),
                                        ),
                                      ],
                                    )

                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      );
    });
  }
  void dialogRecordPayments(BuildContext context,String account, double amount){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: account.split("").join(" ").toUpperCase()),
                RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Record ",
                              style: TextStyle(color: secondaryColor)
                          ),
                          TextSpan(
                              text: "tenant ",
                              style: TextStyle(color: secondaryColor)
                          ),
                          TextSpan(
                              text: "${account.toLowerCase()} ",
                              style: TextStyle(color: reverse)
                          ),
                          TextSpan(
                              text: "amount of ",
                              style: TextStyle(color: secondaryColor,)
                          ),
                          TextSpan(
                              text: "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}.",
                              style: TextStyle(color: reverse, )
                          ),
                        ]
                    )
                ),
                SizedBox(height: 5,),
                DialogPay(unit: unit, amount: amount, entity: entity, account: account, reload: _getData, lastPaid: lastPaid,)
              ],
            ),
          ),
        )
    );
  }
  void dialogActivities(BuildContext context, MonthModel month, int index) {
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white70;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final size = MediaQuery.of(context).size;
    final padding = EdgeInsets.symmetric(horizontal: 10);
    List<String> _util = entity.utilities!.split("&");
    List<UtilsModel> _utils = [];

    if (entity.utilities != "") {
      _utils = _util.map((jsonString) => UtilsModel.fromJson(json.decode(jsonString))).toList();
      _utils.removeWhere((element) => element.text == "");
    } else {

      _utils = [];
    }
    List<PaymentsModel> _periodPays = [];
    // _periodPays = _sortedPay.where((element) => DateTime.parse(element.time.toString()).month == monthIndex && DateTime.parse(element.time.toString()).year == year).toList();
    // oldRent = double.parse(widget.unit.price!) -_periodPays.where((pay) => pay.type == "RENT").fold(0, (previousValue, element) => previousValue + double.parse(element.amount!) );
    // oldDepo = double.parse(widget.unit.deposit!) -_periodPays.where((pay) => pay.type == "DEPOSIT").fold(0, (previousValue, element) => previousValue + double.parse(element.amount!));
    // blncRent =  oldRent;
    // blncDepo = oldDepo;

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
            maxHeight: size.height/2 + 100,
            minHeight: size.height/2,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "${month.monthName.toUpperCase().split("").join(" ")} ${month.year.toString().split("").join(" ")}"),
              Padding(
                padding: padding,
                child: Text(
                  'Please click the arrow button to view a comprehensive list of payments associated with each respective account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor),
                ),
              ),
              Expanded(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    index==0
                        ?Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                          Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                            month: month.month.toString(),year: month.year.toString(),type: "DEPOSIT", from: 'unit',),transition: Transition.rightToLeft);
                        },
                        borderRadius: BorderRadius.circular(5),
                        hoverColor: color1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              Icon(CupertinoIcons.padlock),
                              SizedBox(width: 20,),
                              Expanded(child: Text("Security Deposit")),
                              depoBalance == 0
                                  ? Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(deposit)}", style: TextStyle(fontWeight: FontWeight.w600),)
                                  : TextButton(onPressed: (){}, child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(depoBalance)}")),
                              SizedBox(width: 10,),
                              InkWell(
                                onTap: (){Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                                  month: month.month.toString(),year: month.year.toString(),type: "DEPOSIT", from: 'unit',),transition: Transition.rightToLeft);},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                        :SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context);
                          Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                            month: month.month.toString(),year: month.year.toString(),type: "RENT", from: 'unit',),transition: Transition.rightToLeft);
                        },
                        borderRadius: BorderRadius.circular(5),
                        hoverColor: color1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              Icon(CupertinoIcons.home),
                              SizedBox(width: 20,),
                              Expanded(child: Text("Rent")),
                              month.balance==0
                                  ?Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(month.amount)}", style: TextStyle(fontWeight: FontWeight.w600))
                                  :TextButton(onPressed: (){}, child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(month.balance)}")),
                              SizedBox(width: 10),
                              InkWell(
                                onTap: (){Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                                  month: month.month.toString(),year: month.year.toString(),type: "RENT", from: 'unit',),transition: Transition.rightToLeft);},
                                borderRadius: BorderRadius.circular(5),
                                hoverColor: color1,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _utils.length,
                        itemBuilder: (context, index){
                          UtilsModel utils = _utils[index];
                          UtilModel util = Data().utilList.firstWhere((element) => element.text == utils.text);
                          double balance = 0;
                          balance = double.parse(utils.amount) - _periodPays.where((element) => element.type?.toUpperCase() == utils.text.toUpperCase()).fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: (){
                                Navigator.pop(context);
                                Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                                month: month.month.toString(),year: month.year.toString(),type: utils.text, from: 'unit',),transition: Transition.rightToLeft);},
                              borderRadius: BorderRadius.circular(5),
                              hoverColor: color1,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(width: 5,),
                                    util.icon,
                                    SizedBox(width: 20,),
                                    Expanded(child: Text(utils.text)),
                                    balance==0 || balance <0
                                        ?Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}', style: TextStyle(color: secondaryColor),)
                                        :balance==double.parse(utils.amount)
                                        ? TextButton(
                                        onPressed: (){

                                        },
                                        child: Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}"))
                                        :TextButton(
                                        onPressed: (){

                                        },
                                        child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}")),
                                    SizedBox(width: 10,),
                                    InkWell(
                                      onTap: (){},
                                      borderRadius: BorderRadius.circular(5),
                                      hoverColor: color1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                          );
                        })
                  ],
                ),
              )
            ],
          );
        });
  }
  void dialogUtil(BuildContext context){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size = MediaQuery.of(context).size;
    List<String> _util = entity.utilities!.split("&");
    List<UtilsModel> _utils = [];
    if (entity.utilities!="") {
      _utils = _util.map((jsonString) => UtilsModel.fromJson(json.decode(jsonString))).toList();
      _utils.removeWhere((element) => element.text=="");
    } else {
      _utils = [];
    }
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )
        ),
        backgroundColor: bgColor,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height - 100,
            minHeight: size.height/2 + 100,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "U T I L I T I E S"),
              _utils.length == 0
                  ? SizedBox(height: size.height/2 ,width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber, color: Colors.yellow,size: 50,),
                    SizedBox(height: 10,),
                    Text(
                      "This property currently lacks utility configuration. To establish utility services, kindly navigate to your property menu and access the utilities section",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryColor),
                    ),
                    SizedBox(height: 10,),
                    OutlinedButton(onPressed: (){Navigator.pop(context);}, child: Text("CLOSE"))
                  ],
                ),
              )
                  : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _utils.length,
                  itemBuilder: (context, index){
                    UtilsModel utils = _utils[index];
                    UtilModel util = Data().utilList.firstWhere((element) => element.text == utils.text);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: InkWell(
                        onTap: (){
                          dialogRecordPayments(context, utils.text, double.parse(utils.amount));
                        },
                        borderRadius: BorderRadius.circular(5),
                        hoverColor: color1,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              util.icon,
                              SizedBox(width: 20,),
                              Expanded(child: Text(utils.text)),
                              Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}", style: TextStyle(color: secondaryColor),),
                              SizedBox(width: 10,),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })
            ],
          );
        });
  }
  void dialogChargers(BuildContext context){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white12
        : Colors.black12;
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final size = MediaQuery.of(context).size;
    List<String> _util = entity.utilities!.split("&");
    List<UtilsModel> _utils = [];
    if (entity.utilities!="") {
      _utils = _util.map((jsonString) => UtilsModel.fromJson(json.decode(jsonString))).toList();
    } else {
      _utils = [];
    }
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            )
        ),
        backgroundColor: bgColor,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        constraints: BoxConstraints(
            maxHeight: size.height/2 + 100,
            minHeight: size.height/2,
            maxWidth: 500,minWidth: 400
        ),
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DialogTitle(title: "C H A R G E S"),
              Expanded(
                child: ListView.builder(
                    itemCount: Data().charge.length,
                    itemBuilder: (context, index){
                      ChargeModel charge = Data().charge[index];
                      return ListTile(
                        onTap: (){
                          // dialogPayCharge(context, charge.title);
                        },
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: color1,
                          child: Icon(Icons.money_off),
                        ),
                        title: Text(charge.title),
                        subtitle: Text(charge.message, style: TextStyle(fontSize: 11, color: secondaryColor),),
                        trailing: Icon(Icons.chevron_right),
                      );
                    }),
              )
            ],
          );
        });
  }
  void dialogRequestLease(BuildContext context){
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    showDialog(
        context: context,
        builder: (context) => Dialog(
          alignment: Alignment.center,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
          child: Container(
            width: 450,
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: 'R E Q U E S T'),
                RichText(
                  textAlign: TextAlign.center,
                    text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Would you like to submit a request to initiate the lease for unit ",
                              style: TextStyle(color: secondaryColor)
                          ),

                          TextSpan(
                              text: "${unit.title}.",
                              style: TextStyle(color: reverse)
                          ),
                        ]
                    )
                ),
                DialogTntRq(entity: entity, unit: unit,),
              ],
            ),
          ),
        )
    );
  }
  void dialogRequest(BuildContext context){
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('R E Q U E S T'),
        message: Text('Please select one of the following options:'),
        actions: [
          // Convert Iterable to a list using `toList()`
          ...Data().requests.map((e) => CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => CreateRequest(request: e, entity: entity, unit: unit,),transition: Transition.rightToLeft);
            },
            child: Row(
              children: [
                Icon(e.icon, color: secondaryColor),
                SizedBox(width: 10),
                Text('${e.text}', style: TextStyle(color: secondaryColor)),
              ],
            ),
          )).toList(),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          child: Text('Cancel'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _addPay(PaymentsModel paymentsModel, double paid, String account){
    print("Payment adding");
    _pay.add(paymentsModel);
    _rent.add(paymentsModel);
    _current.add(paymentsModel);
    setState(() {
    });
  }
  void changeMessage(MessModel messModel){
  }
  void _updatePay(String payid){
    print("Payment updating");
    _pay.firstWhere((pay) => pay.payid == payid).checked = "true";
    _current.firstWhere((pay) => pay.payid == payid).checked = "true";
    _getPayments();
  }
  void _removePay(){
  }
  void _updateCount(){}
  void _changeMess(MessModel messModel){}
}

class buildButton extends StatelessWidget {
  const buildButton({super.key});

  @override
  Widget build(BuildContext context) {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return InkWell(
        onTap: (){
          Scaffold.of(context).openEndDrawer();
        },
        hoverColor: color1,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(Icons.menu, size: 28,),
        ));
  }
}
