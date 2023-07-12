import 'package:flutter/material.dart';

ThemeData getTheme(ColorScheme colorScheme, bool useMaterial3) {
  final typography = Typography.material2021(colorScheme: colorScheme);
  return ThemeData.from(
    colorScheme: colorScheme,
    textTheme: colorScheme.brightness == Brightness.light
        ? typography.black
        : typography.white,
    useMaterial3: useMaterial3,
  ).copyWith(
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
