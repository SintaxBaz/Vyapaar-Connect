import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MenuOcrService {
  const MenuOcrService();

  Future<String> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    // English-only OCR.
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await recognizer.processImage(inputImage);
      return _normalizeOcrText(recognizedText.text);
    } finally {
      await recognizer.close();
    }
  }

  String _normalizeOcrText(String raw) {
    var t = raw;

    // Fix common UTF-8 mojibake for ₹.
    t = t.replaceAll('â‚¹', '₹');

    // Normalize currency hints so downstream parsing is easier.
    t = t.replaceAll(RegExp(r'\b(inr)\b', caseSensitive: false), '₹');
    t = t.replaceAll(RegExp(r'\b(rs\.?|rupees)\b', caseSensitive: false), '₹');

    // Merge spaced-out digits like "1 2 0" -> "120".
    t = t.replaceAllMapped(RegExp(r'\b\d(?:\s+\d){1,6}\b'), (m) {
      return m.group(0)!.replaceAll(RegExp(r'\s+'), '');
    });

    // Fix some OCR confusions inside numeric sequences.
    t = t.replaceAllMapped(RegExp(r'(?<=\d)[oO](?=\d)'), (_) => '0');
    t = t.replaceAllMapped(RegExp(r'(?<=\d)[lI](?=\d)'), (_) => '1');

    // Normalize whitespace.
    t = t.replaceAll(RegExp(r'[\t\r]+'), ' ');
    t = t.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return t.trim();
  }
}
