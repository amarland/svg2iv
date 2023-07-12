import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/theme.dart' as common_theme;
import 'package:svg2iv_web/main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const name = 'svg2iv';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainPage(),
      title: name,
      theme: common_theme.getTheme(const ColorScheme.light(), true),
      darkTheme: common_theme.getTheme(const ColorScheme.dark(), true),
      debugShowCheckedModeBanner: false,
    );
  }
}
