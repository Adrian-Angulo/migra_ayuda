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

  /// label correo electronico
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailText;

  /// label para contraseña
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get password;

  /// label olvidades tu contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get resetPassword;

  /// texto para boton continuar con google
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get googleText;

  /// label para nombre
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get firstName;

  /// label para apellido
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get lastName;

  /// label para país de origen
  ///
  /// In es, this message translates to:
  /// **'País de origen'**
  String get originCountry;

  /// label para elegir una opción
  ///
  /// In es, this message translates to:
  /// **'Elige una opción'**
  String get chooseAnOption;

  /// label para país de destino
  ///
  /// In es, this message translates to:
  /// **'País de destino'**
  String get destinationCountry;

  /// label para edad
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get age;

  /// label para confirmación de contraseña
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// texto previo a los enlaces de términos y política
  ///
  /// In es, this message translates to:
  /// **'Acepto los'**
  String get iAccept;

  /// enlace a términos y condiciones de uso
  ///
  /// In es, this message translates to:
  /// **'términos y condiciones de uso'**
  String get termsAndConditions;

  /// conector entre términos y política de privacidad
  ///
  /// In es, this message translates to:
  /// **'y la'**
  String get and;

  /// enlace a política de privacidad
  ///
  /// In es, this message translates to:
  /// **'política de privacidad'**
  String get privacyPolicy;

  /// Título de la pantalla de restablecimiento de contraseña
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get resetPasswordTitle;

  /// Texto de ayuda para ingresar el correo en la pantalla de restablecimiento de contraseña
  ///
  /// In es, this message translates to:
  /// **'Introduce tu correo para recibir un enlace y restablecer tu contraseña'**
  String get resetPasswordEmailHint;

  /// Botón para enviar el enlace de restablecimiento de contraseña
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get sendLinkButton;

  /// Botón para volver a la pantalla de inicio de sesión
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio de sesión'**
  String get backToLoginButton;

  /// Título que indica que el enlace fue enviado
  ///
  /// In es, this message translates to:
  /// **'¡Enlace enviado!'**
  String get linkSentTitle;

  /// Mensaje informativo tras enviar el enlace de restablecimiento
  ///
  /// In es, this message translates to:
  /// **'Te hemos enviado un enlace para restablecer tu contraseña. Revisa tu bandeja de entrada y también tu carpeta de spam. Recuerda que el correo debe estar registrado en el sistema'**
  String get linkSentMessage;

  /// Recordatorio para revisar la carpeta de spam si no se encuentra el correo
  ///
  /// In es, this message translates to:
  /// **'Si no encuentras el correo, revisa tu carpeta de spam o correo no deseado.'**
  String get spamReminder;

  /// Hint para el campo de correo electrónico
  ///
  /// In es, this message translates to:
  /// **'Ej. usuario@gmail.com'**
  String get emailHint;

  /// Hint para el campo de nombre
  ///
  /// In es, this message translates to:
  /// **'Juan'**
  String get firstNameHint;

  /// Hint para el campo de apellido
  ///
  /// In es, this message translates to:
  /// **'Castillo'**
  String get lastNameHint;

  /// Hint para el campo de edad
  ///
  /// In es, this message translates to:
  /// **'Ej. 24'**
  String get ageHint;

  /// Hint para el campo de contraseña
  ///
  /// In es, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// Hint para el campo de correo en reset password
  ///
  /// In es, this message translates to:
  /// **'migraAyuda@correo.com'**
  String get emailResetHint;

  /// Texto divisor entre opciones de autenticación
  ///
  /// In es, this message translates to:
  /// **'O'**
  String get orDivider;

  /// Botón para iniciar sesión
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// Título de la pantalla de completar información
  ///
  /// In es, this message translates to:
  /// **'Completar información'**
  String get completeInfoTitle;

  /// Botón para completar información
  ///
  /// In es, this message translates to:
  /// **'Completar Información'**
  String get completeInfoButton;

  /// Botón para cancelar
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// Tab de inicio en navegación
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get homeTab;

  /// Tab de explorar en navegación
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get exploreTab;

  /// Tab de perfil en navegación
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTab;

  /// Tab de entidades en navegación admin
  ///
  /// In es, this message translates to:
  /// **'Entidades'**
  String get entitiesTab;

  /// Tab de servicios en navegación admin
  ///
  /// In es, this message translates to:
  /// **'Servicios'**
  String get servicesTab;

  /// Tab de usuarios en navegación admin
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get usersTab;

  /// Opción para editar perfil
  ///
  /// In es, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// Opción para cambiar idioma
  ///
  /// In es, this message translates to:
  /// **'Cambiar Idioma'**
  String get changeLanguage;

  /// Opción para cerrar sesión
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logout;

  /// Rol de migrante
  ///
  /// In es, this message translates to:
  /// **'Migrante'**
  String get migrantRole;

  /// Rol de administrador
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get adminRole;

  /// Label para país de origen en perfil
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get originLabel;

  /// Label para país de destino en perfil
  ///
  /// In es, this message translates to:
  /// **'Destino'**
  String get destinationLabel;

  /// Mensaje de bienvenida en pantalla explorar
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a explorar'**
  String get welcomeToExplore;

  /// Mensaje de bienvenida en pantalla inicio
  ///
  /// In es, this message translates to:
  /// **'Bienvenido al inicio'**
  String get welcomeToHome;

  /// Texto cuando no hay datos disponibles
  ///
  /// In es, this message translates to:
  /// **'No data'**
  String get noData;

  /// Error de validación: correo requerido
  ///
  /// In es, this message translates to:
  /// **'El correo es obligatorio'**
  String get errorEmailRequired;

  /// Error de validación: formato de correo inválido
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido'**
  String get errorEmailInvalid;

  /// Error de validación: contraseña requerida
  ///
  /// In es, this message translates to:
  /// **'La contraseña es obligatoria'**
  String get errorPasswordRequired;

  /// Error de validación: contraseña muy corta
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres'**
  String get errorPasswordMinLength;

  /// Error de validación: contraseña muy corta (versión corta)
  ///
  /// In es, this message translates to:
  /// **'Debe tener mínimo 8 caracteres'**
  String get errorPasswordMinLength2;

  /// Error de validación: nombre requerido
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu nombre'**
  String get errorFirstNameRequired;

  /// Error de validación: apellido requerido
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu apellido'**
  String get errorLastNameRequired;

  /// Error de validación: confirmación de contraseña requerida
  ///
  /// In es, this message translates to:
  /// **'Por favor confirma tu contraseña'**
  String get errorConfirmPasswordRequired;

  /// Error de validación: contraseñas no coinciden
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get errorPasswordsNotMatch;

  /// Error de validación: opción no seleccionada
  ///
  /// In es, this message translates to:
  /// **'Por favor selecciona una opción'**
  String get errorSelectOption;

  /// Error de validación: edad requerida
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu edad'**
  String get errorAgeRequired;

  /// Error de validación: edad fuera de rango
  ///
  /// In es, this message translates to:
  /// **'Edad debe ser entre 18 y 100 años'**
  String get errorAgeRange;

  /// Error de validación: formato de correo inválido
  ///
  /// In es, this message translates to:
  /// **'Formato de correo inválido'**
  String get errorEmailFormat;

  /// Error de validación: correo electrónico requerido
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu correo electrónico'**
  String get errorEnterEmail;

  /// Error: términos y condiciones no aceptados
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar los términos y condiciones'**
  String get errorAcceptTerms;

  /// Mensaje de éxito tras registro
  ///
  /// In es, this message translates to:
  /// **'¡Registro exitoso! Verifica tu correo para iniciar sesión. Si no lo encuentras, revisa tu carpeta de spam.'**
  String get successRegistration;

  /// Error: correo ya registrado
  ///
  /// In es, this message translates to:
  /// **'Este correo ya está registrado'**
  String get authErrorEmailInUse;

  /// Error: credenciales inválidas
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrecta'**
  String get authErrorInvalidCredential;

  /// Error: correo no válido
  ///
  /// In es, this message translates to:
  /// **'El correo no es válido'**
  String get authErrorInvalidEmail;

  /// Error: contraseña débil
  ///
  /// In es, this message translates to:
  /// **'La contraseña es demasiado débil'**
  String get authErrorWeakPassword;

  /// Error: correo no verificado
  ///
  /// In es, this message translates to:
  /// **'Debes verificar tu correo para iniciar sesión'**
  String get authErrorEmailNotVerified;

  /// Error: usuario no encontrado
  ///
  /// In es, this message translates to:
  /// **'El usuario no se encuentra registrado'**
  String get authErrorUserNotFound;

  /// Error: operación cancelada
  ///
  /// In es, this message translates to:
  /// **'Se canceló la operación'**
  String get authErrorOperationCancelled;

  /// Error: operación no permitida
  ///
  /// In es, this message translates to:
  /// **'Operación no permitida'**
  String get authErrorOperationNotAllowed;

  /// Error: sin conexión
  ///
  /// In es, this message translates to:
  /// **'Error de conexión a internet'**
  String get authErrorNetwork;

  /// Error: error inesperado
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get authErrorUnexpected;

  /// Error: datos de usuario no encontrados
  ///
  /// In es, this message translates to:
  /// **'No se encontraron datos del usuario'**
  String get authErrorUserDataNotFound;
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
