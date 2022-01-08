import 'package:shared_preferences/shared_preferences.dart';

const _isDarkModeEnabled = "is_dark_mode_enabled";

Future<bool> isDarkModeEnabled() async =>
    (await SharedPreferences.getInstance()).getBool(_isDarkModeEnabled) ??
    false;

Future<bool> setDarkModeEnabled(bool enabled) async =>
    await (await SharedPreferences.getInstance())
        .setBool(_isDarkModeEnabled, enabled);
