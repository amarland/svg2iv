import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/main_page_bloc.dart';
import '../state/main_page_state.dart';
import '../ui/main_page.dart';
import '../util/custom_material_localizations.dart';

const _androidGreen = Color(0xFF00DE7A);
const _androidBlue = Color(0xFF2196F3);

class App extends StatelessWidget {
  const App({super.key, required this.bloc});

  static const name = 'svg2iv';
  static const _useMaterial3 = true;

  final MainPageBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc,
      child: BlocBuilder<MainPageBloc, MainPageState>(
        bloc: bloc,
        builder: (context, _) {
          if (_useMaterial3) {
            return FutureBuilder<Color?>(
              future: DynamicColorPlugin.getAccentColor(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final accentColor = snapshot.data;
                  return _buildMaterialApp(
                    lightColors: ColorScheme.fromSeed(
                      seedColor: accentColor ?? _androidBlue,
                    ),
                    darkColors: ColorScheme.fromSeed(
                      seedColor: accentColor ?? _androidGreen,
                      brightness: Brightness.dark,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          } else {
            return _buildMaterialApp(
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
        },
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
      themeMode: bloc.state.themeMode,
      localizationsDelegates: const [
        CustomMaterialLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _getTheme(ColorScheme colorScheme) {
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
