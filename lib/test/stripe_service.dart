import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'consts.dart';

class StripeService{
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> makePayment()async{
    try {
      String? paymentIntentClientSecret = await _createPaymentIntent(10, 'usd');
      if(paymentIntentClientSecret == null) return;
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntentClientSecret,
            merchantDisplayName: "William Free"
          ),
      );
      await _processPayment();
    } catch (e){
      print(e);
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency)async{
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        "amount": _calculatedAmount(amount),
        "currency":currency
      };
      var response = await dio.post(
          'https://api.stripe.com/v1/payment_intents',
          data: data,
          options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {
              "Authorization": "Bearer ${stripeSecretKey}",
              "Content-Type": 'application/x-www-form-urlencoded'
            }
          )
      );
      if(response!=null){
        return response.data['client_secret'];
      } else {
        return null;
      }
    } catch(e){
      print(e);
    }
    return null;
  }

  Future<void> _processPayment()async{
    try{
      await Stripe.instance.presentPaymentSheet();
    }catch(e){

    }
  }

  String _calculatedAmount(int amount){
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}