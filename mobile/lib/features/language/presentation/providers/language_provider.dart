import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:migra_ayuda/features/language/data/repositories/language_repository_impl.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';

// Repository Provider
final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => LanguageRepositoryImpl(),
);

// Language Notifier
class LanguageNotifier extends Notifier<Locale?> {
  @override
  Locale build() {
    _loadLanguage();
    return const Locale('es');
  }

  Future<void> _loadLanguage() async {
    final repository = ref.read(languageRepositoryProvider);
    final locale = await repository.loadLanguage();
    if (locale != null) {
      state = locale;
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final repository = ref.read(languageRepositoryProvider);
    await repository.saveLanguage(languageCode);
    await repository.markLanguageAsSelected();
    state = Locale(languageCode);
  }
}

// Language Provider
final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  () => LanguageNotifier(),
);

// Language Selection Status Notifier
class LanguageSelectionNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadLanguageSelectionStatus();
    return false;
  }

  Future<void> _loadLanguageSelectionStatus() async {
    final repository = ref.read(languageRepositoryProvider);
    final hasSelected = await repository.hasSelectedLanguage();
    state = hasSelected;
  }
}

// Language Selection Provider
final languageSelectionProvider =
    NotifierProvider<LanguageSelectionNotifier, bool>(
  () => LanguageSelectionNotifier(),
);
