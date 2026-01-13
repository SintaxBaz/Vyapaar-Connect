import 'dart:io';
import 'menu_item.dart';

class MenuService {
  static Future<List<MenuItem>> extractMenu(File image) async {
    // 🔥 Simulated Gemini response
    await Future.delayed(const Duration(seconds: 2));

    return [
      MenuItem(name: "Chai", price: 10),
      MenuItem(name: "Samosa", price: 15),
      MenuItem(name: "Bun Maska", price: 15),
    ];
  }
}
