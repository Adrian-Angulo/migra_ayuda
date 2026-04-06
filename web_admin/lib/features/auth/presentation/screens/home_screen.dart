import 'package:flutter/material.dart';
import 'package:migra_ayuda_administracion/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:migra_ayuda_administracion/shared/widgets/sidebar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    Center(child: Text('Entidades')),
    Center(child: Text('Servicios')),
    Center(child: Text('Usuarios')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SidebarWidget(
            selectedIndex: _selectedIndex,
            onItemTap: (i) => setState(() => _selectedIndex = i),
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}
