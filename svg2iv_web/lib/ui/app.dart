import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common_flutter/theme.dart';

import '../main.dart';
import '../preferences.dart';
import 'main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(preferences: BrowserPreferences()),
      child: buildThemedMaterialApp(
        home: const MainPage(),
        name: appName,
      ),
    );
  }
}
