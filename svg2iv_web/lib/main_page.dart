import 'package:flutter/material.dart';
import 'package:svg2iv_common_flutter/widgets.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return MainPageScaffold(
      onToggleThemeButtonPressed: () {},
      onAboutButtonPressed: () {},
      body: const Placeholder(),
    );
  }
}
