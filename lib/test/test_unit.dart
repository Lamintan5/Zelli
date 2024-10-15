import 'dart:convert';
import 'dart:io';

import 'package:Zelli/widgets/items/item_pay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icon.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../main.dart';
import '../../models/data.dart';
import '../../models/entities.dart';
import '../../models/messages.dart';
import '../../models/payments.dart';
import '../../models/lease.dart';
import '../../models/units.dart';
import '../../models/users.dart';
import '../../utils/colors.dart';
import '../../widgets/buttons/call_actions/double_call_action.dart';
import '../../widgets/cards/card_button.dart';
import '../../widgets/cards/row_button.dart';
import '../../widgets/dialogs/dialog_add_tenant.dart';
import '../../widgets/dialogs/dialog_edit_unit.dart';
import '../../widgets/dialogs/dialog_title.dart';
import '../../widgets/profile_images/user_profile.dart';
import '../widgets/text/text_format.dart';


class TestUnit extends StatefulWidget {
  final UnitModel unit;
  final Function reload;
  final Function removeTenant;
  final Function removeFromList;
  const TestUnit({super.key, required this.unit, required this.reload, required this.removeTenant, required this.removeFromList});

  @override
  State<TestUnit> createState() => _TestUnitState();
}

class _TestUnitState extends State<TestUnit> with TickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _search = TextEditingController();
  TextEditingController _searchPay = TextEditingController();
  final _keyOne = GlobalKey();
  final _keyTwo = GlobalKey();
  final _keyThree = GlobalKey();

  List<PaymentsModel> _pay = [];
  List<PaymentsModel> _crntTntPay = [];
  List<PaymentsModel> _rent = [];
  List<PaymentsModel> _utils = [];
  List<PaymentsModel> _crntRent = [];
  List<PaymentsModel> _accrued = [];
  List<PaymentsModel> _prepaid = [];
  List<UserModel> _previoususers = [];

  EntityModel entity = EntityModel(eid: "", title: "", image: "");
  UserModel crrntTenant = UserModel(uid: "", username: "", image: "");
  LeaseModel lease = LeaseModel(tid: "", lid: '');

  double _accrdAmount = 0.0;
  double _prdAmount = 0.0;
  double _crntRntAmount = 0.0;
  double balance = 0;
  double payingAmount = 0;

  double totalRentAmount = 0;
  double totalUtils = 0;

  late DateTime fifthOfMonth;
  List<MonthModel> monthsList = [];
  late DateTime startDate;
  late DateTime endDate;
  final currentPeriod = DateTime.now();

  _getData(){
    _getEntity();
    _getUsers();
    _getPayments();
    widget.reload();
    setState(() {

    });
  }

  _getEntity(){
    entity = myEntity.map((jsonString) => EntityModel.fromJson(json.decode(jsonString))).firstWhere((enty) => enty.eid == widget.unit.eid.toString(), orElse: ()=> EntityModel(eid: ""));
  }
  _getUsers(){
    crrntTenant = myUsers.map((jsonString) => UserModel.fromJson(json.decode(jsonString))).firstWhere((usr) => usr.uid == widget.unit.tid, orElse: ()=> UserModel(uid: ""));
  }

  _getPayments(){
    _pay = myPayment.map((jsonString) => PaymentsModel.fromJson(json.decode(jsonString))).where((pay) => pay.uid == widget.unit.id.toString()).toList();
    _pay.sort((a, b) => a.current!.compareTo(b.current!));
    _crntTntPay = _pay.where((pay) => pay.tid == crrntTenant.uid).toList();
    _rent = _crntTntPay.where((pay) => pay.type == 'RENT').toList();
    _utils = _crntTntPay.where((pay) => pay.type != 'RENT' && pay.type != "DEPOSIT" ).toList();
    _crntRent = _rent.where((rnt) => DateTime.parse(rnt.time!).year == currentPeriod.year && DateTime.parse(rnt.time!).month == currentPeriod.month).toList();
    _accrued = _rent.where((rnt) => DateTime.parse(rnt.time!).year <= currentPeriod.year && DateTime.parse(rnt.time!).month < currentPeriod.month && double.parse(rnt.amount!) < double.parse(widget.unit.price!)).toList();
    _prepaid = _rent.where((rnt) => DateTime.parse(rnt.time!).year >= currentPeriod.year && DateTime.parse(rnt.time!).month > currentPeriod.month).toList();
    _listMonth();
    _getLastPayDate();
  }

  _listMonth(){
    // THIS IS NOT SORTING PLEASE SORT IN FUTURE
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
  List<MonthModel> generateMonthsList(DateTime startDate, DateTime endDate) {
    List<MonthModel> monthsList = [];

    for (DateTime date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = DateTime(date.year, date.month + 1, date.day)) {
      String monthName = DateFormat('MMM').format(date);
      monthsList.add(MonthModel(year: date.year, monthName: monthName, month: date.month));
    }
    return monthsList;
  }
  _getLastPayDate(){
    if(_rent.isEmpty || _rent.length == 0){
      fifthOfMonth = DateTime(currentPeriod.year, currentPeriod.month, int.parse(entity.due.toString()));
      payingAmount = double.parse(widget.unit.price!);
    } else {
      DateTime lastrent =  DateTime.parse(_rent.last.time.toString());
      double latBalance = double.parse(_rent.last.balance!);
      fifthOfMonth = _rent.last.balance == "0.0"
          ? DateTime(lastrent.year, lastrent.month + 1, int.parse(entity.due.toString()))
          : DateTime(lastrent.year, lastrent.month , int.parse(entity.due.toString()));
      payingAmount = _rent.last.balance == "0.0"
          ? double.parse(widget.unit.price!)
          : latBalance;
    }
    setState(() {
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getData();
    // WidgetsBinding.instance.addPostFrameCallback((_) =>
    //     ShowCaseWidget.of(context).startShowCase([_keyOne, _keyThree])
    // );
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
    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _previoususers.forEach((item) {
        if (item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _previoususers;
    }

    List<PaymentsModel> filteredPayList = [];
    if (_searchPay.text.toString() != null && _searchPay.text.isNotEmpty) {
      _crntTntPay.forEach((item) {
        if (item.amount.toString().toLowerCase().contains(_searchPay.text.toString().toLowerCase())
            || item.type.toString().toLowerCase().contains(_searchPay.text.toString().toLowerCase())
            || item.method.toString().toLowerCase().contains(_searchPay.text.toString().toLowerCase()))
          filteredPayList.add(item);
      });
    } else {
      filteredPayList = _crntTntPay;
    }
    return Scaffold(
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                  surfaceTintColor: Colors.transparent,
                  backgroundColor: normal,
                  pinned: true,
                  expandedHeight: widget.unit.tid.toString() == "" ? 220 :290,
                  toolbarHeight: 30,
                  title: Text(entity.title!),
                  actions: [
                    Showcase(
                      key: _keyThree,
                      description: 'Get more options',
                      child: buildButton(),
                      tooltipBackgroundColor: dgColor,
                      textColor: reverse,
                      tooltipPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 5 ),
                      tooltipBorderRadius: BorderRadius.circular(5),
                      descTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                    )
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 40),
                          SizedBox(width: width,
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      margin: EdgeInsets.symmetric(vertical: 5),

                                      child: LiquidLinearProgressIndicator(
                                        value: 0.0,
                                        valueColor: AlwaysStoppedAnimation(Colors.red),
                                        backgroundColor: color1,
                                        borderColor: Colors.transparent,
                                        borderWidth: 0,
                                        borderRadius: 10.0,
                                        direction: Axis.vertical,
                                        center: Text(widget.unit.title.toString(), style: TextStyle(fontWeight: FontWeight.w600),),
                                      ),
                                    ),
                                    // ClipRRect(
                                    //   borderRadius: BorderRadius.circular(10),
                                    //   child: BackdropFilter(
                                    //     filter:
                                    //     ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                    //     child: Container(
                                    //       height: 100,
                                    //       width: 100,
                                    //       decoration: BoxDecoration(
                                    //           color: crrntTenant.uid == ""
                                    //               ? CupertinoColors.activeBlue
                                    //               : _accrdAmount > 0.0
                                    //               ?Colors.red
                                    //               : _prdAmount > 0.0
                                    //               ? Colors.green
                                    //               : color1,
                                    //           borderRadius: BorderRadius.circular(10),
                                    //           border: Border.all(
                                    //               color: color1, width: 2
                                    //           )
                                    //       ),
                                    //       child: Center(
                                    //           child: Text(
                                    //             widget.unit.title.toString(),
                                    //             style: TextStyle(
                                    //                 fontWeight: FontWeight.w500,
                                    //                 fontSize: 18),
                                    //           )),
                                    //     ),
                                    //   ),
                                    // ),
                                    Positioned(
                                        right: 5,
                                        bottom: 8,
                                        child: crrntTenant.uid==""
                                            ? SizedBox()
                                            : UserProfile(image: crrntTenant.image!, radius: 10,)
                                    )
                                  ],
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        crrntTenant.uid == ""
                                            ?SizedBox()
                                            :Text("${crrntTenant.firstname.toString()} ${crrntTenant.lastname.toString()}",
                                          style: TextStyle(
                                              fontSize:16,
                                              fontWeight:FontWeight.w600
                                          ),
                                        ),
                                        Text(
                                          entity.title!.toUpperCase(),
                                          style: TextStyle(
                                              fontWeight:FontWeight.w600
                                          ),
                                        ),
                                        Text(
                                          widget.unit.room == '0'
                                              ? widget.unit.floor.toString() == "0"
                                              ? "STUDIO, GROUND FLOOR" : "STUDIO, FLOOR ${widget.unit.floor}"
                                              : widget.unit.floor.toString() == "0"
                                              ? "${widget.unit.room.toString()} BEDROOM, GROUND FLOOR" : "${widget.unit.room.toString()} BEDROOM, FLOOR ${widget.unit.floor}",
                                          style: TextStyle(
                                          ),
                                        ),
                                        crrntTenant.uid == ""
                                            ? SizedBox()
                                            : Wrap(
                                          runSpacing: 5,
                                          spacing: 5,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: color1
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Icon(CupertinoIcons.mail, color: secondaryColor,size: 13,),
                                                  SizedBox(width: 2,),
                                                  Text(
                                                    crrntTenant.email.toString(),
                                                    style: TextStyle(color: secondaryColor,fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 4),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: color1
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(CupertinoIcons.phone, color: secondaryColor,size:  13),
                                                  SizedBox(width: 2,),
                                                  Text(
                                                    crrntTenant.phone.toString(),
                                                    style: TextStyle(color: secondaryColor,fontSize: 12),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        )

                                        // crrntTenant.uid == "" || LeaseModel.start == ""? SizedBox() : Text(
                                        //   "Lease Commenced on ${DateFormat.yMMMd().format(DateTime.parse(LeaseModel.start.toString()))}",
                                        //   style: TextStyle(color: secondaryColor
                                        //   ),
                                        // ),
                                      ],
                                    )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          crrntTenant.uid.toString() == ''
                              ? SizedBox()
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Platform.isAndroid || Platform.isIOS
                                  ?
                              CardButton(
                                  text: "PHONE",
                                  backcolor: reverse,
                                  forecolor: normal,
                                  icon: Icon(CupertinoIcons.phone, color: normal,size: 20),
                                  onTap: (){

                                  }
                              )
                                  :  SizedBox(),
                              CardButton(
                                  text: "CHAT",
                                  backcolor: reverse,
                                  forecolor: normal,
                                  icon: Icon(CupertinoIcons.bubble_left, color: normal,size: 20),
                                  onTap: (){
                                    // Get.to(() => MessageScreen(receiver: crrntTenant, changeMess: changeMessage,
                                    //   updateCount: _updateCount,), transition: Transition.rightToLeftWithFade);
                                  }
                              ),
                              entity.utilities == ""? SizedBox() :
                              CardButton(
                                  text: "UTILITY",
                                  backcolor: reverse,
                                  forecolor: normal,
                                  icon: Icon(CupertinoIcons.lightbulb, color: normal,size: 20),
                                  onTap: (){
                                    // dialogUtil(context);
                                  }
                              ),
                              CardButton(
                                  text:
                                  _crntTntPay.where((element) => element.type == "DEPOSIT"&& element.tid == crrntTenant.uid).isEmpty? "DEPO": "RENT",
                                  backcolor: reverse,
                                  forecolor: normal,
                                  icon: LineIcon.wallet(color: normal,size: 20,),
                                  onTap: (){
                                    // _getLastPayDate();
                                    // dialogMakePayments(context);
                                  }
                              ),
                            ],
                          ),
                          Container(
                            width: width,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                crrntTenant.uid.toString() == ''
                                    ? Text(
                                  "This unit is currently available for leasing",
                                  style: TextStyle(
                                      fontSize: 11,color: secondaryColor,
                                      fontStyle: FontStyle.italic),
                                )
                                    : crrntTenant.uid.toString() == ''
                                    ? SizedBox()
                                    : Expanded(child: Text(
                                  _crntTntPay.where((element) => element.type == "DEPOSIT" && element.tid == crrntTenant.uid).toList().length == 0
                                      ? "Expected Security Deposit is ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.unit.deposit!))}"
                                      :_prdAmount > 0
                                      ? "Next Months Prepaid by ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(_prdAmount)}"
                                      : _accrdAmount > 0
                                      ? "Last Month Accrued by ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(_accrdAmount)}"
                                      : balance != double.parse(widget.unit.price!)
                                      ? "Rent balance for this month is ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}"
                                      : "This month expected rent is ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.unit.price!))}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: secondaryColor),
                                ),),
                                SizedBox(width: 10,),
                                crrntTenant.uid.toString() != ''
                                    ? SizedBox()
                                    : Showcase(
                                    key: _keyOne,
                                    description: 'Add a new Tenant to this unit',
                                    tooltipBackgroundColor: dgColor,
                                    textColor: reverse,
                                    descTextStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                    tooltipPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 5 ),
                                    tooltipBorderRadius: BorderRadius.circular(5),
                                    child: MaterialButton(
                                      onPressed: (){
                                        dialogAddTenant(context);
                                      },
                                      color: reverse,
                                      child:  Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person_add_alt_rounded,
                                            color: normal,
                                            size: 18,
                                          ),
                                          SizedBox(width: 5,),
                                          Text("Tenant", style: TextStyle(color: normal),
                                          ),
                                        ],
                                      ),
                                    )
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        crrntTenant.uid.toString() == ""
                            ?Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            widget.unit.tid.toString() == "" ? LineIcon.users() : LineIcon.listUl(),
                            Text(
                              '  Previous Tenants' ,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
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
                              Tab(text: 'Payments',),
                              Tab(text: 'Periods'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
              ),
              SliverToBoxAdapter(
                child: crrntTenant.uid.toString() == ""
                    ? Container(
                  width: width,
                  height: size.height,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _search,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "🔎 Search for tenants...",
                                  fillColor: color1,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                onChanged: (text) => setState(() {}),
                              ),
                            ),
                            // IconButton(
                            //     onPressed: () {}, icon: Icon(Icons.filter_list))
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              UserModel user = filteredList[index];
                              return SizedBox();
                              // ItemPrvTnt( user: user, from: 'Unit', eid: widget.unit.eid.toString(), unitId: widget.unit.id.toString(),);
                            }),
                      ),
                    ],
                  ),
                )
                    : Container(
                  height: MediaQuery.of(context).size.height - 35,
                  child: TabBarView(
                      controller: _tabController,
                      children: [
                        Column(
                          children: [
                            Expanded(
                              child: SizedBox(width: width,
                                child: GroupedListView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(5),
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
                                    List<PaymentsModel> current = [];
                                    current =  _rent.where((element) => DateTime.parse(element.time!).year == month.year && DateTime.parse(element.time!).month == month.month).toList();
                                    var amount = _rent.isEmpty? 0.0: current.fold(0.0, (previousValue, element) => previousValue + double.parse(element.amount!));
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
                                      child: InkWell(
                                        onTap: (){
                                          // dialogPayStatements(context, "RENT", current, double.parse(widget.unit.price!) - amount, month);
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
                                                DateFormat.MMMM().format(DateTime(month.year, month.month)).toUpperCase(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,fontSize: 15
                                                ),
                                              ),
                                              Expanded(child: SizedBox()),

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '+${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w600,
                                                        color: CupertinoColors.activeBlue
                                                    ),
                                                  ),
                                                  amount < double.parse(widget.unit.price!)
                                                      ? Text("Balance : ${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(widget.unit.price!) - amount)}", style: TextStyle(color: secondaryColor),)
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
                            SizedBox(height: 10,),
                            Container(
                              width: 500,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: TextFormField(
                                controller: _searchPay,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "🔎 Search by amount, account or transaction type",
                                  fillColor: color1,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                ),
                                onChanged: (text) => setState(() {}),
                              ),
                            ),
                            Expanded(
                              child: SizedBox(width: 500,
                                child: GroupedListView(
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(5),
                                  order: GroupedListOrder.DESC,
                                  elements: filteredPayList,
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
                                    return ItemPay(payments: payment, removePay: _removePay, from: 'Unit', entity: EntityModel(eid: ""), unit: UnitModel(),);
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
                  RowButton(onTap: (){
                    Navigator.pop(context);
                    dialogEditUnit(context, widget.unit);
                  } , icon : Icon(CupertinoIcons.pen), title: "Edit Unit",subtitle: ""),
                  RowButton(onTap: (){
                    Navigator.pop(context);
                    dialogRemoveUnit(context, widget.unit);
                  } ,
                      icon : Icon(CupertinoIcons.delete), title: "Remove Unit",subtitle: ""),

                  widget.unit.tid.toString() == ''
                      ? SizedBox()
                      : RowButton(onTap: (){
                    // dialogRemoveTenant(context, widget.unit, "${crrntTenant.firstname} ${crrntTenant.lastname}", crrntTenant.uid);
                  },
                      icon : LineIcon.removeUser(), title: "Remove Tenant",subtitle: ""),
                  widget.unit.tid.toString() == ''
                      ? SizedBox()
                      : RowButton(onTap: (){
                    // dialogChargers(context);
                  },
                      icon : Icon(CupertinoIcons.money_dollar), title: "Charges",subtitle: ""),
                  RowButton(onTap: (){
                    // dialogMaintain(context);
                  },
                      icon : Icon(CupertinoIcons.gear), title: "Maintenance & Repair",subtitle: ""),
                  RowButton(onTap: (){
                    // Get.to(()=>PreviousTenants(unit: widget.unit), transition: Transition.rightToLeft);
                  },
                      icon : Icon(CupertinoIcons.person_3), title: "Tenants",subtitle: ""),
                  RowButton(onTap: (){
                    // Get.to(()=>UnitPayments(unit: widget.unit,), transition: Transition.rightToLeft);
                  },
                      icon : LineIcon.wallet(), title: "Payments",subtitle: ""),

                  RowButton(onTap: (){
                    //Get.to(()=>UnitReport(unit: widget.unit, ), transition: Transition.rightToLeft);
                  },
                      icon : Icon(CupertinoIcons.graph_square), title: "Reports & Analytics",subtitle: "Beta"),
                  Expanded(child: SizedBox()),
                  Container(
                    child: Column(
                      children: [
                        Text("Z E L L I", style: TextStyle(fontWeight: FontWeight.w200, fontSize: 10),),
                        SizedBox(height: 5,),
                        Text("STUDIO5IVE", style: TextStyle( color: secondaryColor, fontSize: 10),),
                        Text("approved", style: TextStyle(color: secondaryColor, fontSize: 10),),
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
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "E D I T  U N I T"),
                Text(
                  '',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, ),
                ),
                DialogEditUnit(unit: unitModel, reload: _getData,)
              ],
            ),
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
        child:  SizedBox(
          width: 450,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTitle(title: "R E M O V E  U N I T"),
                Text(
                  'Are you sure you wish to remove ${unitModel.title} from your entity completely.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: secondaryColor, ),
                ),
                DoubleCallAction(
                    action: ()async{
                      await Data().removeUnit(unitModel, _getData, context).then((value){
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                    })
              ],
            ),
          ),
        ),
      );
    });
  }

  void _addPay(PaymentsModel paymentsModel, double paid, String account){
    print("Payment adding");
    _pay.add(paymentsModel);
    _rent.add(paymentsModel);
    _crntTntPay.add(paymentsModel);
    setState(() {
    });
  }
  void changeMessage(MessModel messModel){
  }
  void _updatePay(String payid){
    print("Payment updating");
    _pay.firstWhere((pay) => pay.payid == payid).checked = "true";
    _crntTntPay.firstWhere((pay) => pay.payid == payid).checked = "true";
    _getPayments();
  }
  void _removePay(){
  }
}
class MonthModel {
  final int year;
  final int month;
  final String monthName;

  MonthModel({required this.year, required this.monthName, required this.month});
}
class buildButton extends StatelessWidget {
  const buildButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: (){
          Scaffold.of(context).openEndDrawer();
        },
        icon: Icon(Icons.menu));
  }
}