import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _key = 'locale';

  LocaleNotifier() : super(const Locale('es')) {
    _load();
  }

  void _load() {
    final box = Hive.box('settings');
    final langCode = box.get(_key, defaultValue: 'es') as String;
    state = Locale(langCode);
  }

  void toggle() {
    final nowEs = state.languageCode != 'es';
    state = nowEs ? const Locale('es') : const Locale('en');
    Hive.box('settings').put(_key, state.languageCode);
  }

  bool get isSpanish => state.languageCode == 'es';
}
