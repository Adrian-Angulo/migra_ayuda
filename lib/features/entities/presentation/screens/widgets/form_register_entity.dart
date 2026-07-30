import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:migra_ayuda/core/constants/services_utils.dart';
import 'package:migra_ayuda/features/auth/presentation/screens/web/widgets/button_widget.dart';
import 'package:migra_ayuda/features/entities/domain/entities/entity_entity.dart';
import 'package:migra_ayuda/features/entities/presentation/providers/entity_crud_providers.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/image_picker_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/web/screens/widgets/service_type_checklist_widget.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_section_title.dart';
import 'package:migra_ayuda/features/entities/presentation/screens/widgets/build_text_field.dart';

class FormRegisterEntity extends ConsumerStatefulWidget {
  const FormRegisterEntity({super.key});

  @override
  ConsumerState<FormRegisterEntity> createState() => _FormRegisterEntityState();
}

class _FormRegisterEntityState extends ConsumerState<FormRegisterEntity> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  LatLng? location;
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _phoneController = TextEditingController();
  final _scheduleController = TextEditingController();

  final _mapController = MapController();
  bool _isSearching = false;
  bool _addressNotFound = false;

  List<String> selectedServices = [];
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  String seleted = services[1];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<LatLng?> getCoordinates(String address) async {
    try {
      final encoded = Uri.encodeComponent(address);

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$encoded&format=json&limit=1',
      );

      debugPrint("Consultando: $url");

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'MigraAyuda Flutter App',
          'Accept': 'application/json',
        },
      );

      debugPrint("Status: ${response.statusCode}");
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        if (data.isNotEmpty) {
          return LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );
        }
      } else {
        return null;
      }
    } catch (e, s) {
      debugPrint("ERROR:");
      debugPrint(e.toString());

      debugPrint("STACK:");
      debugPrintStack(stackTrace: s);

      rethrow;
    }
    return null;
  }

  Future<void> _searchAddress() async {
    if (_addressController.text.trim().isEmpty) return;
    setState(() {
      _isSearching = true;
      _addressNotFound = false;
    });

    final coords = await getCoordinates(_addressController.text);

    if (!mounted) return;

    setState(() {
      location = coords;
      _isSearching = false;
      _addressNotFound = coords == null;
    });

    if (coords != null) {
      _latitudController.text = coords.latitude.toString();
      _longitudController.text = coords.longitude.toString();
      //_mapController.move(coords, 15);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return build2();
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Completar información'),
        ),
        body: build2(),
      );
    }
  }

  Expanded build2() {
    final registerState = ref.watch(entitiesCrudProvider);
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    ImagePickerWidget(
                      imagen: _selectedImage,
                      imagenBytes: _selectedImageBytes,
                      onImageSelected: (imagen, bytes) {
                        setState(() {
                          _selectedImage = imagen;
                          _selectedImageBytes = bytes;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tamaño recomendado: 400x400px',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const BuildSectionTitle(
                title: 'Información Básica',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 20),
              BuildTextField(
                controller: _nameController,
                label: 'Nombre de la entidad',
                hint: 'Ej: Centro de Salud Norte',
                icon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              BuildTextField(
                controller: _descriptionController,
                label: 'Descripción',
                hint:
                    'Describa brevemente los servicios que ofrece esta entidad',
                icon: null,
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Tipos de Servicio Section
              const BuildSectionTitle(
                title: 'Tipos de Servicio',
                icon: Icons.category_outlined,
              ),
              const SizedBox(height: 12),
              Text(
                'Seleccione los servicios que ofrece esta entidad (maximo 2)',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              ServiceTypeChecklistWidget(
                selectedServices: selectedServices,
                onServicesChanged: (services) {
                  setState(() {
                    selectedServices = services;
                  });
                },
              ),

              const SizedBox(height: 32),

              // Ubicación y Contacto Section
              const BuildSectionTitle(
                title: 'Ubicación y Contacto',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: BuildTextField(
                      controller: _addressController,
                      label: 'Dirección',
                      hint: 'Ej. Calle 123 #45-67, Pasto',
                      icon: Icons.location_on_outlined,
                      suffixIcon: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(11),
                              bottomRight: Radius.circular(11)),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSearching ? null : _searchAddress,
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Center(
                                child: _isSearching
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      onChanged: (_) {
                        if (_addressNotFound) {
                          setState(() => _addressNotFound = false);
                        }
                        if (location != null) {
                          setState(() {
                            location = null;
                            _latitudController.clear();
                            _longitudController.clear();
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La dirección es requerida';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_addressNotFound)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'No se encontró la dirección. Intenta ser más específico.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              if (location != null)
                SizedBox(
                  height: 250,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: location!,
                        initialZoom: 14,
                        minZoom: 14,
                        maxZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.migraayuda.app',
                        ),
                        MarkerLayer(
                          markers: [
                            if (location != null)
                              Marker(
                                point: location!,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              BuildTextField(
                controller: _phoneController,
                label: 'Teléfono de contacto',
                hint: '(57+) 3225321234',
                icon: Icons.phone_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Horario de Atención
              const BuildSectionTitle(
                title: 'Horario de Atención',
                icon: Icons.access_time,
              ),
              const SizedBox(height: 12),
              BuildTextField(
                controller: _scheduleController,
                label: '',
                hint: 'Ej. Lunes a viernes 8:30 AM a 12:00 PM',
                icon: null,
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El horario es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 32,
              ),
              if (kIsWeb == false)
                ButtonWidget(
                  formKey: _formKey,
                  text: registerState.isLoading
                      ? 'Registrando...'
                      : 'Registrarse',
                  onPressed: registerState.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            if (_selectedImageBytes == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Por favor seleccione una imagen'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (selectedServices.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Por favor seleccione al menos un servicio',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_latitudController.text.isEmpty ||
                                _longitudController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Debes buscar y confirmar la dirección en el mapa',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }

                            // Crear entidad con los valores del formulario
                            final entity = EntityEntity(
                                id: '',
                                name: _nameController.text.trim(),
                                description: _descriptionController.text.trim(),
                                services: selectedServices,
                                address: _addressController.text.trim(),
                                localitation: GeoPoint(
                                  double.parse(_latitudController.text),
                                  double.parse(_longitudController.text),
                                ),
                                phone: _phoneController.text.trim(),
                                imageUrl: "",
                                schedule: _scheduleController.text.trim());

                            await ref
                                .read(entitiesCrudProvider.notifier)
                                .registerEntity(
                                    entity: entity,
                                    imagenBytes: _selectedImageBytes!,
                                    fileName: _selectedImage?.name ?? '');

                            if (context.mounted) {
                              final state = ref.read(entitiesCrudProvider);
                              if (state.hasValue && !state.hasError) {
                                Navigator.pop(context);
                              }
                            }
                          }
                        },
                ),

              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
