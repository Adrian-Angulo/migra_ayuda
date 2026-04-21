import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';

import 'package:latlong2/latlong.dart';

class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  int _seletedFiltro = 0;

  final filtros = [
    "Alimentacion",
    "Salud",
    "Alojamiento",
    "Trabajo",
    "Transporte"
  ];
  final lista = const <EntityEntity>[
    EntityEntity(
      id: "1",
      name: "Banco de Alimentos Madrid",
      description:
          "Distribución de alimentos a familias en situación de vulnerabilidad.",
      services: ["Alimentos", "Ropa", "Higiene"],
      address: "Calle Gran Vía 45, Madrid",
      localitation: GeoPoint(40.4200, -3.7050),
      phone: "+34 910 123 456",
      serviceHours: "Lun-Vie 9:00-17:00",
      imageUrl: "",
    ),
    EntityEntity(
      id: "2",
      name: "Cruz Roja Española",
      description:
          "Asistencia humanitaria y apoyo a migrantes recién llegados.",
      services: ["Asesoría legal", "Alojamiento temporal", "Idiomas"],
      address: "Avenida Reina Victoria 26, Madrid",
      localitation: GeoPoint(40.4200, -3.7050),
      phone: "+34 915 222 333",
      serviceHours: "Lun-Sáb 8:00-20:00",
      imageUrl: "",
    ),
    EntityEntity(
      id: "3",
      name: "Centro de Acogida Esperanza",
      description:
          "Alojamiento y orientación para personas en tránsito migratorio.",
      services: ["Alojamiento", "Comedor", "Orientación"],
      address: "Calle Alcalá 120, Madrid",
      localitation: GeoPoint(40.4200, -3.7050),
      phone: "+34 916 444 555",
      serviceHours: "24 horas",
      imageUrl: "",
    ),
    EntityEntity(
      id: "4",
      name: "Médicos del Mundo",
      description:
          "Atención médica gratuita para personas sin acceso al sistema sanitario.",
      services: ["Medicina general", "Salud mental", "Pediatría"],
      address: "Calle Barquillo 8, Madrid",
      localitation: GeoPoint(40.4200, -3.7050),
      phone: "+34 917 666 777",
      serviceHours: "Mar y Jue 10:00-14:00",
      imageUrl: "",
    ),
    EntityEntity(
      id: "5",
      name: "ACCEM Asociación",
      description: "Integración social y laboral de refugiados e inmigrantes.",
      services: ["Empleo", "Formación", "Vivienda"],
      address: "Calle Lope de Vega 34, Madrid",
      localitation: GeoPoint(40.4200, -3.7050),
      phone: "+34 918 888 999",
      serviceHours: "Lun-Vie 9:00-18:00",
      imageUrl: "",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MapView(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¿Que necesitas hoy?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  CategorySelector(
                    items: filtros,
                    selectedIndex: _seletedFiltro,
                    onSelected: (index) {
                      setState(() {
                        _seletedFiltro = index;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
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
                  final screenHeight = MediaQuery.of(context).size.height;

                  // Movimiento proporcional al dedo
                  double delta = details.primaryDelta! / screenHeight;

                  // Restamos porque drag hacia arriba es negativo
                  double newSize = _sheetController.size - delta;

                  // Limitar rango
                  newSize = newSize.clamp(0.15, 0.85);

                  _sheetController.jumpTo(newSize);
                },
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 60,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Servicios cercanos'),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _sheetController.animateTo(
                                0.15,
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 16,
              ),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) => SizedBox(
                    height: 10,
                  ),
                  itemCount: 5,
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    final entity = lista[index];
                    return PlaceCard(
                      title: entity.name,
                      category: entity.services[0],
                      rating: 3.0,
                      isOpen: true,
                      onTap: () {},
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//card

class PlaceCard extends StatelessWidget {
  final String title;
  final String category;

  final double rating;
  final bool isOpen;
  final String? imageUrl;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.title,
    required this.category,
    required this.rating,
    required this.isOpen,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 7,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Row(
        children: [
          _buildImage(),
          const SizedBox(width: 12),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 90,
        height: 90,
        color: Colors.grey[200],
        child: imageUrl == null || imageUrl!.isEmpty
            ? const Icon(Icons.image_not_supported,
                size: 40, color: Colors.grey)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey);
                },
              ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 6),
        _buildSubtitle(),
        const SizedBox(height: 6),
        _buildStatus(),
        const SizedBox(height: 10),
        _buildButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                rating.toString(),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildSubtitle() {
    return Row(
      children: [
        const Icon(Icons.restaurant, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          category,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatus() {
    return Row(
      children: [
        Icon(
          Icons.circle,
          size: 10,
          color: isOpen ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 6),
        Text(
          isOpen ? "Abierto ahora" : "Cerrado",
          style: TextStyle(
            color: isOpen ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.directions),
        label: const Text("Cómo llegar"),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5F9EA0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class CategorySelector extends StatelessWidget {
  final List<String> items;
  final int selectedIndex;
  final Function(int) onSelected;

  const CategorySelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF5F9EA0) // seleccionado
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF5F9EA0)
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                items[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//Mapa

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(6.2442, -75.5812), // Medellín
        initialZoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
      ],
    );
  }
}
