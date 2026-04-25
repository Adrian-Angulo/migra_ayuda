import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:migra_ayuda/features/auth/presentation/widgets/app_drawer.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/category_selector.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/map_view.dart';
import 'package:migra_ayuda/features/entities/presentation/widgets/place_card.dart';
import 'package:migra_ayuda/l10n/app_localizations.dart';



class ExplorarScreen extends StatefulWidget {
  const ExplorarScreen({super.key});

  @override
  State<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends State<ExplorarScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  int _seletedFiltro = 0;
  double _seetSize = 0.40;

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
  void initState() {
    // TODO: implement initState
    super.initState();
    _sheetController.addListener(
      () {
        setState(() {
          _seetSize = _sheetController.size;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: AppDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            MapView(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¿Que necesitas hoy?',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
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
                  selectedIndex: _seletedFiltro,
                  onSelected: (index) {
                    setState(() {
                      _seletedFiltro = index;
                    });
                  },
                ),
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
                              final screenHeight =
                                  MediaQuery.of(context).size.height;
                              double delta =
                                  details.primaryDelta! / screenHeight;
                              double newSize = _sheetController.size - delta;
                              newSize = newSize.clamp(0.15, 0.85);
                              _sheetController.jumpTo(newSize);
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
                                          _sheetController.animateTo(
                                            0.15,
                                            duration: const Duration(
                                                milliseconds: 250),
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
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 10),
                              itemCount: 5,
                              controller: scrollController,
                              itemBuilder: (context, index) {
                                final entity = lista[index];
                                return PlaceCard(
                                  entity: entity,
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
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * _seetSize + 16,
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
}


