import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:migra_ayuda/core/constants/constants.dart';
import 'package:migra_ayuda/core/widgets/snackbar_widget.dart';
import 'package:migra_ayuda/features/auth/presentation/widgets/drawer/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/filter_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/get_all_entites_notifier.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/mobile/place_details_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    String selectedFiltro = ref.watch(seletedFilterProvider);
    final lista = ref.watch(listaEntidades);
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explorar servicios"),
      ),
      key: scaffoldKey,
      endDrawer: const AppDrawer(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SingleChildScrollView(
              key: const PageStorageKey('scroll_horizontal_filtros'),
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Wrap(
                  spacing: 8.0, // Reemplaza al separatorBuilder
                  children: services.map((service) {
                    final isSelected = selectedFiltro == service;
                    return FilterChip(
                      showCheckmark: false,
                      label: Text(service),
                      selected: isSelected,
                      onSelected: (value) {
                        if (value) {
                          ref.read(seletedFilterProvider.notifier).state =
                              service;
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            Expanded(
                child: lista.when(
                    data: (data) {
                      if (data.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off,
                                  size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'No se encontraron entidades proveedoras de servicio $selectedFiltro',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => await ref
                            .read(getAllEntitiesNotifierProvider.notifier)
                            .recargar(),
                        child: ListView.separated(
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 12,
                          ),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final entity = data[index];
                            return EntityCardWidget(entity: entity);
                          },
                        ),
                      );
                    },
                    error: (error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Ocurrió un error al cargar los servicios',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ],
                          ),
                        ),
                    loading: () => const Center(
                          child: CircularProgressIndicator(),
                        )))
          ],
        ),
      )),
    );
  }
}

class EntityCardWidget extends StatelessWidget {
  const EntityCardWidget({
    super.key,
    required this.entity,
  });

  final EntityEntity entity;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetails(entity: entity),
          )),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.business,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: Colors.grey),
                        SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            'Av. Siempre Viva 123, Santiago',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14, color: Colors.blueGrey),
                        SizedBox(width: 4),
                        Text(
                          '15 min',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        SizedBox(width: 2),
                        Text(
                          '4.5',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _ServiceTag(label: 'Legal'),
                        _ServiceTag(label: 'Salud'),
                        _ServiceTag(label: 'Alojamiento'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;

  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
