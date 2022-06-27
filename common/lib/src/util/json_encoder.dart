import 'dart:convert';

import '../extensions.dart';

class CustomJsonEncoder extends JsonEncoder {
  CustomJsonEncoder() : super(_toEncodable);

  @override
  String convert(Object? object) {
    final result = super.convert(object).replaceAllMapped(
      // at least 5 decimal places or `.0`
      RegExp(r'\.\d{5,}|\.0(?!\d)'),
      (match) {
        return match.end - match.start == 2
            ? '' // is `.0`; erase
            : match.input.substring(match.start, match.start + 5);
      },
    );
    return result;
  }

  static dynamic _toEncodable(dynamic obj) {
    if (obj is Iterable) {
      return obj.toNonGrowableList();
    }
    return throw JsonUnsupportedObjectError(obj);
  }
}
