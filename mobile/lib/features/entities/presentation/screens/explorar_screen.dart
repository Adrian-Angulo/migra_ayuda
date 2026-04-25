import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/category_selector.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/map_view.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_card.dart';

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

  final filtros = [
    "Todos",
    "Alimentacion",
    "Salud",
    "Alojamiento",
    "Trabajo",
    "Transporte"
  ];

  @override
  void initState() {
    super.initState();
    // Agrega observer para detectar cuando la app vuelve del background
    WidgetsBinding.instance.addObserver(this);

    // Espera a que el controller esté attached antes de agregar el listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sheetController.isAttached) {
        setState(() {
          _isControllerAttached = true;
        });
        _sheetController.addListener(_onSheetChanged);
      }

      // Inicia la verificación periódica de nuevos datos
      _startPeriodicCheck();
    });
  }

  void _startPeriodicCheck() {
    // Verifica cada 30 segundos si hay datos nuevos
    Stream.periodic(const Duration(seconds: 30)).listen((_) async {
      if (mounted) {
        await _checkForNewData();
      }
    });
  }

  Future<void> _checkForNewData() async {
    try {
      final usecase = ref.read(getAllEntitiesUsecaseProvider);
      final result = await usecase.call();

      result.fold(
        (error) {
          // No hacer nada si hay error
        },
        (entities) {
          if (mounted &&
              _currentDataCount > 0 &&
              entities.length > _currentDataCount) {
            setState(() {
              _hasNewData = true;
            });
          }
        },
      );
    } catch (e) {
      // Ignorar errores silenciosamente
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Cuando la app vuelve a estar activa, verifica si hay datos nuevos
    if (state == AppLifecycleState.resumed) {
      _checkForNewData();
    }
  }

  void _onSheetChanged() {
    if (mounted && _sheetController.isAttached) {
      setState(() {
        _sheetSize = _sheetController.size;
      });
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

  Future<void> _refreshEntities() async {
    ref.invalidate(entitiesStreamProvider);

    // Oculta el banner de nuevos datos
    setState(() {
      _hasNewData = false;
    });
  }

  Widget _buildNewDataBanner() {
    return GestureDetector(
      onTap: _refreshEntities,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.teal[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.teal[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.teal[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nuevos servicios disponibles',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal[900],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: _refreshEntities,
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Actualizar',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.teal[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escucha el stream de entidades
    final entitiesAsync = ref.watch(entitiesStreamProvider);

    return Scaffold(
      key: scaffoldKey,
      endDrawer: const AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            const MapView(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '¿Qué necesitas hoy?',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 24),
                        tooltip: 'Actualizar servicios',
                        onPressed: _refreshEntities,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.menu,
                          size: 30,
                        ),
                        onPressed: () {
                          scaffoldKey.currentState?.openEndDrawer();
                        },
                      ),
                    ],
                  ),
                ),
                CategorySelector(
                  items: filtros,
                  selectedIndex: _selectedFiltro,
                  onSelected: (index) {
                    setState(() {
                      _selectedFiltro = index;
                    });
                  },
                ),
                // Banner de nuevos datos disponibles
                if (_hasNewData) _buildNewDataBanner(),
              ],
            ),
            Positioned.fill(
              child: Stack(
                children: [
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.40,
                    minChildSize: 0.15,
                    maxChildSize: 0.85,
                    expand: true,
                    builder: (context, scrollController) => Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (details) {
                              if (_isControllerAttached &&
                                  _sheetController.isAttached) {
                                final screenHeight =
                                    MediaQuery.of(context).size.height;
                                double delta =
                                    details.primaryDelta! / screenHeight;
                                double newSize = _sheetController.size - delta;
                                newSize = newSize.clamp(0.15, 0.85);
                                _sheetController.jumpTo(newSize);
                              }
                            },
                            child: Column(
                              children: [
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 4,
                                    margin: const EdgeInsets.only(
                                        bottom: 12, top: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Servicios cercanos'),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          if (_isControllerAttached &&
                                              _sheetController.isAttached) {
                                            _sheetController.animateTo(
                                              0.15,
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeInOut,
                                            );
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _buildEntitiesList(
                                entitiesAsync, scrollController),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom:
                        MediaQuery.of(context).size.height * _sheetSize + 16,
                    right: 16,
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      onPressed: () {},
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntitiesList(AsyncValue<List<EntityEntity>> entitiesAsync,
      ScrollController scrollController) {
    return entitiesAsync.when(
      data: (entities) {
        // Actualiza el contador de datos actual
        if (_currentDataCount != entities.length) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _currentDataCount = entities.length;
              });
            }
          });
        }

        final filteredEntities = _filterEntities(entities);

        if (filteredEntities.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _selectedFiltro == 0 ? Icons.inbox : Icons.search_off,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  _selectedFiltro == 0
                      ? 'No hay entidades disponibles'
                      : 'No hay resultados para "${filtros[_selectedFiltro]}"',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _refreshEntities,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recargar'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshEntities,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: filteredEntities.length,
            controller: scrollController,
            itemBuilder: (context, index) {
              final entity = filteredEntities[index];
              return PlaceCard(
                entity: entity,
                title: entity.name,
                category: entity.services.isNotEmpty
                    ? entity.services[0]
                    : 'Sin categoría',
                rating: 3.0,
                isOpen: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ver detalles de ${entity.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Sin conexión',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _refreshEntities,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  List<EntityEntity> _filterEntities(List<EntityEntity> entities) {
    // Si el filtro es "Todos" (índice 0), muestra todas las entidades
    if (_selectedFiltro == 0) {
      return entities;
    }

    final selectedCategory = filtros[_selectedFiltro].toLowerCase();

    // Filtra por servicios que contengan la categoría seleccionada
    return entities.where((entity) {
      return entity.services.any(
        (service) => service.toLowerCase().contains(selectedCategory),
      );
    }).toList();
  }
}
