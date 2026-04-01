// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Start now';

  @override
  String get welcomeMessage => 'Welcome!';

  @override
  String get changeLanguageButton => 'Change language';

  @override
  String get currentLanguage => 'Current language: English';

  @override
  String get gretting => 'Hello user';

  @override
  String get exitButton => 'Exit';
}
