import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class CurrencyService  {
  final String _apiKey = '4b17bace6855f24d877aa384';
  final String _baseUrl = 'https://api.exchangerate-api.com/v4/latest';


  Future<Map<String, double>> fetchExchangeRates(String baseCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency?apikey=$_apiKey'));
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = data['rates'] as Map<String, dynamic>;
      sharedPreferences.setStringList('rates', rates.entries.map((entry) => '${entry.key}: ${entry.value}').toList());
      myRates = rates;
      return rates.map((key, value) => MapEntry(key, value.toDouble()));

    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  double convertCurrency({
    required String toCurrency,
    required double amount}) {

    if (myRates.containsKey("USD") && myRates.containsKey(toCurrency)) {

      double fromRate = double.parse(myRates["USD"]);
      double toRate = double.parse(myRates[toCurrency]);


      return amount * (toRate / fromRate);
    } else {
      throw Exception('Currency not found in rates map');
    }
  }
}


