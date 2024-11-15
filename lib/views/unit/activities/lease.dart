import 'package:Zelli/main.dart';
import 'package:Zelli/models/data.dart';
import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
import 'package:Zelli/resources/services.dart';
import 'package:Zelli/widgets/text/text_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/entities.dart';
import '../../../utils/colors.dart';

class Lease extends StatefulWidget {
  final EntityModel entity;
  final UnitModel unit;
  final LeaseModel lease;
  final UserModel tenant;
  final Function reload;
  const Lease({super.key, required this.unit, required this.lease, required this.tenant, required this.entity, required this.reload});

  @override
  State<Lease> createState() => _LeaseState();
}

class _LeaseState extends State<Lease> {
  TextEditingController _rent = TextEditingController();
  TextEditingController _deposit = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late UnitModel unit;
  late LeaseModel lease;
  late UserModel tenant;
  late EntityModel entity;

  late DateTime startTime;
  late DateTime endTime;

  List<String> _admins = [];

  int totalMonths = 0;

  bool _editLease = false;
  bool _editFinance = false;
  bool  _loading = false;

  _getData(){
    unit = widget.unit;
    lease = widget.lease;
    tenant = widget.tenant;
    entity = widget.entity;

    _admins = entity.admin.toString().split(',');

    startTime = DateTime.parse(lease.start.toString());
    endTime = lease.end.toString().isEmpty? DateTime.now() :  DateTime.parse(lease.end.toString());

    int yearDiff = endTime.year - startTime.year;
    int monthDiff = endTime.month - startTime.month;

    totalMonths = (yearDiff * 12) + monthDiff;

    _rent.text = lease.rent.toString();
    _deposit.text = lease.deposit.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _rent.dispose();
    _deposit.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color1 =  Theme.of(context).brightness == Brightness.dark
        ? Colors.white10
        : Colors.black12;
    final cardColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.white;
    final heading = TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
    final padding = EdgeInsets.symmetric(vertical: 8, horizontal: 10);
    return Scaffold(
      appBar: AppBar(),
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: 450,
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: CupertinoColors.activeBlue.withOpacity(0.2)
                        ),
                        child: Icon(CupertinoIcons.doc_text, size: 40,color: CupertinoColors.activeBlue,),
                      ),
                      Text(
                        "Lease Document", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      // Basic Info
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
                              Text("Basic Information", style: heading,),
                              horizontalItems("Lease ID", lease.lid.split("-").first.toUpperCase()),
                              horizontalItems("Property", entity.title.toString().split("-").first),
                              horizontalItems("Unit Number", unit.title.toString()),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Tenant Info
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
                              Text("Tenant Information", style: heading,),
                              horizontalItems("Username", tenant.username.toString()),
                              horizontalItems("Full Name", "${tenant.firstname} ${tenant.lastname}"),
                              horizontalItems("Email Address", tenant.email.toString()),
                              horizontalItems("Phone Number", tenant.phone.toString()),
                              horizontalItems("No of Co-Tenants", lease.ctid.toString().split(",").length.toString()),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Lease Details
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Lease Details", style: heading,),
                                  _admins.contains(currentUser.uid)
                                      ? InkWell(
                                      onTap: (){
                                        setState(() {
                                          _editLease = !_editLease;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(_editLease? Icons.close : Icons.edit, size: 15,color: _editLease? Colors.red : CupertinoColors.systemBlue,),
                                            SizedBox(width: 5,),
                                            Text(
                                              _editLease? "Cancel" : "Edit",
                                              style: TextStyle(color: _editLease? Colors.red : CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      )
                                  )
                                      : SizedBox()
                                ],
                              ),
                              _editLease
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Start Date", style: TextStyle(fontSize: 15, color: secondaryColor),),
                                      InkWell(
                                        onTap: _showDatePicker,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: color1,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: color1,
                                                  width: 1
                                              )
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.calendar),
                                              Expanded(
                                                  child: Center(
                                                      child: Text(
                                                        DateFormat.yMMMd().format(startTime),
                                                      )
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                  : horizontalItems("Start Date", '${DateFormat('HH:mm').format(DateTime.parse(lease.start!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.start!))}'),
                              _editLease && lease.end!.isNotEmpty
                                  ?Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("End Date", style: TextStyle(fontSize: 15, color: secondaryColor),),
                                      InkWell(
                                        onTap: _showEndDatePicker,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: color1,
                                              borderRadius: BorderRadius.circular(5),
                                              border: Border.all(
                                                  color: color1,
                                                  width: 1
                                              )
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(CupertinoIcons.calendar),
                                              Expanded(
                                                  child: Center(
                                                      child: Text(
                                                        DateFormat.yMMMd().format(endTime),
                                                      )
                                                  )
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                  :horizontalItems("End Date", lease.end!.isEmpty? "N/A" : '${DateFormat('HH:mm').format(DateTime.parse(lease.end!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.end!))}'),
                              horizontalItems("Duration", '${totalMonths} months'),
                              // horizontalItems("Renewal Option", "true"),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      // Financial Details
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Financial Details", style: heading,),
                                  lease.end.toString().isNotEmpty && _admins.contains(currentUser.uid)
                                      ?  SizedBox()
                                      : InkWell(
                                          onTap: (){
                                            setState(() {
                                              _editFinance = !_editFinance;
                                            });
                                          },
                                          borderRadius: BorderRadius.circular(20),
                                          hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(_editFinance?  Icons.close: Icons.edit, size: 15,color: _editFinance? Colors.red : CupertinoColors.systemBlue,),
                                                SizedBox(width: 5,),
                                                Text(
                                                  _editFinance?  "Cancel": "Edit",
                                                  style: TextStyle(color: _editFinance? Colors.red : CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          )
                                      )
                                ],
                              ),
                              _editFinance
                                  ? TextFormField(
                                      controller: _rent,
                                      maxLines: 1,
                                      minLines: 1,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        label: Text("Rent"),
                                        fillColor: color1,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)
                                          ),
                                          borderSide: BorderSide.none,
                                        ),
                                        filled: true,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      ),
                                      onChanged:  (value) => setState((){}),
                                      validator: (value){
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a value.';
                                        }

                                        if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                                          return null;
                                        } else {
                                          return 'Please enter a valid number with only one decimal point.';
                                        }

                                      },
                                    )
                                  : horizontalItems("Monthly Rent", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(lease.rent.toString()))}'),
                              _editFinance
                                  ? Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: TextFormField(
                                        controller: _deposit,
                                        maxLines: 1,
                                        minLines: 1,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          label: Text("Deposit"),
                                          fillColor: color1,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        ),
                                        onChanged:  (value) => setState((){}),
                                        validator: (value){
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a value.';
                                          }

                                          if (RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                                            return null;
                                          } else {
                                            return 'Please enter a valid number with only one decimal point.';
                                          }

                                        },
                                      ),
                                  )
                                  : horizontalItems("Security Deposit", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(lease.deposit.toString()))}'),
                              // horizontalItems("Late Fee Rate", '10%'),
                              horizontalItems("Rent Due Date", '${TFormat().formatOrdinal(int.parse(entity.due.toString()))}' ),
                              horizontalItems("Rent Late Date", '${TFormat().formatOrdinal(int.parse(entity.late.toString()))}'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10,),
                      //Status and Payment Tracking
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
                              Text("Status and Payment Tracking", style: heading,),
                              horizontalItems("Current Balance", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(12000)}'),
                              horizontalItems("Active", lease.end.toString().isEmpty? 'true' : 'false'),
                              horizontalItems("Terminated", lease.end.toString().isEmpty? 'false':'true'),
                              horizontalItems("Last Payment Date", '${DateFormat('HH:mm').format(DateTime.parse(lease.start!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.start!))}' ),
                              horizontalItems("Overdue Amount", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(12000)}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _editLease || _editFinance
                ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: (){
                      final form = formKey.currentState!;
                      if(form.validate()){
                        _update();
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      width: 450,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(5)
                      ),
                      child: Center(child: _loading
                          ? SizedBox(
                              width: 15,height: 15,
                              child: CircularProgressIndicator(color: Colors.black,strokeWidth: 2)
                            )
                          : Text("UPDATE", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),)),
                    ),
                  ),
                )
                : SizedBox()
          ],
        ),
      ),
    );
  }
  void _update()async{
    setState(() {
      _loading = true;
    });
    await Services.updateLeaseDetails(
        lease.lid,
        _rent.text.toString(),
        _deposit.text.toString(),
        startTime.toString(),
        lease.end.toString().isEmpty? "" : endTime.toString()).then((response){
      if(response=="success"){
        lease.rent = _rent.text.toString();
        lease.deposit = _deposit.text.toString();
        lease.start = startTime.toString();
        lease.end = lease.end.toString().isEmpty? "" : endTime.toString();
        Data().addLease(lease);
        widget.reload();
        setState(() {
          _editFinance = false;
          _editLease = false;
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lease was updated. Successfully'),
              showCloseIcon: true,
            )
        );
      } else if(response=="error") {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lease was not updated. Please try again later'),
              showCloseIcon: true,
            )
        );
      } else {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(Data().failed),
            showCloseIcon: true,
          )
        );
      }
    });

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
  void _showDatePicker(){
    showDatePicker(
      context: context,
      initialDate: startTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if(value != null){
          startTime = value;
        }
      });
    });
  }
  void _showEndDatePicker(){
    showDatePicker(
      context: context,
      initialDate: endTime,
      firstDate: startTime,
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        if(value != null){
          endTime = value;
        }
      });
    });
  }
}
