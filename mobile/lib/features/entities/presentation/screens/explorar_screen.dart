import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/entity_detail/entity_detail_card.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/explorar/explorar_header.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/explorar/explorar_sheet_content.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/map_view.dart';

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
      if (mounted && _sheetController.isAttached) {
        setState(() => _isControllerAttached = true);
        _sheetController.addListener(_onSheetChanged);
      }
      _startPeriodicCheck();
    });
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
            onPressed: () {},
            child: const Icon(Icons.my_location),
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
