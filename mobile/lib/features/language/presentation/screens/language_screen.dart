import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/core/router/routes.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/widgets/language_option.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String selected = "es";
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Cargar idioma guardado si existe
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final savedLanguage = ref.read(languageProvider);
    savedLanguage.when(
      data: (locale) {
        if (locale != null && mounted) {
          setState(() {
            selected = locale.languageCode;
          });
        }
      },
      loading: () {},
      error: (error, stackTrace) {},
    );
  }

  Future<void> _saveLanguage() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(languageProvider.notifier).changeLanguage(selected);
      if (context.mounted) {
        context.go(Routes.onboarding);
      }
    } catch (e) {
      // Mostrar error si falla
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar idioma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
              Text(
                l10n.selectLanguageTitle,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.selectLanguageSubtitle,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseLanguageHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              LanguageOption(
                flag: '🇪🇸',
                name: l10n.spanish,
                subtitle: 'Spanish',
                isSelected: selected == 'es',
                onTap: () {
                  setState(() {
                    selected = 'es';
                  });
                },
              ),
              const SizedBox(height: 12),
              LanguageOption(
                flag: '🇬🇧',
                name: l10n.english,
                subtitle: 'Inglés',
                isSelected: selected == 'en',
                onTap: () {
                  setState(() {
                    selected = 'en';
                  });
                },
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveLanguage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64999A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          l10n.continueButton,
                          style: const TextStyle(fontSize: 16),
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
