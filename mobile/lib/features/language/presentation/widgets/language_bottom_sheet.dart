import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/widgets/language_option.dart';

class LanguageBottomSheet extends ConsumerStatefulWidget {
  const LanguageBottomSheet({super.key});

  @override
  ConsumerState<LanguageBottomSheet> createState() =>
      _LanguageBottomSheetState();
}

class _LanguageBottomSheetState extends ConsumerState<LanguageBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          const Text(
            'Seleccionar Idioma',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select Language',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Opciones de idioma
          LanguageOption(
            flag: '🇪🇸',
            name: 'Español',
            subtitle: 'Spanish',
            isSelected: currentLanguage == 'es',
            onTap: () async {
              await ref.read(languageProvider.notifier).changeLanguage('es');
            },
          ),
          const SizedBox(height: 12),

          LanguageOption(
            flag: '🇬🇧',
            name: 'English',
            subtitle: 'Inglés',
            isSelected: currentLanguage == 'en',
            onTap: () async {
              await ref.read(languageProvider.notifier).changeLanguage('en');
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
