import 'package:flutter/material.dart';
import 'package:migra_ayuda/features/auth/presentation/pages/admin/perfil_screen_admin.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

class HomeScreenAdmin extends StatefulWidget {
  const HomeScreenAdmin({super.key});

  @override
  State<HomeScreenAdmin> createState() => _HomeScreenAdminState();
}

class _HomeScreenAdminState extends State<HomeScreenAdmin> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Center(child: Text('Inicio')),
    const Center(child: Text('Entidades')),
    const Center(child: Text('Servicios')),
    const Center(child: Text('Usuarios')),
    const PerfilScreenAdmin(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: l10n.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.business),
            label: l10n.entitiesTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.room_service),
            label: l10n.servicesTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: l10n.usersTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: l10n.profileTab,
          ),
        ],
      ),
    );
  }
}
