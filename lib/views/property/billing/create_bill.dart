import 'package:Zelli/models/billing.dart';
import 'package:Zelli/models/data.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/utils/colors.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:uuid/uuid.dart';

import '../../../main.dart';
import '../../../models/gateway.dart';
import '../../../models/entities.dart';
import '../../../widgets/text/text_filed_input.dart';

class CreateBill extends StatefulWidget {
  final GateWayModel card;
  final EntityModel entity;
  final Function addBill;
  const CreateBill({super.key, required this.card, required this.entity, required this.addBill});

  @override
  State<CreateBill> createState() => _CreateBillState();
}

class _CreateBillState extends State<CreateBill> {
  Country _country = CountryParser.parseCountryCode(deviceModel.country == null? 'US' : deviceModel.country.toString());

  final controller = CarouselSliderController();

  late TextEditingController _phone;
  late TextEditingController _busno;
  late TextEditingController _accno;
  late TextEditingController _tillno;

  List<String> _paybilloptions = ['One account for all units', 'Different accounts for different units'];

  List<BillingModel> bills = [];

  late GateWayModel card;
  late EntityModel entity;

  int activeIndex = 0;

  String paytype = 'BPB';
  String? _selectedOption;

  bool _loading = false;
  bool _isRent = false;

  final formMEKey = GlobalKey<FormState>();
  final formBPBKey = GlobalKey<FormState>();
  final formBBGKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _phone = TextEditingController();
    _busno = TextEditingController();
    _accno = TextEditingController();
    _tillno = TextEditingController();
    card = widget.card;
    entity = widget.entity;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _phone.dispose();
    _busno.dispose();
    _accno.dispose();
    _tillno.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(width: 20, height: 20, card.logo),
            SizedBox(width: 10,),
            Text(card.title)
          ],
        ),
        actions: [
          if(bills.isNotEmpty)
            IconButton(
              onPressed: (){
                if(bills.isNotEmpty){
                  _addBills();
                } else {
                  Navigator.pop(context);
                }
              },
              icon: Icon(CupertinoIcons.check_mark_circled_solid),
              color: CupertinoColors.activeBlue,
            )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: card.title == "Mpesa"
            ? Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: CarouselSlider(
                  carouselController: controller,
                  items: [
                    // payTypeCard(),
                    setUpCard(),
                    completeCard(),
                  ],
                  options: CarouselOptions(
                      scrollPhysics: NeverScrollableScrollPhysics(),
                      initialPage: 0,
                      enlargeFactor: 0.5,
                      autoPlay: false,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      height: size.height/2,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      autoPlayAnimationDuration: const Duration(seconds: 2),
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      }),
                ),
              ),
            ),
            Wrap(
              runSpacing: 5,
              spacing: 5,
              children: bills.map((bill){
                return Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: color1
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                          onTap: (){
                            bills.remove(bill);
                            setState(() {

                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Icon(Icons.cancel, color: color5,)
                      ),
                      SizedBox(width: 5,),
                      Text(bill.businessno),
                      SizedBox(width: 5,),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30,),
            buildIndicator(),
          ],
        )
            : SizedBox(),
      ),
    );
  }
  Widget buildIndicator() {
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white24
        : Colors.black26;
    return AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: 2,
      effect: WormEffect(
        activeDotColor: CupertinoColors.activeBlue,
        dotColor: color2,
        dotHeight: 5,
        dotWidth: 80 ,
      ),
    );
  }
  Widget payTypeCard() {
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Select Payment Type",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          InkWell(
            onTap: () {
              paytype = 'ME';
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            borderRadius: BorderRadius.circular(5),
            splashColor: CupertinoColors.activeBlue,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("M-pesa Express", style: TextStyle(fontSize: 15)),
                  Icon(Icons.keyboard_arrow_right_outlined),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              paytype = 'BPB';
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            borderRadius: BorderRadius.circular(5),
            splashColor: CupertinoColors.activeBlue,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Business Pay Bill", style: TextStyle(fontSize: 15)),
                  Icon(Icons.keyboard_arrow_right_outlined),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          InkWell(
            onTap: () {
              paytype = 'BBG';
              controller.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            borderRadius: BorderRadius.circular(5),
            splashColor: CupertinoColors.activeBlue,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Business Buy Goods", style: TextStyle(fontSize: 15)),
                  Icon(Icons.keyboard_arrow_right_outlined),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget setUpCard(){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Form(
        key: formBPBKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "Add Pay Bill Detail",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                "Please enter the Pay Bill number for the payment recipient.",
                style: TextStyle(color: secondaryColor),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10,),
              TextFieldInput(
                textEditingController: _busno,
                labelText: "Business Number",
                textInputType: TextInputType.number,
                validator: (value){
                  if (value == null || value.isEmpty) {
                    return 'Please enter business number.';
                  }
                  if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
                    return null; // Valid input (contains only digits)
                  } else {
                    return 'Please enter a valid business number';
                  }
                },
              ),
              SizedBox(height: 10,),
              ..._paybilloptions.map((option){
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: RadioListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      dense: true,
                      value: option,
                      groupValue: _selectedOption,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Text(option, style: TextStyle(fontSize: 15),),
                      tileColor: color1,
                      subtitle: option == 'One account for all units' && _selectedOption == 'One account for all units'
                          ? TextFormField(
                        controller: _accno,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          label: Text("Account Number"),
                          fillColor: color1,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          filled: true,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter account number.';
                          }
                          if (value.contains('*')) {
                            return 'The account number cannot contain the "*" character.';
                          }
                          return null;
                        },
                      )
                          : null,
                      onChanged: (value){
                        setState(() {
                          _selectedOption = value;
                        });
                      }
                  ),
                );
              }).toList(),
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Text(
                              "Rent",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Text(
                              'Would you like to enable this account for tenants to make rent payments conveniently?',
                              style: TextStyle(color: secondaryColor),
                          ),
                        ],
                      )
                  ),
                  SizedBox(height: 10,),
                  Switch(
                      value: _isRent,
                      onChanged: (value){
                        setState(() {
                          _isRent =! _isRent;
                        });
                      }
                  )
                ],
              ),
              SizedBox(height: 20,),
              InkWell(
                onTap: (){
                  final form = formBPBKey.currentState!;
                  Uuid uuid = Uuid();
                  var bid = uuid.v1();
                  if(form.validate()) {
                    var newBill = BillingModel(
                        bid: bid,
                        bill: card.title,
                        businessno: _busno.text,
                        type: _selectedOption == 'One account for all units'? 'Same' : 'Different',
                        account: _isRent? 'Rent' : '',
                        accountno: _accno.text,
                        access: '',
                        time: DateTime.now().toString(),
                        eid: widget.entity.eid,
                        pid: widget.entity.pid.toString(),
                        checked: 'true'
                    );
                    if(!bills.any((test) => test.businessno.contains(newBill.businessno))){
                      bills.add(newBill);
                    }
                    controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeIn,
                    );
                  }
                },
                child: Container(
                  width: 450,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: CupertinoColors.activeBlue
                  ),
                  child: Center(
                      child: Text(
                        "Continue", style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                      ),
                      )
                  ),
                ),
              ),
              // TextButton(
              //     onPressed: (){
              //       paytype = '';
              //       controller.previousPage(
              //         duration: const Duration(milliseconds: 300),
              //         curve: Curves.easeIn,
              //       );
              //     },
              //     child: Text("Go Back")
              // )
            ],
          ),
        )
    );

  }
  Widget completeCard(){
    final color1 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    return Column(
      children: [
        Text(
          "Complete",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Text(
          "If you would like to add another payment method, please click the 'Add More' button. Otherwise, click the 'Finish' button to proceed.",
          style: TextStyle(color: secondaryColor),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10,),
        InkWell(
          onTap: (){
            _busno.clear();
            _accno.clear();
            _isRent = false;
            controller.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn,
            );
          },
          borderRadius: BorderRadius.circular(5),
          splashColor: CupertinoColors.activeBlue,
          child: Container(
            width: 450,
            padding: EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  color: CupertinoColors.activeBlue,
                  width: 1
              ),

            ),
            child: Center(
                child: Text(
                  "+Add more", style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: CupertinoColors.activeBlue
                ),
                )
            ),
          ),
        ),
        SizedBox(height: 10,),
        InkWell(
          onTap: (){
            if(bills.isNotEmpty){
              _addBills();

            } else {
              Navigator.pop(context);
            }
          },
          child: Container(
            width: 450,
            padding: EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: CupertinoColors.activeBlue
            ),
            child: Center(
                child: _loading
                    ? SizedBox(width: 15,height: 15, child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2,))
                    : Text(
                      "Finish", style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
                    ),
                )
            ),
          ),
        ),
        TextButton(
            onPressed: (){
              paytype = '';
              controller.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeIn,
              );
            },
            child: Text("Go Back"))
      ],
    );
  }
  void _addBills()async{
    setState(() {
      _loading = true;
    });

    bills.asMap().forEach((index, bill)async {
      await Services.addBill(bill).then((response){
       if(response=="Success"){
          Data().addBill(bill);
          widget.addBill(bill);
          if(index+1==bills.length){
            setState(() {
              _loading = false;
            });
            Navigator.pop(context);
          }
        } else {
          if(index+1==bills.length){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(Data().failed),
                  showCloseIcon: true,
              )
            );
            setState(() {
              _loading = false;
            });
          }
        }
      });
    });

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
  // paytype == "ME"
  //   ? Form(
  //     key: formMEKey,
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //     child: SingleChildScrollView(
  //       child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Text(
  //               "Add Contact Detail",
  //               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //             ),
  //             Text(
  //               "Please enter the contact information for the recipient of the payments.",
  //               style: TextStyle(color: secondaryColor),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 10,),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 InkWell(
  //                   onTap: _showPicker,
  //                   child: Container(
  //                     width: 60, height: 48,
  //                     decoration: BoxDecoration(
  //                       color: color1,
  //                       borderRadius: BorderRadius.circular(5),
  //                       border: Border.all(
  //                           width: 1, color: color1
  //                       ),
  //                     ),
  //                     child: Center(
  //                         child: Text("+${_country.phoneCode}")
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(width: 5,),
  //                 Expanded(
  //                   child: TextFieldInput(
  //                     textEditingController: _phone,
  //                     labelText: "Phone",
  //                     maxLength: 9,
  //                     textInputType: TextInputType.phone,
  //                     validator: (value){
  //                       if (value == null || value.isEmpty) {
  //                         return 'Please enter a phone number.';
  //                       }
  //                       if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
  //                         return null; // Valid input (contains only digits)
  //                       } else {
  //                         return 'Please enter a valid phone number';
  //                       }
  //                     },
  //                   ),
  //                 )
  //               ],
  //             ),
  //             SizedBox(height: 10,),
  //             InkWell(
  //               onTap: (){
  //                 final form = formMEKey.currentState!;
  //                 if(form.validate()) {
  //                   controller.nextPage(
  //                     duration: const Duration(milliseconds: 300),
  //                     curve: Curves.easeIn,
  //                   );
  //                 }
  //               },
  //               child: Container(
  //                 width: 450,
  //                 padding: EdgeInsets.symmetric(vertical: 15),
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(5),
  //                     color: CupertinoColors.activeBlue
  //                 ),
  //                 child: Center(
  //                     child: Text(
  //                       "Continue", style: TextStyle(
  //                         fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
  //                     ),
  //                     )
  //                 ),
  //               ),
  //             ),
  //             TextButton(
  //                 onPressed: (){
  //                   paytype = '';
  //                   controller.previousPage(
  //                     duration: const Duration(milliseconds: 300),
  //                     curve: Curves.easeIn,
  //                   );
  //                 },
  //                 child: Text("Go back"))
  //           ],
  //       ),
  //     ),
  //   )
  //   : paytype == "BPB"
  //   ? Form(
  //     key: formBPBKey,
  //     autovalidateMode: AutovalidateMode.onUserInteraction,
  //     child: SingleChildScrollView(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.max,
  //         children: [
  //           Text(
  //             "Add Pay Bill Detail",
  //             style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //           ),
  //           Text(
  //             "Please enter the Pay Bill number for the payment recipient.",
  //             style: TextStyle(color: secondaryColor),
  //             textAlign: TextAlign.center,
  //           ),
  //           SizedBox(height: 10,),
  //           TextFieldInput(
  //             textEditingController: _busno,
  //             labelText: "Business Number",
  //             textInputType: TextInputType.number,
  //             validator: (value){
  //               if (value == null || value.isEmpty) {
  //                 return 'Please enter business number.';
  //               }
  //               if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
  //                 return null; // Valid input (contains only digits)
  //               } else {
  //                 return 'Please enter a valid business number';
  //               }
  //             },
  //           ),
  //           SizedBox(height: 10,),
  //           ..._paybilloptions.map((option){
  //             return Padding(
  //               padding: const EdgeInsets.only(bottom: 8.0),
  //               child: RadioListTile(
  //                   contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
  //                   dense: true,
  //                   value: option,
  //                   groupValue: _selectedOption,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(5),
  //                   ),
  //                   title: Text(option, style: TextStyle(fontSize: 15),),
  //                   tileColor: color1,
  //                   subtitle: option == 'One account for all units' && _selectedOption == 'One account for all units'? TextFormField(
  //                     controller: _accno,
  //                     keyboardType: TextInputType.text,
  //                     decoration: InputDecoration(
  //                       label: Text("Account Number"),
  //                       fillColor: color1,
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.all(
  //                             Radius.circular(5)
  //                         ),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                       contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                       filled: true,
  //                       isDense: true,
  //                     ),
  //                     validator: (value){
  //                       if (value == null || value.isEmpty) {
  //                         return 'Please enter account number.';
  //                       }
  //                       if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
  //                         return null; // Valid input (contains only digits)
  //                       } else {
  //                         return 'Please enter a valid account number';
  //                       }
  //                     },
  //                   ) : null,
  //                   onChanged: (value){
  //                     setState(() {
  //                       _selectedOption = value;
  //                     });
  //                   }
  //               ),
  //             );
  //           }).toList(),
  //           SizedBox(height: 10,),
  //           InkWell(
  //             onTap: (){
  //               final form = formBPBKey.currentState!;
  //               if(form.validate()) {
  //                 controller.nextPage(
  //                   duration: const Duration(milliseconds: 300),
  //                   curve: Curves.easeIn,
  //                 );
  //               }
  //             },
  //             child: Container(
  //               width: 450,
  //               padding: EdgeInsets.symmetric(vertical: 15),
  //               decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(5),
  //                   color: CupertinoColors.activeBlue
  //               ),
  //               child: Center(
  //                   child: Text(
  //                     "Continue", style: TextStyle(
  //                       fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
  //                   ),
  //                   )
  //               ),
  //             ),
  //           ),
  //           // TextButton(
  //           //     onPressed: (){
  //           //       paytype = '';
  //           //       controller.previousPage(
  //           //         duration: const Duration(milliseconds: 300),
  //           //         curve: Curves.easeIn,
  //           //       );
  //           //     },
  //           //     child: Text("Go Back")
  //           // )
  //         ],
  //       ),
  //     )
  //   )
  //   : Form(
  //       key: formBBGKey,
  //       autovalidateMode: AutovalidateMode.onUserInteraction,
  //       child: SingleChildScrollView(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           mainAxisSize: MainAxisSize.max,
  //           children: [
  //             Text(
  //               "Add Till Number",
  //               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
  //             ),
  //             Text(
  //               "Please enter the till number for the payment recipient.",
  //               style: TextStyle(color: secondaryColor),
  //               textAlign: TextAlign.center,
  //             ),
  //             SizedBox(height: 10,),
  //             TextFieldInput(
  //               textEditingController: _tillno,
  //               labelText: "Till Number",
  //               textInputType: TextInputType.number,
  //               validator: (value){
  //                 if (value == null || value.isEmpty) {
  //                   return 'Please enter till number.';
  //                 }
  //                 if (RegExp(r'^[0-9+]+$').hasMatch(value)) {
  //                   return null; // Valid input (contains only digits)
  //                 } else {
  //                   return 'Please enter a valid till number';
  //                 }
  //               },
  //             ),
  //             SizedBox(height: 10,),
  //             InkWell(
  //               onTap: (){
  //                 final form = formBBGKey.currentState!;
  //                 if(form.validate()) {
  //                   controller.nextPage(
  //                     duration: const Duration(milliseconds: 300),
  //                     curve: Curves.easeIn,
  //                   );
  //                 }
  //               },
  //               child: Container(
  //                 width: 450,
  //                 padding: EdgeInsets.symmetric(vertical: 15),
  //                 decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(5),
  //                     color: CupertinoColors.activeBlue
  //                 ),
  //                 child: Center(
  //                     child: Text(
  //                       "Continue", style: TextStyle(
  //                         fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black
  //                     ),
  //                     )
  //                 ),
  //               ),
  //             ),
  //             TextButton(
  //                 onPressed: (){
  //                   paytype = '';
  //                   controller.previousPage(
  //                     duration: const Duration(milliseconds: 300),
  //                     curve: Curves.easeIn,
  //                   );
  //                 },
  //                 child: Text("Go Back"))
  //           ],
  //         ),
  //       )
  //   );
}
