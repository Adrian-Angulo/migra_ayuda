import 'package:flutter_riverpod/flutter_riverpod.dart';

// El provider guarda el idioma seleccionado: 'es' o 'en'
final languageProvider = StateProvider<String>((ref) => 'es');
