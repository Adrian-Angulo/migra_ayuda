import 'package:flutter/material.dart';
import 'package:migra_ayuda/core/utils/responsive.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/screens/home_admin_screen/widgets/sidebar_widget.dart';


class HomeScreen extends StatelessWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isCompact = context.isCompact;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
    
      appBar: isCompact
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0.5,
              titleSpacing: 0,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded, color: Color(0xFF2D5F4F)),
                  tooltip: 'Abrir menú de navegación',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              title: const Text(
                'MigraAyuda',
                style: TextStyle(
                  color: Color(0xFF2D5F4F),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            )
          : null,
      
      drawer: isCompact
          ? const Drawer(
              width: 280,
              child: SidebarWidget(width: 280),
            )
          : null,
      body: Row(
        children: [
          
          if (!isCompact) const SidebarWidget(width: 250),

          
          Expanded(
            child: Container(
              color: const Color(0xFFF7F9FB),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
