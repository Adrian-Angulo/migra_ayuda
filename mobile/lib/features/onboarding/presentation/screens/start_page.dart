import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/auth_page.dart';
import 'package:migra_ayuda/features/language/presentation/providers/language_provider.dart';
import 'package:migra_ayuda/features/language/presentation/screens/language_screen.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/onboarding/presentation/screens/onboarding_screen.dart';

class StartPage extends ConsumerWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCompletedOnboarding = ref.watch(onboardingProvider);
    final hasSelectedLanguage = ref.watch(languageSelectionProvider);

    if (!hasCompletedOnboarding) {
      return const OnboardingScreen();
    } else if (!hasSelectedLanguage) {
      return const LanguageScreen();
    } else {
      return const AuthPage();
    }
  }
}
