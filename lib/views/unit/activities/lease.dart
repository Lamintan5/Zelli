import 'package:Zelli/models/lease.dart';
import 'package:Zelli/models/units.dart';
import 'package:Zelli/models/users.dart';
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
  const Lease({super.key, required this.unit, required this.lease, required this.tenant, required this.entity});

  @override
  State<Lease> createState() => _LeaseState();
}

class _LeaseState extends State<Lease> {
  late UnitModel unit;
  late LeaseModel lease;
  late UserModel tenant;
  late EntityModel entity;

  late DateTime startTime;
  late DateTime endTime;

  int totalMonths = 0;

  _getData(){
    unit = widget.unit;
    lease = widget.lease;
    tenant = widget.tenant;
    entity = widget.entity;

    startTime = DateTime.parse(lease.start.toString());
    endTime = lease.end.toString().isEmpty? DateTime.now() :  DateTime.parse(lease.end.toString());

    int yearDiff = endTime.year - startTime.year;
    int monthDiff = endTime.month - startTime.month;

    totalMonths = (yearDiff * 12) + monthDiff;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getData();

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
      appBar: AppBar(
        title: Text("Lease"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: 450,
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
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
                            horizontalItems("Lease ID", lease.lid.split("-").first),
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
                                InkWell(
                                    onTap: (){},
                                    borderRadius: BorderRadius.circular(20),
                                    hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit, size: 15,color: CupertinoColors.systemBlue,),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Edit",
                                            style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            horizontalItems("Start Date", '${DateFormat('HH:mm').format(DateTime.parse(lease.start!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.start!))}'),
                            horizontalItems("End Date", lease.end!.isEmpty? "N/A" : '${DateFormat('HH:mm').format(DateTime.parse(lease.end!))}, ${DateFormat.yMMMEd().format(DateTime.parse(lease.end!))}'),
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
                                InkWell(
                                    onTap: (){},
                                    borderRadius: BorderRadius.circular(20),
                                    hoverColor: CupertinoColors.systemBlue.withOpacity(0.2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.edit, size: 15,color: CupertinoColors.systemBlue,),
                                          SizedBox(width: 5,),
                                          Text(
                                            "Edit",
                                            style: TextStyle(color: CupertinoColors.systemBlue, fontSize: 15, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    )
                                )
                              ],
                            ),
                            horizontalItems("Monthly Rent", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(unit.price.toString()))}'),
                            horizontalItems("Security Deposit", '${TFormat().getCurrency()}${TFormat().formatNumberWithCommas(double.parse(unit.deposit.toString()))}'),
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
        ],
      ),
    );
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
}
