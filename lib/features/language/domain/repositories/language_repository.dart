import 'package:flutter/material.dart';

abstract class LanguageRepository {
  Future<Locale?> loadLanguage();
  Future<void> saveLanguage(String languageCode);
}
