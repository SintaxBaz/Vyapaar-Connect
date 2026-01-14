import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_config.dart';
import '../menu_item.dart';

class GeminiMenuService {
  GeminiMenuService({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  Future<List<MenuItem>> parseMenuItems({required String ocrText}) async {
    final trimmed = ocrText.trim();
    if (trimmed.isEmpty) return const [];

    if (AppConfig.hasBackend) {
      return _parseViaBackend(ocrText: trimmed);
    }

    if (AppConfig.hasApiKey) {
      return _parseViaDirectGemini(ocrText: trimmed);
    }

    // Fallback: try to guess items from OCR lines.
    return _parseHeuristically(trimmed);
  }

  Future<List<MenuItem>> _parseViaBackend({required String ocrText}) async {
    final uri = Uri.parse(AppConfig.geminiBackendUrl);
    final res = await _http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'ocrText': ocrText}),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Backend parse failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    return _menuItemsFromDecoded(decoded);
  }

  Future<List<MenuItem>> _parseViaDirectGemini({required String ocrText}) async {
    // NOTE: This exposes the API key in the client app. Use backend for production.
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${Uri.encodeQueryComponent(AppConfig.geminiApiKey)}',
    );

    final prompt = _buildPrompt(ocrText);

    final res = await _http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.2,
          'maxOutputTokens': 2048,
        },
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Gemini API failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);

    final text = _extractTextFromGeminiResponse(decoded);
    final jsonPayload = _extractJsonPayload(text);
    final parsed = jsonDecode(jsonPayload);

    return _menuItemsFromDecoded(parsed);
  }

  String _buildPrompt(String ocrText) {
    return '''You are given OCR text from a restaurant/cafe menu.

Task:
- Extract menu items and prices.
- Return ONLY valid JSON.
-Make sure its existing Indian Food Menu items.

Output format:
[
  {"name": "Item name", "price": 120},
  {"name": "Another item", "price": 80}
]

Rules:
- price must be a number (integer rupees); ignore currency symbols.
- If an item has no price, omit it.
- Remove obvious duplicates.
- Ignore headings, addresses, phone numbers, taxes, totals.

OCR TEXT:
${ocrText}
''';
  }

  String _extractTextFromGeminiResponse(dynamic decoded) {
    // generativelanguage response schema: candidates[0].content.parts[0].text
    try {
      final candidates = decoded['candidates'] as List;
      if (candidates.isEmpty) return '';
      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      if (parts.isEmpty) return '';
      final text = parts.first['text'];
      return (text is String) ? text : '';
    } catch (_) {
      return '';
    }
  }

  String _extractJsonPayload(String text) {
    final t = text.trim();
    if (t.isEmpty) throw Exception('Gemini returned empty response');

    // If it returned fenced code block ```json ... ```
    final fenceStart = t.indexOf('```');
    if (fenceStart != -1) {
      final fenceEnd = t.lastIndexOf('```');
      if (fenceEnd > fenceStart) {
        final inside = t.substring(fenceStart + 3, fenceEnd).trim();
        // Strip optional language label like "json" on first line.
        final lines = inside.split('\n');
        if (lines.isNotEmpty && lines.first.trim().toLowerCase() == 'json') {
          return lines.skip(1).join('\n').trim();
        }
        return inside;
      }
    }

    // Otherwise attempt to find the first JSON array/object.
    final firstArray = t.indexOf('[');
    final lastArray = t.lastIndexOf(']');
    if (firstArray != -1 && lastArray != -1 && lastArray > firstArray) {
      return t.substring(firstArray, lastArray + 1);
    }

    final firstObj = t.indexOf('{');
    final lastObj = t.lastIndexOf('}');
    if (firstObj != -1 && lastObj != -1 && lastObj > firstObj) {
      return t.substring(firstObj, lastObj + 1);
    }

    throw Exception('Could not find JSON in Gemini response');
  }

  List<MenuItem> _menuItemsFromDecoded(dynamic decoded) {
    final items = <MenuItem>[];

    dynamic list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map && decoded['items'] is List) {
      list = decoded['items'];
    }

    if (list is! List) return const [];

    final seen = <String>{};

    for (final raw in list) {
      if (raw is! Map) continue;
      final name = (raw['name'] ?? raw['item'] ?? '').toString().trim();
      if (name.isEmpty) continue;

      final priceRaw = raw['price'];
      final price = _coerceInt(priceRaw);
      if (price == null || price <= 0) continue;

      final key = '${name.toLowerCase()}::$price';
      if (seen.contains(key)) continue;
      seen.add(key);

      items.add(MenuItem(name: name, price: price));
    }

    return items;
  }

  int? _coerceInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.round();

    final s = value.toString();
    final digits = RegExp(r'(\d+)').firstMatch(s)?.group(1);
    if (digits == null) return null;
    return int.tryParse(digits);
  }

  List<MenuItem> _parseHeuristically(String ocrText) {
    final items = <MenuItem>[];
    final seen = <String>{};

    for (final line in ocrText.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Very simple: "Name .... 120" or "Name 120"
      final match = RegExp(r'^(.*?)(?:\s+|\.+\s*)(\d{1,5})\s*$').firstMatch(trimmed);
      if (match == null) continue;

      final name = match.group(1)?.replaceAll(RegExp(r'[\.:]+$'), '').trim() ?? '';
      final price = int.tryParse(match.group(2) ?? '');
      if (name.isEmpty || price == null || price <= 0) continue;

      final key = '${name.toLowerCase()}::$price';
      if (seen.contains(key)) continue;
      seen.add(key);

      items.add(MenuItem(name: name, price: price));
    }

    return items;
  }
}
