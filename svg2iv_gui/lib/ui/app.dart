import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:svg2iv_common_flutter/theme.dart' as common_theme;

import '../state/theme_cubit.dart';
import '../ui/main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const name = 'svg2iv_gui';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => ThemeCubit(),
      child: BlocBuilder<ThemeCubit, AppTheme?>(
        builder: (_, theme) {
          return _buildMaterialApp(
            theme,
            theme != null
                ? const MainPage()
                : const Center(
                    child: SizedBox(
                      width: 48.0,
                      height: 48.0,
                      child: CircularProgressIndicator(),
                    ),
                  ),
          );
        },
      ),
    );
  }

  static Widget _buildMaterialApp(AppTheme? theme, Widget home) {
    return MaterialApp(
      home: home,
      title: name,
      theme: theme != null
          ? _getTheme(theme.lightColorScheme, theme.isMaterial3)
          : null,
      darkTheme: theme != null
          ? _getTheme(theme.darkColorScheme, theme.isMaterial3)
          : null,
      themeMode: theme?.themeMode,
      debugShowCheckedModeBanner: false,
    );
  }

  static ThemeData _getTheme(ColorScheme colorScheme, bool useMaterial3) {
    final theme = common_theme.getTheme(colorScheme, useMaterial3);
    return theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: 'NotoSans'),
    );
  }
}
