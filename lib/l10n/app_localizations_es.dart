// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Comenzar ahora';

  @override
  String get welcomeMessage => '¡Bienvenido!';

  @override
  String get changeLanguageButton => 'Cambiar idioma';

  @override
  String get currentLanguage => 'Idioma actual: Español';

  @override
  String get gretting => 'Hola usuario';

  @override
  String get exitButton => 'Salir';
}
