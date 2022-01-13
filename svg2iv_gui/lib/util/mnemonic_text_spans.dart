import 'package:flutter/material.dart';

extension MnemonicTextSpansCreation on String {
  TextSpan asMnemonic({int charIndex = 0}) {
    if (charIndex >= length) throw ArgumentError.value(charIndex, "charIndex");
    final spans = <TextSpan>[];
    if (charIndex > 0) {
      spans.add(TextSpan(text: substring(0, charIndex)));
    }
    spans.add(
      TextSpan(
        text: this[charIndex],
        style: const TextStyle(decoration: TextDecoration.underline),
      ),
    );
    spans.add(TextSpan(text: substring(charIndex + 1)));
    return TextSpan(children: spans);
  }
}
