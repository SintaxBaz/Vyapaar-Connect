import 'dart:convert';
import 'package:http/http.dart' as http;

class BillService {
  static Future<String> createBill({
    required List<Map<String, dynamic>> items,
    required double total,
  }) async {
    // 🔴 TEMP MOCK BACKEND
    // later replace with real API

    await Future.delayed(Duration(seconds: 1));

    // 🔹 Append bill amount to rewards URL
    final billAmount = total.toStringAsFixed(0); // Remove decimals
    final qrUrl = "https://vyapaar-connect-dfae0.web.app/?amount=$billAmount";
    
    print("QR URL: $qrUrl");
    return qrUrl;

  }
}
