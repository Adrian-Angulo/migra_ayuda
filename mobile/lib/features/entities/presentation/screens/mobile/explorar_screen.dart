import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/providers/location_provider.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/entity_detail/entity_detail_card.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/explorar/explorar_header.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/explorar/explorar_sheet_content.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/widgets/map_view.dart';

class ExplorarScreen extends ConsumerStatefulWidget {
  const ExplorarScreen({super.key});

  @override
  ConsumerState<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends ConsumerState<ExplorarScreen>
    with WidgetsBindingObserver {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedFiltro = 0;
  double _sheetSize = 0.40;
  bool _isControllerAttached = false;
  bool _hasNewData = false;
  int _currentDataCount = 0;
  EntityEntity? _selectedEntity;
  bool _showDetailCard = false;
  bool _isLoadingLocation = false; // Nuevo estado para loading

  final filtros = [
    "Todos",
    "Alimentacion",
    "Salud",
    "Alojamiento",
    "Trabajo",
    "Transporte",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermissionOnStartup(ref);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sheetController.isAttached) {
        setState(() => _isControllerAttached = true);
        _sheetController.addListener(_onSheetChanged);
      }
      _startPeriodicCheck();
      // Centra el mapa automáticamente en la ubicación del usuario
      _centerMapOnUserLocationOnInit();
    });
  }

  /// Centra el mapa automáticamente en la ubicación del usuario al abrir la pantalla
  Future<void> _centerMapOnUserLocationOnInit() async {
    try {
      // Espera un momento para que el mapa esté completamente renderizado
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Verifica si hay ubicación disponible
      final userLocationAsync = ref.read(userLocationStreamProvider);
      final position = userLocationAsync.value;

      if (position != null) {
        // Activa el flag para centrar el mapa
        ref.read(centerOnUserLocationProvider.notifier).trigger();
      }
    } catch (e) {
      // Falla silenciosamente - no es crítico
      print('⚠️ No se pudo centrar el mapa automáticamente: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isControllerAttached && _sheetController.isAttached) {
      _sheetController.removeListener(_onSheetChanged);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) _checkForNewData();
  }

  void _onSheetChanged() {
    if (mounted && _sheetController.isAttached) {
      setState(() => _sheetSize = _sheetController.size);
    }
  }

  void _startPeriodicCheck() {
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      if (mounted) _checkForNewData();
    });
  }

  Future<void> _checkForNewData() async {
    try {
      final result = await ref.read(getAllEntitiesUsecaseProvider).call();
      result.fold((_) {}, (entities) {
        if (mounted &&
            _currentDataCount > 0 &&
            entities.length > _currentDataCount) {
          setState(() => _hasNewData = true);
        }
      });
    } catch (_) {}
  }

  Future<void> _refreshEntities() async {
    ref.invalidate(entitiesStreamProvider);
    setState(() => _hasNewData = false);
  }

  void _onMarkerTap(EntityEntity entity) {
    setState(() {
      _selectedEntity = entity;
      _showDetailCard = true;
    });
    if (_isControllerAttached && _sheetController.isAttached) {
      _sheetController.animateTo(
        0.50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onEntityTap(EntityEntity entity) {
    setState(() {
      _selectedEntity = entity;
      _showDetailCard = true;
    });
    if (_isControllerAttached && _sheetController.isAttached) {
      _sheetController.animateTo(
        0.50,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onCloseDetail() {
    setState(() {
      _showDetailCard = false;
      _selectedEntity = null;
    });
    if (_isControllerAttached && _sheetController.isAttached) {
      _sheetController.animateTo(
        0.40,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  List<EntityEntity> _filterEntities(List<EntityEntity> entities) {
    if (_selectedFiltro == 0) return entities;
    final category = filtros[_selectedFiltro].toLowerCase();
    return entities
        .where((e) => e.services.any((s) => s.toLowerCase().contains(category)))
        .toList();
  }

  /// Solicita permisos de ubicación al iniciar la app
  Future<void> _requestLocationPermissionOnStartup(WidgetRef ref) async {
    try {
      // Verifica si ya se solicitaron permisos anteriormente
      final alreadyRequested = ref.read(locationPermissionRequestedProvider);
      if (alreadyRequested) {
        print('ℹ️ Permisos ya solicitados anteriormente');
        return;
      }

      final locationService = ref.read(locationServiceProvider);

      // Verifica si ya tiene permisos
      final hasPermission = await locationService.hasPermission();
      if (hasPermission) {
        print('✅ Permisos de ubicación ya otorgados');
        ref
            .read(locationPermissionRequestedProvider.notifier)
            .markAsRequested();
        return;
      }

      // Verifica si el GPS está habilitado
      final serviceEnabled = await locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('⚠️ GPS desactivado - No se solicitarán permisos');
        ref
            .read(locationPermissionRequestedProvider.notifier)
            .markAsRequested();
        return;
      }

      // Solicita permisos
      print('📍 Solicitando permisos de ubicación...');
      final granted = await locationService.requestPermission();

      if (granted) {
        print('✅ Permisos de ubicación otorgados');
      } else {
        print('❌ Permisos de ubicación denegados');
      }

      // Marca que ya se solicitaron permisos
      ref.read(locationPermissionRequestedProvider.notifier).markAsRequested();
    } catch (e) {
      print('❌ Error al solicitar permisos de ubicación: $e');
    }
  }

  Future<void> _centerOnUserLocation() async {
    if (_isLoadingLocation) return; // Evita múltiples llamadas

    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);

      // 1. Verifica si el GPS está habilitado
      final serviceEnabled = await locationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor activa el GPS en la configuración'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // 2. Verifica permisos
      final hasPermission = await locationService.hasPermission();
      if (!hasPermission) {
        // Solicita permisos
        final granted = await locationService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Se requieren permisos de ubicación para usar esta función'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // 3. Obtiene la ubicación actual
      final position = await locationService.getCurrentLocation();
      if (position == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No se pudo obtener tu ubicación. Intenta de nuevo'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // 4. Activa el flag para centrar el mapa
      ref.read(centerOnUserLocationProvider.notifier).trigger();

      // 5. Muestra mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📍 Ubicación encontrada'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitiesAsync = ref.watch(entitiesStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: entitiesAsync.when(
          data: (entities) {
            if (_currentDataCount != entities.length) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted)
                  setState(() => _currentDataCount = entities.length);
              });
            }
            final filtered = _filterEntities(entities);
            return _buildBody(context, filtered);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorView(
            error: error.toString(),
            onRetry: _refreshEntities,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<EntityEntity> filtered) {
    return Stack(
      children: [
        MapView(
          entities: filtered,
          selectedEntity: _selectedEntity,
          onMarkerTap: _onMarkerTap,
        ),
        Column(
          children: [
            ExplorarHeader(
              scaffoldKey: scaffoldKey,
              filtros: filtros,
              selectedFiltro: _selectedFiltro,
              hasNewData: _hasNewData,
              onRefresh: _refreshEntities,
              onFilterSelected: (index) => setState(() {
                _selectedFiltro = index;
                _selectedEntity = null;
                _showDetailCard = false;
              }),
            ),
          ],
        ),
        DraggableScrollableSheet(
          controller: _sheetController,
          initialChildSize: 0.40,
          minChildSize: 0.15,
          maxChildSize: 0.85,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8)
              ],
            ),
            child: _showDetailCard && _selectedEntity != null
                ? EntityDetailCard(
                    entity: _selectedEntity!,
                    onClose: _onCloseDetail,
                  )
                : ExplorarSheetContent(
                    entities: filtered,
                    filtros: filtros,
                    selectedFiltro: _selectedFiltro,
                    scrollController: scrollController,
                    sheetController: _sheetController,
                    isControllerAttached: _isControllerAttached,
                    onRefresh: _refreshEntities,
                    onEntityTap: _onEntityTap,
                  ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * _sheetSize + 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: _isLoadingLocation ? null : _centerOnUserLocation,
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  )
                : const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Sin conexión', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
