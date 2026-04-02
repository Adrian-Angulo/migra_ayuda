import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/widgets/language_option.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/auth_page.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF4F4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.translate,
                  color: Color(0xFF64999A),
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Seleccionar Idioma',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select Language',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elige tu idioma para continuar\nChoose your language to continue',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              LanguageOption(
                flag: '🇪🇸',
                name: 'Español',
                subtitle: 'Spanish',
                isSelected: currentLocale.languageCode == 'es',
                onTap: () {
                  ref.read(languageProvider.notifier).changeLanguage('es');
                },
              ),
              const SizedBox(height: 12),
              LanguageOption(
                flag: '🇬🇧',
                name: 'English',
                subtitle: 'Inglés',
                isSelected: currentLocale.languageCode == 'en',
                onTap: () {
                  ref.read(languageProvider.notifier).changeLanguage('en');
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const AuthPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64999A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar / Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
