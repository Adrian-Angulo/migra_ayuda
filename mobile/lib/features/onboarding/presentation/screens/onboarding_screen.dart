import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:migra_ayuda/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:migra_ayuda/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:migra_ayuda/features/onboarding/presentation/widgets/onboarding_widget.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = _currentPage == 2;

    final pages = [
      OnboardingEntity(
        imagePath: 'assets/onboarding/onboardingOne.png',
        title: l10n.onboardingTitle1,
        subtitle: l10n.onboardingSubtitle1,
      ),
      OnboardingEntity(
        imagePath: 'assets/onboarding/onboardingTwo.png',
        title: l10n.onboardingTitle2,
        subtitle: l10n.onboardingSubtitle2,
      ),
      OnboardingEntity(
        imagePath: 'assets/onboarding/onbardingThree.png',
        title: l10n.onboardingTitle3,
        subtitle: l10n.onboardingSubtitle3,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Botón omitir
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 16),
                child: TextButton(
                  onPressed: () async {
                    await ref
                        .read(onboardingProvider.notifier)
                        .completeOnboarding();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                  child: Text(
                    l10n.skipButton,
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
              ),
            ),

            // Páginas
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => OnboardingWidget(data: pages[i]),
              ),
            ),

            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF64999A)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botón siguiente / empezar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Completar onboarding y dejar que StartPage maneje la navegación
                      await ref
                          .read(onboardingProvider.notifier)
                          .completeOnboarding();
                      
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64999A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLast ? l10n.startButton : l10n.nextButton,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
