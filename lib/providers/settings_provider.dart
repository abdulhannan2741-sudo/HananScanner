import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages user preferences: theme mode, default color mode, and other
/// settings persisted across sessions.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider();

  ThemeMode _themeMode = ThemeMode.system;
  ColorMode _defaultColorMode = ColorMode.colorEnhanced;
  bool _hdScan = true;
  bool _autoCrop = true;
  bool _showAds = true;

  ThemeMode get themeMode => _themeMode;
  ColorMode get defaultColorMode => _defaultColorMode;
  bool get hdScan => _hdScan;
  bool get autoCrop => _autoCrop;
  bool get showAds => _showAds;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    _defaultColorMode = ColorMode
        .values[prefs.getInt('defaultColorMode') ?? 1];
    _hdScan = prefs.getBool('hdScan') ?? true;
    _autoCrop = prefs.getBool('autoCrop') ?? true;
    _showAds = prefs.getBool('showAds') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> setDefaultColorMode(ColorMode mode) async {
    _defaultColorMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultColorMode', mode.index);
    notifyListeners();
  }

  Future<void> setHdScan(bool v) async {
    _hdScan = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hdScan', v);
    notifyListeners();
  }

  Future<void> setAutoCrop(bool v) async {
    _autoCrop = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoCrop', v);
    notifyListeners();
  }

  Future<void> setShowAds(bool v) async {
    _showAds = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showAds', v);
    notifyListeners();
  }
}

export '../models/scan_document.dart' show ColorMode;
