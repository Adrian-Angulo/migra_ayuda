import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// El título principal de la aplicación
  ///
  /// In es, this message translates to:
  /// **'Comenzar ahora'**
  String get appTitle;

  /// Mensaje de bienvenida en la pantalla principal
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido!'**
  String get welcomeMessage;

  /// Texto del botón para cambiar el idioma
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get changeLanguageButton;

  /// Muestra el idioma activo
  ///
  /// In es, this message translates to:
  /// **'Idioma actual: Español'**
  String get currentLanguage;

  /// un parrafo corto describiendo la app
  ///
  /// In es, this message translates to:
  /// **'Hola usuario'**
  String get gretting;

  /// Salir
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exitButton;

  /// Título de la primera página de onboarding
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a MigraAyuda!'**
  String get onboardingTitle1;

  /// Subtítulo de la primera página de onboarding
  ///
  /// In es, this message translates to:
  /// **'Estamos aquí para apoyarte en tu camino.\nEncuentra la ayuda que necesitas.'**
  String get onboardingSubtitle1;

  /// Título de la segunda página de onboarding
  ///
  /// In es, this message translates to:
  /// **'Encuentra ayuda cerca de ti'**
  String get onboardingTitle2;

  /// Subtítulo de la segunda página de onboarding
  ///
  /// In es, this message translates to:
  /// **'Localiza comedores, refugios y centros de salud en tiempo real usando tu ubicación GPS.'**
  String get onboardingSubtitle2;

  /// Título de la tercera página de onboarding
  ///
  /// In es, this message translates to:
  /// **'Estamos contigo'**
  String get onboardingTitle3;

  /// Subtítulo de la tercera página de onboarding
  ///
  /// In es, this message translates to:
  /// **'Puedes ver los comentarios de otros para que ingreses seguro y mires la experiencia.'**
  String get onboardingSubtitle3;

  /// Botón para omitir el onboarding
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get skipButton;

  /// Botón para ir a la siguiente página
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get nextButton;

  /// Botón para empezar a usar la aplicación
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get startButton;

  /// Título de la pantalla de selección de idioma
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguageTitle;

  /// Subtítulo en inglés de la pantalla de selección de idioma
  ///
  /// In es, this message translates to:
  /// **'Select Language'**
  String get selectLanguageSubtitle;

  /// Texto de ayuda para elegir idioma
  ///
  /// In es, this message translates to:
  /// **'Elige tu idioma para continuar\nChoose your language to continue'**
  String get chooseLanguageHint;

  /// Botón para continuar
  ///
  /// In es, this message translates to:
  /// **'Continuar / Continue'**
  String get continueButton;

  /// Nombre del idioma español
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

  /// Nombre del idioma inglés
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// Texto de bienvenida en la página de autenticación
  ///
  /// In es, this message translates to:
  /// **'Crea una cuenta o inicia sesión para explorar nuestra aplicación'**
  String get authWelcomeText;

  /// Pestaña de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get loginTab;

  /// Pestaña de registro
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerTab;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
