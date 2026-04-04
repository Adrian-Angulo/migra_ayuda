import 'package:flutter/material.dart';

abstract class LanguageRepository {
  Future<Locale?> loadLanguage();
  Future<void> saveLanguage(String languageCode);
  Future<bool> hasSelectedLanguage();
  Future<void> markLanguageAsSelected();
}
