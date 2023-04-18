import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/theme_cubit.dart';
import '../ui/main_page.dart';
import '../util/custom_material_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  static const name = 'svg2iv';

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
      localizationsDelegates: const [CustomMaterialLocalizations.delegate],
      debugShowCheckedModeBanner: false,
    );
  }

  static ThemeData _getTheme(ColorScheme colorScheme, bool useMaterial3) {
    final typography = Typography.material2021(colorScheme: colorScheme);
    return ThemeData.from(
      colorScheme: colorScheme,
      textTheme: (colorScheme.brightness == Brightness.light
              ? typography.black
              : typography.white)
          .apply(fontFamily: 'WorkSans'),
      useMaterial3: useMaterial3,
    ).copyWith(
      platform: TargetPlatform.windows,
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
