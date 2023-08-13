import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'preferences.dart';

Widget buildThemedMaterialApp({
  required Widget home,
  required String name,
}) {
  return BlocBuilder<ThemeCubit, _AppTheme?>(
    builder: (_, theme) {
      return MaterialApp(
        home: theme != null
            ? home
            : const Center(
                child: SizedBox(
                  width: 48.0,
                  height: 48.0,
                  child: CircularProgressIndicator(),
                ),
              ),
        title: name,
        theme: theme != null
            ? _getThemeData(theme.lightColorScheme, theme.isMaterial3)
            : null,
        darkTheme: theme != null
            ? _getThemeData(theme.darkColorScheme, theme.isMaterial3)
            : null,
        themeMode: theme?.themeMode,
        debugShowCheckedModeBanner: false,
      );
    },
  );
}

ThemeData _getThemeData(ColorScheme colorScheme, bool useMaterial3) {
  final typography = Typography.material2021(colorScheme: colorScheme);
  final themeData = ThemeData.from(
    colorScheme: colorScheme,
    textTheme: (colorScheme.brightness == Brightness.light
            ? typography.black
            : typography.white)
        .apply(fontFamily: 'NotoSans'),
    useMaterial3: useMaterial3,
  );
  final segmentedButtonThemeData = themeData.segmentedButtonTheme;
  final segmentedButtonBackgroundColor = MaterialStateColor.resolveWith(
    (states) {
      if (states.contains(MaterialState.disabled)) {
        return colorScheme.surface.withOpacity(0.38);
      }
      if (states.contains(MaterialState.selected)) {
        return colorScheme.secondaryContainer;
      }
      return colorScheme.surface;
    },
  );
  return themeData.copyWith(
    inputDecorationTheme: themeData.inputDecorationTheme.copyWith(
      border: const OutlineInputBorder(),
      alignLabelWithHint: true,
    ),
    segmentedButtonTheme: segmentedButtonThemeData.copyWith(
      style: segmentedButtonThemeData.style
              ?.copyWith(backgroundColor: segmentedButtonBackgroundColor) ??
          ButtonStyle(backgroundColor: segmentedButtonBackgroundColor),
    ),
  );
}

class ThemeCubit extends Cubit<_AppTheme?> {
  ThemeCubit({
    required Preferences preferences,
    AccentColorDelegate? accentColorDelegate,
  })  : _preferences = preferences,
        _accentColorDelegate = accentColorDelegate,
        super(null) {
    _loadTheme();
  }

  final Preferences _preferences;
  final AccentColorDelegate? _accentColorDelegate;

  static const _androidGreen = Color(0xFF00DE7A);
  static const _androidBlue = Color(0xFF2196F3);

  void toggleTheme() async {
    final currentTheme = state;
    if (currentTheme == null) {
      return;
    }
    final isCurrentThemeLight = currentTheme.themeMode == ThemeMode.light;
    emit(
      currentTheme.copyWith(
        themeMode: isCurrentThemeLight ? ThemeMode.dark : ThemeMode.light,
      ),
    );
    await _preferences.setDarkModeEnabled(isCurrentThemeLight);
  }

  void _loadTheme() async {
    final themeMode = await _preferences.getThemeMode();
    final useMaterial3 = await _preferences.isMaterial3Enabled();
    final accentColor = await _accentColorDelegate?.accentColor;
    final ColorScheme lightColors;
    final ColorScheme darkColors;
    if (useMaterial3) {
      lightColors = ColorScheme.fromSeed(
        seedColor: accentColor ?? _androidBlue,
      );
      darkColors = ColorScheme.fromSeed(
        seedColor: accentColor ?? _androidGreen,
        brightness: Brightness.dark,
      );
    } else {
      lightColors = const ColorScheme.light(
        primary: _androidBlue,
        secondary: _androidGreen,
      );
      darkColors = const ColorScheme.dark(
        primary: _androidGreen,
        secondary: _androidBlue,
      );
    }
    // BUT WHY?! Without this delay, the content of the window is all white
    // and nothing is ever drawn. TODO: investigate
    await Future<void>.delayed(
      const Duration(milliseconds: 150),
    );
    emit(_AppTheme._(lightColors, darkColors, themeMode, useMaterial3));
  }
}

class _AppTheme {
  const _AppTheme._(
    this.lightColorScheme,
    this.darkColorScheme,
    this.themeMode,
    this.isMaterial3,
  );

  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ThemeMode themeMode;
  final bool isMaterial3;

  _AppTheme copyWith({
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    ThemeMode? themeMode,
    bool? isMaterial3,
  }) {
    return _AppTheme._(
      lightColorScheme ?? this.lightColorScheme,
      darkColorScheme ?? this.darkColorScheme,
      themeMode ?? this.themeMode,
      isMaterial3 ?? this.isMaterial3,
    );
  }
}

abstract interface class AccentColorDelegate {
  Future<Color?> get accentColor;
}
