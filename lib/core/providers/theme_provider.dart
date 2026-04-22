import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _boxName = 'settings';
  static const _key = 'isDark';

  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  void _load() {
    final box = Hive.box(_boxName);
    final isDark = box.get(_key, defaultValue: true) as bool;
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    final nowDark = state != ThemeMode.dark;
    state = nowDark ? ThemeMode.dark : ThemeMode.light;
    Hive.box(_boxName).put(_key, nowDark);
  }

  bool get isDark => state == ThemeMode.dark;
}
