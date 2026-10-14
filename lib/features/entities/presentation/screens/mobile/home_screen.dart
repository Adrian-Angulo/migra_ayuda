import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/list_Entities_home.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/homeCardWidgets/filter_container.dart';
import 'package:migra_ayuda/features/map/presentation/providers/map_display_provider.dart';
import 'package:migra_ayuda/features/map/presentation/widgets/mapbox_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    final initials = _getInitials(user?.name);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          "assets/logo/MigraAyuda.png",
          height: 36,
          fit: BoxFit.contain,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: GestureDetector(
              onTap: () => scaffoldKey.currentState?.openEndDrawer(),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00897B), Color(0xFF004D40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border:
                      Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const MapboxWidget(
            key: ValueKey('mapbox_main'),
          ),
          ListEntitesHome(sheetController: _sheetController),
          AnimatedBuilder(
            animation: _sheetController,
            builder: (context, child) {
              final currentSize =
                  _sheetController.isAttached ? _sheetController.size : 0.3;

              if (currentSize >= 0.95) {
                return const SizedBox.shrink();
              }

              final opacity =
                  ((0.95 - currentSize) / (0.95 - 0.70)).clamp(0.0, 1.0);
              final bottomOffset = (screenHeight * currentSize);

              return Positioned(
                bottom: bottomOffset + 8,
                right: 14,
                child: Opacity(
                  opacity: opacity,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: 'location',
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    focusElevation: 0,
                    hoverElevation: 0,
                    highlightElevation: 0,
                    child: const Icon(Icons.my_location_rounded, size: 22),
                    onPressed: () {
                      ref.read(mapProvider.notifier).resumeTracking();
                    },
                  ),
                ),
              ],
            ),
          ),
          const FilterContainer(),
        ],
      ),
    );
  }
}
