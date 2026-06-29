import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/widgets/language_option.dart';

class LanguageBottomSheet extends ConsumerWidget {
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final currentLanguageCode =
        ref.watch(languageProvider.notifier).currentLanguageCode;

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
          currentLanguage.when(
            data: (locale) {
              final isSpanish = locale?.languageCode == 'es';
              final isEnglish = locale?.languageCode == 'en';

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LanguageOption(
                    flag: '🇪🇸',
                    name: 'Español',
                    subtitle: 'Spanish',
                    isSelected: isSpanish,
                    onTap: () async {
                      await ref
                          .read(languageProvider.notifier)
                          .changeLanguage('es');
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  LanguageOption(
                    flag: '🇬🇧',
                    name: 'English',
                    subtitle: 'Inglés',
                    isSelected: isEnglish,
                    onTap: () async {
                      await ref
                          .read(languageProvider.notifier)
                          .changeLanguage('en');
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stackTrace) => Column(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Error al cargar idioma',
                  style: TextStyle(color: Colors.red.shade700),
                ),
                const SizedBox(height: 12),
                // Opciones de idioma con fallback
                LanguageOption(
                  flag: '🇪🇸',
                  name: 'Español',
                  subtitle: 'Spanish',
                  isSelected: currentLanguageCode == 'es',
                  onTap: () async {
                    await ref
                        .read(languageProvider.notifier)
                        .changeLanguage('es');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                const SizedBox(height: 12),
                LanguageOption(
                  flag: '🇬🇧',
                  name: 'English',
                  subtitle: 'Inglés',
                  isSelected: currentLanguageCode == 'en',
                  onTap: () async {
                    await ref
                        .read(languageProvider.notifier)
                        .changeLanguage('en');
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
