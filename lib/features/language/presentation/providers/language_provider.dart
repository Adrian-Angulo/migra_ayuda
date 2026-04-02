import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:migra_ayuda/features/language/data/repositories/language_repository_impl.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';

// Repository Provider
final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => LanguageRepositoryImpl(),
);

// Language Notifier
class LanguageNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadLanguage();
    return const Locale('es');
  }

  Future<void> _loadLanguage() async {
    final repository = ref.read(languageRepositoryProvider);
    final locale = await repository.loadLanguage();
    state = locale;
  }

  Future<void> changeLanguage(String languageCode) async {
    final repository = ref.read(languageRepositoryProvider);
    await repository.saveLanguage(languageCode);
    state = Locale(languageCode);
  }
}

// Language Provider
final languageProvider = NotifierProvider<LanguageNotifier, Locale>(
  () => LanguageNotifier(),
);
