import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common_flutter/theme.dart';

import '../main.dart';
import 'main_page.dart';

class App extends StatelessWidget {
  const App({super.key, required this.themeCubit});

  final ThemeCubit themeCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>.value(
      value: themeCubit,
      child: buildThemedMaterialApp(
        home: const MainPage(),
        name: appName,
      ),
    );
  }
}
