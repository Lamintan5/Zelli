import 'dart:convert';

import 'package:Zelli/api/mpesa-api.dart';
import 'package:Zelli/api/mpesa-api.dart';
import 'package:Zelli/main.dart';
import 'package:Zelli/resources/socket.dart';
import 'package:Zelli/widgets/buttons/call_actions/double_call_action.dart';
import 'package:Zelli/widgets/dialogs/dialog_title.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icon.dart';

import '../../../models/account.dart';
import '../../../models/billing.dart';
import '../../../models/data.dart';
import '../../../models/entities.dart';
import '../../../models/gateway.dart';
import '../../../models/lease.dart';
import '../../../models/month_model.dart';
import '../../../models/payments.dart';
import '../../../models/units.dart';
import '../../../utils/colors.dart';
import '../../../widgets/text/text_filed_input.dart';

class PayScreen extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  final double amount;
  final String account;
  final String cost;
  final bool isMax;
  final Function reload;
  final MonthModel lastPaid;
  const PayScreen({super.key, required this.entity, required this.unit, required this.lease, required this.amount, required this.account, required this.cost, required this.isMax, required this.reload, required this.lastPaid});

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  Country _country = CountryParser.parseCountryCode(deviceModel.country == null? 'US' : deviceModel.country.toString());
  TextEditingController _phone = TextEditingController();
  MpesaApiService _apiService = MpesaApiService();

  List<BillingModel> _bills = [];
  List<AccountModel> _accounts = [];
  List<GateWayModel> billCard = [
    GateWayModel(title: "Card", logo: 'assets/pay/card.png'),
    GateWayModel(title: "PayPal", logo: 'assets/pay/paypal.png'),
    GateWayModel(title: "CashApp", logo: 'assets/pay/cash.png'),
    GateWayModel(title: "Mpesa", logo: 'assets/pay/mpesa.png'),
  ];
  List<String> _expans = [];

  late EntityModel entity;
  late UnitModel unit;
  late LeaseModel lease;
  late MonthModel month;
  late BillingModel selectedBill;
  late PaymentsModel paymodel;

  double amount = 0.0;
  double balance = 0.0;
  double paid = 0.0;

  String accountType = "";
  String cost = "";
  String selectedAccount = "";
  String _accessToken = "";
  String _payStatus = "";
  int _expiresIn = 0;

  bool isMax = false;
  bool _loading = false;
  bool _prompted = false;

  SocketManager _socket = SocketManager();

  _getData(){
    balance = amount - paid;

    _bills = myBills
        .map((jsonString) => BillingModel.fromJson(json.decode(jsonString)))
        .where((test) {
      if (widget.account == 'DEPOSIT' && test.account.contains('Rent')) {
        return true;
      }
      return test.account.toLowerCase().contains(widget.account.toLowerCase());
    })
        .toList();


    for (int i = 0; i < _bills.length; i++) {
      BillingModel bill = _bills[i];

      bill.access
          .split('*')
          .where((jsonString) => jsonString.isNotEmpty)
          .map((jsonString) => AccountModel.fromJson(json.decode(jsonString)))
          .forEach((account) {
        if (!_accounts.any((existing) =>
        existing.bid == account.bid &&
            existing.uid == account.uid &&
            existing.accountno == account.accountno &&
            existing.account == account.account)) {
          if (account.uid == widget.unit.id) {
            _accounts.add(account);
            if (_accounts.isNotEmpty && i == 0) {
              selectedAccount = bill.type == 'Different' ? account.accountno : bill.accountno;
              selectedBill = bill;
            }
          }
        }
      });
    }
    setState(() {

    });
  }

  void _fetchAccessToken() async {
    try {
      final response = await _apiService.getAccessToken();
      setState(() {
        if (response['success'] == true) {
          // Successfully fetched the token
          _accessToken = response['data']['access_token'];
          _expiresIn = int.parse(response['data']['expires_in']);
        } else {
          // Handle error from the API
          _accessToken = "Error: ${response['error']}";
        }
      });
    } catch (e) {
      // Handle any exceptions
      setState(() {
        _accessToken = "Exception occurred: $e";
      });
    }
  }

  void _listenToSocketEvents() {
    final socket = SocketManager().socket;
    socket.on('pay', (pay) async {
      if (!mounted) return;
      print('Event received: $pay');
      if (pay['accessToken'] == _accessToken) {
        if (pay['status'] == "Success") {
          paymodel.payid == pay['payid'];
          bool isSuccess = await Data().addPayment(paymodel, widget.reload);
          if (isSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment was recorded successfully✔️'),
                showCloseIcon: true,
              ),
            );
            Navigator.pop(context);
          } else {
            setState(() {
              _prompted = false;
            });
          }
        } else {
          setState(() {
            _prompted = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(pay['resultDesc']),
              showCloseIcon: true,
            ),
          );
        }
      }
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    entity = widget.entity;
    unit = widget.unit;
    lease = widget.lease;
    amount = widget.amount;
    accountType = widget.account;
    cost = widget.cost;
    isMax = widget.isMax;


    month = MonthModel.copy(widget.lastPaid);
    if(widget.account=="RENT"){
      if(widget.amount == 0){
        amount = double.parse(widget.lease.rent.toString());
        if (month.month == 12) {
          month.year += 1;
          month.month = 1;
        } else {
          month.month += 1;
        }
      } else {
        amount = widget.amount;
      }
    } else {
      amount = widget.amount;
    }
    paid = amount;
    _listenToSocketEvents();
    _getData();
    _fetchAccessToken();
  }

  @override
  void dispose() {
    final socket = SocketManager().socket;

    socket.off('pay');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reverse =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final statusColor = _payStatus==""
        ? CupertinoColors.activeBlue
        : _payStatus=="Success"
        ? CupertinoColors.activeGreen
        : CupertinoColors.destructiveRed;
    final heading = TextStyle(fontSize: 15, fontWeight: FontWeight.w500);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    return Scaffold(
      appBar: AppBar(
        title: Text(TFormat().toCamelCase(accountType)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: CupertinoColors.activeBlue.withOpacity(0.15  )
                            ),
                            child: LineIcon.wallet(color: CupertinoColors.activeBlue, size: 30,)
                        ),
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.all(3),
                                child: Text(
                                  '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}',
                                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: (){
                                    dialogAddPaid(context);
                                  },
                                  borderRadius: BorderRadius.circular(50),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: CupertinoColors.activeBlue
                                    ),
                                    child: Icon(Icons.edit, color: Colors.black,size: 15,),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(_expans.contains("Basic")){
                                        _expans.remove("Basic");
                                      } else {
                                        _expans.add("Basic");
                                      }
                                    });
                                  },
                                  hoverColor: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Basic Information", style: heading,),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 500),
                                        turns: _expans.contains("Basic") ? 0.5 : 0.0,
                                        child: Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  duration: Duration(milliseconds: 500),
                                  alignment: Alignment.topCenter,
                                  curve: Curves.easeInOut,
                                  child: _expans.contains("Basic")?  Column(
                                    children: [
                                      horizontalItems("Lease ID", lease.lid.split("-").first.toUpperCase()),
                                      horizontalItems("Property", entity.title.toString().split("-").first),
                                      horizontalItems("Unit", unit.title.toString()),
                                    ],
                                  ) : SizedBox(),
                                ),

                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Card(
                          elevation: 8,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Padding(
                            padding: padding,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if(_expans.contains("Payment")){
                                        _expans.remove("Payment");
                                      } else {
                                        _expans.add("Payment");
                                      }
                                    });
                                  },
                                  hoverColor: color1,
                                  borderRadius: BorderRadius.circular(5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Payment Details", style: heading,),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 500),
                                        turns: _expans.contains("Payment") ? 0.5 : 0.0,
                                        child: Icon(Icons.keyboard_arrow_down),
                                      ),
                                    ],
                                  ),
                                ),
                                AnimatedSize(
                                  duration: Duration(milliseconds: 500),
                                  alignment: Alignment.topCenter,
                                  curve: Curves.easeInOut,
                                  child:_expans.contains("Payment")?  Column(
                                    children: [
                                      horizontalItems("Remitter", currentUser.username!),
                                      horizontalItems("Account", accountType.toUpperCase()),
                                      horizontalItems("Amount Due", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(amount)}'),
                                      horizontalItems("Balance", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(balance)}'),
                                      horizontalItems("Amount Paid", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(paid)}'),
                                    ],
                                  ) : SizedBox(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                '  Payment Method',
                              style: heading,
                            ),
                          ],
                        ),
                        _accounts.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(10),
                                color: Colors.red.withOpacity(0.15),
                                child: Text(
                                    'It appears that no account is currently linked to this unit. Kindly contact your property manager to set up the necessary payment gateways.',
                                    style: TextStyle(color: Colors.red),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _accounts.length,
                                itemBuilder: (context, index){
                                  AccountModel account = _accounts[index];
                                  BillingModel bill = _bills.firstWhere((test) => test.bid == account.bid);
                                  var crd = billCard.firstWhere((test) => test.title == bill.bill, orElse: () => GateWayModel(title: "", logo: ''));
                                  var accno = bill.type == 'Different'? account.accountno :bill.accountno;
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading:  Image.asset(
                                      crd.logo,
                                      width: 30,
                                      height: 30,
                                    ),
                                    title: Text(bill.businessno),
                                    subtitle: Text(accno, style: TextStyle(color: secondaryColor),),
                                    trailing: CupertinoCheckbox(
                                        shape: CircleBorder(),
                                        checkColor: Colors.black,
                                        value: selectedAccount == accno? true : false,
                                        onChanged: (value){
                                          setState(() {
                                            selectedAccount = accno;
                                            selectedBill = bill;
                                          });
                                    }),
                                    onTap: (){
                                      setState(() {
                                        selectedAccount = accno;
                                        selectedBill = bill;
                                      });
                                    },
                                  );

                            })
                      ],
                    ),
                  )
              ),
              _prompted
                  ? Container(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      margin: EdgeInsets.only(bottom: 5),
                      decoration: BoxDecoration(
                        color: _payStatus==""
                            ? CupertinoColors.activeBlue.withOpacity(0.1)
                            : _payStatus=="Success"
                            ? CupertinoColors.activeGreen.withOpacity(0.1)
                            : CupertinoColors.destructiveRed.withOpacity(0.1)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.dialpad, color: statusColor,),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    _payStatus==""
                                        ? "Prompted"
                                        : _payStatus,
                                    style: TextStyle(color: statusColor, fontSize: 18, fontWeight: FontWeight.w600)),
                                RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'A prompt has been successfully sent to ',
                                            style: TextStyle(color: statusColor)
                                        ),
                                        TextSpan(
                                          text: '+${_country.phoneCode + _phone.text}. ',
                                            style: TextStyle(color: statusColor,fontWeight: FontWeight.w600)
                                        ),
                                        TextSpan(
                                          text: "Kindly enter your PIN to complete the transaction.",
                                          style: TextStyle(color: statusColor)
                                        )
                                      ]
                                    )
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10,),
                          _payStatus==""
                              ? SizedBox(
                                width: 20,height: 20,
                                child: CircularProgressIndicator(
                                  color: statusColor,
                                  strokeWidth: 3,
                                ),
                              )
                              : InkWell(
                                  onTap: (){
                                    setState(() {
                                      _prompted = false;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(5),
                                  splashColor: statusColor,
                                  child: Icon(Icons.close, color: statusColor,)
                                )
                        ],
                      ),
                    )
                  : InkWell(
                    onTap: (){
                      if(selectedBill.bill=="Mpesa" && _accessToken.isNotEmpty){
                        dialogAddPhone(context);
                      } else {

                      }

                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 450,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _accounts.isEmpty || paid == 0
                            ?CupertinoColors.activeBlue.withOpacity(0.4)
                            :CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(
                        child: _loading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 3,))
                            : Text(
                                "Pay",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                      ),

                    ),
                  )
            ],
          ),
        ),
      ),
    );
  }

  void _registerMpesaUrl(String accessToken) async {
    final mpesaService = MpesaApiService();
    String shortCode = '';
    shortCode = selectedBill.businessno;

    setState(() {
      _loading = true;
    });

    try {
      final response = await mpesaService.registerUrl(accessToken, shortCode);
      if (response['success'] == true) {
        print("URL registration successful: ${response['data']}");
        initiateStkPush(accessToken, shortCode);
      } else {
        setState(() {
          _loading = false;
        });
        print("URL registration failed: ${response['error']}");
      }
    } catch (e) {
      setState(() {
        _loading = true;
      });
      print("Exception occurred: $e");
    }
  }

  void initiateStkPush(String accessToken, String businessShortCode) async {
    final mpesaService = MpesaApiService();

    paymodel = PaymentsModel(
      payid: "",
      pid: widget.entity.pid,
      admin: widget.entity.admin,
      tid: widget.unit.tid,
      lid:  widget.unit.lid,
      eid: widget.entity.eid,
      uid: widget.unit.id,
      payerid: currentUser.uid,
      amount: paid.toString(),
      balance: widget.account == "DEPOSIT"? (widget.amount -  paid).toString() : balance.toString(),
      method: selectedBill.bill,
      type: widget.account,
      time: DateTime(month.year, month.month).toString(),
      current: DateTime.now().toString(),
      checked: "true",
    );

    try {
      final response = await mpesaService.stkPush(
        accessToken: accessToken,
        businessShortCode: businessShortCode,
        amount: paid.toStringAsFixed(0),
        phoneNumber: _country.phoneCode+_phone.text,
        accountReference: selectedAccount,
        paymodel:paymodel.toJson()
      );

      if (response['success'] == true) {
        setState(() {
          _prompted = true;
          _loading = false;
        });
        print("STK Push initiated successfully: ${response['data']}");
      } else {
        setState(() {
          _loading = false;
        });
        print("STK Push failed: ${response['error']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${response['details']['errorMessage']}'),
            showCloseIcon: true,
          )
        );

      }
    } catch (e) {
      print("Exception occurred during STK Push: $e");
    }
  }

  Widget horizontalItems(String title, String value){
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, color: secondaryColor),),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),),
        ],
      ),
    );
  }

  void dialogAddPaid(BuildContext context){
    final  _key = GlobalKey<FormState>();
    TextEditingController _paid = TextEditingController();
    _paid.text = paid == 0? amount.toString() : paid.toString();
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
            child: Form(
                key: _key,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'A M O U N T'),
                    SizedBox(height: 5,),
                    TextFieldInput(
                      textEditingController: _paid,
                      textInputType: TextInputType.number,
                      textAlign: TextAlign.center,
                      labelText: "Amount Paid",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a value';
                        }
                        double? amnt = double.tryParse(value);
                        if (amnt == null || amnt <= 0) {
                          return 'Please enter a valid number ';
                        }
                        if (value.contains('.') && value.split('.')[1].length > 2) {
                          return 'Please enter a number with no more than 2 decimal places';
                        }
                        if(widget.isMax == true && amnt > widget.amount){
                          return 'Amount is more than ${TFormat().formatNumberWithCommas(widget.amount)}';
                        }
                        return null;
                      },
                    ),
                    DoubleCallAction(
                        action: (){
                          final form = _key.currentState!;
                          if(form.validate()){
                            Navigator.pop(context);
                            setState(() {
                              paid = double.parse(_paid.text);
                              balance = amount - paid;
                            });

                          }
                    })
                  ],
                )
            ),
          ),
        )
    );
  }
  void dialogAddPhone(BuildContext context){
    final  _phoneKey = GlobalKey<FormState>();
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
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
            child: Form(
                key: _phoneKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DialogTitle(title: 'P H O N E'),
                    Text(
                      "Please provide the phone number you would like to use for this payment.",
                      style: TextStyle(color: secondaryColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 5,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _showPicker,
                          child: Container(
                            width: 60, height: 48,
                            decoration: BoxDecoration(
                              color: color1,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  width: 1, color: color1
                              ),
                            ),
                            child: Center(
                                child: Text("+${_country.phoneCode}")
                            ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Expanded(
                          child: TextFieldInput(
                            textEditingController: _phone,
                            labelText: "Phone",
                            maxLength: 9,
                            textInputType: TextInputType.phone,
                            validator: (value){
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number.';
                              }
                              if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                                return null; // Valid input (contains only digits)
                              } else {
                                return 'Please enter a valid phone number';
                              }
                            },
                          ),
                        )
                      ],
                    ),
                    DoubleCallAction(
                        action: (){
                          final form = _phoneKey.currentState!;
                          if(form.validate()){
                            Navigator.pop(context);
                            _registerMpesaUrl(_accessToken);
                          }
                        })
                  ],
                )
            ),
          ),
        )
    );
  }

  void _showPicker(){
    final dilogbg = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final inputBorder = OutlineInputBorder(
        borderSide: Divider.createBorderSide(context, color: color1,)
    );
    showCountryPicker(
        context: context,
        countryListTheme: CountryListThemeData(
            textStyle: TextStyle(fontWeight: FontWeight.w400),
            bottomSheetHeight: MediaQuery.of(context).size.height / 2,
            backgroundColor: dilogbg,
            borderRadius: BorderRadius.circular(10),
            inputDecoration:  InputDecoration(
              hintText: "🔎 Search for your country here",
              hintStyle: TextStyle(color: secondaryColor),
              border: inputBorder,
              isDense: true,
              fillColor: color1,
              contentPadding: const EdgeInsets.all(10),

            )
        ),
        onSelect: (country){
          setState(() {
            this._country = country;
          });
        });
  }
}
