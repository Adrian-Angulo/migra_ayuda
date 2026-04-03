import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/language/domain/repositories/language_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepositoryImpl implements LanguageRepository {
  @override
  Future<Locale?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language');
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null;
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
  }

  @override
  Future<bool> hasSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('language_selected') ?? false;
  }

  @override
  Future<void> markLanguageAsSelected() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('language_selected', true);
  }
}
