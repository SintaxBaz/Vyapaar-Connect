import 'dart:io';

import '../menu_item.dart';
import 'gemini_menu_service.dart';
import 'menu_ocr_service.dart';

class MenuService {
  MenuService({MenuOcrService? ocrService, GeminiMenuService? geminiService})
      : _ocr = ocrService ?? const MenuOcrService(),
        _gemini = geminiService ?? GeminiMenuService();

  final MenuOcrService _ocr;
  final GeminiMenuService _gemini;

  Future<List<MenuItem>> extractMenu(File image) async {
    final ocrText = await _ocr.recognizeText(image);
    return _gemini.parseMenuItems(ocrText: ocrText);
  }
}
