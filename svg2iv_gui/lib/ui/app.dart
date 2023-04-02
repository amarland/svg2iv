import 'package:flutter/material.dart';

import '../ui/main_page.dart';
import '../util/custom_material_localizations.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

class App extends StatelessWidget {
  const App({super.key});

  static const name = 'svg2iv';

  // TODO: stop hard-coding this
  static const _useMaterial3 = true;

  @override
  Widget build(BuildContext context) {
    // TODO: get the value from "somewhere"
    const accentColor = Colors.blueAccent;
    return _useMaterial3
        ? _buildMaterialApp(
            lightColors: ColorScheme.fromSeed(
              seedColor: accentColor ?? _androidBlue,
            ),
            darkColors: ColorScheme.fromSeed(
              seedColor: accentColor ?? _androidGreen,
              brightness: Brightness.dark,
            ),
          )
        : _buildMaterialApp(
            lightColors: const ColorScheme.light(
              primary: _androidBlue,
              secondary: _androidGreen,
            ),
            darkColors: const ColorScheme.dark(
              primary: _androidGreen,
              secondary: _androidBlue,
            ),
          );
  }

  Widget _buildMaterialApp({
    required ColorScheme lightColors,
    required ColorScheme darkColors,
  }) {
    return MaterialApp(
      home: const MainPage(),
      title: 'svg2iv',
      theme: _getTheme(lightColors),
      darkTheme: _getTheme(darkColors),
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [CustomMaterialLocalizations.delegate],
      debugShowCheckedModeBanner: false,
    );
  }

  static ThemeData _getTheme(ColorScheme colorScheme) {
    final typography = Typography.material2021(colorScheme: colorScheme);
    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: (colorScheme.brightness == Brightness.light
              ? typography.black
              : typography.white)
          .apply(fontFamily: 'WorkSans'),
      useMaterial3: _useMaterial3,
    ).copyWith(
      platform: TargetPlatform.windows,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
