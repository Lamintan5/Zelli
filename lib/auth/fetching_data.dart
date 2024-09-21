
import 'package:flutter/material.dart';


class FetchingData extends StatefulWidget {
  const FetchingData({super.key});

  @override
  State<FetchingData> createState() => _FetchingDataState();
}

class _FetchingDataState extends State<FetchingData> {


  @override
  Widget build(BuildContext context) {
    final reverse = Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black;
    final normal = Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
    final color5 = Theme.of(context).brightness == Brightness.dark
        ? Colors.white54
        : Colors.black54;
    final image = Theme.of(context).brightness == Brightness.dark
        ? "assets/logo/5logo_white.png"
        : "assets/logo/5logo_black.png";
    return Scaffold(
      backgroundColor: normal,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(),
          Text("S T U D I O 5 I V E", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w100, color: reverse)),
        ],
      ),
    );
  }
}
