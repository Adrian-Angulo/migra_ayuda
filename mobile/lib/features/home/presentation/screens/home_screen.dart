import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/mobile/auth_page.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';
import 'inicio_screen.dart';
import '../../../entities/presentation/screens/mobile/explorar_screen.dart';
import 'perfil_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String userName;

  const HomeScreen({
    super.key,
    this.userName = 'Usuario',
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      InicioScreen(),
      const ExplorarScreen(),
      const PerfilScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    ref.listen(
      authNotifierProvider,
      (previous, next) {
        next.whenData(
          (usu) {
            if (usu == null) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuthPage(),
                  ));
            }
          },
        );
      },
    );

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF64999A),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.explore_outlined),
            activeIcon: const Icon(Icons.explore),
            label: l10n.exploreTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
      ),
    );
  }
}
