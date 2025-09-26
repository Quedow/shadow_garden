import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class Translator {
  static late Map<String, dynamic> _keys;
  static final String _defaultLocalName = 'en_US';

  static Future<void> load([String? localeName]) async {
    late String language;
    try {
      language = await rootBundle.loadString('assets/i18n/${localeName ?? Platform.localeName}.json');
    } catch (e) {
      language = await rootBundle.loadString('assets/i18n/$_defaultLocalName.json');
    }
    _keys = json.decode(language);
  }

  static String translate(String key, [List<dynamic> args = const <dynamic>[]]) {
    String content = _keys[key] ?? key;
    for (int i = 0; i < args.length; i++) {
      content = content.replaceAll('{$i}', args[i].toString());
    }
    return content;
  }
}

extension StringExtension on String {
  String t([List<dynamic> args = const <dynamic>[]]) {
    return Translator.translate(this, args);
  }
}