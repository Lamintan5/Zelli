import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;

class MpesaPaymentScreen extends StatefulWidget {
  @override
  _MpesaPaymentScreenState createState() => _MpesaPaymentScreenState();
}

class _MpesaPaymentScreenState extends State<MpesaPaymentScreen> {
  late IO.Socket socket;
  String paymentStatus = "Awaiting payment...";

  @override
  void initState() {
    super.initState();
    connectToSocket();
  }

  void connectToSocket() {
    socket = IO.io('http://YOUR_SERVER_URL', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();
    socket.onConnect((_) => print("Connected to socket"));

    socket.on("payment-status", (data) {
      setState(() {
        paymentStatus = data["status"] == "success"
            ? "Payment Successful"
            : "Payment Failed: ${data["message"]}";
      });
    });

    socket.onDisconnect((_) => print("Disconnected from socket"));
  }

  Future<void> initiatePayment() async {
    final url = Uri.parse("http://YOUR_SERVER_URL/api/pay");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: '{"amount": 100, "phoneNumber": "254712345678", "accountNumber": "ACC123", "businessNumber": "123456"}',
    );

    if (response.statusCode == 200) {
      setState(() {
        paymentStatus = "Payment initiated. Awaiting confirmation...";
      });
    } else {
      setState(() {
        paymentStatus = "Payment initiation failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("MPESA Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(paymentStatus, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: initiatePayment,
              child: Text("Pay with MPESA"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
