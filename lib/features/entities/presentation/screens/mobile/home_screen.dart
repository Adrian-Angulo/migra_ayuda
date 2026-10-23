import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/sync/sync_manager.dart';
import 'package:migra_ayuda/core/widgets/mobil/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/providers/auth_notifier.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/list_entities_home.dart';
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
                const SynchronizationButton(),
                const SizedBox(
                  height: 8,
                ),
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

class SynchronizationButton extends ConsumerWidget {
  const SynchronizationButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = ref.watch(syncProvider).isLoading;

    return Container(
      height: 50,
      width: 50,
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
        heroTag: 'sincronization',
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF00897B),
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        onPressed: isSyncing
            ? null
            : () async {
                final result = await ref.read(syncProvider.notifier).syncAll();
                if (!context.mounted) return;

                switch (result) {
                  case SyncResult.success:
                    SnackbarWidget.success(
                      context,
                      'Sincronización completada con éxito',
                    );
                    break;
                  case SyncResult.noConnection:
                    SnackbarWidget.warning(
                      context,
                      'No hay conexión a internet para sincronizar',
                    );
                    break;
                  case SyncResult.error:
                    SnackbarWidget.error(
                      context,
                      'Ocurrió un error al sincronizar los datos',
                    );
                    break;
                  case SyncResult.alreadySyncing:
                    break;
                }
              },
        child: isSyncing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00897B)),
                ),
              )
            : const Icon(Icons.sync, size: 22),
      ),
    );
  }
}
