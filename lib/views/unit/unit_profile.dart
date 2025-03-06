import 'dart:convert';
import 'dart:io';

import 'package:Zelli/home/tabs/payments.dart';
import 'package:Zelli/main.dart';
import 'package:Zelli/models/billing.dart';
import 'package:Zelli/models/entities.dart';
import 'package:Zelli/models/payments.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/views/property/activities/leases.dart';
import 'package:Zelli/views/unit/activities/co_tenants.dart';
import 'package:Zelli/views/unit/activities/create_request.dart';
import 'package:Zelli/views/unit/activities/lease.dart';
import 'package:Zelli/views/unit/activities/pay_screen.dart';
import 'package:Zelli/views/unit/activities/terminate.dart';
import 'package:Zelli/views/unit/activities/unit_billing.dart';
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
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../../home/actions/chat/message_screen.dart';
import '../../home/actions/chat/web_chat.dart';
import '../../home/tabs/report.dart';
import '../../models/account.dart';
import '../../models/charge.dart';
import '../../models/data.dart';
import '../../models/messages.dart';
import '../../models/month_model.dart';
import '../../models/lease.dart';
import '../../models/units.dart';
import '../../models/util.dart';
import '../../models/utils.dart';
import '../../resources/services.dart';
import '../../test/test_unit.dart';
import '../../utils/colors.dart';
import '../../widgets/buttons/bottom_call_buttons.dart';
import '../../widgets/buttons/call_actions/double_call_action.dart';
import '../../widgets/cards/row_button.dart';
import '../../widgets/dialogs/dialog_add_tenant.dart';
import '../../widgets/dialogs/dialog_edit_unit.dart';
import '../../widgets/dialogs/dialog_title.dart';
import '../../widgets/dialogs/unit_dialogs/dialog_terminate.dart';
import '../../widgets/dialogs/unit_dialogs/dialog_tnt_rq.dart';
import '../../widgets/items/item_pay.dart';
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
  List<MonthModel> _prepayment = [];
  List<MonthModel> monthsList = [];
  List<LeaseModel> _leases = [];
  List<BillingModel> _bills = [];
  List<BillingModel> _newBills = [];
  List<AccountModel> _accounts = [];

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
  double balance = 0;
  double accrued = 0;
  double prepaid = 0;
  double percentage = 0;

  late DateTime startDate;
  late DateTime endDate;
  DateTime currentMonth = DateTime.now();

  String start = "";
  String end = "";
  String expanded = "";
  String lid = "";

  bool _loading = false;
  bool isFilled = false;
  bool isMember = false;
  bool isAdmin = false;
  bool isTenant = false;
  bool isCoTenant = false;
  bool isBilled = false;

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
    _getBilling();

    _accrue = monthsList.where((test)=>test.balance!=0.0).toList();
    _prepayment = monthsList.where((test) => DateTime(test.year, test.month).isAfter(DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString())))).toList();
    accrued = _accrue.fold(0.0, (previous, element) => previous + element.balance);
    prepaid = _prepayment.fold(0.0, (previous, element) => previous + element.amount);

    if(prepaid>0){
      if(prepaid<rent){
        percentage = (prepaid/rent);
      } else {
        percentage = 1;
      }
    } else if(accrued>0){
      if(accrued<rent){
        percentage = 1 - ((accrued/rent));
      } else {
        percentage = 1;
      }
    }

    lastPaid = monthsList.firstWhere((test) => double.parse(test.amount.toString()) != rent,
        orElse: ()=>monthsList.last);

    if(monthsList.last.year == DateTime.now().year && monthsList.last.month == DateTime.now().month && monthsList.last.amount == rent){
      balance = rent;

    } else if (monthsList.last.year >= DateTime.now().year && monthsList.last.month > DateTime.now().month ){
      balance = monthsList.last.balance == 0? rent : monthsList.last.balance;
    }

    monthsList.forEach((mnth){
      print("${mnth.month}:${mnth.monthName}${mnth.year}, Amount : ${mnth.amount}, Bal : ${mnth.balance}");
    });
    print("DATA FETCHED");
    setState(() {
    });
  }

  _getEntity(){
    entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).toList().firstWhere((test)=> test.eid == unit.eid, orElse: ()=> widget.entity);
    _admin = entity.admin.toString().split(",");
    _pids = entity.pid.toString().split(",");
    isMember = entity.pid.toString().split(",").contains(currentUser.uid);
    isAdmin = entity.admin.toString().split(",").contains(currentUser.uid);
    isTenant = unit.tid.toString().contains(currentUser.uid);
    isCoTenant = currentLease.ctid.toString().contains(currentUser.uid);
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

    currentLease = _leases.firstWhere((test) => test.lid == lid, orElse: ()=>LeaseModel(
        lid: "", tid: "", start: "", end: "", deposit: "0.0", rent: "0.0"
    ));
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

    deposit = double.parse(currentTenant.uid.toString().isNotEmpty
        ? currentLease.deposit.toString()
        : unit.deposit.toString());
    rent = double.parse(currentTenant.uid.toString().isNotEmpty? currentLease.rent.toString() : unit.price.toString());
  }

  _getUnit(){
    unit = myUnits.map((jsonString) => UnitModel.fromJson(json.decode(jsonString))).firstWhere((test) => test.id==widget.unit.id, orElse: ()=>widget.unit);
    floor = int.parse(unit.floor.toString());
    room = int.parse(unit.room.toString());
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

  _getBilling(){  
    _bills = myBills.map((jsonString) => BillingModel.fromJson(json.decode(jsonString))).where((test) => test.eid ==widget.unit.eid).toList();
    _bills.forEach((bill) {
      // if (bill.type == 'Different') {
      //   bill.accountno
      //       .split('*')
      //       .where((jsonString) => jsonString.isNotEmpty)
      //       .map((jsonString) => AccountModel.fromJson(json.decode(jsonString)))
      //       .forEach((account) {
      //     // Check for duplicates before adding
      //     if (!_accounts.any((existing) =>
      //     existing.bid == account.bid &&
      //         existing.uid == account.uid &&
      //         existing.accountno == account.accountno &&
      //         existing.account == account.account)) {
      //       if(account.uid == unit.id){
      //         _accounts.add(account);
      //       }
      //     }
      //   });
      // }
      // else {
      //   // Create AccountModel for single account
      //   final account = AccountModel(
      //     bid: bill.bid,
      //     uid: unit.id!,
      //     accountno: bill.accountno,
      //     account: bill.account,
      //   );
      //
      //   // Check for duplicates before adding
      //   if (!_accounts.any((existing) =>
      //   existing.bid == account.bid &&
      //       existing.uid == account.uid &&
      //       existing.accountno == account.accountno &&
      //       existing.account == account.account)) {
      //     _accounts.add(account);
      //   }
      // }
      bill.access
          .split('*')
          .where((jsonString) => jsonString.isNotEmpty)
          .map((jsonString) => AccountModel.fromJson(json.decode(jsonString)))
          .forEach((account) {
        // Check for duplicates before adding
        if (!_accounts.any((existing) =>
        existing.bid == account.bid &&
            existing.uid == account.uid &&
            existing.accountno == account.accountno &&
            existing.account == account.account)) {
          if(account.uid == unit.id){
            _accounts.add(account);
          }
        }
      });
    });
    isBilled = _accounts.any((test) => test.account.contains('Rent'))?true:false;
    _accounts.forEach((e){
      print(e.toJson());
    });
  }

  void _listMonth() {
    DateTime firstEnteredDate = unit.lid.toString().isEmpty && currentLease.lid.isEmpty
        ? DateTime.now()
        : DateTime.parse(currentLease.start.toString());

    DateTime lastRentDate = _rent.isEmpty
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString()))
        : DateTime.parse(_rent.last.time.toString());

    startDate = DateTime(firstEnteredDate.year, firstEnteredDate.month, int.parse(entity.due.toString()));
    endDate = lastRentDate.isBefore(currentMonth)
        ? DateTime(currentMonth.year, currentMonth.month, int.parse(entity.due.toString()))
        : DateTime(lastRentDate.year, lastRentDate.month, int.parse(entity.due.toString()));

    List<ExcessMonth> excessMonthList = [];
    monthsList = generateMonthsList(startDate, endDate, excessMonthList);

    distributeExcessToMonths(excessMonthList);
  }

  List<MonthModel> generateMonthsList(DateTime startDate, DateTime endDate, List<ExcessMonth> excessMonthList) {
    List<MonthModel> monthList = [];
    double remainingBalance = 0.0;

    for (DateTime date = startDate;
    date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
    date = DateTime(date.year, date.month + 1, 1)) {

      double totalAmountPaid = 0.0;
      double monthlyBalance = rent;

      var currentMonthPayments = _rent.where((payment) {
        List<String> times = payment.time!.split(',');
        DateTime paymentStart = DateTime.parse(times.first);
        DateTime paymentEnd = times.length > 1 ? DateTime.parse(times.last) : paymentStart;

        return (paymentStart.year == date.year && paymentStart.month == date.month) ||
            (paymentEnd.year == date.year && paymentEnd.month == date.month) ||
            (paymentStart.isBefore(date) && paymentEnd.isAfter(date));
      }).toList();

      for (var payment in currentMonthPayments) {
        double paymentAmount = double.parse(payment.amount!);

        if (date.month == DateTime.parse(payment.time!.split(',').first).month &&
            date.year == DateTime.parse(payment.time!.split(',').first).year) {
          paymentAmount += remainingBalance;
          remainingBalance = 0;
        }

        if (paymentAmount > monthlyBalance) {
          excessMonthList.add(ExcessMonth(amount: paymentAmount - monthlyBalance, time: date));
          totalAmountPaid += monthlyBalance;
          break;
        } else {
          totalAmountPaid += paymentAmount;
          monthlyBalance -= paymentAmount;
        }
      }

      monthList.add(MonthModel(
        year: date.year,
        month: date.month,
        monthName: DateFormat('MMM').format(date),
        amount: totalAmountPaid,
        balance: monthlyBalance,
      ));
    }

    return monthList;
  }

  void distributeExcessToMonths(List<ExcessMonth> excessMonthList) {
    for (var excess in excessMonthList) {
      double remainingExcess = excess.amount;

      for (var month in monthsList) {
        if (month.amount < rent) {
          double fillAmount = rent - month.amount;

          if (remainingExcess >= fillAmount) {
            month.amount += fillAmount;
            month.balance -= fillAmount;  // Adjust the balance accordingly
            remainingExcess -= fillAmount;
          } else {
            month.amount += remainingExcess;
            month.balance -= remainingExcess;  // Adjust the balance accordingly
            remainingExcess = 0;
            break;
          }
        }
      }

      // Handle any remaining excess after filling existing months
      while (remainingExcess > 0) {
        DateTime lastDate = DateTime(monthsList.last.year, monthsList.last.month);
        DateTime newMonthDate = DateTime(lastDate.year, lastDate.month + 1, 1);

        double fillAmount = remainingExcess >= rent ? rent : remainingExcess;
        monthsList.add(MonthModel(
          year: newMonthDate.year,
          month: newMonthDate.month,
          monthName: DateFormat('MMM').format(newMonthDate),
          amount: fillAmount,
          balance: rent - fillAmount,  // Balance should be adjusted here as well
        ));

        remainingExcess -= fillAmount;
      }
    }
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
    final active = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: reverse);
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
                expandedHeight: isAdmin? isBilled? 220 : 300 : 220,
                toolbarHeight: 40,
                title: Text(
                    entity.title.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
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
                        Get.to(() => Lease(entity: entity, unit: unit, lease: currentLease,
                          tenant: currentTenant, reload: _getData, accrued: accrued, prepaid: prepaid, depositPaid: paidDeposit,), transition: Transition.rightToLeft);
                      },
                      icon: Icon(CupertinoIcons.doc_text)
                  ),
                  isMember || isTenant || currentLease.lid.isNotEmpty
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
                                unit.tid=="" && currentTenant.uid==""
                                    ? Container(
                                  width: 100,
                                  height: 100,
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: CupertinoColors.activeBlue,
                                        width: 1
                                    ),
                                    color: CupertinoColors.activeBlue,
                                  ),
                                  child: Center(child: Text(unit.title.toString(), style: TextStyle(fontWeight: FontWeight.w600),)),
                                )
                                    : Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.symmetric(vertical: 5),
                                      child: LiquidLinearProgressIndicator(
                                        value: percentage,
                                        valueColor: AlwaysStoppedAnimation(
                                          paidDeposit!=deposit
                                              ? color1
                                              : accrued > 0 && prepaid == 0
                                              ? Colors.red
                                              : prepaid > 0
                                              ? Colors.green
                                              : color1,
                                        ),
                                        backgroundColor: Colors.black12,
                                        borderColor: color5,
                                        borderWidth: 0,
                                        borderRadius: 10.0,
                                        direction: Axis.vertical,
                                        center: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(unit.title.toString(), style: TextStyle(fontWeight: FontWeight.w600),),
                                            percentage >= 1 || percentage == 0
                                                ? SizedBox()
                                                : Text('${(percentage*100).toStringAsFixed(0)}%',
                                              style: TextStyle(color: color5),),
                                          ],
                                        ),
                                      ),
                                    ),
                                Positioned(
                                    right: 5,
                                    bottom: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(1.3),
                                      decoration: BoxDecoration(
                                          color: dgColor,
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                                ||unit.checked.toString().contains("EDIT") || unit.checked.toString().contains("false") && isMember?2:0,),

                                          unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                              ? Icon(CupertinoIcons.delete, color: Colors.red,size: 20,)
                                              : unit.checked.toString().contains("EDIT")
                                              ? Icon(Icons.edit, color: Colors.red,size: 20,)
                                              : unit.checked == "false" && isMember
                                              ? Icon(Icons.cloud_upload, color: Colors.red,size: 20,)
                                              : SizedBox(),

                                          SizedBox(width: unit.checked.toString().contains("DELETE") || unit.checked.toString().contains("REMOVED")
                                              ||unit.checked.toString().contains("EDIT") || unit.checked.toString().contains("false") && isMember?3:0,),
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
                                      entity.title.toString().toUpperCase(),
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

                                ],
                              ),
                            ),
                            unit.tid=="" && currentTenant.uid==""
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
                                                currentLease.lid == unit.lid
                                                    ?_admin.contains(currentUser.uid) || unit.tid==currentUser.uid
                                                    ? AnimatedPositioned(
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
                                                )
                                              : SizedBox()
                                              : SizedBox(),
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
                        SizedBox(height: 10),
                        isAdmin ?
                        isBilled
                            ? SizedBox()
                            : Center(
                              child: Container(
                                  width: 500,
                                  margin: EdgeInsets.only(bottom: 10),
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(5)
                                ),
                                  child: Row(
                                  children: [
                                    Icon(CupertinoIcons.creditcard, color: Colors.red,),
                                    SizedBox(width: 10,),
                                    Expanded(
                                      child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: 'This unit has not yet been configured with a payment gateway. Please set up a payment gateway to enable seamless transactions and efficient payment processing. ',
                                                style: TextStyle(color: secondaryColor, fontSize: 13)
                                              ),
                                              WidgetSpan(
                                                  child: InkWell(
                                                      onTap: (){
                                                        Get.to(()=>UnitBilling(entity: entity, unit: unit, reload: _getData,), transition: Transition.rightToLeft);
                                                      },
                                                      child : Text("Get started.",
                                                        style: TextStyle(color: CupertinoColors.activeBlue, fontWeight: FontWeight.w800),
                                                    )
                                                  )
                                              )
                                            ]
                                          )
                                      ),
                                    ),
                                    InkWell(
                                        onTap: (){
                                          setState(() {
                                            isBilled = true;
                                          });
                                        },
                                        child: Icon(Icons.close, color: secondaryColor,)
                                    )
                                  ],
                                  ),
                              ),
                            )
                            : SizedBox(),
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
                                              onTap: (){

                                                if(isCoTenant){
                                                  Get.to(() => PayScreen(
                                                      entity: entity,
                                                      unit: unit,
                                                      reload: _getData,
                                                      lease: currentLease,
                                                      amount: depoBalance,
                                                      account: "DEPOSIT",
                                                      cost: "Fixed",
                                                      isMax: true,
                                                      lastPaid: lastPaid
                                                  ), transition: Transition.rightToLeft);
                                                } else {
                                                  dialogRecordPayments(context, "DEPOSIT",depoBalance, "Fixed",true, lastPaid);
                                                }
                                                },
                                              child: Text(
                                                  "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(depoBalance)}",
                                                  style: activeBlue
                                              ),
                                            )
                                        ),
                                      ]
                                  )
                                      : accrued > 0 && prepaid == 0
                                      ?TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "The rent has accrued by ",
                                            style: style
                                        ),
                                        WidgetSpan(
                                            child: InkWell(
                                              onTap: (){

                                                if(isCoTenant){
                                                  Get.to(() => PayScreen(
                                                      entity: entity,
                                                      unit: unit,
                                                      reload: _getData,
                                                      lease: currentLease,
                                                      amount: accrued,
                                                      account: "RENT",
                                                      cost: "Fixed",
                                                      isMax: false,
                                                      lastPaid: lastPaid
                                                  ), transition: Transition.rightToLeft);
                                                } else {
                                                  dialogRecordPayments(context, "RENT",accrued, "Fixed",false, lastPaid);
                                                }
                                              },
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
                                      : prepaid > 0
                                      ? TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "Rent prepaid by ",
                                            style: style
                                        ),
                                        WidgetSpan(
                                            child: Text(
                                              "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(prepaid)} ",
                                              style: active,
                                            )
                                        ),
                                        TextSpan(
                                            text: _prepayment.length < 2? "." : "for the next ",
                                            style: style
                                        ),
                                        TextSpan(
                                            text: _prepayment.length < 2? "" :"${_prepayment.length} ",
                                            style: bold
                                        ),
                                        TextSpan(
                                            text: _prepayment.length < 2? "" : "months",
                                            style: style
                                        ),
                                      ]
                                  )
                                      : TextSpan(
                                      children: [
                                        TextSpan(
                                            text: "All rent payments are currently up to date.",
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
                                                          : amount < rent
                                                          ? CupertinoIcons.circle_lefthalf_fill
                                                          :CupertinoIcons.check_mark_circled,
                                                      size: 20,
                                                      color: amount == rent && amount != 0? Colors.green :secondaryColor,
                                                    ),
                                                    SizedBox(width: 10,),
                                                    Text(
                                                      TFormat().toCamelCase(DateFormat.MMMM().format(DateTime(month.year, month.month))),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,fontSize: 15,
                                                        color: amount < rent ? secondaryColor : reverse
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
                                                        amount < rent && rent - amount != rent
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
                              Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid, from: '',)
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

                            Navigator.pop(context);
                            Get.to(() => Terminate(entity: entity, tenant: currentTenant, unit: unit, lease: currentLease,
                            accrued: accrued,prepaid: prepaid,depositPaid: paidDeposit, reload: _getData,), transition: Transition.rightToLeft);
                            },
                          icon : Icon(CupertinoIcons.clear_circled), title: "Terminate Lease",subtitle: ""
                      )
                      : SizedBox(),

                  lid == ''
                      ? SizedBox()
                      : currentLease.ctid.toString().contains(currentUser.uid) || currentLease.tid.toString().contains(currentUser.uid)
                      || _admin.contains(currentUser.uid)
                      || _pids.contains(currentUser.uid)
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

                  _admin.contains(currentUser.uid)
                      || unit.tid.toString().contains(currentUser.uid)
                      || _pids.contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            // Navigator.pop(context);
                            // dialogRequest(context);
                          },
                          icon : Icon(CupertinoIcons.arrowshape_turn_up_right), title: "Request",subtitle: "", isBeta: true,
                        )
                      : SizedBox(),

                  isMember && unit.lid == currentLease.lid
                      ?  RowButton(
                          onTap: (){
                            Get.to(()=>Leases(entity: entity, unit: unit, lease: currentLease,), transition: Transition.rightToLeft);
                          },
                          icon : Icon(CupertinoIcons.doc_text), title: "Leases",subtitle: ""
                      )
                      : SizedBox(),

                  _pids.contains(currentUser.uid) || currentLease.tid.toString().contains(currentUser.uid)
                      || currentLease.ctid.toString().contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            Get.to(()=>Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid, from: 'unit',), transition: Transition.rightToLeft);
                          },
                          icon : LineIcon.wallet(), title: "Payments",subtitle: ""
                      )
                      : SizedBox(),

                  isAdmin? RowButton(
                      onTap: (){
                            Get.to(()=>UnitBilling(entity: entity, unit: unit, reload: _getData,), transition: Transition.rightToLeft);
                          },
                          icon : Icon(CupertinoIcons.creditcard), title: "Billing",subtitle: ""
                      )
                      : SizedBox(),

                  _pids.contains(currentUser.uid) || unit.tid.toString().contains(currentUser.uid)
                      || currentLease.tid.toString().contains(currentUser.uid)
                      || currentLease.ctid.toString().contains(currentUser.uid)
                      ? RowButton(
                          onTap: (){
                            Get.to(()=>Report(entity: entity, unitid: widget.unit.id.toString(), tid: currentTenant.uid.toString(), lid: lid,), transition: Transition.rightToLeft);
                          },
                          icon : Icon(CupertinoIcons.chart_bar_alt_fill), title: "Reports & Analytics",subtitle: "Beta"
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
      floatingActionButton: currentLease.lid != unit.lid
          ? SizedBox()
          :  unit.lid.toString().isEmpty
          ?  FloatingActionButton(
              onPressed: (){
                isMember
                    ? dialogAddTenant(context)
                    : dialogRequestLease(context);
              },
              child: Icon(CupertinoIcons.add),
            )
          : SpeedDial(
              backgroundColor: CupertinoColors.activeBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              icon: CupertinoIcons.money_dollar,
              overlayOpacity: 0.7,
              curve: Curves.easeInOut,
              tooltip: "Payments",
              spaceBetweenChildren: 10,
              children: [
                if(paidDeposit < deposit)
                  SpeedDialChild(
                      child: Icon(CupertinoIcons.lock, size: 20,),
                      shape: CircleBorder(),
                      label: "Deposit",
                      onTap: (){
                        if(isCoTenant){
                          Get.to(() => PayScreen(
                              entity: entity,
                              unit: unit,
                              reload: _getData,
                              lease: currentLease,
                              amount: depoBalance,
                              account: "DEPOSIT",
                              cost: "Fixed",
                              isMax: true,
                              lastPaid: lastPaid
                          ), transition: Transition.rightToLeft);
                        } else {
                          dialogRecordPayments(context, "DEPOSIT", depoBalance, "Fixed",true, lastPaid);
                        }
                      }
                  ),
                SpeedDialChild(
                    child: Icon(CupertinoIcons.home, size: 20,),
                    shape: CircleBorder(),
                    label: "Rent",
                    onTap: (){

                        if(isCoTenant){
                          Get.to(() => PayScreen(
                              entity: entity,
                              unit: unit,
                              reload: _getData,
                              lease: currentLease,
                              amount: accrued,
                              account: "RENT",
                              cost: "Fixed",
                              isMax: false,
                              lastPaid: lastPaid
                          ), transition: Transition.rightToLeft);
                        } else {
                          dialogRecordPayments(context, "RENT", accrued,  "Fixed",false,lastPaid);
                        }
                    }
                ),
                SpeedDialChild(
                  child: Icon(CupertinoIcons.lightbulb, size: 20,),
                    shape: CircleBorder(),
                  label: "Utilities",
                  onTap: (){
                    dialogUtil(context);
                  }
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
                            builder:  (_) => UnitProfile(
                              unit: unit, reload: (){}, removeTenant: (){},
                              removeFromList: (){}, user: user, leasid: lease.lid, entity: widget.entity,),
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
  void dialogRecordPayments(BuildContext context,String account, double amount, String cost, bool ismax, MonthModel monthmodel){
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
                DialogPay(
                  unit: unit,
                  lease: currentLease,
                  amount: amount,
                  entity: entity,
                  account: account,
                  reload: _getData,
                  lastPaid: monthmodel,
                  cost: cost, isMax: ismax,
                )
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
    // oldRent = rent -_periodPays.where((pay) => pay.type == "RENT").fold(0, (previousValue, element) => previousValue + double.parse(element.amount!) );
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
                  'Please click the any item to view a comprehensive list of payments associated with each respective account.',
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
                              unit.lid != currentLease.lid
                                  ? Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paidDeposit)}', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600))
                                  : depoBalance == 0
                                  ? Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(deposit)}", style: TextStyle(fontWeight: FontWeight.w600),)
                                  : TextButton(
                                      onPressed: (){
                                        Navigator.pop(context);
                                        dialogRecordPayments(context, "DEPOSIT", depoBalance,  "Fixed",true,month);
                                      },
                                      child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(depoBalance)}")
                                    ),
                              SizedBox(width: 10,),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                              ),
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
                              unit.lid != currentLease.lid
                                  ? Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(month.amount)}', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600))
                                  : month.balance==0
                                  ?Text("${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(month.amount)}", style: TextStyle(fontWeight: FontWeight.w600))
                                  :TextButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                    dialogRecordPayments(context, "RENT", month.balance,  "Fixed",true, month);
                                  },
                                  child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(month.balance)}")),
                              SizedBox(width: 10),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                              ),
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
                          double amnt = utils.amount.isEmpty? 0.0 : double.parse(utils.amount);
                          double paid = _pay.where((element) => element.type?.toUpperCase() == util.text.toUpperCase() 
                              && DateTime.parse(element.time.toString()).year == month.year && DateTime.parse(element.time.toString()).month ==  month.month)
                              .fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
                          double balance = utils.cost == 'Variable'? 0.0 : double.parse(utils.amount) - paid;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: InkWell(
                              onTap: (){
                                Get.to(()=> Payments(entity: entity, unit: unit, tid: "", lid: currentLease.lid,
                                month: month.month.toString(),year: month.year.toString(), type: utils.text, from: 'unit',),transition: Transition.rightToLeft);},
                              borderRadius: BorderRadius.circular(5),
                              hoverColor: color1,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  children: [
                                    SizedBox(width: 5,),
                                    Icon(util.icon),
                                    SizedBox(width: 20,),
                                    Expanded(child: Text(utils.text)),
                                    unit.lid != currentLease.lid
                                        ? Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}',
                                          style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600))
                                        : utils.cost == 'Variable'
                                         ? TextButton(
                                             onPressed: (){
                                               Navigator.pop(context);
                                               dialogRecordPayments(context, util.text, 0, utils.cost, false, month);
                                             },
                                             child: Text('VC ● ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)} ● ${utils.period}',)
                                         ) : paid == amnt
                                        ? Text(
                                            '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          )
                                        : balance==amnt
                                        ? TextButton(
                                        onPressed: (){
                                          Navigator.pop(context);
                                          dialogRecordPayments(context, util.text, double.parse(utils.amount), utils.cost, true, month);
                                        },
                                        child: Text(" ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}"))
                                        :TextButton(
                                          onPressed: (){
                                            Navigator.pop(context);
                                            dialogRecordPayments(context, util.text, balance, utils.cost, true, month);
                                          },
                                          child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}")),

                                     // unit.lid != currentLease.lid
                                     //     ? Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}', style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600))
                                     //     : balance <=0
                                     //    ?utils.cost == 'Variable'
                                     //    ? TextButton(
                                     //        onPressed: (){
                                     //          Navigator.pop(context);
                                     //          dialogRecordPayments(context, util.text, 0, utils.cost, false);
                                     //        },
                                     //        child: Text('Variable Cost ● ${utils.period}',)
                                     //    )
                                     //    : Text(
                                     //      '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}',
                                     //       style: TextStyle(color: secondaryColor),
                                     //     )
                                     //    : balance==amnt
                                     //    ? TextButton(
                                     //    onPressed: (){
                                     //      Navigator.pop(context);
                                     //      dialogRecordPayments(context, util.text, double.parse(utils.amount), utils.cost, true);
                                     //    },
                                     //    child: Text(" ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}"))
                                     //    :TextButton(
                                     //    onPressed: (){
                                     //
                                     //    },
                                     //    child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}")),


                                    // TextButton(
                                    //     onPressed: (){},
                                    //     child: Text(
                                    //       balance <= 0
                                    //           ? utils.cost == 'Variable'? 'Variable Cost ● ${utils.period}' : '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}'
                                    //           : balance==amnt
                                    //           ? "${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}"
                                    //           : 'Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}',
                                    //       style: TextStyle(
                                    //           color: unit.lid != currentLease.lid
                                    //               ? secondaryColor
                                    //               : balance==amnt
                                    //               ? Colors.white
                                    //               : CupertinoColors.activeBlue
                                    //
                                    //       ),
                                    //     )
                                    // ),
                                    SizedBox(width: 10,),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                                    ),
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
                  :   ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _utils.length,
                  itemBuilder: (context, index){
                    UtilsModel utils = _utils[index];
                    UtilModel util = Data().utilList.firstWhere((element) => element.text == utils.text);
                    MonthModel month = MonthModel(year: currentMonth.year, monthName: "", month: currentMonth.month, amount: 0, balance: 0);
                    double amnt = utils.amount.isEmpty? 0.0 : double.parse(utils.amount);
                    double paid = _pay.where((element) => element.type?.toUpperCase() == util.text.toUpperCase()
                        && DateTime.parse(element.time.toString()).year == month.year && DateTime.parse(element.time.toString()).month ==  month.month)
                        .fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
                    double balance = utils.cost == 'Variable'? 0.0 : double.parse(utils.amount) - paid;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            SizedBox(width: 5,),
                            Icon(util.icon),
                            SizedBox(width: 20,),
                            Expanded(child: Text(utils.text)),
                            unit.lid != currentLease.lid
                                ? Text('${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}',
                                style: TextStyle(color: secondaryColor, fontWeight: FontWeight.w600))
                                : utils.cost == 'Variable'
                                ? TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  if(isCoTenant){
                                    Get.to(() => PayScreen(
                                        entity: entity,
                                        unit: unit,
                                        reload: _getData,
                                        lease: currentLease,
                                        amount: 0,
                                        account: util.text,
                                        cost: utils.cost,
                                        isMax: false,
                                        lastPaid: month
                                    ), transition: Transition.rightToLeft);
                                  } else {
                                    dialogRecordPayments(context, util.text, 0, utils.cost, false, month);
                                  }

                                },
                                child: Text('VC ● ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}',)
                            ) : paid == amnt
                                ? Text(
                              '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                                : balance==amnt
                                ? TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  if(isCoTenant){
                                    Get.to(() => PayScreen(
                                        entity: entity,
                                        unit: unit,
                                        reload: _getData,
                                        lease: currentLease,
                                        amount: double.parse(utils.amount),
                                        account: util.text,
                                        cost: utils.cost,
                                        isMax: true,
                                        lastPaid: month
                                    ), transition: Transition.rightToLeft);
                                  } else {
                                    dialogRecordPayments(context, util.text, double.parse(utils.amount), utils.cost, true, month);
                                  }

                                },
                                child: Text(" ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(utils.amount))} ● ${utils.period}"))
                                :TextButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  if(isCoTenant){
                                    Get.to(() => PayScreen(
                                        entity: entity,
                                        unit: unit,
                                        reload: _getData,
                                        lease: currentLease,
                                        amount: balance,
                                        account: util.text,
                                        cost: utils.cost,
                                        isMax: true,
                                        lastPaid: month
                                    ), transition: Transition.rightToLeft);
                                  } else {
                                    dialogRecordPayments(context, util.text, balance, utils.cost, true, month);
                                  }

                                },
                                child: Text("Balance ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}")),
                            SizedBox(width: 10,),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Icon(Icons.keyboard_arrow_right, color: secondaryColor,),
                            ),
                          ],
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
  void changeMessage(MessModel messModel){}
  void _updatePay(String payid){
    print("Payment updating");
    _pay.firstWhere((pay) => pay.payid == payid).checked = "true";
    _current.firstWhere((pay) => pay.payid == payid).checked = "true";
    _getPayments();
  }
  void _removePay(){}
  void _updateCount(){}
  void _changeMess(MessModel messModel){}
}
class ExcessMonth {
  double amount;
  DateTime time;

  ExcessMonth({required this.amount, required this.time});
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
