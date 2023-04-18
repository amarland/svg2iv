import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../outer_world/preferences.dart';

class ThemeCubit extends Cubit<AppTheme?> {
  ThemeCubit() : super(null) {
    _loadTheme();
  }

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
    await Preferences.setDarkModeEnabled(isCurrentThemeLight);
  }

  void _loadTheme() async {
    final themeMode = await Preferences.getThemeMode();
    final useMaterial3 = await Preferences.isMaterial3Enabled();
    final accentColor = await DynamicColorPlugin.getAccentColor();
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
    emit(AppTheme._(lightColors, darkColors, themeMode, useMaterial3));
  }
}

class AppTheme {
  const AppTheme._(
    this.lightColorScheme,
    this.darkColorScheme,
    this.themeMode,
    this.isMaterial3,
  );

  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;
  final ThemeMode themeMode;
  final bool isMaterial3;

  AppTheme copyWith({
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    ThemeMode? themeMode,
    bool? isMaterial3,
  }) {
    return AppTheme._(
      lightColorScheme ?? this.lightColorScheme,
      darkColorScheme ?? this.darkColorScheme,
      themeMode ?? this.themeMode,
      isMaterial3 ?? this.isMaterial3,
    );
  }
}
