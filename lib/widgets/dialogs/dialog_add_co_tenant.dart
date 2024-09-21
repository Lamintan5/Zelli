import 'package:Zelli/models/units.dart';
import 'package:Zelli/resources/services.dart';
import 'package:flutter/material.dart';

import '../../models/users.dart';
import '../../utils/colors.dart';
import '../profile_images/user_profile.dart';

class DialogAddCoTenant extends StatefulWidget {
  final UnitModel unit;
  const DialogAddCoTenant({super.key, required this.unit});

  @override
  State<DialogAddCoTenant> createState() => _DialogAddCoTenantState();
}

class _DialogAddCoTenantState extends State<DialogAddCoTenant> {
  late TextEditingController _search;

  List<UserModel> _users = [];

  bool _loading = false;
  bool _isLoading = false;

  _getUsers()async{
    setState(() {
      _loading = true;
    });
    _users = await Services().getAllUsers();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _search = TextEditingController();
    _getUsers();
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
    final color2 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;

    List filteredList = [];
    if (_search.text.toString() != null && _search.text.isNotEmpty) {
      _users.forEach((item) {
        if (item.username.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.firstname.toString().toLowerCase().contains(_search.text.toString().toLowerCase())
            || item.lastname.toString().toLowerCase().contains(_search.text.toString().toLowerCase()))
          filteredList.add(item);
      });
    } else {
      filteredList = _users;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: _search,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: "🔎  Search for Tenants...",
              hintStyle: TextStyle(color: secondaryColor, fontWeight: FontWeight.normal),
              fillColor: color1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(5)
                ),
                borderSide: BorderSide.none,
              ),
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.all(10),
            ),
            onChanged:  (value) => setState((){}),
          ),
          SizedBox(height: 10,),
          _loading
              ? Center(child: SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: color2,strokeWidth: 2,)))
              : Expanded(
            child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index){
                  UserModel user = filteredList[index];
                  return InkWell(
                    onTap: (){
                      // dialogSendRequest(context, user);
                    },
                    borderRadius: BorderRadius.circular(5),
                    hoverColor: color1,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5)
                      ),
                      child: Row(
                        children: [
                          UserProfile(image: user.image!),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user.username.toString()),
                                Text('${user.firstname} ${user.lastname}', style: TextStyle(color: secondaryColor, fontSize: 12),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          _isLoading? LinearProgressIndicator(backgroundColor: color1,color: reverse,) : SizedBox()
        ],
      ),
    );
  }
}
