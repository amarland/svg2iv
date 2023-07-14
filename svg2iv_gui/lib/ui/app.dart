import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common_flutter/theme.dart';

import '../main.dart';
import '../outer_world/preferences.dart';
import 'main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(
        preferences: FilePreferences(),
        accentColorDelegate: _AccentColorDelegate(),
      ),
      child: buildThemedMaterialApp(
        home: const MainPage(),
        name: appName,
      ),
    );
  }
}

class _AccentColorDelegate implements AccentColorDelegate {
  @override
  Future<Color?> get accentColor => DynamicColorPlugin.getAccentColor();
}
