import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/language/data/datasources/language_local_datasource.dart';
import 'package:migra_ayuda/features/language/data/datasources/language_local_datasource_impl.dart';
import 'package:migra_ayuda/features/language/data/repositories/language_repository_impl.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';

// DataSource Provider
final languageLocalDataSourceProvider = Provider<LanguageLocalDataSource>(
  (ref) => LanguageLocalDataSourceImpl(),
);

// Repository Provider (con inyección de dependencias)
final languageRepositoryProvider = Provider<LanguageRepository>(
  (ref) => LanguageRepositoryImpl(
    ref.watch(languageLocalDataSourceProvider),
  ),
);

// Language Notifier
class LanguageNotifier extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final repository = ref.watch(languageRepositoryProvider);
    return await repository.loadLanguage();
  }

  Future<void> changeLanguage(String languageCode) async {
    final repository = ref.read(languageRepositoryProvider);
    try {
      await repository.saveLanguage(languageCode);
      state = AsyncData(Locale(languageCode));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Helper para obtener el código de idioma actual
  String? get currentLanguageCode => state.value?.languageCode;
}

// Language Provider
final languageProvider = AsyncNotifierProvider<LanguageNotifier, Locale?>(
  () => LanguageNotifier(),
);
