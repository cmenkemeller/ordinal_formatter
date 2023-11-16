// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
// ignore_for_file: avoid_dynamic_calls

import 'dart:js' as js;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:ordinal_formatter/ordinal_formatter_platform_interface.dart';

/// A web implementation of the OrdinalFormatterPlatform of the
/// OrdinalFormatter plugin.
class OrdinalFormatterWeb extends OrdinalFormatterPlatform {
  final defaultLocale = 'en';

  static void registerWith(Registrar registrar) {
    OrdinalFormatterPlatform.instance = OrdinalFormatterWeb();
  }

  @override
  Future<String?> format(int number, [String? localeCode]) async {
    //https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/PluralRules
    final locale = localeCode ?? defaultLocale;
    final ordinalRules = getOrdinalRules(number, locale);
    final suffix = ordinalSuffixes[locale]?[ordinalRules];
    if (suffix == null) {
      return null;
    }
    return '$number$suffix';
  }

  String? getOrdinalRules(int number, [String? localeCode]) {
    final ordinalFormatter = js.JsObject(
      js.context['Intl']['PluralRules'],
      [
        localeCode ?? defaultLocale,
        js.JsObject.jsify({'type': 'ordinal'}),
      ],
    );

    final ordinalRules = ordinalFormatter.callMethod('select', [number]);

    return ordinalRules;
  }

  // Localized ordinal documentation can be found at-
  // https://www.unicode.org/cldr/charts/43/supplemental/language_plural_rules.html
  final Map<String, Map<String, String>> ordinalSuffixes = {
    'en': {
      'one': 'st',
      'two': 'nd',
      'few': 'rd',
      'other': 'th',
    },
    // Add more languages and suffixes as needed
  };
}
